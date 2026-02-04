#!/usr/bin/env python3

"""
jira-pr-searcher.py
Predictable GitHub PR search for Jira tickets

Usage:
    ./jira-pr-searcher.py AWSMETRICS-406
    ./jira-pr-searcher.py AWSMETRICS-406,AWSMETRICS-407
    ./jira-pr-searcher.py AWSMETRICS-406 --detailed
    ./jira-pr-searcher.py AWSMETRICS-406 --output json
"""

import argparse
import json
import subprocess
import sys
from collections import defaultdict
from typing import Dict, List, Any, Optional
from datetime import datetime


class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color


class JiraPRSearcher:
    """Search for GitHub PRs associated with Jira tickets"""

    def __init__(self, tickets: List[str], limit: int = 100,
                 repos_filter: Optional[str] = None, detailed: bool = False):
        self.tickets = [t.strip() for t in tickets]
        self.limit = limit
        self.repos_filter = repos_filter
        self.detailed = detailed
        self.results: Dict[str, List[Dict[str, Any]]] = {}
        self.pr_details: Dict[str, Dict[str, Any]] = {}
        self.total_prs = 0
        self.total_files = 0
        self.repos_affected = set()

    def check_gh_auth(self) -> bool:
        """Check if gh CLI is authenticated"""
        try:
            subprocess.run(['gh', 'auth', 'status'],
                         check=True,
                         capture_output=True)
            return True
        except subprocess.CalledProcessError:
            return False
        except FileNotFoundError:
            print(f"{Colors.RED}Error: gh CLI not found{Colors.NC}", file=sys.stderr)
            print("Please install gh CLI: https://cli.github.com/", file=sys.stderr)
            sys.exit(1)

    def search_prs_for_ticket(self, ticket: str) -> List[Dict[str, Any]]:
        """Search for PRs associated with a Jira ticket"""
        search_query = f"{ticket} in:title org:DataDog"

        if self.repos_filter:
            search_query = f"{ticket} in:title repo:{self.repos_filter}"

        print(f"{Colors.BLUE}Searching for PRs with ticket: {ticket}{Colors.NC}",
              file=sys.stderr)

        try:
            result = subprocess.run(
                ['gh', 'search', 'prs', search_query,
                 '--limit', str(self.limit),
                 '--json', 'number,title,state,url,closedAt,author,repository'],
                capture_output=True,
                text=True,
                check=True
            )

            prs = json.loads(result.stdout)
            print(f"{Colors.GREEN}Found {len(prs)} PRs for {ticket}{Colors.NC}",
                  file=sys.stderr)

            return prs
        except subprocess.CalledProcessError as e:
            print(f"{Colors.RED}Error searching for {ticket}: {e.stderr}{Colors.NC}",
                  file=sys.stderr)
            return []
        except json.JSONDecodeError as e:
            print(f"{Colors.RED}Error parsing JSON for {ticket}: {e}{Colors.NC}",
                  file=sys.stderr)
            return []

    def fetch_pr_details(self, pr_number: int, repo: str, ticket: str) -> Optional[Dict[str, Any]]:
        """Fetch detailed information about a PR including files"""
        print(f"{Colors.YELLOW}  Fetching details for PR #{pr_number}...{Colors.NC}",
              file=sys.stderr)

        try:
            result = subprocess.run(
                ['gh', 'pr', 'view', str(pr_number),
                 '--repo', repo,
                 '--json', 'number,title,body,files,additions,deletions,state,url,mergedAt,author'],
                capture_output=True,
                text=True,
                check=True
            )

            details = json.loads(result.stdout)
            file_count = len(details.get('files', []))
            self.total_files += file_count

            return details
        except subprocess.CalledProcessError as e:
            print(f"{Colors.RED}Error fetching PR #{pr_number}: {e.stderr}{Colors.NC}",
                  file=sys.stderr)
            return None
        except json.JSONDecodeError as e:
            print(f"{Colors.RED}Error parsing JSON for PR #{pr_number}: {e}{Colors.NC}",
                  file=sys.stderr)
            return None

    def search_all(self):
        """Search for all PRs for all tickets"""
        print(f"{Colors.BLUE}Starting PR search for {len(self.tickets)} ticket(s)...{Colors.NC}\n",
              file=sys.stderr)

        for ticket in self.tickets:
            prs = self.search_prs_for_ticket(ticket)
            self.results[ticket] = prs
            self.total_prs += len(prs)

            # Fetch details for each PR
            for pr in prs:
                pr_number = pr['number']
                repo = pr['repository']['nameWithOwner']
                self.repos_affected.add(repo)

                # Fetch detailed information
                details = self.fetch_pr_details(pr_number, repo, ticket)
                if details:
                    pr_key = f"{repo}#{pr_number}"
                    self.pr_details[pr_key] = details

        print(f"\n{Colors.GREEN}Search complete!{Colors.NC}\n", file=sys.stderr)

    def output_json(self) -> str:
        """Output results in JSON format"""
        output = {
            "total_tickets": len(self.tickets),
            "total_prs": self.total_prs,
            "total_files": self.total_files,
            "repositories": sorted(list(self.repos_affected)),
            "tickets": []
        }

        for ticket in self.tickets:
            prs = self.results.get(ticket, [])

            # Enrich PRs with detailed information
            enriched_prs = []
            for pr in prs:
                pr_number = pr['number']
                repo = pr['repository']['nameWithOwner']
                pr_key = f"{repo}#{pr_number}"

                if pr_key in self.pr_details:
                    enriched_prs.append(self.pr_details[pr_key])
                else:
                    enriched_prs.append(pr)

            output["tickets"].append({
                "ticket_id": ticket,
                "prs": enriched_prs
            })

        return json.dumps(output, indent=2)

    def output_markdown(self) -> str:
        """Output results in Markdown format"""
        lines = ["# GitHub PRs for Jira Tickets", ""]

        # Group by repository
        prs_by_repo = defaultdict(list)

        for ticket in self.tickets:
            prs = self.results.get(ticket, [])
            for pr in prs:
                repo = pr['repository']['nameWithOwner']
                pr_number = pr['number']
                pr_key = f"{repo}#{pr_number}"

                # Get detailed info if available
                pr_data = self.pr_details.get(pr_key, pr)
                pr_data['ticket'] = ticket

                prs_by_repo[repo].append(pr_data)

        # Output PRs grouped by repository
        for repo in sorted(prs_by_repo.keys()):
            lines.append(f"## {repo}")
            lines.append("")

            for pr in prs_by_repo[repo]:
                pr_number = pr['number']
                pr_title = pr['title']
                pr_state = pr['state']
                pr_url = pr['url']
                pr_merged = pr.get('mergedAt', 'N/A')
                pr_author = pr.get('author', {}).get('login', 'unknown')
                ticket = pr.get('ticket', 'unknown')

                lines.append(f"### PR #{pr_number}: {pr_title}")
                lines.append(f"- **Jira Ticket**: {ticket}")
                lines.append(f"- **State**: {pr_state}")
                lines.append(f"- **Author**: {pr_author}")
                lines.append(f"- **Merged**: {pr_merged}")
                lines.append(f"- **URL**: {pr_url}")

                # Add file information if available
                if 'files' in pr:
                    additions = pr.get('additions', 0)
                    deletions = pr.get('deletions', 0)
                    files = pr.get('files', [])
                    file_count = len(files)

                    lines.append(f"- **Changes**: +{additions} additions, -{deletions} deletions")
                    lines.append("")

                    if self.detailed and files:
                        lines.append(f"**Changed Files** ({file_count} files):")
                        for file in files:
                            path = file['path']
                            file_additions = file.get('additions', 0)
                            file_deletions = file.get('deletions', 0)
                            lines.append(f"- `{path}` (+{file_additions}/-{file_deletions})")
                    else:
                        lines.append(f"**Files Changed**: {file_count} files")

                lines.append("")
                lines.append("---")
                lines.append("")

        # Summary section
        lines.append("## Summary")
        lines.append("")
        lines.append(f"- **Total tickets searched**: {len(self.tickets)}")
        lines.append(f"- **Total PRs found**: {self.total_prs}")
        lines.append(f"- **Total files changed**: {self.total_files}")
        lines.append(f"- **Repositories affected**: {', '.join(sorted(self.repos_affected))}")
        lines.append("")

        # Tickets without PRs
        tickets_without_prs = [t for t in self.tickets if not self.results.get(t)]
        if tickets_without_prs:
            lines.append("### Tickets without PRs")
            for ticket in tickets_without_prs:
                lines.append(f"- {ticket}")
            lines.append("")

        return "\n".join(lines)


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Search for GitHub PRs associated with Jira tickets',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s AWSMETRICS-406
  %(prog)s "AWSMETRICS-406,AWSMETRICS-407" --detailed
  %(prog)s AWSMETRICS-406 --repos DataDog/dd-source
  %(prog)s AWSMETRICS-406 --output json
        """
    )

    parser.add_argument(
        'tickets',
        help='Comma-separated Jira ticket IDs (e.g., AWSMETRICS-406,AWSMETRICS-407)'
    )
    parser.add_argument(
        '--detailed',
        action='store_true',
        help='Include full file lists for each PR'
    )
    parser.add_argument(
        '--output',
        choices=['json', 'md', 'markdown'],
        default='md',
        help='Output format (default: md)'
    )
    parser.add_argument(
        '--limit',
        type=int,
        default=100,
        help='Limit results per ticket (default: 100)'
    )
    parser.add_argument(
        '--repos',
        help='Limit search to specific repository (e.g., DataDog/dd-source)'
    )

    args = parser.parse_args()

    # Parse ticket IDs
    ticket_list = [t.strip() for t in args.tickets.split(',')]

    # Create searcher
    searcher = JiraPRSearcher(
        tickets=ticket_list,
        limit=args.limit,
        repos_filter=args.repos,
        detailed=args.detailed
    )

    # Check authentication
    if not searcher.check_gh_auth():
        print(f"{Colors.RED}Error: gh CLI not authenticated{Colors.NC}",
              file=sys.stderr)
        print("Please run: gh auth login", file=sys.stderr)
        sys.exit(1)

    # Search for PRs
    searcher.search_all()

    # Output results
    if args.output == 'json':
        print(searcher.output_json())
    else:  # markdown
        print(searcher.output_markdown())


if __name__ == '__main__':
    main()
