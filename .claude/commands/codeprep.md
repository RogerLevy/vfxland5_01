@CLAUDE.md
@doc/claude/word-naming-conventions.txt
@doc/claude/stack-comment-conventions.txt
@doc/claude/coding-style-guidelines.md
@engineer/vfxcore.vfx

Read the individual files included by vfxcore.vfx.

## Testing

`include engineer/vfxcore.vfx` loads a subset of Engineer functionality excluding all game related functions (graphics, audio, input).

Specify a timeout of 5000 (5 seconds) with every use of the Bash tool to run VFX tests.

### Running VFX Commands

Use this pattern to run VFXLand5 code:

```bash
(echo "command1"; echo "command2"; echo "bye"; sleep 1) | vfxlin include engineer/vfxcore.vfx
```

Examples:
```bash
# Basic arithmetic test
(echo "1 2 + . bye"; sleep 1) | vfxlin include engineer/vfxcore.vfx

# Load files and test
(echo "include etc/hanoi.vfx"; echo "bye"; sleep 1) | vfxlin include engineer/vfxcore.vfx

# Multiple commands
(echo "words"; echo "bye"; sleep 1) | vfxlin include engineer/vfxcore.vfx
```

The `sleep 1` ensures VFX has time to process commands before the pipe closes.

### Accessing private words

hanoi.vfx Example:

```forth
private

: private-word ;

public
```

Enable access to words in the private block:

```forth
private-word   \ word will not be found
also `hanoi    \ add hanoi.vfx's namespace to search order
private-word   \ word will be found
```
