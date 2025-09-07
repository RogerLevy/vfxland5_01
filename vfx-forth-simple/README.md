# VFX Forth Simple Syntax Highlighting

This is a simplified version that treats punctuation as part of words, with only 4 special cases:

## Rules:
1. **Words with `:` or `;`** → RED (defining words)
2. **String literals** → MAGENTA (between quotes)
3. **Numbers** → GREEN 
4. **Character literals** → GREEN (like `'c'`)
5. **Everything else** → YELLOW (user words)

## Special handling:
- `{: ... :}` → All RED
- All punctuation is part of words unless it's one of the 4 exceptions
- `[']`, `n[`, `n]`, `[]` → All YELLOW (user words)
- Comments → GRAY

## Installation:
The extension is installed. **Restart VS Code** and open a `.vfx` file to test.

## Testing:
- `{: | n[ 256 ] :}` should be all RED
- `: word` should be RED  
- `word:` should be RED
- `[']` should be YELLOW
- `n[` should be YELLOW
- `[]` should be YELLOW