# Path System Waypoint Transitions

## Problem Statement

The current path system creates noticeable abrupt speed changes at waypoints because each segment uses independent easing curves that don't consider velocity at segment boundaries. This creates visible "jerks" in motion when segments transition.

**Example of the problem:**
```forth
segments[
    1.0 waypoint 2 ease 0.8 0.2 strength  \ ends with low velocity (ease-out)
    0.8 waypoint 1 ease 0.8 0.2 strength  \ starts with low velocity (ease-in)
segments]
```

Even though both segments have low velocity at the boundary, the transition isn't smooth because the acceleration profiles don't match.

## Solution: Transition Zones with `shave`

Instead of trying to solve this mathematically in the playback mechanism, we add explicit transition segments that bridge between waypoints with guaranteed smooth velocity transitions.

### The `shave` Word

The `shave` word creates transition segments that interpolate smoothly between the exit velocity of the previous segment and the entry velocity of the next segment.

```forth
: shave ( proportion. - )
    \ Creates or modifies a transition segment
    \ Proportion is relative to the previous waypoint's duration
```

### Automatic Smooth Transitions

All waypoints automatically create reasonable transition segments (e.g., 10% of their duration). Users can override this behavior:

```forth
segments[
    1.0 waypoint 2 ease 0.8 0.2 strength     \ auto-creates ~0.1s transition
    0 shave                                   \ override: hard transition
    0.8 waypoint 1 ease 0.8 0.2 strength     \ auto-creates ~0.08s transition
    0.3 shave                                 \ override: 30% of 0.8s = 0.24s transition
    0.6 waypoint 2 ease 0.5 0.5 strength     \ auto-creates ~0.06s transition
segments]
```

## Implementation Strategy

### Stub Segment Approach

Due to forward-parsing limitations (can't read ahead to segments that haven't been defined), we use a stub segment approach:

```forth
: waypoint ( secs. - segment ) 
    1000 p* to duration-ms  \ Convert seconds to milliseconds internally
    
    \ Calculate automatic transition duration
    duration-ms 0.1 * to auto-transition-duration
    duration-ms auto-transition-duration - to actual-waypoint-duration
    
    \ Create the actual waypoint segment
    (create-waypoint-segment actual-waypoint-duration)
    
    \ Create 0-length transition stub for next segment to fill
    (create-transition-stub)
;

: shave ( proportion. - )
    last-waypoint-created-transition? @ if
        \ Modify the existing transition segment
        last-transition-segment modify-transition-duration
    else
        \ Create new transition segment
        (create-transition-segment)
    then ;

: segments] ( - )
    \ Fill in all transition stubs with proper durations
    \ Leave the final 0-length stub - it's harmless
    fill-transition-stubs
    array] segments ! ;
```

### Transition Segment Properties

Transition segments have a special type `SEG_TRANSITION` and automatically calculate:
- **Entry velocity**: From the exit velocity of the previous waypoint segment
- **Exit velocity**: To match the entry velocity of the next waypoint segment  
- **Control points**: Smooth interpolation (cubic or hermite) between these velocities

### Duration Management

The transition duration is "stolen" from the current waypoint segment:
```forth
1.0 waypoint with 0.1 shave becomes:
- 0.9 secs waypoint segment (actual movement)
- 0.1 secs transition segment (smooth velocity change)
```

This makes the total specified duration predictable and self-contained.

## Benefits

1. **Smooth by default**: Artists don't need to think about transitions
2. **Artistic control**: Choose exactly where and how long transitions should be
3. **Intuitive**: "I want a 0.2s smooth transition here"
4. **Optional**: Can omit for sharp direction changes when desired (`0 shave`)
5. **Proportional timing**: Scales naturally with segment duration
6. **Predictable**: Total path time = sum of waypoint times
7. **Simple implementation**: Uses existing playback mechanisms

## Boundary Handling

- **First segment**: No transition at beginning (nothing to transition from)
- **Last segment**: 0-length stub transition (harmless, effectively invisible)
- **Middle segments**: Transition at end bridges to next segment

## Zero-Length Stub Segments

The final waypoint creates a 0-length transition stub that remains in the array. This is harmless because:
- **0 secs duration**: No time spent in the segment
- **Bezier evaluation**: At t=0, returns the waypoint position
- **Velocity**: Zero contribution to overall path velocity
- **Arc-length**: Zero length, no impact on parameterization

## Example Usage

```forth
path[
  segments[
    1.0 waypoint 10.0 5.0 30.0 15.0 curve 2 ease 0.5 0.8 strength
    0.2 shave                                 \ 20% of 1.0 secs = 0.2 secs transition
    0.8 waypoint -5.0 -10.0 20.0 0.0 curve 1 ease 0.3 0.6 strength
    0 shave                                   \ hard transition
    1.2 waypoint 0.0 0.0 -10.0 -5.0 curve 2 ease 0.4 0.7 strength
  segments]
path]
```

This creates a path with smooth transitions where specified and sharp changes where desired, giving artists full control over the motion quality while providing smooth defaults.