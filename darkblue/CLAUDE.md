# CLAUDE.md

## DarkBlue Game Overview

DarkBlue is a shoot-em-up game built on the VFXLand 5 game engine stack. It features advanced enemy AI powered by a sophisticated Bezier curve-based path system for complex movement patterns.

## Development Commands

### Path Editor (Electron App)

pe/

## Engine framework

@../claude.md

## Architecture

### Core Game Loop
Standard VFXLand 5 pattern implemented in game.vfx:
- `think` - Update game logic and actor behaviors
- `render` - Draw graphics (backdrop, starfield, HUD, sprites)
- `animate` - Advance animations and timers

### Path System (path.vfx)
Advanced movement system featuring:
- **Bezier Curves** - Complex curved movement with control points
- **Arc-Length Parameterization** - Ensures constant speed along curves
- **Easing Functions** - Smooth acceleration/deceleration
- **Multi-slot Playback** - Up to 3 simultaneous paths per actor
- **Loop/Pingpong Support** - Repeating movement patterns

Key classes:
- `path%` - Path definition with segments and arc-length data
- `segment%` - Individual waypoints with timing and curve data
- `playback%` - Runtime playback state for actors

### Actor System
Built on Supershow's 512-byte actor system:
- **ship.vfx** - Player ship with turret system
- **enemy1.vfx** - Enemy with path-based movement
- **orb.vfx** - Collectible items
- **shot.vfx** - Projectiles
- **tri.vfx** - Geometric enemy type
- **turret.vfx** - Rotating weapon component

### Object-Oriented Patterns
Uses VFXLand 5's custom Forth OOP:
- `class:` ... `class;` - Class definitions
- `property` - Instance variables
- `m:` ... `::` - Method declarations and implementations
- `me [[` ... `]]` - Object context scoping
- `'s propertyname` - Property access syntax

### Development Tools
- **Live REPL** - Interactive development during gameplay
- **Path Editor** - Visual editor for complex movement paths
- **Hot Reload** - Instant code changes without restart
- **Asset Auto-loading** - Graphics from `dat/gfx/`, sounds from `dat/smp/`

## Key Files

### Core Game Files
- `main.vfx` - Entry point, loads spunk environment
- `game.vfx` - Core game loop and rendering
- `common.vfx` - Shared variables and utilities
- `constants.vfx` - Game-specific constants
- `path.vfx` - Advanced path movement system
- `enemies.vfx` - Enemy definitions and behaviors

### Development Files
- `testing.vfx` - Test scenarios and debugging
- `scripts/` - Individual actor behavior scripts
- `pe/` - Electron-based path editor application

### Asset Directories
- `dat/gfx/` - PNG graphics files (auto-loaded as bitmaps)
- `dat/smp/` - OGG audio samples (auto-loaded)

## Technical Details

### Fixed-Point Mathematics
- 16.16 fixed-point format used throughout (`.` suffix)
- Conversion: `p>f` (to float), `f>p` (from float)
- Operations: `p*` (multiply), `p/` (divide), `2p*` (coordinate multiply)
- Addition and subtraction re-use `+` and `-`

### Coordinate System
- Screen coordinates stored as x,y pairs
- `2@` `2!` for coordinate fetch/store
- `at` `+at` for pen positioning
- `2+` `2-` for coordinate arithmetic

### Path Definition Syntax
```forth
path[ mypath
    segments[
        1.5 waypoint  200 300 at   \ 1.5 second segment to (200,300)
        2.0 waypoint  400 100 at   \ 2.0 second segment to (400,100)
    segments]
path]
```

### Actor Integration
- `meander` - Get velocity from active path playback
- `path-move` - Start path playback on actor
- `path-speed` - Set playback speed multiplier
- `path-scale` - Set runtime scaling

## Coding Conventions

### VFX Forth Syntax
- `cr` at beginning of output lines, not end
- `\`` `\`\`` for stack management placeholders
- `for ... loop` instead of `0 ?do ... loop`
- `'c'` instead of `[char] c`

### Actor Patterns
- `act>` assigns per-frame behavior
- `draw>` assigns rendering behavior (UI elements only)
- `physics>` assigns per-frame, physics phase logic (alternative pattern: `['] word phys !`)
- `me` refers to current actor instance
- `actor#` provides actor index in the actors array (not a unique ID)

### File Organization
- Include chains rather than build systems
- `private` for file-local namespaces
- Relative paths for same-project includes
- `require` for conditional loading

## Common Development Tasks

### Adding New Enemy Types
1. Create script in `scripts/newenemy.vfx`
2. Define class (note that inheritance is not supported)
3. Implement `act>` and `physics>` behaviors

### Creating Movement Paths
1. Use path editor (`npm start` in `pe/`)
2. Export path data to game
3. Define path using `path[` ... `path]` syntax
4. Integrate with actor using `path-move`