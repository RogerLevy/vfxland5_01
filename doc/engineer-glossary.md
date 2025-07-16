# Engineer Glossary

VFXLand5 Engineer Framework - Base IDE/runtime providing Allegro 5 graphics/audio/input bindings, object-oriented programming extensions, and development tools.

## Table of Contents

- [engineer.vfx - Main Entry Point](#engineervfx---main-entry-point)
- [allegro-5.2.5.vfx - Allegro Bindings](#allegro-525vfx---allegro-bindings)
- [al-utils.vfx - Allegro Utilities](#al-utilsvfx---allegro-utilities)
- [oop.vfx - Object System](#oopvfx---object-system)
- [array.vfx - Array System](#arrayvfx---array-system)
- [dictionary.vfx - Dictionaries](#dictionaryvfx---dictionaries)
- [fixed.vfx - Fixed Point Math](#fixedvfx---fixed-point-math)
- [format.vfx - String Formatting](#formatvfx---string-formatting)
- [misc.vfx - Miscellaneous Utilities](#miscvfx---miscellaneous-utilities)
- [scope.vfx - Scope Management](#scopevfx---scope-management)
- [print.vfx - Text Rendering](#printvfx---text-rendering)
- [vga13h.vfx - VGA Palette](#vga13hvfx---vga-palette)
- [matrix.vfx - Matrix Stack](#matrixvfx---matrix-stack)
- [gamemath.vfx - Game Math](#gamemathvfx---game-math)
- [mersenne.vfx - Random Numbers](#mersennevfx---random-numbers)
- [counter.vfx - Performance Counters](#countervfx---performance-counters)
- [strout.vfx - String Output](#stroutvfx---string-output)
- [repl.vfx - REPL System](#replvfx---repl-system)
- [debug/oversight.vfx - Contract System](#debugoversightvfx---contract-system)
- [keys.vfx - Key Constants](#keysvfx---key-constants)

---

## engineer.vfx - Main Entry Point

  Purpose: Top-level system integration and application framework.

### Public Words

#### System Control

---
`: bye ( -- )`

  Exit application.

---
`: empty ( -- )`

  Reset system to clean state. Clears all stacks, restores default behaviors (desktop, warm, onSwitchIn), resets OOP field offsets, switches to Forth-only vocabulary, evaluates 'anew gild' to clear user definitions, and destroys all loaded bitmaps. Everything loaded after Engineer, including Supershow and all of its data structures, are destroyed.

---
`: cold ( -- )`

  Release startup sequence. Calls frigid (development setup), then warm (user startup code), then go (main loop). Used as entry point for release builds.

---
`: frigid ( -- )`

  Development startup sequence. Sets home path, enables cross-references, loads xref.xrf if present, clears stacks, calls setup (Allegro/graphics init), then boot (loads bitmaps and main.vfx). Can be used in development shell scripts to bring up Engineer without starting the game (drops user into VFX CLI).

---
`: switch ( -- )`

  Switch project context. Calls empty (reset system), boot (reload bitmaps and main.vfx), then warm (user startup). Used for hot-reloading during development.

---
`: reload ( -- )`

  Reload current context. If honing mode is active, retries last file; otherwise calls switch to reload entire project.

---
`: go ( -- )`

  Main application loop.

#### Display Management

---
`: clip-screen ( -- )`

  Set clipping to game screen bounds.

---
`: cls ( -- )`

  Clear screen to black.

---
`: >display ( -- )`

  Bring display window to front.

---
`: >vfx ( -- )`

  Bring VFX console to front.

#### Graphics System

---
`: at ( int:x int:y -- )`

- param `x` (int) - X coordinate
- param `y` (int) - Y coordinate

  Set pen position for subsequent drawing operations. All graphics functions (put, print, etc.) use this position as their reference point.

  Cross-references: See `+at` for relative positioning, `at@` for reading position.

---
`: +at ( int:x int:y -- )`

- param `x` (int) - X offset
- param `y` (int) - Y offset

  Add to pen position.

  Cross-references: See `at` for absolute positioning.

---
`: put ( int:bitmap -- )`

- param `bitmap` (int) - Bitmap index with optional flags

  Draw bitmap at current pen position. Parameter is a bitfield $F000IIII where lower 16 bits are bitmap index and upper 8 bits are flip/rotation flags. Bitmap is drawn with its top-left corner at pen position.

  Cross-references: See `bmpwh` for size information, `h|`, `v|`, `hv|` for flip flags.

---
`: bmpwh ( int:bitmap -- int:width int:height )`

- param `bitmap` (int) - Bitmap index
- return `width` (int) - Bitmap width in pixels
- return `height` (int) - Bitmap height in pixels

  Get bitmap width and height.

#### Input System

---
`: held? ( int:key -- flag:pressed )`

- param `key` (int) - Key constant
- return `pressed` (flag) - True if key is currently held

  Check if key is currently held down.

  Cross-references: See `pressed?` for key press events, `letgo?` for key release events.

---
`: pressed? ( int:key -- flag:pressed )`

- param `key` (int) - Key constant  
- return `pressed` (flag) - True if key was just pressed

  Check if key was just pressed this frame.

  Cross-references: See `held?` for continuous key state.

---
`: letgo? ( int:key -- flag:released )`

- param `key` (int) - Key constant
- return `released` (flag) - True if key was just released

  Check if key was just released this frame.

---
`: shift? ( -- flag:pressed )`

- return `pressed` (flag) - True if shift is held

  Check if shift key is held.

---
`: ctrl? ( -- flag:pressed )`

- return `pressed` (flag) - True if ctrl is held

  Check if ctrl key is held.

#### Timing System

---
`: ticks ( int:count -- ms:milliseconds )`

- param `count` (int) - Tick count
- return `milliseconds` (ms) - Time in milliseconds

  Convert tick count to milliseconds.

---
`: frame ( -- )`

  Execute one frame of main loop.

---
`: present ( -- )`

  Present frame to display with timing.

#### Filesystem

---
`: dir-exists? ( addr:path len:path -- flag:exists )`

- param `path` (addr, len) - Directory path string
- return `exists` (flag) - True if directory exists

  Check if directory exists.

---
`: >datadir ( addr:path len:path -- addr:newpath len:newpath )`

- param `path` (addr, len) - Original path
- return `newpath` (addr, len) - Data directory path

  Convert to data directory path.

---
`: each-file ( addr:path xt:callback -- )`

- param `path` (addr) - Directory path
- param `callback` (xt) - Execution token to call for each file

  Execute xt for each file in directory. Callback receives filename address and length.

#### Development Tools

---
`: try ( -- <filename> )`

  Load and execute VFX file, appending .vfx extension. Stores path for retry. If honing mode is active, forces reload of required files.

---
`: retry ( -- )`

  Retry loading the last file attempted with try. Useful for development when fixing syntax errors.

---
`: func ( addr:command len:command int:key -- )`

- param `command` (addr, len) - Command string
- param `key` (int) - Function key number

  Assign function key command.

---
`: ?func ( int:key -- )`

- param `key` (int) - Function key number

  Execute function key command.

#### Bitmap Management

---
`: bitmap@ ( int:index -- bmp:bitmap )`

- param `index` (int) - Bitmap index
- return `bitmap` (bmp) - Bitmap handle

  Get bitmap by index.

---
`: +bitmap ( bmp:bitmap -- int:index )`

- param `bitmap` (bmp) - Bitmap handle
- return `index` (int) - Assigned bitmap index

  Add bitmap, return index.

---
`: load-bitmaps ( -- )`

  Load all PNG/bitmap files from dat/gfx/ directory, creating numbered bitmap assets. Files are automatically assigned bitmap indices and can be referenced by filename.

---
`: reload-bitmaps ( -- )`

  Reload all bitmaps from gfx directory. Destroys existing bitmap at each index before loading fresh copy from disk.

---
`: destroy-bitmaps ( -- )`

  Free all allocated bitmap memory and reset bitmap system. Called during cleanup. Prints status message during operation.

---
`: bitmap-file ( int:index -- addr:filename int:len )`

- param `index` (int) - Bitmap index
- return `filename` (addr) - Filename string
- return `len` (int) - Filename length

  Get filename for bitmap index.

#### Turnkey System

---
`: save-release ( -- <path> )`

  Save release executable.

---
`: save-debug ( -- <path> )`

  Save debug executable.

---
`: turnkey ( -- )`

  Complete turnkey build process.

### Public Variables

---
`variable 'show ( -- addr )`

  Application logic/rendering execution token.

---
`variable debug ( -- addr )`

  Debug mode flag.

---
`variable going ( -- addr )`

  Main loop continue flag.

---
`4 value zoom ( -- int )`

  Display scaling factor (default 4).

---
`0 value mstime ( -- ms )`

  Current time in milliseconds.

---
`0 value pdelta ( -- fixed )`

  Frame delta in fixed-point seconds.

---
`0e fvalue sdelta ( -- float )`

  Frame delta in float seconds.

---
`0 value alt? ( -- flag )`

  Alt key state value.

---

## allegro-5.2.5.vfx - Allegro Bindings

  Purpose: Complete Allegro 5.2.5 library bindings for graphics, audio, and input.

### Public Constants

  All Allegro constants are available as direct imports. Key categories include:

#### Display Constants
- `ALLEGRO_FULLSCREEN`, `ALLEGRO_OPENGL`, `ALLEGRO_FULLSCREEN_WINDOW` - Display flags
- `ALLEGRO_PIXEL_FORMAT_*` - Pixel format constants

#### Event Constants  
- `ALLEGRO_EVENT_*` - Event type constants
- `KEYBOARD_EVENT.*`, `MOUSE_EVENT.*` - Event field accessors

#### Audio Constants
- `ALLEGRO_AUDIO_DEPTH_*` - Audio bit depth constants
- `ALLEGRO_PLAYMODE_*` - Audio playback mode constants

#### Bitmap Constants
- `ALLEGRO_MEMORY_BITMAP`, `ALLEGRO_VIDEO_BITMAP` - Bitmap storage flags

### Public Structures

---
`constant /ALLEGRO_EVENT ( -- int:size )`

- return `size` (int) - Size in bytes

  Event structure size.

---
`constant /ALLEGRO_KEYBOARD_STATE ( -- int:size )`

- return `size` (int) - Size in bytes

  Keyboard state structure size.

---
`constant /ALLEGRO_MOUSE_STATE ( -- int:size )`

- return `size` (int) - Size in bytes

  Mouse state structure size.

### Features

  Complete Allegro 5.2.5 API is available for direct use. All display, graphics, input, event, bitmap, audio, and system functions can be called directly.




---

## al-utils.vfx - Allegro Utilities

  Purpose: High-level Allegro integration and setup utilities.

### Public Values

---
`640 value appw ( -- int:width )`

- return `width` (int) - Application width

  Application width in pixels (default 640).

---
`480 value apph ( -- int:height )`

- return `height` (int) - Application height

  Application height in pixels (default 480).

---
`0 value winw ( -- int:width )`

- return `width` (int) - Window width

  Current window width.

---
`0 value winh ( -- int:height )`

- return `height` (int) - Window height

  Current window height.

---
`0 value monw ( -- int:width )`

- return `width` (int) - Monitor width

  Monitor width in pixels.

---
`0 value monh ( -- int:height )`

- return `height` (int) - Monitor height

  Monitor height in pixels.

---
`0 value fullscreen? ( -- flag:enabled )`

- return `enabled` (flag) - True if fullscreen mode

  Fullscreen mode flag.

---
`0 value display ( -- addr:handle )`

- return `handle` (addr) - Display handle

  Allegro display handle.

---
`ALLEGRO_OPENGL ALLEGRO_PROGRAMMABLE_PIPELINE or value display-flags ( -- int:flags )`

- return `flags` (int) - Display creation flags

  Display creation flags.

---
`0 value builtin-font ( -- font:handle )`

- return `handle` (font) - Font handle

  Built-in font handle.

### Public Arrays

---
`array kbs0`

  Current keyboard state buffer.

---
`array kbs1`

  Previous keyboard state buffer.

---
`array ms0`

  Current mouse state buffer.

---
`array ms1`

  Previous mouse state buffer.

### Public Words

---
`: reset-keyboard ( -- )`

  Reset keyboard system state.

---
`: init-allegro ( -- )`

  Initialize Allegro subsystems.

---
`: create-display ( -- )`

  Create game display window.

---
`: poll-keyboard ( -- )`

  Update keyboard state buffers.

---
`: poll-mouse ( -- )`

  Update mouse state buffers.

---
`: reset-mouse ( -- )`

  Reset mouse state.

---
`: file-dialog ( zstring:path zstring:title zstring:formats -- addr:result int:len )`

- param `path` (zstring) - Initial path
- param `title` (zstring) - Dialog title
- param `formats` (zstring) - File format filter
- return `result` (addr) - Selected filename
- return `len` (int) - Filename length

  Show file selection dialog.

### Public Aliases

---
`alias alqueue`

  Event queue handle alias.

---
`alias almixer`

  Audio mixer handle alias.

---

<br/><br/><br/>

---

## oop.vfx - Object System

  Purpose: Custom object-oriented programming system with late-bound message dispatch.

### Public Values

---
`0 value me ( -- addr:object )`

- return `object` (addr) - Current object pointer

  Current object context pointer.

---
`0 value /obj ( -- int:offset )`

- return `offset` (int) - Next field offset

  Next instance field offset for current class.

---
`0 value /static ( -- int:offset )`

- return `offset` (int) - Next static field offset

  Next static field offset for current class.

### Public Words

#### Object Context

---
`: [[ ( addr:object -- ) ( -- )`

- param `object` (addr) - Object to enter context for

  Enter object context, setting `me`.

  Cross-references: Use with `]]` to exit context.

---
`: ]] ( -- )`

  Exit object context, restoring previous `me`.

  Cross-references: Use with `[[` to enter context.

---
`: unsafe-[[ ( addr:object -- ) ( -- )` 🔧 [INTERNAL]

- param `object` (addr) - Object to enter context for

  Enter object context without safety checks.

#### Field Definition

---
`: var ( -- <name> ) ( -- addr )`

- return `field` (addr) - Address of field within object

  Define instance variable field.

  Cross-references: See `static` for class-level fields.

---
`: static ( -- <name> ) ( -- addr )`

- return `field` (addr) - Address of field within class

  Define class-level static field.

  Cross-references: See `var` for instance fields.

#### Property Access

---
`: 's ( addr:object -- <name> addr:field )`

- param `object` (addr) - Object handle
- return `field` (addr) - Address of object's field

  Property access operator for objects on stack.

#### Classes

---
`: create-class ( cstring:name -- class:handle )`

- param `name` (cstring) - Class name
- return `handle` (class) - New class handle

  Create new class with given name.

---
`: :: ( class:target -- <message> <code> ; )`

- param `target` (class) - Class to add method to

  Define method implementation for class and message.

#### Messages

---
`: m: ( -- <name> <code> ; ) ( -- )`

  Define message with default behavior.

---
`: do-message ( ... addr:message addr:object -- ... )`

- param `message` (addr) - Message to send
- param `object` (addr) - Target object

  Send message to object with late binding.

#### Object Creation

---
`: >object ( class:class addr:memory -- obj:object )`

- param `class` (class) - Class to instantiate
- param `memory` (addr) - Pre-allocated memory
- return `object` (obj) - Initialized object

  Initialize object at given memory location.

### Built-in Classes

---
`class object%`

  Base object class providing `init` and `destruct` messages.

---

<br/><br/><br/>

---

## array.vfx - Array System

  Purpose: Dynamic arrays and stacks with configurable element width.

### Public Words

#### Array Creation

---
`: *array ( int:max int:width -- array:handle )` 📝 [INFERRED]

- param `max` (int) - Maximum number of elements  
- param `width` (int) - Size of each element in bytes
- return `handle` (array) - Array handle

  Create unnamed zero-initialized array with specified capacity and element size.

---
`: array ( int:max int:width -- <name> ) ( -- array:handle )`

- param `max` (int) - Maximum number of elements
- param `width` (int) - Size of each element in bytes
- return `handle` (array) - Array handle

  Create named zero-initialized array with specified capacity and element size.

---
`: array: ( int:width -- <name> ) ( -- array:handle )` 📝 [INFERRED]

- param `width` (int) - Size of each element in bytes
- return `handle` (array) - Array handle

  Begin named array definition. Use with `array;` to complete.

---
`: array; ( int:width addr:data -- )` 📝 [INFERRED]

- param `width` (int) - Size of each element in bytes  
- param `data` (addr) - Address of initialization data

  Complete named array definition with initialization data.

---
`: array[ ( int:width -- int:width addr:temp )` 📝 [INFERRED]

- param `width` (int) - Size of each element in bytes
- return `width` (int) - Element width (passed through)
- return `temp` (addr) - Temporary array workspace

  Begin unnamed array definition. Use with `array]` to complete.

---
`: array] ( int:width addr:temp -- array:handle )` 📝 [INFERRED]

- param `width` (int) - Size of each element in bytes
- param `temp` (addr) - Temporary array data address
- return `handle` (array) - Completed array handle

  Complete unnamed array definition and return array handle.

#### Stack Creation

---
`: *stack ( int:max int:width -- stack:handle )` 📝 [INFERRED]

- param `max` (int) - Maximum number of elements
- param `width` (int) - Size of each element in bytes
- return `handle` (stack) - Stack handle

  Create unnamed empty stack with specified capacity and element size.

---
`: stack ( int:max int:width -- <name> ) ( -- stack:handle )`

- param `max` (int) - Maximum number of elements
- param `width` (int) - Size of each element in bytes
- return `handle` (stack) - Stack handle

  Create named empty stack with specified capacity and element size.

#### Array Access

---
`: [] ( int:index array:handle -- addr:element )` 📝 [INFERRED]

- param `index` (int) - Zero-based element index
- param `handle` (array) - Array handle
- return `element` (addr) - Address of element

  Get address of element at specified index.

  Cross-references: See `n[]` for normalized indexing.

---
`: tos ( array:handle -- addr:element )` 📝 [INFERRED]

- param `handle` (array) - Array/stack handle
- return `element` (addr) - Address of top/last element

  Get address of top element (for stacks) or last element (for arrays).

---
`: index ( addr:element array:handle -- int:index )` 📝 [INFERRED]

- param `element` (addr) - Element address from `[]` or `tos`
- param `handle` (array) - Array handle
- return `index` (int) - Zero-based element index

  Calculate index of element address within array.

---
`: n[] ( fixed:factor array:handle -- addr:element )` 📝 [INFERRED]

- param `factor` (fixed) - Normalized index (0.0 = first, 1.0 = last)
- param `handle` (array) - Array handle
- return `element` (addr) - Address of element

  Get element address using normalized floating-point index.

  Cross-references: See `[]` for integer indexing.

#### Array Information

---
`: max-items ( array:handle -- int:max )` 📝 [INFERRED]

- param `handle` (array) - Array handle
- return `max` (int) - Maximum element capacity

  Get maximum number of elements the array can hold.

---
`: /item ( array:handle -- int:width )` 📝 [INFERRED]

- param `handle` (array) - Array handle
- return `width` (int) - Element size in bytes

  Get size of each element in bytes.

---
`: #items ( array:handle -- int:count )` 📝 [INFERRED]

- param `handle` (array) - Array handle
- return `count` (int) - Current element count

  Get current number of elements in array/stack.

#### Stack Operations

---
`: push ( int:value stack:handle -- )` 📝 [INFERRED]

- param `value` (int) - Value to push (must fit element width)
- param `handle` (stack) - Stack handle

  Push value onto stack.

---
`: pop ( stack:handle -- int:value )` 📝 [INFERRED]

- param `handle` (stack) - Stack handle
- return `value` (int) - Popped value

  Pop value from stack.

---
`: push-data ( addr:data stack:handle -- )` 📝 [INFERRED]

- param `data` (addr) - Address of data to copy
- param `handle` (stack) - Stack handle

  Push block of data onto stack. Data size must match element width.

---
`: pop-data ( stack:handle -- addr:element )` 📝 [INFERRED]

- param `handle` (stack) - Stack handle
- return `element` (addr) - Address of popped element

  Pop data block from stack and return element address.

---
`: vacate ( array:handle -- )` 📝 [INFERRED]

- param `handle` (array) - Array/stack handle

  Empty array or stack, setting item count to zero.

#### Iteration

---
`: each ( ... xt:behavior array:handle -- ... )` 📝 [INFERRED]

- param `behavior` (xt) - Execution token to call for each element
- param `handle` (array) - Array handle

  Execute xt for each element address in array. xt receives `( ... addr:element -- ... )`.

  Cross-references: See `each@` for value iteration.

---
`: each@ ( ... xt:behavior array:handle -- ... )` 📝 [INFERRED] 🔧 [INTERNAL]

- param `behavior` (xt) - Execution token to call for each element
- param `handle` (array) - Array handle

  Execute xt for each element value in array. xt receives `( ... int:value -- ... )`.

  Cross-references: See `each` for address iteration.

### Notes

  Arrays are zero-initialized on creation. Stacks start empty.

  Cross-references: Uses Engineer memory allocation (`engineer/misc.vfx`), integrates with contract validation system (`engineer/debug/oversight.vfx`).

---

<br/><br/><br/>

---

## dictionary.vfx - Dictionaries

  Purpose: Key-value dictionaries using wordlists for efficient string-based lookups.

### Public Words

---
`: dictionary ( -- <name> ) ( -- dict:handle )`

- return `handle` (dict) - Dictionary handle

  Create named dictionary using wordlist.

---
`: lookup ( cstring:key dict:handle -- addr:value )`

- param `key` (cstring) - String key to look up
- param `handle` (dict) - Dictionary handle
- return `value` (addr) - Value address (created if new)

  Look up or create key in dictionary, returning value address.

---
`: walk-dictionary ( xt:callback dict:handle -- ) ( cstring:key addr:value -- )`

- param `callback` (xt) - Execution token for each entry
- param `handle` (dict) - Dictionary handle

  Iterate over dictionary entries, calling xt for each.

---
`: walk> ( dict:handle -- <code> ; ) ( cstring:key addr:value -- )`

- param `handle` (dict) - Dictionary handle

  Continuation-style dictionary iteration. Code receives key and value for each entry.

---
`: dict. ( dict:handle -- )`

- param `handle` (dict) - Dictionary handle

  Print dictionary contents to console.

---

<br/><br/><br/>

---

## fixed.vfx - Fixed Point Math

  Purpose: 16.16 fixed-point arithmetic system for consistent fractional math.

### Public Words

#### Conversion

---
`: s>p ( int:value -- fixed:result )`

- param `value` (int) - Integer value
- return `result` (fixed) - Fixed-point representation

  Convert integer to fixed-point.

  Cross-references: See `p>s` for reverse conversion.

---
`: p>s ( fixed:value -- int:result )`

- param `value` (fixed) - Fixed-point value
- return `result` (int) - Integer part only

  Convert fixed-point to integer (truncate fractional part).

  Cross-references: See `s>p` for reverse conversion.

---
`: p>f ( fixed:value -- float:result )`

- param `value` (fixed) - Fixed-point value
- return `result` (float) - Float equivalent

  Convert fixed-point to float.

---
`: f>p ( float:value -- fixed:result )`

- param `value` (float) - Float value
- return `result` (fixed) - Fixed-point equivalent

  Convert float to fixed-point.

#### Arithmetic

---
`: p* ( fixed:a fixed:b -- fixed:result )`

- param `a` (fixed) - Fixed-point multiplicand
- param `b` (fixed) - Fixed-point multiplier
- return `result` (fixed) - Product

  Fixed-point multiply by integer.

---
`: p/ ( fixed:a fixed:b -- fixed:result )`

- param `a` (fixed) - Fixed-point dividend
- param `b` (fixed) - Fixed-point divisor
- return `result` (fixed) - Quotient

  Fixed-point divide by integer.

#### Display

---
`: p. ( fixed:value -- )`

- param `value` (fixed) - Fixed-point value to print

  Print fixed-point number with decimal representation.

---
`: p? ( addr:address -- )`

- param `address` (addr) - Address containing fixed-point value

  Print fixed-point number at address.

#### Math Functions

---
`: pcos ( fixed:degrees -- fixed:result )`

- param `degrees` (fixed) - Angle in degrees
- return `result` (fixed) - Cosine value

  Fixed-point cosine function.

  Cross-references: See `psin`, `ptan` for other trig functions.

---
`: psin ( fixed:degrees -- fixed:result )`

- param `degrees` (fixed) - Angle in degrees
- return `result` (fixed) - Sine value

  Fixed-point sine function.

---
`: ptan ( fixed:degrees -- fixed:result )`

- param `degrees` (fixed) - Angle in degrees
- return `result` (fixed) - Tangent value

  Fixed-point tangent function.

---
`: pacos ( fixed:value -- fixed:degrees )`

- param `value` (fixed) - Cosine value (-1.0 to 1.0)
- return `degrees` (fixed) - Angle in degrees

  Fixed-point inverse cosine.

---
`: pasin ( fixed:value -- fixed:degrees )`

- param `value` (fixed) - Sine value (-1.0 to 1.0)
- return `degrees` (fixed) - Angle in degrees

  Fixed-point inverse sine.

---
`: patan ( fixed:value -- fixed:degrees )`

- param `value` (fixed) - Tangent value
- return `degrees` (fixed) - Angle in degrees

  Fixed-point inverse tangent.

---
`: psqrt ( fixed:value -- fixed:result )`

- param `value` (fixed) - Value to find square root of
- return `result` (fixed) - Square root

  Fixed-point square root.

#### Utilities

---
`: 1i ( fixed:value -- fixed:integer )`

- param `value` (fixed) - Fixed-point value
- return `integer` (fixed) - Integer part as fixed-point

  Get integer part of fixed-point number, keeping fixed-point format.

### Features

- Automatic number recognition for fixed-point literals (ending in decimal point)
- Integration with VFX recognizer system
- Consistent precision for game calculations

---

<br/><br/><br/>

---

## format.vfx - String Formatting

  Purpose: Printf-style string formatting with rotating buffer system.

### Public Words

---
`: format ( ... addr:template len:template addr:buffer -- addr:result len:result )`

- param `template` (addr, len) - Format template string
- param `buffer` (addr) - Output buffer
- return `result` (addr, len) - Formatted string

  Format string with arguments from stack.

---
`: f" ( -- addr:result len:result )`

- return `result` (addr, len) - Formatted string

  Immediate formatting word with template parsed from input stream.

---
`: fe" ( -- addr:result len:result )`

- return `result` (addr, len) - Formatted string

  Formatting with escape sequences enabled.

### Format Specifiers

- `%c` - character from stack
- `%n` - signed number from stack
- `%u` - unsigned number from stack
- `%dn` - double-cell signed number
- `%du` - double-cell unsigned number
- `%s` - string (addr len) from stack
- `%p` - fixed-point number from stack
- `%f` - float from float stack
- `%[...]` - evaluate Forth code in brackets
- `%%` - literal % character

### Features

- Field width specification
- Left/right justification  
- Zero padding
- Rotating buffer system prevents overwrites
- Supports all VFX Forth data types

---

<br/><br/><br/>

---

## misc.vfx - Miscellaneous Utilities

  Purpose: General utility words and convenience functions.

### Public Words

#### Stack Manipulation

---
`: ` ( -- )` 🔧 [INTERNAL]

  No-op placeholder (1-backtick version).

---
`: `` ( -- )` 🔧 [INTERNAL]

  No-op placeholder (2-backtick version).

---
`: ``` ( -- )` 🔧 [INTERNAL]

  No-op placeholder (3-backtick version).

---
`: ```` ( -- )` 🔧 [INTERNAL]

  No-op placeholder (4-backtick version).

---
`: not ( flag:input -- flag:output )`

- param `input` (flag) - Boolean flag
- return `output` (flag) - Inverted flag

  Logical not (alias for `0=`).

---
`: ?exit ( flag:condition -- )`

- param `condition` (flag) - Exit condition

  Exit current word if flag is true.

---
`: -exit ( flag:condition -- )`

- param `condition` (flag) - Exit condition (inverted)

  Exit current word if flag is false.

#### String Utilities

---
`: >zpad ( addr:string len:string -- zstring:result )`

- param `string` (addr, len) - Source string
- return `result` (zstring) - Zero-terminated copy

  Copy string to zero-terminated pad.

---
`: >pad ( addr:string len:string -- cstring:result )`

- param `string` (addr, len) - Source string
- return `result` (cstring) - Counted string copy

  Copy to counted string pad.

---
`: $+ ( cstring:dest addr:src len:src -- cstring:result )`

- param `dest` (cstring) - Destination counted string
- param `src` (addr, len) - Source string to append
- return `result` (cstring) - Updated counted string

  Append string to counted string.

#### Path Manipulation

---
`: -path ( addr:fullpath len:fullpath -- addr:path len:path )`

- param `fullpath` (addr, len) - Full file path
- return `path` (addr, len) - Path without filename

  Extract directory path without filename.

---
`: -ext ( addr:filename len:filename -- int:baselen )`

- param `filename` (addr, len) - Filename with extension
- return `baselen` (int) - Length without extension

  Get filename length without extension.

---
`: ending ( addr:string len:string char:terminator -- addr:substring len:substring )`

- param `string` (addr, len) - Source string
- param `terminator` (char) - Character to find
- return `substring` (addr, len) - Substring ending with terminator

  Find substring ending with specified character.

---
`: slashes ( addr:path len:path -- addr:result len:result )`

- param `path` (addr, len) - Path with forward slashes
- return `result` (addr, len) - Path with backslashes

  Convert forward slashes to backslashes in path.

#### File Operations

---
`: file, ( addr:filename len:filename -- )`

- param `filename` (addr, len) - File to include

  Include file content at compile time.

---
`: bytes-left ( int:fileid -- int:remaining )`

- param `fileid` (int) - File handle
- return `remaining` (int) - Bytes remaining

  Get bytes remaining in file.

---
`: write ( addr:data int:len addr:path len:path -- )`

- param `data` (addr) - Data to write
- param `len` (int) - Data length
- param `path` (addr, len) - File path

  Write data to file.

---
`: read ( addr:buffer int:maxlen addr:path len:path -- )`

- param `buffer` (addr) - Buffer for data
- param `maxlen` (int) - Maximum bytes to read
- param `path` (addr, len) - File path

  Read data from file.

#### Debug/Development

---
`: .s ( -- )`

  Smart stack display showing contents and depth.

---
`: f.s ( -- )` 📝 [INFERRED]

  Float stack display.

---
`: .rs ( -- )`

  Return stack display with function names where available.

---
`: rs ( -- )`

  Reset all stacks (alias for convenience).

---
`: .name ( xt:token -- )`

- param `token` (xt) - Execution token

  Smart name printing for execution tokens.

#### Memory/Dictionary

---
`: @+ ( addr:source -- addr:next int:value )`

- param `source` (addr) - Address to fetch from
- return `next` (addr) - Next address (source + cell size)
- return `value` (int) - Fetched value

  Fetch value and increment address.

---
`: lastbody ( -- addr:body )`

- return `body` (addr) - Body address of last defined word

  Get body address of most recently defined word.

---
`: allotted ( -- int:bytes )`

- return `bytes` (int) - Bytes allocated

  Get bytes allocated by last word definition.

---
`: ?constant ( int:value -- <name> )`

- param `value` (int) - Value for constant

  Conditional constant definition based on compilation state.

---
`: ?fconstant ( f:value -- <name> )`

- param `value` (float) - Float value for constant

  Conditional float constant definition.

#### Control Structures

---
`: for ( int:count -- )`

- param `count` (int) - Loop iteration count

  Alias for `0 ?do` - counted loop.

---
`: :now ( -- <name> )`

  Immediate colon definition that executes during compilation.

---
`: link, ( addr:address -- )`

- param `address` (addr) - Address to link

  Link address into execution chain.

---
`: do-chain ( addr:chain -- )`

- param `chain` (addr) - Chain head address

  Execute chain of linked words.

#### Data Structures

---
`: jumptable ( addr:table -- <name> ) ( -- addr:table )`

- param `table` (addr) - Jump table address
- return `table` (addr) - Jump table handle

  Create named jump table.

---
`: cstring ( -- <name> ) ( -- addr:buffer )`

- return `buffer` (addr) - String buffer address

  Create counted string buffer.

#### Math

---
`: clamp ( int:value int:min int:max -- int:result )`

- param `value` (int) - Value to clamp
- param `min` (int) - Minimum allowed value
- param `max` (int) - Maximum allowed value
- return `result` (int) - Clamped value

  Clamp value to specified range.

---
`: umod ( uint:dividend uint:divisor -- uint:remainder )`

- param `dividend` (uint) - Dividend value
- param `divisor` (uint) - Divisor value
- return `remainder` (uint) - Unsigned remainder

  Unsigned modulo operation.

---
`: h. ( int:value -- )`

- param `value` (int) - Value to print

  Print integer in hexadecimal format.

#### Advanced

---
`: d[ ( addr:dictptr -- )` 🔧 [INTERNAL]

- param `dictptr` (addr) - Dictionary pointer to save

  Save dictionary pointer and switch context.

  Cross-references: Use with `d]` to restore.

---
`: d] ( -- )` 🔧 [INTERNAL]

  Restore saved dictionary pointer.

  Cross-references: Use with `d[` to save.

---

<br/><br/><br/>

---

## scope.vfx - Scope Management

  Purpose: Per-file public/private word support with search order management.

### Public Words

#### Scope Control

---
`: private ( -- )`

  Switch current definitions to private wordlist.

  Cross-references: See `public` to return to public scope.

---
`: public ( -- )`

  Switch current definitions to public wordlist.

---
`: || ( -- <code> )` 📝 [INFERRED]

  Execute code in private context (single-line private modifier).

#### Search Order Stack

---
`: push-order ( -- )`

  Save current search order to internal stack.

  Cross-references: Use with `pop-order` to restore.

---
`: pop-order ( -- )`

  Restore previously saved search order.

#### Protected Include

---
`: include ( -- <filename> )`

  Include file with automatic scope protection.

---
`: included ( addr:filename int:len -- )`

- param `filename` (addr) - File path
- param `len` (int) - Path length

  Include file with scope protection.

---
`: require ( -- <filename> )`

  Require file (include only once) with scope protection.

---
`: required ( addr:filename int:len -- )`

- param `filename` (addr) - File path
- param `len` (int) - Path length

  Required file with scope protection.

---
`: ?included ( addr:filename int:len -- )`

- param `filename` (addr) - File path
- param `len` (int) - Path length

  Conditional include based on compilation state.

#### Advanced

---
`: borrow ( -- <scope> <word> )`

  Import specific word from another scope into current scope.

### Features

- Automatic per-file vocabulary creation
- Stack imbalance detection after includes
- Search order preservation across file boundaries
- Protection against scope pollution

---

<br/><br/><br/>

---

## print.vfx - Text Rendering

  Purpose: VGA-style bitmap text rendering system.

### Public Words

#### Text Output

---
`: color ( int:colorindex -- )`

- param `colorindex` (int) - Palette color index (0-255)

  Set text rendering color.

---
`: print ( addr:text int:len -- )`

- param `text` (addr) - Text string to render
- param `len` (int) - Text length

  Print text at current pen position using current color.

---
`: mltext ( addr:text int:len int:width -- )`

- param `text` (addr) - Text string to render
- param `len` (int) - Text length
- param `width` (int) - Maximum line width in pixels

  Render multi-line text with automatic word wrapping.

---
`: glyph ( char:character -- )`

- param `character` (char) - Character code to render

  Draw single character glyph at current pen position.

#### Text Measurement

---
`: textw ( addr:text int:len -- int:width )`

- param `text` (addr) - Text string to measure
- param `len` (int) - Text length
- return `width` (int) - Text width in pixels

  Calculate text width in pixels.

---
`: font@ ( -- font:current )`

- return `current` (font) - Current font handle

  Get current font handle.

#### System

---
`: init-vga-font ( -- )`

  Initialize built-in VGA 8x8 font system.

### Features

- Built-in 8x8 VGA character set
- 256-color palette support
- Automatic character spacing
- Embedded font bitmap data

  Cross-references: Uses pen positioning from `engineer.vfx`, color system from `vga13h.vfx`.

---

<br/><br/><br/>

---

## vga13h.vfx - VGA Palette

  Purpose: Standard VGA 256-color palette data for retro graphics.

### Public Data

---
`constant vga13h ( -- addr:palette )`

- return `palette` (addr) - 256-entry color table

  Standard VGA 13h mode palette with 256 RGB color entries (default).

### Features

- Classic VGA color arrangement
- Compatible with retro game development
- Standard palette indices for common colors

  Cross-references: Used by `print.vfx` for text coloring, `engineer.vfx` for graphics.

---

<br/><br/><br/>

---

## matrix.vfx - Matrix Stack

  Purpose: 2D transformation matrix stack for graphics operations.

### Public Words

#### Matrix Stack

---
`: +m ( -- )`

  Push current transformation matrix onto stack.

  Cross-references: Use with `-m` to restore matrix.

---
`: -m ( -- )`

  Pop transformation matrix from stack, making it current.

#### Transformations

---
`: transform ( f:x f:y f:scalex f:scaley f:angle -- )`

- param `x` (float) - X translation
- param `y` (float) - Y translation  
- param `scalex` (float) - X scale factor
- param `scaley` (float) - Y scale factor
- param `angle` (float) - Rotation angle

  Apply complete 2D transformation to current matrix.

---
`: identity ( -- )`

  Reset current matrix to identity (no transformation).

---
`: inverse ( -- )`

  Invert current transformation matrix.

#### Coordinate Transform

---
`: 2p*m ( fixed:x fixed:y -- fixed:newx fixed:newy )`

- param `x` (fixed) - Input X coordinate
- param `y` (fixed) - Input Y coordinate
- return `newx` (fixed) - Transformed X coordinate
- return `newy` (fixed) - Transformed Y coordinate

  Transform 2D point through current matrix.

### Features

- Hardware-accelerated when available
- Nested transformation support via stack
- Integration with Allegro 5 transformation system

---

<br/><br/><br/>

---

## gamemath.vfx - Game Math

  Purpose: 2D vector mathematics and game-specific mathematical operations.

### Public Words

#### 2D Vector Operations

---
`: x@ ( addr:vector -- int:x )`

- param `vector` (addr) - Address of 2D vector
- return `x` (int) - X component

  Extract X component from 2D vector.

  Cross-references: See `y@` for Y component.

---
`: y@ ( addr:vector -- int:y )`

- param `vector` (addr) - Address of 2D vector  
- return `y` (int) - Y component

  Extract Y component from 2D vector.

---
`: 2@ ( addr:vector -- int:x int:y )`

- param `vector` (addr) - Address of 2D vector
- return `x` (int) - X component
- return `y` (int) - Y component

  Fetch both components of 2D vector.

  Cross-references: See `2!` for storing vectors.

---
`: 2! ( int:x int:y addr:vector -- )`

- param `x` (int) - X component
- param `y` (int) - Y component
- param `vector` (addr) - Address to store vector

  Store 2D vector components.

---
`: 2+! ( int:dx int:dy addr:vector -- )`

- param `dx` (int) - X offset to add
- param `dy` (int) - Y offset to add
- param `vector` (addr) - Vector to modify

  Add offset to 2D vector in place.

---
`: 2, ( int:x int:y -- )`

- param `x` (int) - X component
- param `y` (int) - Y component

  Compile 2D vector into dictionary.

---
`: 2+ ( int:x1 int:y1 int:x2 int:y2 -- int:x int:y )`

- param `x1` (int) - First vector X
- param `y1` (int) - First vector Y
- param `x2` (int) - Second vector X
- param `y2` (int) - Second vector Y
- return `x` (int) - Sum X component
- return `y` (int) - Sum Y component

  Add two 2D vectors.

  Cross-references: See `2-` for subtraction.

---
`: 2- ( int:x1 int:y1 int:x2 int:y2 -- int:x int:y )`

- param `x1` (int) - First vector X
- param `y1` (int) - First vector Y
- param `x2` (int) - Second vector X
- param `y2` (int) - Second vector Y
- return `x` (int) - Difference X component
- return `y` (int) - Difference Y component

  Subtract second 2D vector from first.

---
`: 2* ( int:x int:y int:scale -- int:x int:y )`

- param `x` (int) - Vector X component
- param `y` (int) - Vector Y component
- param `scale` (int) - Scale factor
- return `x` (int) - Scaled X component
- return `y` (int) - Scaled Y component

  Scale 2D vector by integer factor.

---
`: 2/ ( int:x int:y int:divisor -- int:x int:y )`

- param `x` (int) - Vector X component
- param `y` (int) - Vector Y component
- param `divisor` (int) - Division factor
- return `x` (int) - Divided X component
- return `y` (int) - Divided Y component

  Divide 2D vector by integer factor.

---
`: 2mod ( int:x int:y int:modulus -- int:x int:y )`

- param `x` (int) - Vector X component
- param `y` (int) - Vector Y component
- param `modulus` (int) - Modulus value
- return `x` (int) - X mod modulus
- return `y` (int) - Y mod modulus

  Apply modulo to both vector components.

---
`: 2negate ( int:x int:y -- int:x int:y )`

- param `x` (int) - Vector X component
- param `y` (int) - Vector Y component
- return `x` (int) - Negated X component
- return `y` (int) - Negated Y component

  Negate both components of 2D vector.

#### Fixed-Point 2D Operations

---
`: 2s>f ( int:x int:y -- float:x float:y )`

- param `x` (int) - Integer X
- param `y` (int) - Integer Y
- return `x` (float) - Float X
- return `y` (float) - Float Y

  Convert 2D integer vector to float.

---
`: 2p>s ( fixed:x fixed:y -- int:x int:y )`

- param `x` (fixed) - Fixed-point X
- param `y` (fixed) - Fixed-point Y
- return `x` (int) - Integer X (truncated)
- return `y` (int) - Integer Y (truncated)

  Convert fixed-point 2D vector to integer.

---
`: 2s>p ( int:x int:y -- fixed:x fixed:y )`

- param `x` (int) - Integer X
- param `y` (int) - Integer Y
- return `x` (fixed) - Fixed-point X
- return `y` (fixed) - Fixed-point Y

  Convert integer 2D vector to fixed-point.

---
`: 2p>f ( fixed:x fixed:y -- float:x float:y )`

- param `x` (fixed) - Fixed-point X
- param `y` (fixed) - Fixed-point Y
- return `x` (float) - Float X
- return `y` (float) - Float Y

  Convert fixed-point 2D vector to float.

---
`: 2f>p ( float:x float:y -- fixed:x fixed:y )`

- param `x` (float) - Float X
- param `y` (float) - Float Y
- return `x` (fixed) - Fixed-point X
- return `y` (fixed) - Fixed-point Y

  Convert float 2D vector to fixed-point.

---
`: 2p. ( fixed:x fixed:y -- )`

- param `x` (fixed) - Fixed-point X
- param `y` (fixed) - Fixed-point Y

  Print 2D fixed-point vector.

---
`: 2p? ( addr:vector -- )`

- param `vector` (addr) - Address of fixed-point vector

  Print 2D fixed-point vector at address.

---
`: 2i ( fixed:x fixed:y -- fixed:x fixed:y )`

- param `x` (fixed) - Fixed-point X with fractional part
- param `y` (fixed) - Fixed-point Y with fractional part
- return `x` (fixed) - Integer part as fixed-point
- return `y` (fixed) - Integer part as fixed-point

  Get integer parts of fixed-point 2D vector.

---
`: 2p* ( fixed:x1 fixed:y1 fixed:x2 fixed:y2 -- fixed:x fixed:y )`

- param `x1` (fixed) - First vector X
- param `y1` (fixed) - First vector Y
- param `x2` (fixed) - Second vector X
- param `y2` (fixed) - Second vector Y
- return `x` (fixed) - Result X
- return `y` (fixed) - Result Y

  Multiply two fixed-point 2D vectors.

---
`: 2p/ ( fixed:x1 fixed:y1 fixed:x2 fixed:y2 -- fixed:x fixed:y )`

- param `x1` (fixed) - First vector X
- param `y1` (fixed) - First vector Y
- param `x2` (fixed) - Second vector X
- param `y2` (fixed) - Second vector Y
- return `x` (fixed) - Result X
- return `y` (fixed) - Result Y

  Divide first fixed-point 2D vector by second.

#### Range/Collision Operations

---
`: 2rnd ( -- int:x int:y )`

- return `x` (int) - Random X component
- return `y` (int) - Random Y component

  Generate random 2D vector.

---
`: overlap? ( int:x1 int:y1 int:x2 int:y2 -- flag:overlaps )`

- param `x1` (int) - First range start
- param `y1` (int) - First range end
- param `x2` (int) - Second range start
- param `y2` (int) - Second range end
- return `overlaps` (flag) - True if ranges overlap

  Check if two 1D ranges overlap.

---
`: inside? ( int:x int:y int:x1 int:y1 int:x2 int:y2 -- flag:inside )`

- param `x` (int) - Point X coordinate
- param `y` (int) - Point Y coordinate
- param `x1` (int) - Rectangle left
- param `y1` (int) - Rectangle top
- param `x2` (int) - Rectangle right
- param `y2` (int) - Rectangle bottom
- return `inside` (flag) - True if point is inside rectangle

  Check if point is inside rectangle.

---
`: lerp ( fixed:t fixed:start fixed:end -- fixed:result )`

- param `t` (fixed) - Interpolation factor (0.0 to 1.0)
- param `start` (fixed) - Starting value
- param `end` (fixed) - Ending value
- return `result` (fixed) - Interpolated value

  Linear interpolation between two values.

---
`: 2max ( int:x1 int:y1 int:x2 int:y2 -- int:x int:y )`

- param `x1` (int) - First vector X
- param `y1` (int) - First vector Y
- param `x2` (int) - Second vector X
- param `y2` (int) - Second vector Y
- return `x` (int) - Maximum X component
- return `y` (int) - Maximum Y component

  Component-wise maximum of two 2D vectors.

  Cross-references: See `2min` for minimum operation.

---
`: 2min ( int:x1 int:y1 int:x2 int:y2 -- int:x int:y )`

- param `x1` (int) - First vector X
- param `y1` (int) - First vector Y
- param `x2` (int) - Second vector X
- param `y2` (int) - Second vector Y
- return `x` (int) - Minimum X component
- return `y` (int) - Minimum Y component

  Component-wise minimum of two 2D vectors.

---
`: 2clamp ( int:x int:y int:minx int:miny int:maxx int:maxy -- int:x int:y )`

- param `x` (int) - Input X coordinate
- param `y` (int) - Input Y coordinate
- param `minx` (int) - Minimum X value
- param `miny` (int) - Minimum Y value
- param `maxx` (int) - Maximum X value
- param `maxy` (int) - Maximum Y value
- return `x` (int) - Clamped X coordinate
- return `y` (int) - Clamped Y coordinate

  Clamp 2D vector to rectangular bounds.

#### Bit Operations

---
`: << ( int:value int:bits -- int:result )`

- param `value` (int) - Value to shift
- param `bits` (int) - Number of bits to shift left
- return `result` (int) - Shifted value

  Left shift alias for convenience.

---
`: >> ( int:value int:bits -- int:result )`

- param `value` (int) - Value to shift
- param `bits` (int) - Number of bits to shift right
- return `result` (int) - Shifted value

  Right shift alias for convenience.

### Notes

  This module provides comprehensive 2D mathematics suitable for game development, with both integer and fixed-point precision options.

  Cross-references: Uses fixed-point system from `fixed.vfx`, integrates with actor positioning in Supershow.

---

<br/><br/><br/>

---

## mersenne.vfx - Random Numbers

  Purpose: Mersenne Twister pseudo-random number generator for consistent random sequences.

### Public Words

---
`: rnd32 ( -- uint:random )`

- return `random` (uint) - 32-bit random number

  Generate 32-bit unsigned random number.

---
`: rnd ( int:max -- int:result )`

- param `max` (int) - Upper bound (exclusive)
- return `result` (int) - Random number from 0 to max-1

  Generate random number in specified range.

---
`: seed! ( uint:seed -- )`

- param `seed` (uint) - Random seed value

  Seed random number generator with specific value.

---
`: init-mersenne ( -- )`

  Initialize random number generator with time-based seed.

### Features

- High-quality pseudo-random sequence
- Deterministic when seeded consistently
- Period of 2^19937-1
- Suitable for games requiring reproducible randomness

  Cross-references: Used by `2rnd` in `gamemath.vfx`, various game systems requiring randomness.

---

<br/><br/><br/>

---

## counter.vfx - Performance Counters

  Purpose: High-resolution timing using Windows performance counters.

### Public Words

---
`: dcounter ( -- dint:ticks )`

- return `ticks` (dint) - Performance counter value

  Get high-resolution performance counter as double-cell integer.

---
`: ucounter ( -- dint:microseconds )`

- return `microseconds` (dint) - Microsecond counter

  Get microsecond-resolution counter as double-cell integer.

---
`: counter ( -- ms:milliseconds )`

- return `milliseconds` (ms) - Millisecond counter

  Get millisecond counter as single integer.

---
`: timing ( xt:code -- int:microseconds )`

- param `code` (xt) - Code to time
- return `microseconds` (int) - Execution time

  Time execution of code in microseconds.

---
`: time? ( xt:code -- )`

- param `code` (xt) - Code to time and display

  Time execution and print result.

### Features

- Sub-microsecond precision when available
- Platform-specific optimization
- Suitable for performance profiling

  Cross-references: Used by frame timing in `engineer.vfx`, development profiling tools.

---

<br/><br/><br/>

---

## strout.vfx - String Output

  Purpose: String capture system for redirecting console output to buffers.

### Public Words

---
`: z[ ( -- )`

  Begin zero-terminated string capture, redirecting output.

  Cross-references: Use with `]z` to complete capture.

---
`: ]z ( -- zstring:result )`

- return `result` (zstring) - Captured output

  End zero-terminated string capture and return result.

---
`: s[ ( -- )`

  Begin counted string capture, redirecting output.

  Cross-references: Use with `]s` to complete capture.

---
`: s] ( -- addr:result int:len )`

- return `result` (addr) - Captured string
- return `len` (int) - String length

  End counted string capture and return result.

### Features

- Redirects all console output (TYPE, EMIT, etc.)
- Nested capture protection
- Automatic buffer management

  Cross-references: Used by formatting systems, debugging tools requiring string capture.

---

<br/><br/><br/>

---

## repl.vfx - REPL System

  Purpose: Interactive Read-Eval-Print Loop for live development.

### Public Words

#### Display Modes

---
`: ints ( -- )`

  Set REPL to display integers in decimal format.

  Cross-references: See `fixeds`, `hexints` for other display modes.

---
`: fixeds ( -- )`

  Set REPL to display numbers as fixed-point values.

---
`: hexints ( -- )`

  Set REPL to display integers in hexadecimal format.

#### System Integration

---
`: repl-events ( -- )`

  Process REPL keyboard events and input.

---
`: draw-repl ( -- )`

  Draw REPL interface overlay on game display.

### Public Variables

---
`variable repl ( -- addr )`

REPL enable flag (toggled by Tab key).

### Features

- Tab key toggles REPL visibility
- Integrated with main game loop
- Stack display with multiple number formats
- Command history and line editing
- Transparent overlay on game graphics

  Cross-references: Integrates with main loop in `engineer.vfx`, uses text rendering from `print.vfx`.

---

<br/><br/><br/>

---

## debug/oversight.vfx - Contract System

  Purpose: Contract-oriented programming with runtime validation and zero-overhead option.

### Public Words

#### Validation Levels

---
`: crucial ( -- int:level )`

- return `level` (int) - Essential safety level (default 1)

  Essential safety checks that should always run.

---
`: charmful ( -- int:level )`

- return `level` (int) - Non-critical level (default 2)

  Non-critical checks for development and debugging.

---
`: else-warn ( int:result -- int:result )`

- param `result` (int) - Validation result
- return `result` (int) - Modified result (converts errors to warnings)

  Convert validation failure to warning instead of error.

#### Control Variables

---
`variable safety ( -- addr )`

  Master validation enable/disable flag.
  
  ```
  safety on  \ run validations
  safety off \ do not run validations (~50% performance gain)
  ```

---
`variable validations ( -- addr )`

  Compilation-time validation control flag.

  ```
  validations on   \ compile code with validations
  validations off  \ compile code without validations (~90% performance gain)
  ```

#### Validator Definition

---
`: test: ( int:level -- <name> ) ( -- )`

- param `level` (int) - Validation level (crucial/charmful)

  Define validator with cached source for efficient compilation.

#### Contract Attachment

---
`: before ( -- <target> <validator> )`

  Attach pre-condition validator to target word.

  Cross-references: See `after` for post-conditions.

---
`: after ( -- <target> <validator> )`

  Attach post-condition validator to target word.

---
`: >before ( xt:validator addr:wordname int:namelen -- addr:validation )`

- param `validator` (xt) - Validation function
- param `wordname` (addr) - Target word name
- param `namelen` (int) - Name length
- return `validation` (addr) - Validation record

  Stack-based pre-condition attachment.

---
`: >after ( xt:validator addr:wordname int:namelen -- addr:validation )`

- param `validator` (xt) - Validation function
- param `wordname` (addr) - Target word name
- param `namelen` (int) - Name length
- return `validation` (addr) - Validation record

  Stack-based post-condition attachment.

#### Debug Messages

---
`: say-before ( -- <word> <message> )`

  Set pre-execution debug message for word.

---
`: say-after ( -- <word> <message> )`

  Set post-execution debug message for word.

#### Word Wrapping

---
`: wrap-word ( -- <name> )`

  Add all configured validations to existing word.

#### Inspection

---
`: csee ( -- <word> )`

  Display contract information for word.

---
`: xt>contract ( xt:token -- addr:contract )`

- param `token` (xt) - Word execution token
- return `contract` (addr) - Contract record or 0

  Get contract record for execution token.

#### Control

---
`: init-oversight ( -- )`

  Initialize oversight system and redefine core words.

---
`: disable-validator ( xt:validator -- )`

- param `validator` (xt) - Validator to disable

  Disable specific validator globally.

---
`: enable-validator ( xt:validator -- )`

- param `validator` (xt) - Validator to enable

  Enable previously disabled validator.

### Features

- Automatic `:` and `;` redefinition for seamless contract integration
- Lazy compilation of validators for efficiency
- Self-healing validation support
- Zero runtime overhead when disabled
- Stack-safe validation with automatic cleanup

  Cross-references: Extended by `core-checks.vfx` and `checks.vfx`, used throughout Engineer for safety.


---

<br/><br/><br/>

---

## keys.vfx - Key Constants

  Purpose: Comprehensive keyboard key constant definitions for input handling.

### Public Constants

#### Letter Keys
`<A>` through `<Z>` - Letter key constants

#### Number Keys  
`<0>` through `<9>` - Number key constants

#### Function Keys
`<F1>` through `<F12>` - Function key constants

#### Special Keys
- `<ESCAPE>`, `<ENTER>`, `<SPACE>` - Common special keys
- `<TAB>`, `<BACKSPACE>`, `<DELETE>` - Editing keys
- `<INSERT>`, `<HOME>`, `<END>` - Navigation keys
- `<PAGEUP>`, `<PAGEDOWN>` - Page navigation

#### Arrow Keys
`<LEFT>`, `<RIGHT>`, `<UP>`, `<DOWN>` - Directional keys

#### Modifier Keys
- `<lshift>`, `<rshift>` - Shift key variants
- `<LCTRL>`, `<RCTRL>` - Control key variants  
- `<ALT>`, `<ALTGR>` - Alt key variants
- `<LWIN>`, `<RWIN>` - Windows key variants

#### Keypad Keys
- `<PAD0>` through `<PAD9>` - Numeric keypad numbers
- `<PAD_PLUS>`, `<PAD_MINUS>` - Keypad operators
- `<PAD_MULTIPLY>`, `<PAD_DIVIDE>` - Keypad operators
- `<PAD_ENTER>`, `<PAD_DELETE>` - Keypad special keys

#### Modifier Flags
`ALLEGRO_KEYMOD_*` constants for key modifier detection

### Aliases
- `<esc>` - Alias for `<ESCAPE>`
- `<bksp>` - Alias for `<BACKSPACE>`
- `<ins>` - Alias for `<INSERT>`
- `<del>` - Alias for `<DELETE>`

### Features

- Complete Allegro 5 key code coverage
- Consistent naming convention
- Both full names and common aliases
- Integration with Engineer input system

  Cross-references: Used by `engineer.vfx` input functions, game input handling throughout VFXLand5.

---

**Total Public API Coverage**: The Engineer framework provides approximately 300+ public words covering all aspects of 2D game development, object-oriented programming, contract-based validation, and interactive development tools.