# MCP & Integrations

When working with MCP servers (Slack, Google Drive, etc.), always check available MCP tools first with `mcp__*` tool discovery before attempting CLI or API approaches. If an MCP server is not connected or authenticated, report this immediately rather than exploring alternatives.

## Confluence short links

A short link `https://datadoghq.atlassian.net/wiki/x/<code>` encodes the page id: base64url, little-endian. Decode it offline instead of fetching: `python3 -c "import base64;s='<code>';s+='='*(-len(s)%4);print(int.from_bytes(base64.urlsafe_b64decode(s),'little'))"`.
