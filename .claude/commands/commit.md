Commit the staged changes.  If there are no staged changes inform the user.

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

  **FINALLY*: Have a sub-agent double-check and correct your work.