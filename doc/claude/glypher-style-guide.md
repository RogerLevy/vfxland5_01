# Reading and Writing Actor Behavior in Glypher Style

## Philosophy

Glypher style treats code as **prose written in symbolic shorthand**. Each word represents a complete concept that you understand "from the heart" rather than parse analytically. The visual weight of large, colorful text activates nurturing instincts - you care for each word like tending individual entities.

The constraints force aggressive factoring: there is no room for waste of brain cells or screen real estate. You HAVE to focus on the meat of the topic with NO distractions.

## Reading Strategy

### 1. Two-Direction Reading

**Top-down**: Scan for concept inventory to get the broad story
**Bottom-up**: Read each definition left-to-right, referencing unknown words

### 2. Story First, Technicals Second

Get a feel for the narrative being told, then verify the implementation details. Think of punctuation as abbreviations, not categorical patterns:
- `?` means "question" 
- `>` means "to"
- `!` means "store"
- `/` means "init"

### 3. Complete Thoughts

Each line should express a complete behavioral concept. Read the entire sentence to understand what the actor "does," then break it down into constituent parts.

## Writing Strategy

### 1. Start With the Story

Write a single sentence describing what your actor does:
*"A turret smoothly aims at targets, charges weapons, fires automatically or manually, orbits around its owner, and provides visual feedback."*

### 2. Factor Into Concepts

Break the sentence into conceptual chunks, each worthy of its own word:
- "smoothly aims" → `?aim`
- "charges weapons" → `?charge` 
- "fires peas" → `?pea`
- "orbits owner" → `!pos`
- "visual feedback" → `!bmp`

### 3. Write the Definition

Express the complete behavior in a single line:
```forth
turret% :: init act> ?aim ?charge ?pea !ang !pos !bmp !bars ;
```

### 4. Define Each Word

Each word gets its own definition that tells a mini-story:
```forth
: ?pea   <shoot> pressed? -; automatic @ if /auto else 1 pea then ;
: !ang   a @ p>f aim @ p>f 0.2e alerp f>p a ! ;
: !pos   >owner spinfix ?shake ;
```

## Key Principles

### Aggressive Factoring
If you can't fit the concept on one line at large font size, it needs to be factored. Every concept must earn its own word.

### Minimal Stack Passing
Avoid complex stack manipulation. Most words should be self-contained behaviors. When stack items are needed, make it obvious:
```forth
: adhere  [[ x 2@ vx 2@ 2+ ]] x 2! ;  \ takes owner from stack
```

### Complete Concepts
Each word should represent a complete thought:
- `?shake` - "question: should I shake?"
- `!bmp` - "store: update my bitmap"
- `>owner` - "to: my owner"

### Natural Execution Order
Don't artificially "reverse" anything. Write in the order that makes sense for the story. The stack-based execution will handle data flow naturally.

### Visual Clarity
At large font sizes, every word must be immediately meaningful. Abbreviations should be intuitive. Complex logic gets factored into clearly-named sub-behaviors.

## Visual Organization

A minimum of visual organization helps group related behaviors. Use comment headers to separate conceptual domains:

```forth
\ shooting
    : ?-auto <shoot> letgo? -; -task ;
    : /auto 0 t1 work> begin ?-auto 1 pea 0.12 pause again ;
    : ?pea <shoot> pressed? -; automatic @ if /auto else 1 pea then ;
\ positioning  
    : ?shake shaking @ dup 3. 3. 2p* 2rnd 2. 2. 2- x 2+! ;
    : spinfix a @ 360. umod 180. >= if 1. 1. x 2+! then ;
    : adhere [[ x 2@ vx 2@ 2+ ]] x 2! ;
    : orbit a @ 32. vec x 2+! ;
    : >owner owner @ adhere orbit ;
    : !pos >owner spinfix ?shake ;
    : !ang a @ p>f aim @ p>f 0.2e alerp f>p a ! ;
\ display
    : !bmp turret.ts a @ ang>bmp flicker bmp ! ;
\ init
    : /level -1 level ! ;
    turret% :: init
        !bmp *bars /level
        act> ?aim ?charge ?pea !ang !pos !bmp !bars ;
```

The sectioning creates natural reading chunks while maintaining aggressive factoring. Indentation shows hierarchical relationships within each behavioral domain.

## Example Analysis

**Reading top-down**: shooting, positioning, display, init - "this is about a turret that shoots, moves, shows feedback, and initializes itself"

**Reading by section**: 
- Shooting: handles automatic/manual firing with timing control
- Positioning: manages owner attachment, spinning, shaking, and smooth aiming
- Display: updates visual representation based on angle
- Init: sets up initial state and continuous behaviors

**The story**: "I am a turret. I can shoot automatically or on command. I stick to my owner and orbit smoothly around them. I aim fluidly at targets. I shake when firing and show the right sprite for my angle."

## When NOT to Use This Style

Glypher style is inappropriate for:
- Complex mathematical operations
- Graphics rendering pipelines  
- Memory management code
- Data structure manipulation

Use it for high-level behavioral logic where each word represents a meaningful action or decision in the actor's "life story."