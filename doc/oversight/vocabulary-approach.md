# Vocabulary Approach for Selective Original/Wrapped Word Compilation

## Overview

This approach uses Forth vocabularies to maintain separate namespaces for original and wrapped word implementations. By manipulating the search order, we can selectively compile original vs wrapped versions without touching the original words.

## Core Concept

For every vocabulary containing wrapped words, create a parallel `-WRAPPED` vocabulary:
- `FORTH` → `FORTH-WRAPPED`
- `MYLIB` → `MYLIB-WRAPPED` 
- `ENGINEER` → `ENGINEER-WRAPPED`

Wrapped versions live in the `-WRAPPED` vocabularies, originals remain untouched in their original vocabularies.

## Implementation

### 1. Variable Renaming
```forth
\ Replace current 'validations' variable with clearer names:
variable wrap-colons     \ Controls whether : and ; wrap words with contracts
variable validations     \ Controls search order for original vs wrapped compilation
```

### 2. Vocabulary Management System
```forth
wordlist constant wrapped-vocabs   \ Track wrapped vocabulary pairs

: >wrapped-vocab-name ( addr len -- wrapped-addr wrapped-len )
    \ Convert vocabulary name to wrapped version name
    pad >r
    r@ place
    s" -WRAPPED" r@ +place
    r> count ;

: make-wrapped-vocab ( wid -- wrapped-wid )
    \ Create wrapped vocabulary for given vocabulary
    dup wid>name count >wrapped-vocab-name
    >$ $wordlist
    \ Store the pair for later lookup
    2dup wrapped-vocabs >voc ;

: find-wrapped-vocab ( wid -- wrapped-wid | 0 )
    \ Look up wrapped vocabulary for given original vocabulary
    wrapped-vocabs find-voc ;

: get-wrapped-vocabs ( -- wid1..widn n )
    \ Get all wrapped vocabularies corresponding to current search order
    get-order { wids n }
    0 { wrapped-count }
    
    \ Count wrapped vocabularies that exist
    n for
        iwids [] find-wrapped-vocab if
            wrapped-count 1+ to wrapped-count
        then
    loop
    
    \ Build array of wrapped vocabularies
    wrapped-count cells allocate throw { wrapped-array }
    0 { index }
    
    n for
        i wids [] find-wrapped-vocab ?dup if
            index wrapped-array [] !
            index 1+ to index
        then
    loop
    
    \ Return wrapped vocabularies on stack
    wrapped-count for
        i wrapped-array [] @
    loop
    wrapped-array free throw
    wrapped-count ;
```

### 3. Word Wrapping Strategy
```forth
: wrap-word ( -- <name> )
    {: | original-xt source-wid wrapped-wid c :}
    
    bl preparse 2dup find if        \ Find original word
        execute to original-xt      \ Save original xt
        original-xt wid-of to source-wid \ Get source vocabulary
        
        source-wid find-wrapped-vocab ?dup if
            to wrapped-wid
        else
            source-wid make-wrapped-vocab to wrapped-wid
        then
        
        \ Switch to wrapped vocabulary and create wrapped version
        get-current >r
        wrapped-wid set-current
        
        bl parse >$ $create         \ Create with same name
        does-wrapper
        original-xt ,               \ Store original xt
        bl preparse lookup-contract , \ Store contract
        
        r> set-current              \ Restore compilation vocabulary
    else
        2drop ." Word not found"
    then ;

: current-wrapped-vocab ( -- wid )
    \ Get wrapped vocabulary for current compilation vocabulary
    get-current find-wrapped-vocab ?dup 0= if
        get-current make-wrapped-vocab
    then ;
```

### 4. Search Order Control
```forth
: get-original-order ( -- wid1..widn n )
    \ Get current search order with wrapped vocabularies removed
    get-order { wids n }
    0 { original-count }
    
    \ Count non-wrapped vocabularies
    n for
        i wids [] dup wid>name count 
        s" -WRAPPED" search nip nip 0= if
            original-count 1+ to original-count
        else
            drop
        then
    loop
    
    \ Build original vocabulary array
    original-count for
        \ Find i-th original vocabulary
        0 { found-count }
        n for
            j wids [] dup wid>name count
            s" -WRAPPED" search nip nip 0= if
                found-count i = if
                    \ This is the i-th original vocabulary
                    leave
                else
                    drop
                    found-count 1+ to found-count
                then
            else
                drop
            then
        loop
    loop
    original-count ;

: validations-on ( -- )
    \ Put wrapped vocabularies before originals in search order
    get-original-order              \ Get original vocabularies
    get-wrapped-vocabs             \ Get wrapped versions  
    rot + set-order ;              \ Wrapped vocabs first: FORTH-WRAPPED MYLIB-WRAPPED FORTH MYLIB

: validations-off ( -- )
    \ Use only original vocabularies in search order
    get-original-order set-order ;  \ Just: FORTH MYLIB
```

### 5. Enhanced Colon Definition
```forth
: :: ( -- <word-name> )
    \ Enhanced colon that automatically creates wrapped versions when appropriate
    wrap-colons @ if
        bl preparse lookup-contract if
            \ Contract exists, define in wrapped vocabulary
            current-wrapped-vocab set-current
        then
    then
    : ;
```

### 6. Inspection Tools
```forth
: .wrapped-vocabs ( -- )
    \ Display all wrapped vocabularies and their contents
    cr ." Wrapped vocabularies:"
    wrapped-vocabs >voc
    begin ?dup while
        cr ." === " dup wid>name count type ." ==="
        dup words
        voc>
    repeat ;

: see-original ( -- <word-name> )
    \ Display original version of a word
    validations-off
    ' see
    validations-on ;

: see-wrapped ( -- <word-name> )
    \ Display wrapped version of a word  
    validations-on
    ' see
    validations-off ;
```

## Usage Examples

```forth
\ Setup phase
wrap-colons-on                    \ Enable wrapping new colon definitions

\ Create some contracts and wrap words
before @ test-not-null
wrap-word @

\ Compilation control
validations-off                   \ Search: FORTH MYLIB ...
: test @  ;                      \ Compiles original @

validations-on                    \ Search: FORTH-WRAPPED MYLIB-WRAPPED FORTH MYLIB ...  
: test @  ;                      \ Compiles wrapped @

\ Inspection
.wrapped-vocabs                   \ Show all wrapped vocabularies
see-original @                    \ See original @ definition
see-wrapped @                     \ See wrapped @ definition
```

## Benefits

- **Clean separation**: Original words never touched or redefined
- **Leverage Forth's lookup**: Uses built-in vocabulary search mechanisms
- **Vocabulary-aware**: Automatically works with any vocabulary structure  
- **Search order control**: Simple on/off switching via search order manipulation
- **Inspection friendly**: `words` in each vocabulary shows what's available
- **Scalable**: Automatically handles complex vocabulary hierarchies
- **Portable**: Uses standard Forth vocabulary mechanisms

## Drawbacks

- **Memory overhead**: Duplicate vocabulary structures for each wrapped vocabulary
- **Search order complexity**: More vocabularies in search order may slow word lookup
- **Vocabulary proliferation**: Creates many `-WRAPPED` vocabularies
- **Name collision potential**: If original vocabularies change, wrapped versions may become stale

## Advanced Features

### Automatic Vocabulary Synchronization
```forth
: sync-wrapped-vocab ( original-wid -- )
    \ Ensure wrapped vocabulary contains wrapped versions of all contracted words
    dup find-wrapped-vocab { orig wrapped }
    
    ['] ( lambda: original-word --
        original-word lookup-contract if
            original-word wrapped create-wrapped-version
        then
    ) orig walk-wordlist ;

: sync-all-wrapped-vocabs ( -- )
    \ Synchronize all wrapped vocabularies
    get-order for
        i [] sync-wrapped-vocab
    loop ;
```

This approach provides a clean, Forth-idiomatic solution that scales naturally with complex vocabulary structures while maintaining complete separation between original and wrapped implementations.