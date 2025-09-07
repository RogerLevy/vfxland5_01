# Shadow Files

Automatically open corresponding `.txt` files alongside `.vfx` files in VS Code.

## Features

When you open a `.vfx` file, the extension automatically checks for a corresponding `.txt` file with the same name in the same directory. If found, it opens the `.txt` file in the right split pane.

For example:
- Opening `test-totem2.vfx` will automatically open `test-totem2.txt` alongside it

## Installation

1. Copy the `shadow-files` folder to your VS Code extensions directory:
   - **Windows**: `%USERPROFILE%\.vscode\extensions\`
   - **macOS**: `~/.vscode/extensions/`
   - **Linux**: `~/.vscode/extensions/`

2. Alternatively, use VS Code's "Developer: Install Extension from Location" command

3. Reload VS Code to activate the extension

## Usage

Simply open any `.vfx` file. If a corresponding `.txt` file exists in the same directory, it will automatically open in a split pane to the right.

The extension is non-intrusive - it does nothing if no corresponding `.txt` file exists.