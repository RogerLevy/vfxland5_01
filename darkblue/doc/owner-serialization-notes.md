# Owner Serialization for Dark Blue Scenes

## Problem Statement
- Dark Blue actors can reference other actors through the OWNER property
- Current SCENE serialization doesn't handle actor-to-actor references
- Need to serialize/deserialize these references without modifying scene.vfx

## Current Understanding

### Scene Serialization Process
1. **Commit (Save):**
   - Saves SCENE_FORMAT_VERSION
   - Serializes scene object itself (SERBIN)
   - Serializes all enabled actors using SERMULTI
   
2. **Load:**
   - Reads format version
   - Deserializes scene object (DESBIN)
   - Deserializes actors using DESMULTI with LOAD-ACTOR

### Actor System
- Actors stored in global ACTORS array (stage.vfx)
- Each actor has an ID property (actor index)
- OWNER property defined as `prop owner <ref actor` in darkblue/common.vfx

## Proposed Solution Approach

During serialization:
1. Build index mapping of actors (position in serialization order)
2. For each actor with non-null OWNER, store index as OWNER-ID property
3. Serialize normally (OWNER-ID gets saved, OWNER reference ignored)

During deserialization:
1. Track each deserialized actor in order (stack/array)
2. After all actors loaded, resolve OWNER-ID → OWNER references
3. Clear OWNER-ID properties

## Implementation Options Considered

### Option 1: Extension Class
- **Issue:** Scene editor and future Supershow features use SCENE class directly
- Can't just derive a new class without changing how scenes are created

### Option 2: Mixin Trait
- Add owner-tracking capabilities via trait
- Still requires overriding _commit/_load

### Option 3: Hook-based Extension
- Add pre/post serialization hooks
- Minimal code, works with existing system
- Requires OWNER-ID property on actors

### Option 4: Custom Serializers
- Override SERBIN/DESBIN for actors
- Most complex but most control

● You raise an excellent point about the scene editor and future Supershow features needing to
  use the SCENE class directly. Let me explore alternative approaches:

● Given this constraint, here are better options:

  Alternative Approaches

### Option 5: Method Override/Extension Pattern

  Since VFX Forth allows runtime redefinition, we could extend the existing SCENE class methods:

  \ darkblue/scene-owner-ext.vfx
  \ Extend scene class with owner support without changing its identity

  variable owner-index-map
  variable actor-resolve-stack

  \ Save original methods
  scene :: _commit  ' lit , constant original-scene-commit
  scene :: _load    ' lit , constant original-scene-load

  \ Override with extended versions
  scene :: _commit ( - )
      \ Pre-serialization: set owner-ids
      ...
      original-scene-commit execute
      \ Post-serialization: cleanup
      ...
  ;

### Option 6: Serialization Filter Pattern

  Modify the actor serialization at the filter level:

  \ Use the filter-xt parameter of SERMULTI to inject owner tracking
  : track-and-filter ( actor - flag )
      dup enabled? dup if
          \ Track this actor for owner resolution
          dup current-index @ swap set-owner-id
          1 current-index +!
      then ;

### Option 7: Property-Level Extension

  Since OWNER is defined with <ref, we could define custom serialization for reference
  properties:

  \ Add to darkblue - make <ref properties handle owner specially
  : serialize-ref-as-index ( property - )
      \ Custom serialization for <ref properties
      ...
  ;

## Key Constraints
- Cannot modify scene.vfx
- Scene editor must continue to work
- Future Supershow features must not break
- Solution should be Dark Blue specific

## Next Steps
- Need to determine best way to extend SCENE without replacing it
- Consider monkey-patching or method extension patterns
- May need to add hooks to actor serialization process

## New Direction: Polymorphic Scene System

### The Problem with Current Design
- MATERIALIZE and +TOTEM need to know the class to instantiate
- Scene files (.scn) are always materialized as SCENE class
- No way to use derived scene classes without changing how scenes are discovered/loaded

### Proposed Solution: Store Class in Scene File
Make scene files self-describing by storing the class name in the file:
1. First item in scene file = class name (string)
2. MATERIALIZE checks if file exists, reads class name
3. Creates instance of that class (must inherit from SCENE)
4. Rest of deserialization proceeds normally

### Implementation Challenges
1. **Asset Discovery**: How does MATERIALIZE know what class before reading file?
   - Option A: Read first few bytes to get class name
   - Option B: Use file extension mapping (.scn = SCENE, .dbs = darkblue-scene)
   - Option C: Registry/manifest approach

2. **Backwards Compatibility**: Existing scene files don't have class name
   - Could check format version or presence of class name
   - Default to SCENE if no class specified

3. **Tool Support**: Scene editor needs to handle different scene classes
   - Could query scene for its class
   - UI might need to adapt based on scene capabilities

## Final Decision: Make OWNER a Supershow Feature

After exploring options, making OWNER serialization a core Supershow/SCENE feature is simpler and cleaner.

### Changes Required

#### 1. Add OWNER property to actor class (supershow/stage.vfx)
- Add `prop owner <ref actor` to base actor class
- Add `prop owner-id <int` for serialization (not saved, temporary)

#### 2. Modify scene.vfx _commit method
- Before serializing actors, build index map
- For each actor with non-null owner, set owner-id to index
- After serialization, clear owner-ids

#### 3. Modify scene.vfx _load method  
- Track loaded actors in array/stack
- After all actors loaded, resolve owner-ids to owner references
- Clear owner-ids after resolution

#### 4. Update SCENE_FORMAT_VERSION
- Increment to version 2 to indicate owner support
- Maintain backwards compatibility for version 1 files

### Benefits
- Works transparently for all games
- Scene editor automatically supports owner relationships
- No special configuration needed
- Clean implementation in one place

## Future-Proofness Assessment of OWNER

### Current Use Case
- OWNER is a quick solution for tracking actor "containers" 
- Avoids complexity of full hierarchical tree features
- Single parent reference per actor

### Potential Future Limitations

1. **No Multi-Parent Support**
   - Can't have shared ownership (e.g., actor belonging to multiple groups)
   - No way to track different relationship types

2. **No Child Tracking**
   - Parent doesn't know its children
   - Must scan all actors to find children of a parent
   - O(n) operation for each parent-child query

3. **No Hierarchy Operations**
   - Can't easily move entire subtrees
   - No cascade delete/update
   - No depth queries or traversal utilities

4. **Serialization Complexity Growth**
   - Current approach uses indices during save/load
   - Circular references would break this
   - Deep hierarchies might need recursive handling

### When OWNER is Sufficient
- Projectiles tracking their firer
- Items tracking their container/holder  
- UI elements tracking their parent panel
- Simple spawn relationships
- Any 1:1 or N:1 relationships

### When You'd Need More
- Scene graphs with transforms
- Component systems with multiple attachments
- Inventory systems with nested containers
- Complex AI squad hierarchies
- Particle systems with emitter chains

### Recommendations

1. **Keep OWNER Simple**
   - Document it as "single parent reference only"
   - Don't try to make it handle complex cases
   - It's fine as a 80% solution

2. **Future Hierarchy System**
   - Could coexist with OWNER
   - Add separate `children` array property when needed
   - Or create dedicated `hierarchy` trait/class

3. **Alternative Patterns to Consider**
   - **Tags/Groups**: For many-to-many relationships
   - **Entity-Component**: For flexible composition
   - **Scene Graph**: For transform hierarchies
   - **Slots**: For fixed parent-child relationships

### Verdict
OWNER is future-proof *for its intended use case* - simple container tracking. Don't overload it with hierarchy features. When you need true hierarchies, build a separate system rather than extending OWNER.

## Reconsidering Option 5: Method Override Pattern

### The Interoperability Question
- Scenes wouldn't be portable between games without the extension
- But actor classes already aren't portable (depend on common.vfx, modules.vfx)
- Each game already has implicit dependencies for its actors

### This is a Valid Pattern Because:

1. **Games Already Have Coupling**
   - Actor scripts assume game-specific properties exist
   - Scripts reference game-specific globals (player0, energy, etc.)
   - Scenes are already tied to their game's actor definitions

2. **Explicit Dependencies Are Good**
   - Including owner-extension.vfx makes dependency clear
   - Can be conditionally included only when needed
   - Easier to debug than hidden core engine behavior

3. **Precedent in VFXLand**
   - Similar to how Spunk extends core systems
   - Games already override/extend base behaviors
   - Method overriding is idiomatic in Forth

4. **Advantages Over Core Integration**
   - No version bump for SCENE_FORMAT_VERSION
   - Existing scenes remain unchanged
   - Can iterate on implementation without affecting engine
   - Other games don't pay for feature they don't use

### Implementation Strategy
```forth
\ supershow/owner-extension.vfx (shared library)
\ or darkblue/owner-extension.vfx (game-specific)

\ Save original methods
scene ' _commit @ constant original-scene-commit  
scene ' _load @ constant original-scene-load

\ Override with owner-aware versions
scene :: _commit ( - )
    build-owner-indices
    original-scene-commit
    clear-owner-indices ;

scene :: _load ( - )
    original-scene-load  
    resolve-owner-references ;
```

### When to Use Option 5 vs Core Integration

**Use Option 5 (Override) when:**
- Feature is experimental or game-specific
- Not all games need it
- Want to iterate quickly
- Backward compatibility is critical

**Use Core Integration when:**
- Feature becomes widely used
- Multiple games need it
- Want single point of truth
- Tool support is important

### Recommendation
Start with Option 5 as a proving ground. If multiple games adopt it, promote to core.
This follows the pattern of "extract shared code when you have 3+ users."

## Implementation Plan - Option 5

### Files to Create/Modify
1. `darkblue/owner-serialization.vfx` - New extension file
2. `darkblue/common.vfx` - Add owner-id property 
3. `darkblue/main.vfx` - Include the extension

### Key Implementation Points
- Save original methods using scene accessor
- Build owner index map during _commit
- Set owner-id properties before serialization
- Clear owner-ids after serialization
- Resolve owner-ids to owner references during _load
- Handle case where owner might not exist in loaded scene