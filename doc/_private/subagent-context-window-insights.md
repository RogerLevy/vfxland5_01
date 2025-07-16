# Subagent Context Window Insights

## Key Discovery
Subagents are dramatically more capable for research-heavy tasks due to **context window allocation**, not inherent capability differences.

## Context Window Constraints

**Main Agent (in conversation):**
- Conversation history consumes most context window
- File reads, edits, tool results, system reminders
- Very limited space for deep file analysis
- Forced to make shallow, generic analysis

**Subagent (fresh context):**
- Clean slate - no conversation history
- Entire context window dedicated to the task
- Can read multiple large files simultaneously
- Builds comprehensive domain knowledge before analyzing
- Holds full system architecture while performing analysis

## Practical Impact
- **Research tasks**: Subagents can read entire codebases and build complete mental models
- **Analysis quality**: Deep, context-aware recommendations vs generic defensive programming
- **Multi-file tasks**: Subagents can synthesize information across many files
- **Complex domains**: Subagents can become experts before performing tasks

## When to Use Subagents
- Tasks requiring extensive file reading/research
- Multi-file analysis or cross-referencing
- Complex domain understanding needed
- When conversation context is limiting main agent capability

## Protocol Issue
Subagent output not visible to user - rich analysis can be lost unless explicitly saved.