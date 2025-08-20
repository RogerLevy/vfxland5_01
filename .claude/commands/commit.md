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

**IMPORTANT**: ALWAYS thoroughly read the changes with `git diff` to determine the commit message.  The actual changes should override whatever has been said in the conversation.  If you don't do this, you will be fined $100.

**IMPORTANT**: Omit the Claude attribution text from the commit summary and description.

Here are specific prompts to improve commit message specificity:

  Before analyzing changes, ask yourself:
  - What was broken/missing before this change?
  - What specific behavior changed?
  - What would someone notice is different?

  Replace vague terms with specifics:

  Instead of "improved", "better", "enhanced" → Ask:
  - "What specific metric improved?" (performance, accuracy, usability)
  - "How did it improve?" (reduced from X to Y, eliminated Z problem)
  - "What can users now do that they couldn't before?"
  - "Better how?" (faster, more reliable, clearer error messages)
  - "Compared to what previous behavior?"
  - "What new capability was added?"
  - "What limitation was removed?"

  Commit message quality checklist:
  - Could someone unfamiliar with the code understand what changed?
  - Are the reasons for changes clear from the symptoms described?
  - Would this help during debugging/archaeology later?
  - Did I avoid words like "improve," "better," "enhance," "fix" without specifics?

**CRITICAL**: The commit message must be structured as:
1. FIRST LINE: Short subject - "(Component) Verb aspect" only
2. BLANK LINE (if description needed)
3. ADDITIONAL LINES: Description details

DO NOT put everything on the subject line. Keep it under 50 characters when possible.

**FINALLY**: Have a sub-agent double-check and correct your work.