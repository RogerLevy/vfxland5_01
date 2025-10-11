# Dark Blue Architectural Risk Assessment

This document identifies potential brittle architectural choices in the darkblue codebase, categorized by their attribution (stack-specific vs universal) and estimated effort to resolve.

## Risk Categories

- **Stack-Specific**: Issues arising from VFX Forth, VFXLand5 engine, or NIBS OOP limitations
- **Universal**: Common game development issues that could occur in any engine
- **Hybrid**: Issues with stack-specific manifestations but universal root causes

## Identified Risks

### 1. Manual Actor Slot Management
**Attribution**: Stack-Specific
**Effort to Resolve**: 4/10
**Location**: enemies.vfx:74, :93

**Description**: Entity spawning uses hardcoded slot ranges (`512`, `4096`, `4096 512 +`). Multiple systems manually set the global `next#` variable to partition actor slots. If ranges overlap, entities silently overwrite each other.

**Risk**: Adding new entity types could cause slot conflicts.

**Why Stack-Specific**: Direct consequence of Supershow's fixed actor array design. The `next#` global for slot allocation is an engine pattern.

**Potential Solution**: Build a compile-time slot allocator that assigns non-overlapping ranges.

---

### 2. Global State Scatter
**Attribution**: Universal
**Effort to Resolve**: 3/10
**Location**: common.vfx:49-53

**Description**: Critical state is stored in global variables: `player0`, `energy`, `charge`, `automatic`. No clear ownership model - any code can mutate these from anywhere. `player0` must be initialized before other systems use it.

**Risk**: Initialization order bugs, unexpected mutations.

**Why Universal**: Singletons and global state appear in Unity, Unreal, and other engines. This is an organizational issue, not a language issue.

**Potential Solution**: Organizational refactor - centralize globals into a game state object or namespace.

---

### 3. Path System Complexity
**Attribution**: Hybrid
**Effort to Resolve**: 9/10
**Location**: path.vfx (500+ lines)

**Description**: Complex bezier curve system with arc-length parameterization and drift compensation. Includes manual memory allocation/deallocation, disabled validations for performance (`fast[`), and floating-point accumulation errors requiring drift correction.

**Risk**: Memory leaks, numerical instability, difficult to debug.

**Why Hybrid**: Path complexity is universal. Manual `allocate`/`free` and `fast[` are VFX Forth specific. Fixed-point drift compensation needed due to `.` fixed-point math.

**Potential Solution**: Fundamental rewrite or accept the complexity as necessary for the feature set.

---

### 4. String-Based Entity References
**Attribution**: Universal
**Effort to Resolve**: 5/10
**Location**: enemies.vfx:73, :95; event.vfx:144

**Description**: Uses `s" tri" find-class`, `s" orb" find-class` for runtime lookups. Event system uses filenames as identifiers.

**Risk**: Silent failures if names change, no compile-time verification.

**Why Universal**: Equivalent to `GameObject.Find("Tri")` in Unity. Common in scripting-heavy engines.

**Potential Solution**: Build a type registry system with compile-time name validation.

---

### 5. Collision Detection Coupling
**Attribution**: Universal
**Effort to Resolve**: 7/10
**Location**: ship.vfx:107, :126

**Description**: Collision handlers check specific types: `me enemy is?`, `me orb is?`. Each entity type has its own collision logic with hardcoded knowledge of others.

**Risk**: Adding new collidable entities requires modifying multiple files.

**Why Universal**: Type-checking collision handlers happens in all engines. Just different syntax for `instanceof` patterns.

**Potential Solution**: Architectural change to layer-based or tag-based collision system.

---

### 6. Event System Control Flow
**Attribution**: Stack-Specific
**Effort to Resolve**: 8/10
**Location**: event.vfx:64; events/event1.vfx:21-29

**Description**: Events capture return addresses for delays: `r> delay-xt !`. Uses infinite `begin...again` loops with continuation points. No clear event cleanup or cancellation model.

**Risk**: Stack corruption if misused, hard to reason about execution flow.

**Why Stack-Specific**: Return stack manipulation (`r>`) is a pure Forth idiom. This pattern doesn't exist outside stack-based languages.

**Potential Solution**: Complete redesign using a different coroutine/state machine approach.

---

### 7. Trait Serialization Workaround
**Attribution**: Stack-Specific
**Effort to Resolve**: 10/10
**Location**: common.vfx:39-44

**Description**: Comment admits: "this is fine because we know all Dark Blue actors have firers, but if we wanted more modularity, implementing this across traits would have to be accumulative, rather than destructive."

The issue: when an actor `works-with` multiple traits, and each trait defines the same protocol (e.g., `serializable?`), only the last trait's implementation wins. Current workaround puts all logic in `actor::serializable?`.

**Risk**: Architectural assumption baked in that limits extensibility.

**Why Stack-Specific**: Limitation of the NIBS trait system's method override semantics.

**Potential Solution**: Fundamental OOP system changes to support method composition across multiple traits. May require static bitmask properties or protocol accumulation mechanism.

---

### 8. Hot-Reload Dual Codepaths
**Attribution**: Stack-Specific
**Effort to Resolve**: 2/10
**Location**: enemies.vfx:171-174; main.vfx:7-31

**Description**: Multiple `honing @ [if]` blocks create development vs release code paths. Enemy hot-reload system and debug overlays only active during development.

**Risk**: Behavior differences between dev and release builds.

**Why Stack-Specific**: `honing @` conditional compilation is VFXLand5-specific workflow.

**Potential Solution**: Cleanup and consolidation of conditional code. Ensure critical paths are tested in both modes.

---

### 9. Fixed Resource Limits
**Attribution**: Universal
**Effort to Resolve**: 2/10
**Location**: constants.vfx:3-5

**Description**: Hardcoded constants: `#actors` (8192), `#temps` (8192), `#elements` (32).

**Risk**: Can't adjust limits without recompilation.

**Why Universal**: Hardcoded max actors/entities common in pooling systems and embedded engines.

**Potential Solution**: Add indirection layer or configuration system.

---

### 10. Type Safety via Runtime Checks
**Attribution**: Hybrid
**Effort to Resolve**: 10/10
**Location**: common.vfx:45-47; throughout codebase

**Description**: No compile-time type safety for entity interactions. Nullable references checked at runtime: `fired?` checks `0=`. Uses runtime `is?` checks throughout.

**Risk**: Runtime errors that could be caught at compile time.

**Why Hybrid**: Forth's dynamic typing necessitates runtime checks. Similar patterns exist in dynamically-typed scripting languages, but static engines can prevent these errors.

**Potential Solution**: Impossible without fundamental language changes to add static typing.

---

## Summary Statistics

### By Attribution
- **Stack-Specific**: 4 issues (#1, #6, #7, #8)
- **Hybrid**: 2 issues (#3, #10)
- **Universal**: 4 issues (#2, #4, #5, #9)

### Effort Analysis
Total effort to resolve all issues: **60 units**

**By Category:**
- Stack-Specific: 24 units (40%)
- Hybrid: 19 units (32%)
- Universal: 17 units (28%)

**Splitting Hybrid Proportionally:**
- Stack-attributable: **56%** of total effort
- Could happen anywhere: **44%** of total effort

### Critical Observations

**Unfixable Issues**: #7 and #10 are near-impossible without fundamental changes to the OOP system or language itself. However, these don't block the game - workarounds exist.

**Easy Wins**: #8 (2 units) and #9 (2 units) could be addressed quickly.

**High-Effort Universal Issues**: #5 (collision coupling, 7 units) would be equally challenging in Godot due to architectural constraints.

**Most Brittle Areas**:
1. Manual actor slot partitioning (#1)
2. Global state management (#2)
3. Path system complexity (#3)

The collision detection coupling (#5) and string-based lookups (#4) would make adding new entity types cumbersome but not impossible.

The event system's control flow manipulation (#6) is clever but fragile - use with caution.
