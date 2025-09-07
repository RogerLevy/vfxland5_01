--------------------------------------------------------------------------------
Remember!

1. Forth is about putting in only what's relevant; clarity is everything!
2. Tuck away the gory details! Make it simple for yourself later!
3. That said, DON'T BURY IMPORTANT INFORMATION - don't contradict #1!
4. Do what's obvious and minimize documentation!
5. Leave it to future you to solve the problem at hand in a simple way!
6. Divide and conquer: Dice, not slice!
7. Arriving at the general solution takes time!
8. Your stability is precious; protect it!
9. When it comes to all games and applications, the presentation and how it FEELS
    is EVERYTHING!
10. Put relationships that you want to be easy to change close to each other! (maybe?)
11. Reality is Constant Change! Forth can make it easier if you don't impede yourself!
12. Code like an artist; it's all about exploring and roughing it out first, and then filling in the details! (Forth lets you do this easy!)
13. "Layers" are a concept that Chuck didn't use. The words used by other words are always whatever is useful at the moment, ignoring the common conception of what "layer" they belong in.
14. Artistic, simple names for the digital mean understanding.  Use them instead of complexifying.

--------------------------------------------------------------------------------
Filesystem

start.bat
    just runs engineer.exe, adding engineer\bin\ to PATH
    if main.vfx is present it will be loaded automatically

main.vfx
    optional entry point

bitmaps\ - bitmaps, automatically loaded by the Engineer

lib\ - all non application-level modules, can contain git submodules
    
engineer\ - folder for engineer; git submodule? probably one day a separate project 
    engineer.vfx
    build.vfx
    build.bat
    bin\engineer.exe
    bin\*.dll - binary dependencies
    lib\*.vfx - code dependencies

--------------------------------------------------------------------------------
\ Engineer

An IDE for BUILDING game engines (it's an app, not a library!)
Versioned; every time we make a big change we increment
    (what is a big change? a bunch of new stuff that works!)
Handles creating the window, input, main loop, etc
Bare minimum wordset and functionality to start
Intention: write game(s) based on this, with their own "engines", until
    stable, common words fall out enough to the next iteration of Engineer
Tries to sandbox things in a self-contained dictionary on the system heap, so when things go wrong
    we have a higher chance of recovering (following GC-Forth's philosophy)
Imports Allegro
However, apps are NOT ALLOWED to use Allegro directly.
Custom libraries, on the other hand, are.
All the stuff that is NOT exposed to applications is kept in the `engineer.vfx` vocabulary 
Extensions use that vocabulary but don't extend it, to prevent cross-library coupling.
Apart from drastic, code-breaking versions, engineer.vfx should do as little as possible
    and expansions of functionality should be separated into additional files,
    loaded by engineer.vfx.  Maintain clarity!

--------------------------------------------------------------------------------
\ Objects

This is my style of Forth OOP, refined over many years.
We have structs and objects.
Objects are structs that have a class defined in the first cell.
Classes facilitate message-passing, allocation, and shared data and code.
Classes have message responses and static fields.
The user is responsible for allocation and initialization.
Fields work in the conventional way. ( a - a )
We also have vars, which use `me` as the base address.  (Though you can
    use `->` to access the field of an object on the stack.)
There is no enforced namespacing, that's up to the user.
