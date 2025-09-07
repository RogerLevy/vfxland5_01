# Dark Blue Path System Documentation

## Overview

This is the path system documentation for "Dark Blue", a shoot-em-up game written in VFX/Forth with an Electron-based path editor tool.

### Core Components

- **Main Game**: Written in VFX/Forth scripting language
  - `main.vfx` - Entry point, includes loader from spunk framework
  - `game.vfx` - Core game loop with backdrop, starfield, sprites, and HUD
  - `common.vfx` - Shared variables, time system, and scripting helpers
  - `starfield.vfx` - Parallax starfield background system
  - `scripts/` - Individual actor scripts (ship, enemies, projectiles)

- **Path Editor**: Electron desktop application in `pe/` directory
  - Bezier curve editor for creating enemy movement paths
  - Exports to both JSON and VFX/Forth format
  - Features arc-length parameterization for smooth animation

- **Path System**: Advanced path playback engine (`path.vfx`)
  - Bezier curve interpolation with easing functions
  - Arc-length parameterization for constant-speed movement
  - Multi-segment path support with timing controls
  - Multiple simultaneous path playback (`thruster1`, `thruster2`, `thruster3`)
 
### Architecture

The game uses a stack-based Forth-like language (VFX) with object-oriented extensions:
- Classes defined with `class:` ... `class;`
- Objects have properties accessible via `'s propertyname`
- Game loop follows: `think` → `render` → `animate` → repeat
- Actor system with automatic lifecycle management

## Development Commands

### Path Editor
```bash
cd pe
npm install        # Install dependencies
npm start         # Run path editor
npm run dev       # Run with developer tools
```

### Game Development
- No build system - VFX files are interpreted directly. 
- Game assets stored in `dat/` directory
- Path definitions can be imported from path editor exports

## Key Systems

### Path Definition Format
Paths use waypoint + bezier curve format:
```forth
segments[
  1.0 waypoint 10.0 5.0 30.0 15.0 curve 1 ease 0.5 0.8 strength
  0.8 waypoint -5.0 -10.0 20.0 0.0 curve 2 ease 0.3 0.6 strength
segments]
```

### Actor Integration
- `thruster1`, `thruster2`, `thruster3` - Individual path playback slots
- `follow` - Attach actor to path
- `meander` - Get combined velocity from all active paths
- Arc-length parameterization provides smooth constant-speed motion

### Easing Functions
- 0: Linear
- 1: Ease In
- 2: Ease Out  
- 3: Ease In-Out

## File Conventions

- `.vfx` files are VFX/Forth source code
- Game graphics in PNG format stored in `dat/gfx/`
- Path editor uses JSON for save/load, exports VFX format
- Object classes use `%` suffix (e.g., `ship%`, `segment%`)

## Additional Context

  See also: ../CLAUDE.md for engine-wide documentation and search paths.
