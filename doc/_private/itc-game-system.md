# ITC Game Scripting System Design

## Overview

An interactive game scripting system built within an existing Forth environment that provides the flexibility of indirect threaded code (ITC) while leveraging the host system's infrastructure. The system enables live coding, interactive development, and clean code export for game logic programming.

## Core Architecture

### Fundamental Approach
Instead of implementing true indirect threading with virtual machine overhead, the system uses Forth's `defer`/`is` mechanism to achieve similar flexibility:

- Every callable entity becomes a `defer`
- Implementations are assigned via `is` 
- Live reconfiguration without recompilation
- Host Forth handles execution, stacks, and error management

### Benefits
- **Live Development**: Change game behavior while running
- **Clean Export**: Generate standard Forth code
- **Host Integration**: Leverage existing debugging and development tools
- **AI Programmable**: Enables AI assistance for complete game features

## Module Organization

### Vocabulary-Based Namespacing
Each game module lives in its own vocabulary:

```forth
vocabulary game-core
vocabulary game-entities  
vocabulary game-physics
vocabulary game-ui
```

### Import System
Modules reference each other through explicit imports:

```forth
game-physics definitions
import game-core update-world
import game-entities player-pos
```

### Flat Namespace Structure
Each vocabulary maintains a flat namespace internally for simplicity and clarity.

## Host Engine Integration

### Binding Architecture
Host engine functions are exposed through deferrables:

```forth
host-bindings definitions
defer draw-sprite
defer play-sound  
defer get-input
```

### Multiple Binding Sets
Different execution contexts supported:

- **Production**: Real engine functions
- **Testing**: Mock implementations for logic testing
- **Debug**: Instrumented versions for development
- **AI Development**: Text-based simulation for AI programming

### Runtime Switching
```forth
: >production ( -- ) ['] real-draw-sprite is draw-sprite ... ;
: >testing    ( -- ) ['] mock-draw-sprite is draw-sprite ... ;
: >debug      ( -- ) ['] debug-draw-sprite is draw-sprite ... ;
```

## Export System

### Transparent Compilation
Special vocabulary with redefined compilation words:

```forth
itc-forth definitions

: : ( "name" -- )
  create-word                    \ parse name
  dup defer                      \ create the defer
  also forth definitions : ;     \ compile normally  
  previous definitions           
  dup ' swap is ;               \ assign implementation

: variable ( "name" -- )
  dup defer                      \ create defer for access
  also forth definitions variable previous definitions
  dup ' swap is ;
```

### Clean Output Format
Exported files look like standard Forth:

```forth
\ Auto-generated from game-entities vocabulary
itc-forth definitions

: player-move ( -- ) x-pos @ 1+ x-pos ! ;
variable score  
create sprite-data 100 allot

forth definitions
```

### Dependency Management
Export system handles vocabulary dependencies and import relationships automatically.

## State Persistence (Optional)

### Structure vs Values
Two export modes:

1. **Structure Only**: Export word definitions only
2. **Structure + State**: Export definitions plus current variable values

### State Export Format
```forth
\ Structure
variable player-health
variable player-score

\ Optional state assignments  
100 player-health !
1500 player-score !
```

## Development Workflow

### Interactive Development Cycle
1. Define words in appropriate vocabularies
2. Test and iterate with live modifications
3. Export working modules to files
4. Continue development or deploy

### Live Text Editor Integration
External editor integration for familiar text-based development:

**External Editor Workflow:**
- Decompile word to temporary file
- Open in system's default text editor
- Monitor file for changes and reload automatically
- Update runtime state when file is saved

**Editor Integration:**
```forth
: edit-word ( "name" -- )
  find-word decompile-to-temp-file    \ create /tmp/word-name.fs
  temp-file system-editor open       \ open in external editor
  temp-file monitor-and-reload ;     \ watch for saves
  
: edit-vocabulary ( vocab -- )
  decompile-vocabulary-to-temp-file   \ create /tmp/vocab-name.fs
  temp-file system-editor open
  temp-file monitor-and-reload ;
```

**Live Update Process:**
1. Decompile current implementation to temporary file
2. Launch external editor (VS Code, vim, emacs, etc.)
3. User edits using familiar tools and syntax highlighting
4. File watcher detects saves and recompiles automatically
5. Runtime immediately reflects changes

### AI Integration
AI can write complete game features using mock bindings:

```forth
: animate-explosion ( x y -- )
  10 0 do
    i 2* dup draw-sprite
    explosion-sound play-sound
    100 ms
  loop ;
```

## Implementation Considerations

### Error Handling & Tracing Infrastructure

#### Unified Error Reporting
Instead of system exceptions, interpreter errors, and runtime validation being handled differently, the system provides unified error handling:

- All errors reported consistently through common mechanism
- Game logic errors treated same as system errors
- Consistent error format across all error types

#### Hook Infrastructure
Special compiler words automatically inject entry/exit hooks into every defined word:

```forth
: : ( "name" -- )
  create-word dup defer
  also forth definitions
  : ( -- )
    [compile] me enter-hook     \ automatic entry tracking
    ; \ normal compilation
    [compile] me exit-hook      \ automatic exit tracking
  previous definitions  
  dup ' swap is ;
```

#### Extensible Tracing System
Hook mechanism supports multiple use cases:

- **Call Traces**: Track execution flow through game code
- **Full Execution Traces**: Complete word-by-word execution history
- **Performance Profiling**: Timing and call frequency analysis
- **Runtime Validation**: Parameter and state checking
- **Game Features**: Achievement tracking, analytics, etc.

#### Hook Implementation
```forth
defer trace-hook
: no-trace ( word-xt entry/exit-flag -- ) 2drop ;
' no-trace is trace-hook   \ zero overhead by default

\ Optional implementations:
: call-trace-hook ( word-xt entry/exit-flag -- )
  if ." Entering: " else ." Exiting: " then
  >name id. cr ;

: full-trace-hook ( word-xt entry/exit-flag -- )
  log-execution
  check-performance  
  validate-invariants
  update-profiler ;
```

### Performance
- All calls go through defer mechanism
- Optional performance monitoring for optimization
- Hook infrastructure designed for zero overhead when disabled
- Trade-off: flexibility vs execution speed

### Namespace Management
- Clean separation between game code and host system
- Export process maintains import relationships
- Module dependencies resolved automatically

## Key Features Summary

- **Live Coding**: Modify running game behavior
- **Clean Export**: Standard Forth output for sharing/deployment  
- **Modular Organization**: Vocabulary-based module system
- **Host Integration**: Seamless engine API access
- **AI Programmable**: Full game feature development capability
- **State Persistence**: Optional variable value export
- **Multiple Binding Sets**: Testing, debug, and production modes
- **Round-trip Compatibility**: Export/import maintains fidelity

## Future Enhancements

- Performance profiling integration
- Visual debugging tools for defer chains  
- Template systems for common game patterns
- Integration with version control systems
- Automated testing framework for game logic