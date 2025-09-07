# Trait Inheritance Specification

## Overview

Extension to NIB2 object system to support trait inheritance and multiple trait adoption, enabling cleaner separation of abstract concepts from concrete implementations.

## Problem Statement

Current NIB2 limitations:
- Single inheritance chains prevent mixing orthogonal capabilities
- Cannot combine actor (concrete class with field space) and file-asset (abstract functionality)
- Forces artificial architectural choices between unrelated concerns

Example conflict:
```forth
asset(t) -> file-asset(c) -> scene(c)
actor(c) --/-> scene(c)   \ Cannot add actor to scene inheritance
```

## Proposed Solution

### Design Rules

1. **Abstract concepts → traits**: asset-ness, file-asset-ness, serializable-ness
2. **Concrete implementations → classes**: scene, tileset, actor (need memory layout/pools)
3. **Linear inheritance**: specialization chains (asset → file-asset)
4. **Multiple traits**: cross-cutting concerns (scene gets both actor behavior AND file handling)

### Syntax Extensions

#### Trait Inheritance
```forth
trait: asset
    static registry
    256 nprop srcpath
trait;

trait: file-asset
    asset derive        \ NEW: trait inherits from trait
    prop data
trait;
```

#### Multiple Trait Adoption
```forth
class: scene
    actor derive        \ class inheritance (memory pools)
    is-a file-asset     \ trait adoption (protocols)
class;
```

### Inheritance Model

- **Traits**: Single inheritance chains only
- **Classes**: Single class inheritance + multiple trait adoption
- **Protocol resolution**: Derived trait/class implementations override parent implementations
- **Explicit parent calls**: `asset:init`, `file-asset:refresh` syntax

## Implementation Tasks

### 1. Trait Derivation (Primary Task)

**Compiler Changes**:
- Extend trait definition parser to support `derive` keyword
- Build trait inheritance chains at compile-time
- Merge protocol implementations from parent traits
- Handle protocol overriding (derived wins)

**Runtime Changes**:
- Extend trait registry to track parent relationships
- Modify method dispatch to walk trait inheritance chains
- Support explicit parent implementation calls

**Testing**:
- Basic trait inheritance (asset → file-asset)
- Protocol overriding
- Multiple levels (asset → file-asset → versioned-asset)
- Class + multiple traits adoption

### 2. Runtime Lineage Validation (Subtask)

**Safety Checks**:
- Validate `parent:method` calls against actual inheritance chain
- Prevent calls to unrelated trait/class implementations
- Provide clear error messages for invalid calls

**Implementation**:
```forth
\ Valid from scene object:
scene:method ✓       \ own class
actor:method ✓       \ parent class
file-asset:method ✓  \ adopted trait
asset:method ✓       \ trait grandparent

\ Invalid:
tileset:method ✗     \ unrelated class
```

**Chain Validation Algorithm**:
1. Walk class inheritance chain for class parents
2. Walk trait chains for each adopted trait
3. Check if target implementation exists in combined chain
4. Error if not found

**Error Handling**:
- Compile-time validation where possible
- Runtime checks for dynamic calls
- Clear error messages indicating valid alternatives

## Benefits

1. **Architectural clarity**: Separate abstract protocols from concrete implementations
2. **Code reuse**: Share file handling across different concrete types
3. **Type safety**: Maintain inheritance constraints while enabling composition
4. **Future extensibility**: Foundation for more complex multiple inheritance patterns

## Migration Path

1. Implement basic trait derivation without validation
2. Convert existing code to use trait inheritance patterns
3. Add runtime validation as safety enhancement
4. Extend to more complex inheritance scenarios as needed

## Examples

### Before (Blocked)
```forth
\ Cannot achieve both actor capabilities and file handling
class: scene
    actor derive        \ Gets memory pools, actor protocols
    \ Want file-asset protocols too, but can't inherit both
class;
```

### After (Enabled)
```forth
trait: file-asset
    asset derive
    prop data
    256 nprop srcpath
trait;

class: scene
    actor derive        \ Memory pools + actor protocols
    is-a file-asset     \ File loading + asset protocols
class;

\ Usage
s" level1.vfx" scene level1    \ Both actor and file-asset work
level1 refresh                 \ file-asset protocol
level1 load                    \ creates actors on stage
```