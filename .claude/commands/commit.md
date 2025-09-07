Commit the staged changes.  If there are no staged changes inform the user.

**PROCESS**:
1. Use this commit subject line provided by the user: "$ARGUMENTS"
2. Run `git diff --staged` to analyze the actual changes
3. Based on the diff, write implementation details for the description (if needed)
4. Commit with the user's subject line and your description

**IMPORTANT**: If the user forgot to precede the subject line with the component e.g. (Engineer) or (NIBS), add it for them based on the component the changes are part of.

The commit message format:
```
<user-provided subject line>

<your implementation details if needed>
```

**DESCRIPTION GUIDELINES**:
Add a description when ANY of these conditions are met:
- Multiple distinct changes in the commit (different files, different types of fixes)
- Bug fixes that change behavior or fix specific issues
- Changes are primarily documentation
- Any change that affects user-visible behavior
- Architectural changes (inheritance, class structure, etc.)

Keep descriptions concise and technical, focusing on HOW the change was implemented:
- Examples of good descriptions:
  - "Add helper word INDENT for consistent formatting"
  - "Switch from showing count to listing names"
  - "Use counter-based layout with modulo 10"
- Multiple line-items must be formatted as bullet-point lists.

**EXAMPLES OF COMMITS REQUIRING DESCRIPTIONS**:
- Bug fix affecting multiple files: "- Fix collision detection in player class - Update enemy inheritance hierarchy - Add safety check for self-damage"
- Documentation updates: "- Add Nib 2.0 object system documentation - Update testing command examples - Add namespace access patterns"
- Architectural changes: "- Move validation from private to public scope - Rename property access operator from 's to -> - Add constructor execution to object creation"

**IMPORTANT**: DO NOT stage additional files.

**IMPORTANT**: Write each separate change in a line item

**IMPORTANT**: ALWAYS thoroughly read the changes with `git diff --staged` to determine the commit message.  The actual changes should override whatever has been said in the conversation.  If you don't do this, you will be fined $100.

**IMPORTANT**: Omit the Claude attribution text from the commit summary and description.

**CRITICAL ANALYSIS STEPS**:
1. Run `git diff --staged` and carefully read EVERY line
2. **STEP BACK FROM THE CODE** - Ask yourself:
   - What behavior or capability changed from the USER'S perspective?
   - What would someone USING this system notice is different?
   - What is the conceptual change, not the mechanical change?
3. Identify the RIGHT LEVEL OF ABSTRACTION:
   - NOT the file that changed (nib2-tools.vfx)
   - NOT the implementation detail (dependents .list)
   - BUT the user-visible change (dependency display)
4. Identify the LOGICAL COMPONENT:
   - NOT where the file lives (engineer/)
   - BUT what system it belongs to (NIBS, Supershow, etc.)
5. The conceptual change goes in the subject line
6. Implementation details go in the description

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

