# Supershow Glossary

VFXLand5 Supershow Game Engine - Middleware providing actor/sprite system, tilemap rendering, audio sample playback, GPU shader support, and UI framework.

## Table of Contents

- [supershow.vfx - Main Entry Point](#supershowvfx---main-entry-point)
- [stage.vfx - Actor System Core](#stagevfx---actor-system-core)
- [tilemap.vfx - Tilemap and Tileset System](#tilemapvfx---tilemap-and-tileset-system)
- [tools.vfx - Development Tools](#toolsvfx---development-tools)
- [shader.vfx - GPU Shader Support](#shadervfx---gpu-shader-support)
- [crt.vfx - CRT Display Effect](#crtvfx---crt-display-effect)
- [waveplay.vfx - Audio Sample Playback](#waveplayvfx---audio-sample-playback)
- [tmcol.vfx - Tilemap Collision Detection](#tmcolvfx---tilemap-collision-detection)
- [tread.vfx - Tile Reading Utilities](#treadvfx---tile-reading-utilities)
- [udlr.vfx - Directional Input Handling](#udlrvfx---directional-input-handling)
- [dltree.vfx - Doubly-Linked Tree](#dltreevfx---doubly-linked-tree)
- [ui/ui.vfx - User Interface System](#uiuivfx---user-interface-system)

---

## supershow.vfx - Main Entry Point

  Purpose: Main entry point and core utilities for the Supershow game engine.

### Public Constants

---
`constant gap ( -- int:tilesize )`

- return `tilesize` (int) - Tile size in pixels (default 20)

  Standard tile size for tilemaps.

---
`constant tmw ( -- int:width )`

- return `width` (int) - Tilemap width in tiles (default 16)

  Tilemap width in tile units.

---
`constant tmh ( -- int:height )`

- return `height` (int) - Tilemap height in tiles (default 12)

  Tilemap height in tile units.

### Public Words

#### Utility Functions

---
`: 4s>p ( int:n1 int:n2 int:n3 int:n4 -- fixed:a fixed:b )` 📝 [INFERRED]

- param `n1` (int) - First integer
- param `n2` (int) - Second integer  
- param `n3` (int) - Third integer
- param `n4` (int) - Fourth integer
- return `a` (fixed) - First fixed-point value
- return `b` (fixed) - Second fixed-point value

  Convert 4 stack integers to 2 fixed-point values.

---
`: 2? ( addr:vector -- )`

- param `vector` (addr) - Address containing 2 values

  Print 2 values from memory address.

---
`: w? ( addr:word -- )`

- param `word` (addr) - Address containing word value

  Print word value at address.

---
`: c? ( addr:char -- )`

- param `char` (addr) - Address containing character

  Print character value at address.

---
`: h. ( int:value -- )`

- param `value` (int) - Integer value

  Print integer in hexadecimal format.

---
`: at@ ( -- int:x int:y )`

- return `x` (int) - Current pen X position
- return `y` (int) - Current pen Y position

  Get current pen position.

  Cross-references: See `at`, `+at` in Engineer for setting position.

---
`: toggle ( addr:flag -- )`

- param `flag` (addr) - Address of boolean flag

  Toggle boolean value at address between true and false.

---
`: cput ( bmp:bitmap -- )`

- param `bitmap` (bmp) - Bitmap to draw

  Draw bitmap centered at current pen position. Calculates bitmap center offset, adjusts pen position, draws with `put`, then restores the pen.

---
`: hold ( int:bitmap -- )`

- param `bitmap` (int) - Bitmap index to hold

  Suspend bitmap drawing operations.

  Cross-references: See `hold>` for code execution with held drawing.

---
`: hold> ( -- <code> ; ) ( -- )`

  Execute code with bitmap drawing suspended. Restores drawing state even if code throws exception.

---
`: h| ( int:flags -- int:result )`

- param `flags` (int) - Current bitmap flags
- return `result` (int) - Flags with horizontal flip set

  Set horizontal flip flag for bitmap drawing.

  Cross-references: See `v|`, `hv|` for other flip options.

---
`: v| ( int:flags -- int:result )`

- param `flags` (int) - Current bitmap flags
- return `result` (int) - Flags with vertical flip set

  Set vertical flip flag for bitmap drawing.

---
`: hv| ( int:flags -- int:result )`

- param `flags` (int) - Current bitmap flags
- return `result` (int) - Flags with both flip directions set

  Set both horizontal and vertical flip flags.

---
`: named? ( xt:token cstring:name -- flag:matches )`

- param `token` (xt) - Execution token to check
- param `name` (cstring) - Name to compare against
- return `matches` (flag) - True if xt has given name

  Check if execution token has specified name.

---
`: bmpw ( bmp:bitmap -- int:width )`

- param `bitmap` (bmp) - Bitmap handle
- return `width` (int) - Bitmap width in pixels

  Get bitmap width.

  Cross-references: See `bmph` for height.

---
`: bmph ( bmp:bitmap -- int:height )`

- param `bitmap` (bmp) - Bitmap handle
- return `height` (int) - Bitmap height in pixels

  Get bitmap height.

#### Trigonometry and Vector Math

---
`: fscale ( float:x float:y float:scale -- float:x float:y )`

- param `x` (float) - Vector X component
- param `y` (float) - Vector Y component
- param `scale` (float) - Scale factor
- return `x` (float) - Scaled X component
- return `y` (float) - Scaled Y component

  Scale float vector by scalar factor.

---
`: uvec ( fixed:degrees -- fixed:x fixed:y )`

- param `degrees` (fixed) - Angle in degrees
- return `x` (fixed) - Unit vector X component
- return `y` (fixed) - Unit vector Y component

  Generate unit vector from angle in degrees.

  Cross-references: See `fuvec` for float version, `vec` for scaled version.

---
`: fuvec ( float:degrees -- float:x float:y )`

- param `degrees` (float) - Angle in degrees
- return `x` (float) - Unit vector X component
- return `y` (float) - Unit vector Y component

  Generate float unit vector from angle.

---
`: vec ( fixed:degrees fixed:length -- fixed:x fixed:y )`

- param `degrees` (fixed) - Angle in degrees
- param `length` (fixed) - Vector magnitude
- return `x` (fixed) - Vector X component
- return `y` (fixed) - Vector Y component

  Generate vector from angle and length.

---
`: ang ( fixed:x fixed:y -- fixed:degrees )`

- param `x` (fixed) - Vector X component
- param `y` (fixed) - Vector Y component
- return `degrees` (fixed) - Angle in degrees

  Calculate angle from vector components.

---
`: hypot ( fixed:x fixed:y -- fixed:length )`

- param `x` (fixed) - Vector X component
- param `y` (fixed) - Vector Y component
- return `length` (fixed) - Vector magnitude

  Calculate hypotenuse (vector length).

---
`: dist ( fixed:x1 fixed:y1 fixed:x2 fixed:y2 -- fixed:distance )`

- param `x1` (fixed) - First point X
- param `y1` (fixed) - First point Y
- param `x2` (fixed) - Second point X
- param `y2` (fixed) - Second point Y
- return `distance` (fixed) - Distance between points

  Calculate distance between two points.

---
`: alerp ( float:angle1 float:angle2 float:t -- float:result )`

- param `angle1` (float) - Starting angle
- param `angle2` (float) - Ending angle
- param `t` (float) - Interpolation factor (0.0 to 1.0)
- return `result` (float) - Interpolated angle

  Angular interpolation handling wrap-around.

#### File Operations

---
`: include, ( addr:path len:path -- )`

- param `path` (addr, len) - File path string

  Include file by path and length.

#### Audio Creation

---
`: bgm ( -- <name> <filename> ) ( -- )`

  Create named word that streams background music file with looping. When executed, loads and plays the specified audio file continuously.

---
`: audioclip ( -- <name> <filename> ) ( -- )`

  Create one-shot audio clip word that plays specified file.

#### Screen Management

---
`: blank ( -- )`

  Blank the screen for 10 frames.

#### Animation System

---
`var anm ( -- addr )`

  Current animation data pointer.

---
`var a.ts ( -- addr )`

  Animation tileset.

---
`var a.spd ( -- addr )`

  Animation speed.

---
`var a.len ( -- addr )`

  Animation length.

---
`var a.ofs ( -- addr )`

  Animation offset.

---
`var a.done ( -- addr )`

  Animation completion flag.

---
`var a.flp ( -- addr )`

  Animation flip flags.

---
`: cycle ( anim:data fixed:speed -- )`

- param `data` (anim) - Animation data structure
- param `speed` (fixed) - Animation playback speed

  Start animation cycle with specified speed. Sets animation data and speed for current actor. Animation automatically advances frames based on game time.

---
`: animation ( int:tileset -- <name> ) ( -- anim:data )`

- param `tileset` (int) - Tileset for animation frames
- return `data` (anim) - Animation data structure

  Create named animation data structure using specified tileset. Use with frame, and range, to define animation sequences.

---
`: frame, ( int:framenum -- )`

- param `framenum` (int) - Frame number to add

  Add single frame to current animation definition.

---
`: range, ( int:start int:end -- )`

- param `start` (int) - Starting frame number
- param `end` (int) - Ending frame number

  Add frame range to current animation definition.

---
`: +animation ( -- )`

  Update current animation (advance frame, check completion).

---
`: animate ( -- )`

  Animate all active actors with animation data.

#### Auto-Class System

---
`: load-autoclass ( addr:filename len:filename -- )`

- param `filename` (addr, len) - Bitmap filename

  Create auto-generated class from bitmap file.
  
  `dat\gfx\mybitmap.png` -> `mybitmap%`

---
`: load-autoclasses ( -- )`

  Create autoclasses out of each bitmap in dat\gfx\.

---
`: load-script ( addr:filename len:filename -- )`

- param `filename` (addr, len) - Script filename

  Load actor script file, finding it scripts\.

---
`: load-scripts ( -- )`

  Load all actor scripts and auto-classes.

#### Interactive Development Tools

---
`: init-by-class ( class:target -- )`

- param `target` (class) - Actor class to initialize

  Initialize all actors of specified class.

---
`: update ( -- <classname> )`

  Live update actor class during development.
  The script for the given class is loaded with `>try`.
  All active instances of the class are re-initialized.

---
`: .actors ( -- )`

  Display list of active actors for debugging.

---
`: .temps ( -- )`

  Display list of temporary actors for debugging.

---
`: freemove ( actor:target -- )`

- param `target` (actor) - Actor to enable free movement

  Development tool: Allow actor free movement with arrow keys.

#### Graphics Management

---
`: reload-graphics ( -- )`

  Reload all graphics assets from disk.

#### System Initialization

---
`: init-supershow ( -- )`

  Initialize the Supershow game engine.
  Initializes tilesets, loads audio samples, initializes the CRT shader,
  and does other initialization.

---

<br/><br/><br/>

---

## stage.vfx - Actor System Core

  Purpose: Core actor system providing fixed-size actor instances (default 512 bytes) with behavior scripting.

### Public Constants

---
`constant #actors ( -- int:max )`

- return `max` (int) - Maximum actors (default 1024)

  Maximum number of regular actors.

---
`constant #temps ( -- int:max )`

- return `max` (int) - Maximum temp actors (default 8192)

  Maximum number of temporary actors.

---
`constant #elements ( -- int:max )`

- return `max` (int) - Maximum UI elements (default 256)

  Maximum number of UI elements.

---
`constant /actor ( -- int:size )`

- return `size` (int) - Actor size in bytes (default 512)

  Size of each actor instance.

### Public Arrays

---
`array actors`

  Main actor pool containing all regular actors.

---
`array temps`

  Temporary actor pool for short-lived objects.

---
`array elements`

UI element pool for interface objects.

### Public Variables

---
`variable gamelife ( -- addr )`

  Global frame counter for game timing.

---
`2variable gametime ( -- addr )`

  Total game time as double-precision value.

---
`variable next# ( -- addr )`

  Next actor allocation index.

### Actor Field Variables

---
`var en ( -- addr )`

- return addr - Field for enabled flag

  Actor enabled flag field.

---
`var x ( -- addr )`, `var y ( -- addr )`

- return addr - Field for position

  Actor position fields (fixed-point).

---
`var vx ( -- addr )`, `var vy ( -- addr )`

- return addr - Field for velocity

  Actor velocity fields (fixed-point).

---
`var bmp ( -- addr )`

- return addr - Field for bitmap ID

  Actor bitmap/sprite field.

---
`var x1 ( -- addr )`, `var y1 ( -- addr )`, `var w1 ( -- addr )`, `var h1 ( -- addr )`

- return addr - Field for hitbox parameters

  Actor collision hitbox fields.

---
`var beha ( -- addr )`

- return addr - Field for behavior XT

  Actor behavior execution token field.

---
`var time ( -- addr )`

- return addr - Field for time counter

  Actor time counter field (milliseconds).

---
`var n1 ( -- addr )`, `var n2 ( -- addr )`

- return addr - Field for general purpose numbers

  General purpose numeric fields.

---
`var phys ( -- addr )`

- return addr - Field for physics XT

  Physics behavior execution token field.

---
`var prio ( -- addr )`

- return addr - Field for priority

  Drawing priority field (0=behind BG, <>0=in front).

---
`var disabled ( -- addr )`

- return addr - Field for disabled flag

  Disable behavior and physics execution flag.

### Public Words

#### Actor Access and Management

---
`: free? ( actor:target -- flag:available )`

- param `target` (actor) - Actor to check
- return `available` (flag) - True if actor slot is free

  Check if actor slot is available for allocation.

---
`: as> ( actor:target -- <code> ; ) ( -- )`

- param `target` (actor) - Actor to set as current context

  Execute code with specified actor as current `me`.

---
`: actor ( int:index -- actor:handle )`

- param `index` (int) - Actor index (0 to #actors-1)
- return `handle` (actor) - Actor at specified index

  Get actor by index number.

  Cross-references: See `actor#` for reverse lookup.

---
`: actor# ( actor:handle -- int:index )`

- param `handle` (actor) - Actor handle
- return `index` (int) - Actor index number

  Get index number of actor.

---
`: act> ( -- <code> ; ) ( -- )`

  Set behavior execution token for current actor. Resets actor's time counter to 0 and stores the following code as the actor's per-frame behavior. Behavior executes every frame when actor is active.

  Cross-references: See `act&>` for immediate execution version.

---
`: act&> ( -- <code> ; ) ( -- )`

  Set behavior and execute immediately.

---
`: physics> ( -- <code> ; ) ( -- )`

  Set physics behavior execution token for current actor.

---
`: all> ( -- <code> ; ) ( -- )`

  Execute code for all actors in main pool.

  Cross-references: See `actives>` for active-only iteration.

---
`: actives> ( -- <code> ; ) ( -- )`

  Execute code for all active (enabled) actors.

#### Actor Serialization

---
`m: peeked ( -- )`

  Message for custom actor display during debugging.

---
`: peek ( actor:target -- )`

- param `target` (actor) - Actor to display

  Display actor information for debugging.

#### Actor State Management

---
`: disabled? ( actor:target -- flag:disabled )`

- param `target` (actor) - Actor to check
- return `disabled` (flag) - True if actor is disabled

  Check if actor behavior/physics is disabled.

---
`: disable ( actor:target -- )`

- param `target` (actor) - Actor to disable

  Disable actor behavior and physics execution.

---
`: behave ( -- )`

  Execute behavior for all active actors.

---
`: step ( -- )`

  Execute one complete simulation step (behavior + physics).

---
`: +time ( -- )`

  Update global game time and frame counters.

#### Actor Search

---
`: who> ( -- <code> ; ) ( actor:candidate -- flag:matches )`

  Find first actor matching condition. Code receives actor and returns flag.

#### Actor Drawing

---
`: sprite ( -- )`

  Draw current actor's bitmap centered at actor's position. Converts fixed-point actor coordinates to integers, sets pen position, then calls cput with actor's bmp field.

---
`: backsprites ( -- )`

  Draw all sprites with priority 0 (behind background).

---
`: sprites ( -- )`

  Draw all sprites with priority <>0 (in front of background).

#### Actor Creation and Destruction

---
`actor default`

  Default actor template with standard field values.

---
`xt floating`

  Default physics behavior (no special physics).

---
`: priority ( int:level -- )`

- param `level` (int) - Priority level for next allocation

  Set drawing priority for next actor allocation.

---
`: unload ( -- )`

  Free current actor slot. Disables actor (en off), clears bitmap, behavior, and physics fields. Actor becomes available for reallocation.

---
`: just ( -- )`

  Clear all actors (mark all as free).

---
`: one ( class:actorclass -- actor:handle )`

- param `actorclass` (class) - Actor class to instantiate
- return `handle` (actor) - New actor instance

  Allocate one actor of specified class. Searches actor pool starting at next# for free slot, initializes with class and default values, calls init message, returns actor handle. Aborts with error message if no free actors available (can catch with `['] one catch` to test).

---
`: *actor ( -- actor:handle )`

- return `handle` (actor) - Generic actor instance

  Create generic actor without class.

#### Actor Collision Detection

---
`: hitbox1 ( -- int:x1 int:y1 int:x2 int:y2 )` 📝 [INFERRED]

- return `x1` (int) - Left edge of hitbox
- return `y1` (int) - Top edge of hitbox
- return `x2` (int) - Right edge of hitbox
- return `y2` (int) - Bottom edge of hitbox

  Get current actor's hitbox coordinates.

---
`: hit? ( actor:obj1 actor:obj2 -- flag:collision )`

- param `obj1` (actor) - First actor
- param `obj2` (actor) - Second actor
- return `collision` (flag) - True if actors collide

  Check collision between two actors using their hitboxes.

#### Actor Scripting Tools

---
`: att ( int:col int:row -- )`

- param `col` (int) - Tile column
- param `row` (int) - Tile row

  Position current actor at tile coordinates.

---
`: *[[ ( class:actorclass -- <code>]] ) ( -- actor:handle )`

- param `actorclass` (class) - Class to instantiate
- return `handle` (actor) - New actor instance

  Create and initialize actor, setting it as current context.

---
`: in? ( -- flag:onscreen )`

- return `onscreen` (flag) - True if actor is visible on screen

  Check if current actor is within screen bounds.

---
`: ?out ( -- flag:unloaded )`

- return `unloaded` (flag) - True if actor was unloaded

  Check if actor is out of bounds and unload if so.

---
`: passed? ( ms:duration -- flag:elapsed )`

- param `duration` (ms) - Time duration to check
- return `elapsed` (flag) - True if time has passed

  Check if specified time has elapsed for current actor.

---
`: from ( actor:reference int:x int:y -- )`

- param `reference` (actor) - Reference actor
- param `x` (int) - X offset from reference
- param `y` (int) - Y offset from reference

  Sets the pen relative to reference actor.

---
`: halt ( -- )`

  Stop current actor movement, setting velocity to zero and clearing its behavior.

---
`: morph ( class:newclass -- )`

- param `newclass` (class) - New class for actor

  Change current actor's class while preserving position and velocity. Copies from default template, updates class pointer, restores position/velocity, calls init.

---
`: is? ( actor:target class:testclass -- flag:matches )`

- param `target` (actor) - Actor to test
- param `testclass` (class) - Class to test against
- return `matches` (flag) - True if actor is of specified class

  Check if actor is instance of specified class.

---
`: out ( actor:target -- )`

- param `target` (actor) - Actor to unload

  Force unload specified actor.

---
`: vanish ( -- )`

  Hide current actor by moving it very far off-screen.

---
`: appear ( -- )`

  Show previously hidden actor.

---
`: copy ( actor:source actor:dest -- actor:dest )`

- param `source` (actor) - Source actor to copy from
- param `dest` (actor) - Destination actor
- return `dest` (actor) - Modified destination actor

  Copy actor data from source to destination.

---
`: expanded ( actor:source int:expansion -- actor:copy )`

- param `source` (actor) - Actor to copy
- param `expansion` (int) - Hitbox expansion amount
- return `copy` (actor) - Temporary actor with expanded hitbox

  Create temporary actor copy with expanded hitbox.
  This copy is static and exists outside the stage.  

---
`: hb1! ( int:x int:y int:w int:h -- )`

- param `x` (int) - Hitbox X offset
- param `y` (int) - Hitbox Y offset
- param `w` (int) - Hitbox width
- param `h` (int) - Hitbox height

  Set current actor's hitbox parameters.

#### Timer System

---
`class timer%`

  Timer actor class for delayed execution.

---
`: clear-timers ( -- )`

  Clear all timer actors from the system.

---
`: timer> ( fixed:delay -- <code> ; ) ( -- )`

- param `delay` (fixed) - Delay time in seconds

  Create timer that executes code after specified delay.

#### Secondary Storage (Temp Actors)

---
`: temp ( int:index -- actor:handle )`

- param `index` (int) - Temp actor index
- return `handle` (actor) - Temp actor at index

  Get temporary actor by index.

---
`: *temp ( -- actor:handle )`

- return `handle` (actor) - New temp actor

  Allocate new temporary actor.

---
`: temps> ( -- <code> ; ) ( -- )`

  Execute code for all temporary actors.

---
`: clear-temps ( -- )`

  Clear all temporary actors.

#### Script Classes

---
`: script-class ( -- <name> class:handle ) ( -- class:handle )`

- param `name` (parsed) - Class name from input stream
- return `handle` (class) - Script class handle

  Ensure script-based actor class.
  If the class doesn't exist, it is created.
  In either case, either the new class or the existing one is returned.
  A private namespace is created for a newly-created class. (class% -> class`)
  The private namespace then becomes the current scope.

---
`: actor-class ( -- <name> ) ( -- class:handle )`

- return `handle` (class) - Actor class handle

  Create actor script class.

---
`static autoclass ( -- addr )`

- return addr - Static field address

  Static field indicating auto-generated class status.

### Features

- Fixed 512-byte actor size for consistent memory layout
- Automatic behavior and physics execution
- Hierarchical drawing with priority system
- Collision detection with configurable hitboxes
- Timer system for delayed actions
- Temporary actor pool for short-lived objects
- Script-based class system with auto-generation

  Cross-references: Integrates with Supershow tilemap system, uses Engineer OOP framework, serves as a basis for the UI system.

---

<br/><br/><br/>

---

## tilemap.vfx - Tilemap and Tileset System

  Purpose: Efficient tile-based rendering system with tile metadata support for game logic.

### Public Words

#### Tileset Management

---
`: baseid@ ( tileset:handle -- int:baseid )`

- param `handle` (tileset) - Tileset handle
- return `baseid` (int) - Base bitmap ID for tileset

  Get base bitmap ID for tileset's first tile.

---
`: tile ( tileset:handle int:tilenum -- int:bitmapid )`

- param `handle` (tileset) - Tileset handle
- param `tilenum` (int) - Tile number within tileset
- return `bitmapid` (int) - Bitmap ID for specific tile

  Get bitmap ID for specific tile in tileset.

---
`: tileset ( int:baseid int:tilewidth int:tileheight -- <name> ) ( -- tileset:handle )`

- param `baseid` (int) - Starting bitmap ID
- param `tilewidth` (int) - Width of each tile
- param `tileheight` (int) - Height of each tile
- return `handle` (tileset) - Tileset handle

  Create named tileset from contiguous bitmap range.

---
`: init-tilesets ( -- )`

  Initialize all defined tilesets.

---
`: reload-tilesets ( -- )`

  Reload all tileset graphics from disk.

---
`: is-tile? ( int:bitmapid -- flag:istile )`

- param `bitmapid` (int) - Bitmap ID to check
- return `istile` (flag) - True if bitmap belongs to a tileset

  Check if bitmap ID belongs to any tileset.

#### Tilemap Operations

---
`variable pile ( -- addr )`

  Current active tileset for tilemap operations.

---
`: lay ( addr:mapdata -- )`

- param `mapdata` (addr) - Tilemap data array

  Render tilemap from tile data array using current tileset.

---
`: spot ( int:col int:row addr:mapdata -- addr:tileaddr )`

- param `col` (int) - Tile column
- param `row` (int) - Tile row
- param `mapdata` (addr) - Tilemap data
- return `tileaddr` (addr) - Address of tile data

  Get address of specific tile in tilemap data.

---
`: xy>cr ( fixed:x fixed:y -- int:col int:row )`

- param `x` (fixed) - World X coordinate
- param `y` (fixed) - World Y coordinate
- return `col` (int) - Tile column
- return `row` (int) - Tile row

  Convert world coordinates to tile column/row.

#### Tile Metadata System

---
`: meta ( int:tileid -- int:flags )`

- param `tileid` (int) - Tile ID to check
- return `flags` (int) - Metadata flags for tile

  Get metadata flags for tile (collision, special properties).

---
`: collectible? ( -- flag:iscollectible )`

- return `iscollectible` (flag) - True if tile is collectible

  Check if current tile is collectible (metadata flag $20).

---
`: destructible? ( -- flag:isdestructible )`

- return `isdestructible` (flag) - True if tile is destructible

  Check if current tile is destructible (metadata flag $80).

---
`: solid? ( -- flag:issolid )`

- return `issolid` (flag) - True if tile is solid

  Check if current tile blocks movement (metadata flag $0F).

---
`: instakill? ( -- flag:iskill )`

- return `iskill` (flag) - True if tile kills player

  Check if current tile causes instant death (metadata flag $40).

---
`: trap? ( -- flag:istrap )`

- return `istrap` (flag) - True if tile is a trap

  Check if current tile is a trap (metadata flag $10).

---
`: load-metas ( addr:filename len:filename tileset:target -- )`

- param `filename` (addr, len) - Metadata filename
- param `target` (tileset) - Tileset to load metadata for

  Load tile metadata from file for specified tileset.

### Features

- Efficient tile rendering with automatic positioning
- Metadata system for game logic (collision, collectibles, hazards)
- Multiple tileset support
- Coordinate conversion utilities
- Hot-reload support for development

  Cross-references: Uses Engineer bitmap system, integrates with collision detection in `tmcol.vfx`, supports tile reading in `tread.vfx`.

---

<br/><br/><br/>

---

## tools.vfx - Development Tools

  Purpose: Development utilities for project management and rapid prototyping.

### Public Words

---
`: project ( -- <name> )`

  Switch to specified project directory for development.

---
`: script ( -- <name> ) ( -- )`

  Create new actor script file with standard boilerplate code.

### Features

- Project directory management
- Automatic script template generation
- Integration with hot-reload workflow

  Cross-references: Works with Supershow script loading system, Engineer file management.

---

<br/><br/><br/>

---

## shader.vfx - GPU Shader Support

  Purpose: GPU shader program management and uniform variable control.

### Public Words

---
`: load-shader ( zstring:vertexfile zstring:fragmentfile -- shader:handle )`

- param `vertexfile` (zstring) - Vertex shader filename
- param `fragmentfile` (zstring) - Fragment shader filename
- return `handle` (shader) - Compiled shader program

  Load and compile vertex and fragment shaders.

---
`: shade ( shader:handle -- )`

- param `handle` (shader) - Shader to activate (0 = disable shaders)

  Activate shader program for subsequent rendering.

---
`: sampler! ( bmp:texture int:unit zstring:name -- )`

- param `texture` (bmp) - Texture bitmap
- param `unit` (int) - Texture unit number
- param `name` (zstring) - Uniform sampler name

  Bind texture to shader sampler uniform.

---
`: float! ( float:value zstring:name -- )`

- param `value` (float) - Float value to set
- param `name` (zstring) - Uniform variable name

  Set shader float uniform variable.

---
`: vec4! ( float:x float:y float:z float:w zstring:name -- )`

- param `x` (float) - Vector X component
- param `y` (float) - Vector Y component
- param `z` (float) - Vector Z component
- param `w` (float) - Vector W component
- param `name` (zstring) - Uniform variable name

  Set shader vec4 uniform variable.

### Features

- OpenGL shader program compilation
- Automatic uniform variable binding
- Texture sampler management
- Error handling for shader compilation

  Cross-references: Used by CRT effect system (`crt.vfx`), integrates with Allegro 5 OpenGL context.

---

<br/><br/><br/>

---

## crt.vfx - CRT Display Effect

  Purpose: CRT monitor simulation with scanlines, phosphor glow, and color bleeding effects.

### Public Words

---
`: init-crt ( -- )`

  Initialize CRT shader system and load required shaders.

---
`: crt> ( -- <code> ; ) ( -- )`

  Execute rendering code with CRT post-processing effect applied.

### Features

- Authentic CRT monitor simulation
- Scanline and phosphor effects
- Color bleeding and curvature
- Customizable intensity settings

  Cross-references: Uses shader system (`shader.vfx`), integrates with main rendering pipeline.

---

<br/><br/><br/>

---

## waveplay.vfx - Audio Sample Playback

  Purpose: Audio sample management and playback system for sound effects and music.

### Public Words

#### Sample Playback

---
`: play ( smp:sample -- )`

- param `sample` (smp) - Sample handle to play

  Play audio sample once without blocking. Sample plays immediately if audio system is available.

---
`: playing? ( smp:sample -- flag:isplaying )`

- param `sample` (smp) - Sample to check
- return `isplaying` (flag) - True if sample is currently playing

  Check if sample is currently playing.

#### Sample Management

---
`: load-samples ( -- )`

  Load all audio samples from smp/ directory.

---
`: reload-samples ( -- )`

  Reload all audio samples from disk.

#### Audio Streaming

---
`: stream ( addr:filename len:filename -- )`

- param `filename` (addr, len) - Audio filename

  Stream audio file once (for long audio like music).

---
`: streamL ( addr:filename len:filename -- )`

- param `filename` (addr, len) - Audio filename

  Stream audio file with looping.

---
`: stream-gain! ( fixed:volume -- )`

- param `volume` (fixed) - Volume level (0.0 to 1.0)

  Set streaming audio volume.

#### Audio Control

---
`: hush ( -- )`

  Stop all currently playing sounds and streams.

---
`: gain ( fixed:volume -- )`

- param `volume` (fixed) - Master volume (0.0 to 1.0)

  Set master audio volume.

### Features

- Automatic sample loading from directory
- Streaming for long audio files
- Volume control for samples and streams
- Multiple simultaneous sample playback

  Cross-references: Uses Allegro 5 audio system, integrates with `bgm` and `audioclip` creation words.

---

<br/><br/><br/>

---

## tmcol.vfx - Tilemap Collision Detection

  Purpose: Efficient tilemap collision detection with corner sliding and collision state tracking.

### Public Values

---
`0 value lwall? ( -- flag )`

  Left wall collision state flag (default 0).

---
`0 value rwall? ( -- flag )`

  Right wall collision state flag (default 0).

---
`0 value floor? ( -- flag )`

  Floor collision state flag (default 0).

---
`0 value ceiling? ( -- flag )`

  Ceiling collision state flag (default 0).

### Public Words

---
`: tmcol> ( fixed:x fixed:y int:w int:h addr:mapdata actor:me -- <code> ; ) ( flag:collided -- flag:collided )`

- param `x` (fixed) - Test X position
- param `y` (fixed) - Test Y position
- param `w` (int) - Collision rectangle width
- param `h` (int) - Collision rectangle height
- param `mapdata` (addr) - Tilemap data to test against
- param `me` (actor) - Actor context for collision

  Test rectangle collision with tilemap. Code executes if collision occurs.

---
`: cut-corners ( int:amount -- )` (NEEDS EXAMPLE)

- param `amount` (int) - Corner cutting distance

  Enable smooth corner sliding for collision detection.

### Features

- Efficient rectangle-vs-tilemap collision
- Automatic collision state flag updates
- Corner sliding for natural actor movement around solid tiles
- Integration with tile metadata system

  Cross-references: Uses tilemap system (`tilemap.vfx`), integrates with actor movement, uses tile metadata for collision types.

---

<br/><br/><br/>

---

## tread.vfx - Tile Reading Utilities

  Purpose: Utilities for reading and processing tiles under rectangular areas.

### Public Words

---
`: tread> ( fixed:x fixed:y int:w int:h addr:mapdata -- <code> ; ) ( int:col int:row int:tileid -- )`

- param `x` (fixed) - Rectangle X position
- param `y` (fixed) - Rectangle Y position
- param `w` (int) - Rectangle width
- param `h` (int) - Rectangle height
- param `mapdata` (addr) - Tilemap data

  Execute code for each tile under rectangle. Code receives column, row, and tile ID.

### Features

- Efficient tile enumeration under rectangular areas
- Integration with tilemap coordinate system
- Useful for area-based tile processing

  Cross-references: Uses tilemap coordinate conversion, integrates with tile metadata system.

---

<br/><br/><br/>

---

## udlr.vfx - Directional Input Handling

  Purpose: Unified directional input handling with facing direction management.

### Public Constants

---
`constant right ( -- int:direction )`

- return `direction` (int) - Right direction constant (default 0)

  Right direction identifier.

---
`constant up ( -- int:direction )`

- return `direction` (int) - Up direction constant (default 1)

  Up direction identifier.

---
`constant left ( -- int:direction )`

- return `direction` (int) - Left direction constant (default 2)

  Left direction identifier.

---
`constant down ( -- int:direction )`

- return `direction` (int) - Down direction constant (default 3)

  Down direction identifier.

### Public Variables

---
`variable fac ( -- addr )`

  Current facing direction (right/up/left/down).

### Public Words

---
`: dirkeys? ( -- flag:pressed )`

- return `pressed` (flag) - True if any direction key is held

  Check if any directional key is currently pressed.

---
`: dirkeysup? ( -- flag:released )`

- return `released` (flag) - True if any direction key was released

  Check if any directional key was just released.

---
`: pudlr4 ( -- )`

  Set facing direction from pressed direction keys (press detection).

  Cross-references: See `sudlr4` for held key version.

---
`: sudlr4 ( -- )`

  Set facing direction from held direction keys (continuous detection).

---
`: dir>v ( int:direction -- fixed:velx fixed:vely )`

- param `direction` (int) - Direction constant
- return `velx` (fixed) - X velocity component
- return `vely` (fixed) - Y velocity component

  Convert direction constant (right=0, up=1, left=2, down=3) to fixed-point velocity vector. Returns appropriate X,Y velocity components for movement.

### Features

- Unified 4-direction input handling
- Automatic facing direction tracking
- Conversion between direction constants and velocity vectors
- Support for both press and hold detection

  Cross-references: Uses Engineer input system, integrates with actor movement and animation systems.

---

<br/><br/><br/>

---

## dltree.vfx - Doubly-Linked Tree

  Purpose: Doubly-linked tree data structure for hierarchical object management.

### Public Words

---
`: dlremove ( addr:node -- )`

- param `node` (addr) - Node to remove from tree

  Remove node from its current position in tree.

---
`: dlpush ( addr:node addr:parent -- )`

- param `node` (addr) - Node to add
- param `parent` (addr) - Parent node

  Add node at end of parent's children list.

  Cross-references: See `dlunshift` for adding at start.

---
`: dlinsert-after ( addr:node addr:dest -- )`

- param `node` (addr) - Node to insert
- param `dest` (addr) - Node to insert after

  Insert node immediately after destination node.

---
`: dlunshift ( addr:node addr:parent -- )`

- param `node` (addr) - Node to add
- param `parent` (addr) - Parent node

  Add node at start of parent's children list.

---
`: dleach ( xt:callback addr:node -- )`

- param `callback` (xt) - Function to call for each child
- param `node` (addr) - Parent node

  Execute callback for each child of node.

---
`: dlclear ( addr:node -- )`

- param `node` (addr) - Parent node

  Remove all children from node.

---
`: #children ( addr:node -- int:count )`

- param `node` (addr) - Parent node
- return `count` (int) - Number of children

  Count children of node.

---
`: nth-child ( int:index addr:node -- addr:child )`

- param `index` (int) - Child index (0-based)
- param `node` (addr) - Parent node
- return `child` (addr) - Child node at index

  Get nth child of node.

---
`: descendant? ( addr:child addr:ancestor -- flag:isdescendant )`

- param `child` (addr) - Potential descendant node
- param `ancestor` (addr) - Potential ancestor node
- return `isdescendant` (flag) - True if child is descendant of ancestor

  Check if node is descendant of another node.

### Features

- Efficient tree manipulation operations
- Parent-child relationship management
- Tree traversal utilities
- Ancestry testing

  Cross-references: Used by UI system for element hierarchy, actor parent-child relationships.

---

<br/><br/><br/>

---

## ui/ui.vfx - User Interface System

  Purpose: Hierarchical UI element system with transform inheritance and event handling.

### UI Element Fields

---
`var sx ( -- addr )`, `var sy ( -- addr )`

- return addr - Field for scale factors

  Element scale factor fields.

---
`var en ( -- addr )`

- return addr - Field for enabled flag

  Element enabled flag field.

---
`var vis ( -- addr )`

- return addr - Field for visibility flag

  Element visibility flag field.

---
`var draw ( -- addr )`

- return addr - Field for draw behavior

  Element draw behavior execution token field.

---
`var parent ( -- addr )`, `var lowest ( -- addr )`, `var highest ( -- addr )`

- return addr - Field for tree structure

  Tree structure fields for parent-child relationships.

---
`var next ( -- addr )`, `var prev ( -- addr )`

- return addr - Field for sibling links

  Sibling navigation fields.

### Public Words

---
`: element ( int:index -- element:handle )`

- param `index` (int) - Element index
- return `handle` (element) - UI element at index

  Get UI element by index.

---
`: el ( class:elementclass -- element:handle )`

- param `elementclass` (class) - Element class to instantiate
- return `handle` (element) - New UI element

  Create UI element of specified class.

---
`: el: ( class:elementclass -- <name> element:handle ) ( -- element:handle )`

- param `elementclass` (class) - Element class to instantiate
- return `handle` (element) - Named UI element

  Create named UI element of specified class.

---
`: draw> ( -- <code> ; ) ( -- )`

  Set draw behavior for current UI element.

---
`: announce ( xt:message element:target -- )`

- param `m:` (xt) - Message to send
- param `target` (element) - Target element

  Send message to element and all its children.

---
`: announce> ( element:target -- <code> ; ) ( -- )`

- param `target` (element) - Target element

  Send code as message to element and all children.

---
`: ui ( -- )`

  Process entire UI system (update and draw all elements).

---
`: p>local ( fixed:x fixed:y -- fixed:localx fixed:localy )`

- param `x` (fixed) - World X coordinate
- param `y` (fixed) - World Y coordinate
- return `localx` (fixed) - Local X coordinate
- return `localy` (fixed) - Local Y coordinate

  Convert world coordinates to local element coordinates.

---
`: >local ( int:x int:y -- int:localx int:localy )`

- param `x` (int) - World X coordinate
- param `y` (int) - World Y coordinate
- return `localx` (int) - Local X coordinate
- return `localy` (int) - Local Y coordinate

  Convert integer world coordinates to local element coordinates.

---
`: ui-update ( -- <classname> )`

  Live update UI element class during development.

  Cross-reference:  Works similarly to `update`, except it re-initializes 
  elements of the given class in the UI, rather than the stage.

---
`: isolate ( element:target -- )`

- param `target` (element) - Element to isolate

  Remove element from its siblings (disconnect from parent's child list).

---
`: element-class ( -- <name> ) ( -- class:handle )`

- return `handle` (class) - Element class handle

  Create element script class.

### Public Constants

---
`constant root ( -- element:handle )`

- return `handle` (element) - Root UI element

  Root element of UI hierarchy.

### Features

- Hierarchical element organization with automatic transform inheritance
- Message propagation through element tree
- Local coordinate system for each element
- Visibility and enabled state management
- Hot-reload support for UI development

  Cross-references: Uses doubly-linked tree system (`dltree.vfx`), integrates with actor system, uses Engineer OOP framework.


---

**Total Public API Coverage**: The Supershow engine provides approximately 200+ public words covering actor management, tilemap rendering, audio playback, collision detection, UI framework, and development tools for complete 2D game development.