# Path System Easing Enhancements

## Overview

The VFXLand5 path system already supports sophisticated easing through a dual-path approach where an "easing path" controls progress through the main journey path. However, the current DSL can be improved to make the system more intuitive and flexible.

## Current System Analysis

The existing easing system works by:
1. Taking raw time-based progress (0-1.0)
2. Mapping it through easing segments to get adjusted progress
3. Using this adjusted progress to traverse the main journey path

The current DSL uses `waypoint` with duration values, but internally converts these to progress proportions by dividing against the journey's total duration.

## Enhancement: Progress-Based Easing

### The `progress` Word

A new word `progress` makes the DSL more explicit about specifying journey progress rather than absolute time.

```forth
: progress ( factor. - segment )
    journey-total-duration p* waypoint ;
```

#### Usage Example

```forth
easing[
    0.0 progress                              \ start at 0%
    0.3 progress 2 ease 0.8 0.2 strength     \ 30% through journey  
    0.5 progress 1 ease 0.2 0.5 strength     \ 50% through journey
    1.0 progress 2 ease 0.5 0.8 strength     \ 100% (complete)
easing]
```

#### Benefits

- **Explicit intent**: Clear that you're specifying journey progress, not absolute time
- **Proportional thinking**: Natural to think "halfway through" = 0.5
- **Journey-independent**: Same easing definition works regardless of journey duration
- **Maintains sync**: Still uses the same underlying duration-based system

## Enhancement: Segment Synchronization

### The `segsync` Word

Automatically sync easing segments with journey segment boundaries without manual duration calculation.

```forth
: segsync ( n - segment )
    {: target-seg# | current-journey-seg# :}
    
    \ Calculate current journey segment position
    current-easing-segments-consumed-duration 
    journey-path total-duration p/ 
    journey-path leg drop to current-journey-seg#
    
    \ Auto-advance if target is not in future
    target-seg# current-journey-seg# <= if
        nextsync
    else
        target-seg# (do-segsync)
    then ;
```

### The `nextsync` Word

Convenience word for syncing to the next journey segment.

```forth
: nextsync ( - segment )
    current-journey-seg# 1+ (do-segsync) ;
```

### Helper Implementation

```forth
: seg-cumulative-duration ( seg# path - ms )
    >segments 0 swap seg# 1+ for i [] 's seg-duration @ + loop ;

: current-easing-segments-consumed-duration ( - ms )
    \ Calculate total duration of easing segments created so far
    \ (Implementation depends on how easing segments are tracked during creation)
    ;

: (do-segsync) ( target-seg# - segment )
    {: target-seg# | target-cumulative consumed-so-far needed-duration :}
    
    \ Calculate target boundary time
    target-seg# journey-path seg-cumulative-duration to target-cumulative
    
    \ Calculate how much easing time we've used so far
    current-easing-segments-consumed-duration to consumed-so-far
    
    \ Set this segment's duration to bridge the gap
    target-cumulative consumed-so-far - to needed-duration
    needed-duration waypoint ;
```

#### Usage Examples

```forth
easing[
    0.0 progress
    1 segsync 2 ease 0.8 0.2 strength    \ sync to segment 1 boundary
    1 segsync 1 ease 0.2 0.5 strength    \ already past seg 1, auto-becomes nextsync
    nextsync  2 ease 0.5 0.8 strength    \ explicitly sync to next segment
    5 segsync 1 ease 0.1 0.9 strength    \ sync way ahead to segment 5
easing]
```

#### Benefits

- **Non-destructive**: Doesn't modify previous segments
- **Mixable**: Can combine with `waypoint`, `progress`, and sync words freely
- **Foolproof**: Can't accidentally sync to past segments (auto-advances)
- **Convenient**: `nextsync` for the common case, `segsync N` for jumping ahead

## Mixed Usage Example

All three approaches can be combined in a single easing definition:

```forth
easing[
    0.0 progress                              \ explicit progress start
    500 waypoint 2 ease 0.8 0.2 strength     \ normal duration-based
    0.3 progress 1 ease 0.2 0.5 strength     \ progress-based
    2 segsync 2 ease 0.5 0.8 strength        \ sync to journey segment 2
    nextsync 1 ease 0.1 0.9 strength         \ sync to next segment
    1.0 progress 2 ease 0.2 0.7 strength     \ explicit end
easing]
```

This flexibility allows the most appropriate method to be used for each part of the easing curve while maintaining the elegant synchronization guarantees of the existing system.