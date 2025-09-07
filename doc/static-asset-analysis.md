# Static Asset Analysis System

## Overview

A compile-time script analyzer that automatically discovers asset dependencies through bracket notation in source code, eliminating the need for lazy loading or manual manifest files. Source files become their own dependency declarations.

## Current Problem

VFXLand5's current approach:
- Walks all directories and loads everything
- Can't exclude broken assets without moving to subdirectories  
- No selective loading without explicit load statements
- Security risk: shipping games with exposed script source code

## Proposed Solution

**Three-phase compilation process:**

### Phase 1: Static Analysis
Scan all `.vfx` files for bracket notation patterns before compilation:

```forth
\ Analyzer finds all [asset-name] patterns in source
: analyze-dependencies ( - )
    \ Find all [asset-name] patterns in source
    \ Build dependency graph  
    \ Topologically sort load order
    \ Generate load sequences
;
```

### Phase 2: Controlled Loading
Generate and execute load sequences based on discovered dependencies:

```forth
\ Auto-generated from analysis
: load-discovered-assets ( - )
    \ Load in dependency order
    require scripts/enemy1.vfx
    require scripts/ship/laser.vfx  
    load-bitmap dat/gfx/player.png
    load-sample dat/smp/explosion.ogg
    require events/test1.vfx
;
```

### Phase 3: Compilation
Bracket notation compiles to direct references:
- `[enemy1]` → `enemy1` (literal class reference)
- `[events/test1]` → `test1` (literal event reference)

## Bracket Notation Examples

```forth
:event
    [enemy1] one            \ → scripts/enemy1.vfx
    [ship.laser] spawn      \ → scripts/ship/laser.vfx  
    [events/test1] run      \ → events/test1.vfx
    [sfx.explosion] play    \ → dat/smp/explosion.ogg
    [gfx.player] put        \ → dat/gfx/player.png
    [rooms.level1] load     \ → dat/maps/level1.dat + level1.vfx
;
```

## Path Resolution Rules

- `[name]` → search scripts/ for `name.vfx`
- `[path/name]` → exact path relative to project root
- `[sfx.name]` → `dat/smp/name.ogg`
- `[gfx.name]` → `dat/gfx/name.png`  
- `[rooms.name]` → `dat/maps/name.dat` + `dat/maps/name.vfx`

## Benefits

1. **Zero runtime overhead** - All assets pre-loaded, no lazy loading
2. **Source files ARE manifests** - No separate manifest files needed
3. **Compile-time validation** - Missing assets caught early
4. **Automatic dependency ordering** - Complex load orders handled automatically
5. **Hot-reload compatible** - Analysis can re-run on file changes
6. **Extensible** - New bracket patterns easy to add
7. **Security** - Scripts compiled into game, not shipped as source
8. **Self-documenting** - Code shows exactly what assets it uses

## Implementation Considerations

- Static analyzer needs to handle Forth's dynamic nature carefully
- Bracket notation must be distinguishable from array literals
- Error reporting should point to exact source locations
- Hot-reload needs to re-analyze dependencies on file changes
- Consider caching analysis results for large projects

## Migration Strategy

1. Implement bracket notation parser
2. Add static analysis pass to build system
3. Gradually migrate existing asset loading to bracket notation  
4. Maintain backward compatibility with current directory walking
5. Eventually phase out manual loading approaches

## Future Extensions

- Conditional loading: `[?debug.enemy]` - only in debug builds
- Version dependencies: `[enemy1@v2.1]` - specific asset versions
- Asset variants: `[enemy1|mobile]` - platform-specific assets
- Build-time asset processing: `[sprite.png|optimized]`