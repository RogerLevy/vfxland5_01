Commit the staged changes.  If there are no staged changes inform the user.

The commit message format should generally follow this pattern:

<template>
(MajorComponent) Verb aspect
Description line if needed
</template>

<explanations>
MajorComponent = which component the commit is mainly about. (e.g. Engineer, Supershow, NIBS, Oversight, DarkBlue, Claude)

Verb = Action taken (e.g. Add, Update, Fix, Remove, Refactor)

Aspect = What was changed:
- For file changes: use the filename (e.g. commit.md, tilemap.vfx)  
- For functions: use ALLCAPS (e.g. LOAD-BITMAP, DRAW-SPRITE)
- For features: use descriptive name (e.g. collision detection, path system)

The FIRST LINE should be concise: just (Component) Verb aspect
Additional details go on SEPARATE LINES below as the description.

Examples:
```
(Claude) Update commit.md
Add commit message format template
```

```
(Supershow) Fix DRAW-SPRITE
Correct pen position after rotation
```

```
(DarkBlue) Add enemy spawning system
```

See recent commits for more examples.
</explanations>

**IMPORTANT**: DO NOT stage additional files.

**IMPORTANT**: Write each separate change in a line item

**IMPORTANT**: ALWAYS check for staged changes with `git status` first.

**IMPORTANT**: ALWAYS thoroughly read the changes with `git diff --staged` to determine the commit message.  The actual changes should override whatever has been said in the conversation.  If you don't do this, you will be fined $100.

**IMPORTANT**: Omit the Claude attribution text from the commit summary and description.

**CRITICAL ANALYSIS STEPS**:
1. Run `git diff --staged` and carefully read EVERY line
2. Identify the MAIN CHANGE by asking:
   - What is the primary function/word/feature that changed?
   - Is there a single word/function that other changes support?
   - Trust that the user has staged related changes around ONE main change
3. The main change goes in the subject line
4. Implementation details (helper functions, formatting changes, etc.) go in the description

**SUBJECT LINE RULES**:
- MUST follow template: "(Component) Verb aspect"
- Focus on WHAT changed, not HOW it changed
- If a function like .LIST was modified, say "Update .LIST"
- If a new word like INDENT was added ONLY to support another change, INDENT is NOT the main change
- Keep it simple and under 50 characters
- DO NOT include implementation details in the subject

**DESCRIPTION RULES**:
- Implementation details go here (if needed)
- Examples: "Add helper word INDENT", "Use counter-based formatting"
- This is optional - only add if there are important implementation details

**CRITICAL**: The commit message must be structured as:
1. FIRST LINE: Short subject - "(Component) Verb aspect" ONLY
2. BLANK LINE (if description needed)
3. ADDITIONAL LINES: Implementation details ONLY

**MANDATORY**: Use the Task tool to launch a sub-agent to double-check that:
1. The subject line follows the template exactly
2. The subject line identifies the MAIN change, not implementation details
3. Implementation details are in the description, not the subject
4. The message matches what `git diff --staged` actually shows

If the sub-agent finds issues, you MUST fix them before committing.