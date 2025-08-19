# VFX Forth Simple Extension - Claude Instructions

## Installing/Reinstalling the Extension

When making changes to this VS Code extension, use the following process to reinstall it:

1. **Uninstall existing extension**:
   ```bash
   code --uninstall-extension vfxland.vfx-forth-simple
   ```

2. **Copy extension to Windows VS Code extensions directory**:
   ```bash
   cp -r /mnt/c/Users/roger/Desktop/vfxland5_starling/vfxland5_01/vfx-forth-simple /mnt/c/Users/roger/.vscode/extensions/vfxland.vfx-forth-simple-2.0.1
   ```

3. **Verify installation**:
   ```bash
   code --list-extensions | grep vfx
   ```
   Should show: `vfxland.vfx-forth-simple`

4. **Reload VS Code**: 
   - Use Ctrl+Shift+P → "Developer: Reload Window"
   - Or restart VS Code completely

## Notes

- The `vsce package` tool has compatibility issues in this environment
- Manual copying to the extensions directory is the reliable installation method
- The extension directory name must match the format: `publisher.extension-name-version`
- Always reload VS Code after installation to activate changes