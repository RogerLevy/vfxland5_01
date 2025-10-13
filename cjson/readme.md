# cJSON Wrapper for VFX Forth

Provides Forth words that wrap the cJSON C library, handling the STDCALL calling convention and making the API more Forth-friendly.

## Parsing JSON

```forth
\ Parse from string
s" {\"name\":\"player\",\"health\":100}" parse-json  \ ( a len -- cjson )

\ Parse from file
s" data.json" file@ parse-json  \ ( -- cjson )
```

## Reading Fields

**Strings:**
```forth
z" name" cjson get-string       \ ( zkey cjson -- addr len )
type                             \ prints value
```

**Numbers:**
```forth
z" health" cjson get-int         \ ( zkey cjson -- n )
z" pi" cjson get-float           \ ( zkey cjson -- f:n )
z" position" cjson get-fixed     \ ( zkey cjson -- p ) for 16.16 fixed-point
```

**Objects and arrays:**
```forth
z" player" cjson get-object      \ ( zkey cjson -- cjson )
z" actors" cjson get-array       \ ( zkey cjson -- cjson )
```

**Generic field access:**
```forth
z" health" cjson get-field       \ ( zkey cjson -- cjson ) returns item for any type
get-string-content               \ ( cjson -- addr len ) extract string value from item
```

## Working with Arrays

```forth
\ Get array and its length
z" actors" cjson count-array     \ ( zkey cjson -- cjson-array length )

\ Access array element by index
0 array get-item                 \ ( n cjson-array -- cjson ) get first element

\ Iterate through array
z" actors" cjson count-array for
    i over get-item              \ get i-th element
    z" name" over get-string type cr
loop drop
```

## Creating JSON

**Objects:**
```forth
create-cjson                     \ ( -- cjson ) new empty object
z" Alice" z" name" obj add-string
100 z" health" obj add-int
3.14e0 z" pi" obj add-float
5.5 z" x" obj add-fixed          \ for 16.16 fixed-point
```

**Nested objects:**
```forth
create-cjson value inner
z" data" z" field" inner add-string

create-cjson value outer
inner z" nested" outer add-object
```

**Arrays:**
```forth
create-array value arr
z" Alice" create-string 0 arr add-item   \ 0 for arrays (no key)
z" Bob" create-string 0 arr add-item
arr z" names" obj add-array
```

## Serialization

```forth
\ Print and free in one step
cjson cjson.                     \ ( cjson -- ) prints formatted JSON

\ Get serialized string
cjson serialize-cjson            \ ( cjson -- heap-zstr len )
\ ... use the string ...
free-cjson                       \ ( heap-zstr -- ) free the serialized string

\ Write directly to file
s" output.json" serjson>
    >r
    z" value" z" key" r@ add-string
    123 z" number" r@ add-int
    r> drop ;
```

## Cleanup

```forth
delete-cjson                     \ ( cjson -- ) free the cJSON object tree
```

## Type Checking

```forth
cjson get-type                   \ ( cjson -- type )
cjson is-array?                  \ ( cjson -- flag )
```

Type constants: `cJSON_Invalid`, `cJSON_False`, `cJSON_True`, `cJSON_NULL`, `cJSON_Number`, `cJSON_String`, `cJSON_Array`, `cJSON_Object`

## Key Design Notes

- All keys must be null-terminated strings (use `z"` or equivalent)
- `add-*` words for arrays take `0` instead of a key: `( value 0 array -- )`
- `add-*` words for objects take a key: `( value zkey object -- )`
- `serialize-cjson` returns heap-allocated string that must be freed with `free-cjson`
- `cjson.` is a convenience word that prints and frees the serialized string
- `get-item` works for both arrays (pass index) and objects (pass key)

## Complete Example

```forth
\ Create a player character
create-cjson value player
z" Warrior" z" class" player add-string
100 z" hp" player add-int
50 z" x" player add-int
25 z" y" player add-int

\ Print it
player cjson. cr

\ Save to file
s" player.json" serjson>
    >r
    z" Warrior" z" class" r@ add-string
    100 z" hp" r@ add-int
    50 z" x" r@ add-int
    25 z" y" r@ add-int
    r> drop ;

\ Clean up
player delete-cjson
```
