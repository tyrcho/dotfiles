---
allowed-tools: Skill, Agent, Read
argument-hint: <feature description> [--verify-design]
description: Drive a feature end-to-end through three hierarchical subagents (product → design → coder).
---

# /feature

Ship a feature end-to-end using a strict three-stage pipeline. Each stage is a dedicated subagent and concerns are isolated by contract: the product stage decides **what** and **how we verify**, the design stage decides **how it is built** and writes integration tests first, the coder stage implements with TDD.

## Argument parsing

`$ARGUMENTS` contains the user's input. Parse it as:

- If the literal token `--verify-design` appears anywhere in `$ARGUMENTS`, set the flag to `true` and remove that token. The remaining text is the feature description.
- Otherwise, the flag is `false` (trust the design subagent by default) and the entire `$ARGUMENTS` is the feature description.
- If `$ARGUMENTS` is empty, ask the user for the feature description before doing anything else.

## What you do

1. Invoke the `feature` skill via the `Skill` tool. Pass the cleaned description and the flag value through.
2. Do **not** launch any of `feature-product`, `feature-design`, or `feature-coder` directly from here — the skill is the entry point and `feature-product` is responsible for the chain.
3. When the workflow returns, relay the final report to the user. Keep your relay tight (~250 words max). Do not add implementation commentary; the product subagent has already filtered that out on purpose.

## What you must not do

- Do not bypass any stage, even for "tiny" features. The discipline is the point.
- Do not edit code, docs, or diagrams from this command. Delegate everything.
- Do not strip or rewrite the feature description before passing it down — the product subagent handles clarification.
