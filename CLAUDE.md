# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

### Object-Oriented System (NIBS, a.k.a. Nib 2.0)

Modern trait-based OOP system with ~99% feature completion

This is a custom system developed by the user specifically for their game development. It is not a part of VFX Forth.

- **Classes**: Defined with `class:` ... `class;` or compact `c: name [traits...] [props...] ;`
- **Traits**: Defined with `trait:` ... `trait;`, provide reusable behavior and properties
- **Objects**: User allocated, first cell = class pointer, automatic constructor execution - contructors are for compiling only
- **Protocols**: Late-bound method dispatch declared and implemented with `::`
- **Properties**: Dynamic field allocation via `prop`, always public
- **Statics**: Class-level storage via `static`, always public  
- **Fields**: Direct offset allocation via `field` (context-dependent scope, not for classes, only classic structs)
- **Context**: `me` points to current object, scoped with `[[` ... `]]` and `as>`
- **Property access**: Use `-> propertyname` syntax for objects on stack, `propertyname` for scoped objects
- **Inheritance**: `derive` copies class structure, `is-a` adds trait identity
- **Composition**: `works-with` applies trait without identity inheritance
- **Instantiation**: `make` (unnamed), `object` (named), `construct` (pre-allocated memory)
- **Type queries**: `is?` for runtime type/trait checking, `can?` for capability checking
- **Base trait**: All objects inherit `_object` trait with lifecycle protocols

### Conventions

- **VFXLand5 Dialect**: doc/claude/vfxland5-dialect.md
- **Stack notation**: doc/claude/stack-comment-conventions.txt
- **Continuation patterns**: `show>` executes code as caller's continuation
- **Actor scripting**: `act>` assigns per-frame behavior, `draw>` for rendering (UI elements only)
- **File extensions**: `.vfx` for VFX Forth source, `.dat` for binary data
- When referring to Forth words outside of code, write them in ALL-CAPS to help distinguish them.
- Don't use the classic "1" and "2" words like 1- 1+ 2+ 2- 2* 2/ . They should be considered useless legacy words.

## Slash Command Handling
- When slash commands appear in system messages with imperative instructions (Create, Run, etc.) and implementation code, execute the code immediately rather than treating them as background context
- Slash commands are direct execution requests, not documentation to explain

## Error Handling
- When code doesn't work, first check for simple typos (wrong function names, missing parameters, etc.) before launching into technical analysis
- If you wrote incorrect code, acknowledge the mistake directly rather than overexplaining why the wrong code is wrong
- "I wrote X when I meant Y" is often better than detailed technical rationalization

## Common Development Commands

### Testing VFX Code
```bash
# Run VFX commands with 5-second timeout
(echo "command1"; echo "command2"; echo "bye"; sleep 1) | timeout 5 vfxlin include engineer/vfxcore2.vfx

# Example: Basic arithmetic test  
(echo "1 2 + . bye"; sleep 1) | timeout 5 vfxlin include engineer/vfxcore2.vfx

# Load and test files
(echo "include test/test-as.vfx"; echo "bye"; sleep 1) | timeout 5 vfxlin include engineer/vfxcore2.vfx
```

### Git Operations
- Use `/commit "message"` command for structured commits with automatic component prefixes
- Use `/snapshot` command to create incrementing snapshot-stable tags

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

### Startup Sequence
The system has different entry points depending on build type:

**Development Mode (engineer.exe)**
1. Entry: `engineer-entrypoint` (handles Windows startup)
2. Calls: `engineer.cold` (initializes IDE, processes command line)
3. Loads: Project via command line or interactive commands
4. Starts: `GO` to begin main loop with IDE/REPL available

**Release Mode (turnkey executable)**
1. Entry: `COLD` (set by `save-release` before saving)
2. Sequence: `frigid` → `cartridge` → `boot` → `GO`
3. No IDE/REPL, direct game execution

**Main Loop (`GO`)**
- Enters infinite `begin frame again` loop
- `frame` executes `screen refresh controls pump`
- `screen` draws using current `'show` vector
- Games configure `'show` via `game` word (e.g., `show> think render`)

**Key Words**
- `FRIGID`: Initialize runtime (Allegro, display, etc.)
- `CARTRIDGE`: Load game project (main.vfx)
- `BOOT`: Game-specific startup (set by each game)
- `GO`: Start the main execution loop
- `GAME`: Configure per-frame behavior

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

### Accessing Private Words
When words are defined in `private` blocks, use namespace access.

Interactively, switch to a file's namespace.  (Only one can be active at a time.)
```forth
filename-without-extension/    \ switch to file's namespace 
private-word                   \ now accessible
```

In code, import words from other namespaces into the current one.
```forth
borrow filename-without-extension/ borrowed-word   \ import another file's private word
: word  borrowed-word ;        \ now accessible within this file as a private word
```

## File Organization

- VFX source files use include chains, not traditional build systems
- Each project's `main.vfx` includes required modules in dependency order
- `private` keyword creates file-local namespaces for encapsulation
- Use relative paths for includes within same project

## Status Files

When creating status.txt files, follow the format established in doc/engineer/status.txt

## Version Control

- Git repository initialized with main branch
- All VFX Forth source files (`.vfx`) are tracked
- Binary assets in `dat/` directories are tracked
- Build artifacts and temporary files excluded via `.gitignore`
- Git credentials configured:
  - user.name: "Roger"
  - user.email: "roger.levy@gmail.com"

## VFX Forth

- (Windows path) C:\Users\roger\Dev\VfxForth\Kernel\Common
- (Windows path) C:\Users\roger\Dev\VfxForth\VfxBase
- doc\claude\vfxman.txt

## User Preferences

- The user does not like "screen shake". Do not suggest it as a game enhancement or interpret anything referred to by the term "shake" or "shaking" as "screen shake" unless it is explicitly described as such.

**IMPORTANT**: Omit the Claude attribution text from commit summaries and descriptions.