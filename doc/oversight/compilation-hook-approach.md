# Compilation Hook Approach for Selective Original/Wrapped Word Compilation

## Overview

This approach intercepts VFX Forth's compilation mechanism at the lowest level by overriding the deferred words `compile,` and `ndcs,`. This allows selective compilation of original vs wrapped word implementations based on the `validations` flag.

## VFX Forth Compilation Mechanism

From `/mnt/c/Users/roger/Dev/VfxForth/Kernel/Common/kernel.fth`:

```forth
defer Compile,          \ xt --                         6.2.0945
defer ndcs,            \ xt --
: compile-word         \ i*x xt -- j*x
  dup ndcs?            \ NDCS or normal
  if  ndcs,  else  compile,  then
;
```

- `compile-word` checks if a word has NDCS (non-default compilation semantics)
- If NDCS: calls `ndcs,` (deferred)  
- If normal: calls `compile,` (deferred)

## Implementation

### 1. Variable Renaming
```forth
\ Replace current 'validations' variable with clearer names:
variable wrap-colons     \ Controls whether : and ; wrap words with contracts
variable validations     \ Controls whether compiled words use original or wrapped versions
```

### 2. Save Original Deferred Actions
```forth
' compile, defer@ constant orig-compile,
' ndcs, defer@ constant orig-ndcs,
```

### 3. Original-Word Storage System
```forth
wordlist constant originals-wl

: save-original ( xt -- )
    \ Save original XT in special wordlist during wrapping
    dup >name count
    get-current >r originals-wl set-current
    nextname create ,
    r> set-current ;

: find-original ( xt -- orig-xt | xt )
    \ Look up original version if validations off
    validations @ if
        \ Use wrapped version as-is
    else
        \ Try to find original
        dup >name count originals-wl search-wordlist if
            nip execute @
        then
    then ;
```

### 4. Override Compilation Behavior
```forth
: oversight-compile, ( xt -- )
    find-original orig-compile, execute ;

: oversight-ndcs, ( xt -- )
    find-original orig-ndcs, execute ;

: enable-oversight-compilation ( -- )
    ['] oversight-compile, is compile,
    ['] oversight-ndcs, is ndcs, ;

: disable-oversight-compilation ( -- )
    orig-compile, is compile,
    orig-ndcs, is ndcs, ;
```

### 5. Enhanced Control Words
```forth
: validations-on ( -- )
    validations on
    enable-oversight-compilation ;

: validations-off ( -- )
    validations off
    disable-oversight-compilation ;

: wrap-colons-on ( -- )
    wrap-colons on
    \ Enable contract wrapping in : and ; redefinitions
    ;

: wrap-colons-off ( -- )
    wrap-colons off
    \ Disable contract wrapping in : and ; redefinitions
    ;
```

### 6. Update Wrapping System
Modify the existing wrapping mechanism to call `save-original` before creating wrapped versions:

```forth
: wrap-word ( -- <name> )
    {: | c original-xt :}
    bl preparse 2dup find if 
        execute dup to original-xt
        save-original          \ Save before wrapping
    else
        2drop 0 to original-xt
    then
    
    lookup-contract-current to c
    c if
        \ Create wrapped version with existing logic
        :noname
        original-xt compile,   \ Compile call to original
        postpone ;
        bl parse >$ $create
        does-wrapper
        , c ,
    else
        cr bl parse f" Contract for %s not found, wrapping skipped." log-warning
    then ;
```

## Usage Examples

```forth
\ Development mode - wrap new definitions and use wrapped versions
wrap-colons-on
validations-on

\ Production compilation - no new wrapping, but use wrapped versions  
wrap-colons-off
validations-on

\ Performance testing - no new wrapping, use original versions
wrap-colons-off
validations-off

: my-word @ ;              \ With validations-off: compiles original @
                          \ With validations-on: compiles wrapped @
```

## Benefits

- **Low-level interception**: Works at VFX Forth's compilation core
- **Zero runtime overhead**: When validations-off, original code executes
- **Transparent**: No changes to existing word lookup mechanisms
- **Selective**: Fine-grained control over wrapping vs compilation behavior

## Drawbacks

- **VFX Forth specific**: Relies on VFX Forth's deferred compilation words
- **Storage overhead**: Requires separate storage for original XTs
- **Complexity**: Additional lookup mechanism during compilation