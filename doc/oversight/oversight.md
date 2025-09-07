# Oversight Documentation

Oversight is a contract-oriented debugging system for VFXLand5 providing automatic validation and self-healing capabilities with zero runtime overhead when disabled.

## Overview

Oversight allows you to attach validation logic to any Forth word without modifying the word's definition. Validations can detect problems, warn about issues, or automatically fix data before passing it to the target word.

## Key Features

- **Automatic wrapping**: Words with contracts get wrapped transparently when defined
- **Self-healing**: Validators can automatically correct invalid data
- **Zero syntax overhead**: Contracted words look and behave like normal words
- **Clean separation**: Validation logic separate from business logic
- **Performance**: No runtime overhead when validations pass
- **Interactive development**: Redefined words automatically maintain validation

## Basic Usage

### 1. Define a Validator

```forth
crucial test: is-non-zero ( n -- n n:result )
    dup 0<> ;  \ Returns -1 (pass) if non-zero, 0 (fail) if zero
```

Validators return result codes:
- `-1` = success, continue normally
- `0` = failure, throw exception  
- `1` = failure, warn but continue

### 2. Attach Validator to Word (Convenient Syntax)

```forth
before / is-non-zero drop    \ Attach to division operator
```

### 3. Define or Redefine Target Word

```forth
\ For new words, just define normally:
: my-divide / ;         \ Gets wrapped automatically

\ For existing words, use wrap-word:
wrap-word /             \ Wraps existing division operator
```

### 4. Use Contracted Word

```forth
10 2 /     \ Works normally: 5
10 0 /     \ Throws exception: "IS-NON-ZERO failed (THROW)"
```

## Validation Types

### Crucial Validations
Essential safety checks that catch real bugs:

```forth
crucial test: check-non-null ( addr -- addr n:result )
    dup 0<> ;  \ Non-null pointer check

crucial test: check-array-bounds ( n array -- n array n:result )  
    2dup [] drop -1 ;  \ Let [] do the bounds checking
```

### Charmful Validations  
Non-critical checks for artistic concerns:

```forth
charmful test: reasonable-volume ( n -- n n:result )
    dup 0 100 within? else-warn ;  \ Warn if volume outside 0-100

charmful test: performance-hint ( n -- n n:result )
    dup 1000 > if s" Large iteration count" log-info then -1 ;
```

**Result Modifiers:**
- `else-warn` - Converts failure (0) to warning (1), allowing execution to continue
- Used when condition failure should generate warning instead of exception

## Self-Healing Validators

Validators can automatically fix problems using the `fix?` word:

```forth
crucial test: clamp-index ( n array -- n array n:result )
    {: n arr :}
    n arr max-items 0 swap within? 
    fix? if
        n arr max-items 1- 0 clamp to n  \ Clamp to valid range
        -1                               \ Return success
    then
    >r n arr r> ;

clamp-index before []
```

**Self-Healing Process:**
1. `fix?` detects validation failure (result >= 0)
2. On first failure, `fix?` returns true and sets recheck flag
3. Validator executes fix code (clamp index to valid range)
4. Return `-1` to indicate successful fix
5. System outputs: "clamp-index performing self-fix..."

**Important:** `fix?` and `else-warn` are independent concepts:
- `fix?` - Enables automatic data correction on failure
- `else-warn` - Converts throw (0) to warning (1) without fixing data

## Control System

### Two-Level Control

```forth
\ 1. Compile-time wrapping control
validations on                 \ Enable automatic word wrapping
validations off                \ Disable wrapping of new definitions

\ 2. Runtime execution control  
safety on                     \ Enable both crucial and charmful validations
safety off                    \ Disable all validation execution (zero overhead)
crucial safety !              \ Enable only crucial validations
charmful safety !             \ Enable only charmful validations
```

**Control Variable Details:**
- `validations` - Controls whether new `:` definitions get automatically wrapped
- `safety` - Bitfield controlling which validation types execute at runtime
- Use `validations off` during development to avoid wrapping temporary words
- Use `safety off` in production to disable all validation overhead
- Use `crucial safety !` to run only essential safety checks

## Usage Patterns

### Pattern 1: New Words

```forth
\ 1. Define validator
crucial test: positive-only ( n -- n n:result )
    dup 0> ;

\ 2. Attach to future word  
before set-health positive-only drop

\ 3. Define word (gets wrapped automatically)
: set-health ( n player -- )
    's health ! ;
```

### Pattern 2: Existing Core Words

```forth
\ 1. Define validator
crucial test: null-check ( addr -- addr n:result )
    dup 0<> ;

\ 2. Attach to existing word
before @ null-check drop

\ 3. Wrap the existing word
wrap-word @

\ Now all @ operations are validated
```

### Pattern 3: Game-Specific Safety

```forth
\ Array bounds checking
crucial test: safe-array-access ( n array -- n array n:result )
    2dup check-array-bounds ;

before [] safe-array-access drop
wrap-word []

\ All array access now validated:
5 my-array []  \ Safe
99 my-array [] \ Throws if out of bounds
```

### Pattern 4: Performance Monitoring

```forth
charmful test: expensive-operation ( data -- data n:result )
    dup size 1000 > if
        s" Large dataset processed" log-info
    then -1 ;

before complex-algorithm expensive-operation drop
wrap-word complex-algorithm
```

### Pattern 5: Performance-Critical Sections

For selective validation control within single word definitions:

```forth
\ Disable validations for hot code blocks
validations off
: fast-loop ( n - )
  for i @ i 1+ ! loop ;
validations on

\ Within a single word definition
: word
  some code
  [ validations off ]
  some performance-critical code
  [ validations on ]
  some more code ;
```

This pattern allows you to disable validation compilation for specific code sections that are performance-critical and presumably already tested and solid.

## File Organization

### Recommended Structure

```
project/
├── src/
│   ├── game.vfx           # Pure business logic
│   ├── player.vfx         # Pure business logic
│   └── weapons.vfx        # Pure business logic
└── validation/
    ├── game-safety.vfx    # Safety validations  
    ├── player-checks.vfx  # Player data validation
    └── weapon-balance.vfx # Game balance checks
```

### Loading Order

```forth
\ Load validations first
include validation/game-safety.vfx
include validation/player-checks.vfx

\ Then load business logic (gets wrapped automatically)
include src/game.vfx
include src/player.vfx
```

## Advanced Features

### Stack-Based Attachment

For dynamic contract creation:

```forth
' my-validator s" target-word" >before drop  \ Precondition
' my-validator s" target-word" >after drop   \ Postcondition
```

### Single Validation Per Position

Each word can have one pre-validation and one post-validation:

```forth
before @ check-fetch-address drop
after @ log-fetch-complete drop
wrap-word @
```

### Validation with Warnings

```forth
crucial test: size-warning ( n -- n n:result )
    dup 1000000 > if
        s" Very large allocation" log-warning
        1  \ Return warning code
    else
        -1 \ Return success
    then ;
```

## Debug Output

The system provides detailed debug output with stack traces:

```
[ERROR] check-fetch-address : @ failed (THROW)
Data stack: 0 1234 5678
bottom-word > calling-word > @ > top-word
[WARN] check-sample-index : play failed (OK)
Data stack: -1 5
bottom-word > calling-word > play > top-word
[INFO] check-bounds-with-fix performing self-fix...
```

**Error Output Includes:**
- **Validation name**: Which check failed  
- **Calling word**: What word triggered the validation
- **Failure type**: (THROW) for exceptions, (OK) for warnings
- **Data stack**: Current stack contents for debugging
- **Return stack trace**: Automatically shown for both failures and warnings

**Note**: Stack traces are automatically included for all validation failures, whether they throw exceptions (result = 0) or continue with warnings (result = 1).

### Debug Messages

Add custom debug messages that print when words execute:

```forth
say-before my-word Entering calculation phase
say-after my-word Calculation complete

\ Usage: word executes normally, but prints:
\ [DEBUG] Entering calculation phase
\ ... word executes ...
\ [DEBUG] Calculation complete
```

**Syntax:**
- `say-before <word-name> <message...>` - Message before word execution
- `say-after <word-name> <message...>` - Message after word execution
- Messages are printed only when `charmful` validations are enabled
- Useful for tracing execution flow and timing analysis

## System Integration

### Initialization

```forth
include engineer/debug/oversight.vfx
include engineer/debug/core-checks.vfx
init-oversight              \ Initialize Oversight system
```

### Control Configuration

```forth
validations on              \ Enable automatic word wrapping
safety on                   \ Enable both crucial and charmful validations
\ or:
crucial safety !            \ Enable only crucial validations
charmful safety !           \ Enable only charmful validations
crucial charmful or safety ! \ Enable both types explicitly
```

### Shutdown

```forth
shutdown-oversight          \ Clean up (optional)
```

## Performance Notes

- **Zero overhead** when validations are disabled
- **Minimal overhead** when validations pass (single comparison)
- **Self-healing** happens only on failure, no performance impact normally
- **Compilation-time** wrapping, no runtime dispatch

## Best Practices

1. **Define contracts before words** - Required for automatic wrapping
2. **Use crucial for safety** - Memory safety, bounds checking, null pointers
3. **Use charmful for quality** - Performance hints, game balance, artistic concerns
4. **Keep validators simple** - Complex logic should be factored out
5. **Test self-healing** - Ensure fixes actually work as intended
6. **Organize by domain** - Group related validations in separate files

## Common Patterns

### Memory Safety
```forth
crucial test: non-null ( addr -- addr n:result )
    dup 0<> ;

before @ non-null drop
before ! non-null drop
before c@ non-null drop
before c! non-null drop
wrap-word @
wrap-word !
wrap-word c@
wrap-word c!
```

### Array Safety  
```forth
crucial test: array-bounds ( n array -- n array n:result )
    over 0>= over max-items 0 swap within? and ;

before [] array-bounds drop
wrap-word []
```

### Arithmetic Safety
```forth
crucial test: no-divide-zero ( n1 n2 -- n1 n2 n:result )
    dup 0<> ;

before / no-divide-zero drop
before mod no-divide-zero drop
wrap-word /
wrap-word mod
```

This contract system provides robust validation capabilities while maintaining the clean, efficient nature of Forth code.