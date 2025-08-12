# Customizing Colors for VFX Forth

## Setting Colors in VS Code

You can customize the colors for VFX Forth syntax highlighting in two ways:

### Method 1: Using VS Code Settings (Recommended)

1. Open VS Code Settings (`Ctrl+,` or `Cmd+,`)
2. Search for "editor.tokenColorCustomizations"
3. Click "Edit in settings.json"
4. Add this configuration:

```json
{
  "editor.tokenColorCustomizations": {
    "[*]": {
      "textMateRules": [
        {
          "scope": "keyword.other.defining.vfx-forth",
          "settings": {
            "foreground": "#FF6666"
          }
        },
        {
          "scope": "keyword.control.vfx-forth", 
          "settings": {
            "foreground": "#FF6666"
          }
        },
        {
          "scope": "support.function.vfx-forth",
          "settings": {
            "foreground": "#66DDDD"
          }
        },
        {
          "scope": "keyword.other.parsing.vfx-forth",
          "settings": {
            "foreground": "#66DDDD"
          }
        },
        {
          "scope": "string.quoted.double.vfx-forth",
          "settings": {
            "foreground": "#DD66DD"
          }
        },
        {
          "scope": "string.quoted.double.formatted.vfx-forth",
          "settings": {
            "foreground": "#DD66DD"
          }
        },
        {
          "scope": "string.quoted.double.alternate.vfx-forth",
          "settings": {
            "foreground": "#DD66DD"
          }
        },
        {
          "scope": "keyword.other.string.vfx-forth",
          "settings": {
            "foreground": "#DD66DD"
          }
        },
        {
          "scope": "constant.numeric.hex.vfx-forth",
          "settings": {
            "foreground": "#66DD66"
          }
        },
        {
          "scope": "constant.numeric.float.vfx-forth",
          "settings": {
            "foreground": "#66DD66"
          }
        },
        {
          "scope": "constant.numeric.integer.vfx-forth",
          "settings": {
            "foreground": "#66DD66"
          }
        },
        {
          "scope": "constant.character.vfx-forth",
          "settings": {
            "foreground": "#66DD66"
          }
        },
        {
          "scope": "variable.other.vfx-forth",
          "settings": {
            "foreground": "#DDBB44"
          }
        },
        {
          "scope": "comment.line.backslash.vfx-forth",
          "settings": {
            "foreground": "#999999",
            "fontStyle": "italic"
          }
        },
        {
          "scope": "comment.block.parens.vfx-forth",
          "settings": {
            "foreground": "#999999",
            "fontStyle": "italic"
          }
        }
      ]
    }
  }
}
```

### Method 2: Create a Custom Color Theme

1. Create a new theme file in your VS Code extensions folder
2. Modify the theme to include VFX Forth scopes

## Color Mapping

Based on your Komodo editor screenshot, here's the exact color mapping:

- **Red** (`#FF6666`): Defining words and flow control
  - `keyword.other.defining.vfx-forth` - words like `:`, `variable`, `create`, `class:`
  - `keyword.control.vfx-forth` - words like `if`, `then`, `loop`, `begin`

- **Cyan** (`#66DDDD`): Core Forth/VFX words and parsing words
  - `support.function.vfx-forth` - words like `dup`, `swap`, `2>r`, `@`, `!`
  - `keyword.other.parsing.vfx-forth` - words like `char`, `[char]`, `postpone`

- **Magenta** (`#DD66DD`): Strings
  - `string.quoted.double.vfx-forth` - `s"`, `c"`, `z"`
  - `string.quoted.double.formatted.vfx-forth` - `f"`, `fe"`
  - `string.quoted.double.alternate.vfx-forth` - `s\"`
  - `keyword.other.string.vfx-forth` - the string prefixes themselves

- **Green** (`#66DD66`): Numbers and character literals
  - `constant.numeric.hex.vfx-forth` - `$123`, `#120`, `%1001`
  - `constant.numeric.float.vfx-forth` - `1.0`, `1.5e3`
  - `constant.numeric.integer.vfx-forth` - `123`, `-456`
  - `constant.character.vfx-forth` - `'c'`

- **Orange/Yellow** (`#DDBB44`): User-defined words
  - `variable.other.vfx-forth` - any words not in the predefined categories

- **Light Gray** (`#999999`, italic): Comments
  - `comment.line.backslash.vfx-forth` - `\ line comments`
  - `comment.block.parens.vfx-forth` - `( inline comments )`

## Testing

After adding the color customizations:
1. Restart VS Code or reload the window (`Ctrl+Shift+P` → "Developer: Reload Window")
2. Open a `.vfx` file to see the custom colors
3. Adjust the hex color values as needed