# OEXEC Enhancement Ideas

## Overview
`oexec` is a safe execution wrapper for object methods that provides error handling and recovery. The current implementation uses a protocol-based error handler system with conditional compilation for debug vs release builds.

## Current Implementation
- Debug builds: Full error catching with protocol-based handler
- Release builds: Direct execution via `>r` for maximum performance
- Error handler called via defer: `(on-exec-error)`

## Potential Enhancements

### 1. Stack Protection for Error Handlers
Protect against stack corruption in error handlers themselves:

```forth
: oexec ( ... xt - ... )
    ?dup -exit
    {: xt | depth0 :}
    depth to depth0
    xt catch ?dup if
        depth to depth0  \ Capture stack depth at error
        xt swap ['] (on-exec-error) catch if
            \ Error handler itself failed!
            cr ." OEXEC: Error handler failed!" 
            depth depth0 <> if
                cr ." Stack corrupted, resetting..."
                depth0 set-depth  \ Reset to original depth
            then
            throw  \ Re-throw original error
        then
    then ;
```

**Benefits**: Prevents cascade failures, maintains system stability
**Cost**: Additional overhead, complexity

### 2. Optional Retry Logic
Handle transient errors with automatic retry:

```forth
0 value oexec-retries  \ Max retry count

: oexec ( ... xt - ... )
    ?dup -exit
    {: xt | retries :}
    oexec-retries to retries
    begin
        xt catch ?dup if
            retries 0> if
                1 -to retries
                dup recoverable-error? if
                    drop false  \ Try again
                else
                    xt swap (on-exec-error)
                    true  \ Done
                then
            else
                xt swap (on-exec-error)
                true
            then
        else
            true  \ Success
        then
    until ;
```

**Benefits**: Automatic recovery from temporary failures
**Cost**: Potential for infinite loops if not carefully controlled

### 3. Performance Optimization Variants
Multiple implementations for different scenarios:

```forth
\ Hot path version - minimal overhead
: oexec-fast ( xt - ) ?dup -exit execute ;

\ Safe version - full error handling
: oexec-safe ( xt - )
    ?dup -exit
    {: xt :}
    xt catch ?dup if
        xt swap (on-exec-error)
    then ;

\ Debug version - with tracing
: oexec-debug ( xt - )
    ?dup -exit
    {: xt :}
    cr ." OEXEC: " xt .name ."  on " me .name
    xt catch ?dup if
        cr ." Error: " dup .
        xt swap (on-exec-error)
    then ;
```

**Benefits**: Choose appropriate version per use case
**Cost**: Code duplication, maintenance overhead

### 4. Nested Context Preservation
Handle nested oexec calls properly:

```forth
variable oexec-depth
variable oexec-context  \ Could store current actor, state, etc.

: oexec ( ... xt - ... )
    ?dup -exit
    {: xt | saved-context saved-depth :}
    oexec-context @ to saved-context
    oexec-depth @ to saved-depth
    me oexec-context !
    1 oexec-depth +!
    
    xt catch ?dup if
        xt swap (on-exec-error)
    then
    
    saved-context oexec-context !
    saved-depth oexec-depth ! ;
```

**Benefits**: Proper error attribution in complex call chains
**Cost**: Memory overhead for context storage

### 5. Conditional Execution Based on Object State
Skip execution for invalid/disabled objects:

```forth
: oexec ( ... xt - ... )
    ?dup -exit
    me valid-object? not if drop exit then
    me 's enabled @ not if drop exit then  \ If object has enabled flag
    {: xt :}
    xt catch ?dup if
        xt swap (on-exec-error)
    then ;
```

**Benefits**: Prevents errors from invalid objects
**Cost**: Additional checks per call

### 6. Trace/Debug Support
Execution history for debugging:

```forth
create oexec-trace 256 cells allot
variable oexec-trace-ptr
variable oexec-trace-on

: oexec-traced ( ... xt - ... )
    ?dup -exit
    {: xt :}
    oexec-trace-on @ if
        xt oexec-trace oexec-trace-ptr @ cells + !
        1 oexec-trace-ptr +!
        oexec-trace-ptr @ 256 = if
            0 oexec-trace-ptr !  \ Wrap around
        then
    then
    xt catch ?dup if
        cr ." OEXEC Error in: " xt .name
        ."  Object: " me .
        ."  Error: " dup .
        xt swap (on-exec-error)
    then ;

: .oexec-trace ( - )
    cr ." Recent oexec calls:"
    oexec-trace-ptr @ 0 ?do
        i oexec-trace swap cells + @ ?dup if
            cr i . ." : " .name
        then
    loop ;
```

**Benefits**: Post-mortem debugging capability
**Cost**: Memory for trace buffer, performance overhead

### 7. Protocol Return Value Convention
Allow error handlers to control recovery:

```forth
: oexec ( ... xt - ... )
    ?dup -exit
    {: xt :}
    xt catch ?dup if
        xt swap (on-exec-error)  ( - flag )
        \ Handler returns: 
        \   0 = error handled, continue
        \  -1 = rethrow error
        \   1 = error logged, continue
        case
            -1 of throw endof
             0 of endof
             1 of endof
        endcase
    then ;
```

**Benefits**: Flexible error recovery strategies
**Cost**: Protocol complexity

### 8. Statistical Monitoring
Track execution patterns:

```forth
variable oexec-calls
variable oexec-errors

: oexec-stats ( ... xt - ... )
    ?dup -exit
    1 oexec-calls +!
    {: xt :}
    xt catch ?dup if
        1 oexec-errors +!
        xt swap (on-exec-error)
    then ;

: .oexec-stats ( - )
    cr ." OEXEC Statistics:"
    cr ."   Total calls: " oexec-calls @ .
    cr ."   Errors: " oexec-errors @ .
    cr ."   Success rate: " 
    oexec-calls @ ?dup if
        oexec-calls @ oexec-errors @ - 100 * 
        oexec-calls @ / . ." %"
    else
        ." N/A"
    then ;
```

**Benefits**: Performance monitoring, reliability metrics
**Cost**: Counter overhead

## Implementation Priorities

### High Priority (Recommended)
1. **Stack Protection** - Critical for stability
2. **Debug Tracing** - Essential for development
3. **Nested Context** - Important for complex systems

### Medium Priority
4. **Conditional Execution** - Useful for robust systems
5. **Return Value Convention** - Flexible error handling

### Low Priority
6. **Retry Logic** - Situational benefit
7. **Statistics** - Nice to have for monitoring

## Performance Considerations

The current dual-implementation approach (debug vs release) is excellent. Additional features should follow this pattern:

```forth
debug @ [if]
    \ Full featured version
[else]
    \ Minimal overhead version
[then]
```

## Testing Strategy

Each enhancement should include:
1. Unit tests for normal operation
2. Error injection tests
3. Performance benchmarks
4. Stack balance verification
5. Nested call scenarios

## Migration Path

1. Start with current simple implementation
2. Add stack protection in debug builds
3. Gradually add features based on actual needs
4. Keep release builds minimal unless issues arise in production