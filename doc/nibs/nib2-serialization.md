# NIB2 Serialization System

## Overview

Property-level serialization system for NIB2 objects that generates compact, self-describing binary formats. Properties declare their serialization metadata and global serializers automatically handle type-specific encoding/decoding.

## Basic Usage

### Property Declaration
```forth
class: game-actor
    prop x <int <save
    prop y <int <save  
    256 nprop name <cstring <save
    prop health <int <save
    prop score <fixed <save
    prop temp <int  \ not serialized
class;
```

### Serialization
```forth
\ Serialize object to binary
game-actor object hero
here hero serbin here swap -  \ ( data-addr data-len )

\ Inspect serialized data
data-addr .bin

\ Deserialize from binary
: my-allocator ( len - addr ) allocate throw ;
data-addr ' my-allocator deserbin  \ ( new-object )
```

## Metadata Words

### Type Declarations
- `<int` - 32-bit signed integer
- `<fixed` - 16.16 fixed-point number
- `<float` - IEEE 754 single-precision float
- `<cstring` - counted string (embedded in object)
- `<save` - mark property for serialization

### Usage Pattern
```forth
prop health <int <save      \ serialized integer
prop position <fixed        \ fixed-point, not serialized
static registry             \ static fields cannot be serialized
```

## Binary Format

Self-describing binary format with embedded type information:

```
[class-name-string] [property-name-string] [typed-value] ... [-1 terminator]
```

**Example serialized data:**
```
"GAME-ACTOR" "X" 100 "Y" 200 "NAME" "Hero" "HEALTH" 85 "SCORE" 1250. -1
```

## API Functions

### Core Serialization
- `serbin ( obj - )` - serialize object to dictionary space
- `deserbin ( data allocator-xt - obj )` - deserialize with custom allocator
- `readbin ( data callback-xt - )` - inspect data without instantiation

### Inspection
- `serialize? ( property - flag )` - check if property is serializable
- `.bin ( data - )` - display serialized data in human-readable format

### Utilities
- `temp[ ... temp]` - build temporary data structures
- `$,` - store aligned counted string  
- `$@+` - read counted string and advance pointer
- `file@` - read entire file into allocated memory

## Implementation Notes

### Type-Safe Serialization
Each property type has dedicated serialization functions:
```forth
: bin-ser-int ( - ) val-addr @ , ;
: bin-ser-cstring ( - ) val-addr count $, ;
\ etc...
```

Dispatch tables ensure correct type handling:
```forth
property -> property-type @ cells bin-ser-table + @ execute
```

### Hot-Reload Compatibility
The `current-property` value tracks the property being configured, ensuring metadata words apply correctly during development:
```forth
: nproperty ( size <name> - )
    \ ... property creation or lookup ...
    dup to current-property  \ metadata words operate on this
    \ ...
```

### Memory Management
- Serialization builds data in dictionary space (no allocation)
- Deserialization requires custom allocator for object creation
- File I/O utilities handle memory allocation/deallocation automatically

## Error Handling

### Validation Checks
- Unknown class names during deserialization abort with clear messages
- Invalid property references caught during deserialization
- Metadata words validate `current-property` is set
- Type mismatches detected through property-type validation

### Debugging Support
The `.bin` inspection function provides readable output for debugging serialized data without requiring deserialization.