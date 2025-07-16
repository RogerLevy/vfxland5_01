# CLAUDE.md

## VFXLand 5 

- Custom game engine and 2D games written in VFX Forth.

### Core Layers

1. **Engineer** (`engineer/`) - Base IDE/runtime providing:
   - Allegro 5 graphics/audio/input bindings
   - Window management and REPL
   - Automatic bitmap loading system
   - Object-oriented programming extensions
   - Fixed-point math and utility functions
   - Contract-oriented runtime validations
   - Arrays and Stacks
   - String formatting utilities
   - Dictionaries (key/value collections)
   - Note that engineer is a GUI application and cannot yet be used by Claude for testing.
   - Hot-reload development workflow

2. **Supershow** (`supershow/`) - Game engine middleware providing:
   - Actor/sprite system with collision detection
   - Tilemap rendering system
   - Audio sample playback
   - GPU shader support with CRT effects
   - UI framework
   - Mathematical utilities for game development

3. **Spunk** (`spunk/`) - Integrated development environment providing:
   - Specific game constraints - 100x10-screen world layout
   - Live level editor (`le/`)
   - Bitmap editor (`be/`)
   - Tileset editor (`te/`)

4. **Game Projects** - Individual games that build on the stack:
   - `darkblue/` - Shoot-em-up with advanced path system
   - `kevin/` - Adventure platformer
   - `jamesjam/` - Dialog-driven adventure
   - `pinky/` - Action platformer
   - `kvn/` - Precision platformer

### Object-Oriented System

Custom Forth OOP implementation

- **Classes**: Defined with `class:` ... `class;`, create private namespaces
- **Objects**: User allocated.  First cell = class pointer
- **Actors**: (in Supershow) 512-byte fixed-size instances 
- **Messages**: Late-bound method dispatch declared with `m:` and implemented with `::`
- **Fields**: Declared via `var` (instance) or `static` (class-level)
- **Context**: `me` points to current object, scoped with `[[` ... `]]`
- **Property access**: Use `'s propertyname` syntax for objects on stack.  Use `propertyname` for scoped objects e.g. `[[ propertyname @ ]]`

### Conventions

- **VFXLand5 Dialect**: doc/claude/vfxland5-dialect.md
- **Stack notation**: doc/claude/stack-comment-conventions.txt
- **Continuation patterns**: `show>` executes code as caller's continuation
- **Actor scripting**: `act>` assigns per-frame behavior, `draw>` for rendering
- **File extensions**: `.vfx` for VFX Forth source, `.dat` for binary data
- **Output formatting**: `cr` goes at the beginning of line outputs, not the end
- **Backup files**: naming convention `original-filename-backup-YYYYMMDD-HHMMSS.ext`

## Communication Requirements

The user has a strong dislike for several opening phrases typically uttered by Claude Code.

The user prefers these phrases to be avoided, but will accept these alternatives.

- "Perfect!" "Good!" -> "OK." 
- "You're right!" "You're absolutely right!" -> "Understood." or "It is possible/likely that..." 
- "Good observation!" -> "I see." 
- "I see the problem!" "I see the issue!" -> "Error(s) located." 

**Don't tell the user what to do** unless they specifically ask for guidance or recommendations

## Development Workflow

### Project Structure Patterns
Each game project follows this structure:
```
projectname/
├── dev.bat              # Launch script
├── main.vfx            # Entry point (includes spunk loader)  
├── game.vfx            # Core game loop
├── common.vfx          # Shared variables and utilities
├── constants.vfx       # Game-specific constants
├── modules.vfx         # Additional systems (if needed)
├── scripts/            # Individual actor behavior scripts
├── testing.vfx         # Testing facilities
├── dat/               # Game assets
│   ├── gfx/           # PNG graphics files
│   ├── maps/          # Level data (.dat/.scn files)
│   ├── bgm/           # Background music
│   └── smp/           # Sound samples
└── doc/               # Design documents
```

### Asset Loading
- Bitmaps are automatically loaded from `dat/gfx/` directory
- Other assets are automatically loaded from other subdirs of dat/
- (Spunk) Maps combine binary tile data (`.dat`) and Forth scene scripts (`.scn`)

### Game Loop Architecture  
Standard pattern: `think` → `render` → `animate` → repeat
- `think`: Update game logic and actor behaviors
- `render`: Draw graphics to screen 
- `animate`: Advance animations and timers

### Interactive Development
- REPL available during runtime for live coding
- In-game editors (Spunk) allow immediate asset modification
- Hot-reload workflow: edit code/assets and see changes instantly

### Exporting Releases

- supershow/loader.vfx - standard compilation sequence for games
- `turnkey` copies game files to ../rel/<game>/ and saves executables

## Key Systems

### Fixed-Point Mathematics
- 16.16 fixed-point format used throughout (denoted with `.` suffix)
- Conversion: `p>f` (to float), `f>p` (from float), `p*` (multiply), `p/` (divide)

### Allegro 5 Integration
- Direct function calls to Allegro 5 library (not fully wrapped)
- Drawing uses pen position system with words `at` `+at` `at@`

### Oversight
- Contract-oriented zero-overhead runtime validations 
- Automatically loaded by Engineer
- Several system-wide validations provided (engineer/debug/core-checks.vfx, engineer/checks.vfx)

## File Organization

- VFX source files use include chains, not traditional build systems
- Each project's `main.vfx` includes required modules in dependency order
- `private` keyword creates file-local namespaces for encapsulation
- Use relative paths for includes within same project

## Status Files

When creating status.txt files, follow the format established in doc/engineer/status.txt

## Codebase Backups

Location: ../01_backups

## VFX Forth

- (Windows path) C:\Users\roger\Dev\VfxForth\Kernel\Common
- (Windows path) C:\Users\roger\Dev\VfxForth\VfxBase
- doc\claude\vfxman.txt