\ ConfigTools.fth - configuration files using Forth interpreter.

((
Copyright (c) 2006, 2007
MicroProcessor Engineering
133 Hill Lane
Southampton SO15 5AF
England

tel:   +44 (0)23 8063 1441
email: mpe@mpeforth.com
       tech-support@mpeforth.com
web:   htpp://www.mpeforth.com
Skype: mpe_sfp

From North America, our telephone and fax numbers are:
       011 44 23 8063 1441
       901 313 4312 (North American access number to UK office)


To do
=====

Change history
==============
20100616 SFP003 v4.4 correction.
20071218 SFP002 Added NUM/Constant if not already defined.
		Added more documentation.
20060220 SFP001 Corrected \EMIT.
		Reformatted output of Z$VAR to support long strings.
		Updated documentation.
))

only forth definitions
decimal

Module Configuration

[-sin

\ ===========
\ *> library
\ *S Configuration files
\ ===========
\ *P Application configuration can be done in a number of ways,
\ ** especially under Windows.
\ *D Registry	A user nightmare to copy from one machine to another
\ *D INI files  Very slow for large configurations (before mpeparser.dll)
\ *D binary	Usually incompatible between versions
\ *D database	Big and often similar to binary
\ *D Forth	Already there, needs changes to interpreter.
\ **            Independent of operating system.

\ *P A solution to this problem is available in *\i{Lib/ConfigTools.fth}.
\ ** Before compiling the file, ensure that the file GenIO device from
\ ** *\i{Lib/Genio/FILE.FTH} has been compiled.

\ *P The Forth interpreter is already available, but we have to
\ ** consider how to handle incompatibilities between configuration
\ ** files and issue versions of applications. The two basic
\ ** solutions are:
\ *B Abort on error
\ *B Ignore on error
\ *P The abort on error solution is already available - it just
\ ** requires the caller of *\fo{included} to provide some
\ ** additional clean up code.
\ *E : CfgIncluded	\ caddr len --
\ **   -source-files            \ don't add source file names
\ **   ['] included catch
\ **   if  2drop  endif         \ clean stack on error
\ **   +source-files            \ restore source action
\ ** ;

\ *P In VFX Forth, *\fo{INTERPRET} is used to process lines of
\ ** input. *\fo{INTERPRET} is *\fo{DEFER}red and the default
\ ** action is *\fo{(INTERPRET)}. The maximum line size
\ ** (including CR/LF) is *\fo{FILETIBSZ}, which is currently
\ ** 512 bytes. If we restrict each configuration unit to one
\ ** line of source code, we can protect the system by ignoring
\ ** the line if an error occurs. We also have to introduce the
\ ** convention in configuration files that actions are performed
\ ** by the last word on the line (except for any parsing).
\ ** This action has to be installed and removed, leading to
\ ** the following code.

\ *E : CfgInterp     \ --
\ ** \ Interprets a line, discarding it on error.
\ **   ['] (interpret) catch
\ **   if  postpone \  endif
\ ** ;
\ **
\ ** : CfgIncluded   \ caddr len --
\ ** \ Interprets a file, discarding lines with errors.
\ **   -source-files                 \ don't add source file names
\ **   behavior interpret >r
\ **   ['] CfgInterp is interpret
\ **   ['] included catch
\ **   if  2drop  endif              \ clean stack on error
\ **   r> is interpret
\ **   +source-files                 \ restore source action
\ ** ;


\ *****************************************
\ *N Loading and saving configuration files
\ *****************************************

: CfgInterp     \ --
\ *G A protected version of *\fo{(INTERPRET)} which discards any
\ ** line that causes an error.
  ['] (interpret) catch
  if  postpone \  endif
;

also system
: CfgIncluded   \ caddr len --
\ *G A protected version of *\fo{INCLUDED} which discards any
\ ** line that causes an error, and carries on through the
\ ** source file.
  2dup FileExist? 0=
  if  2drop  exit  endif
  -source-files                 	\ don't add source file names
  action-of interpret >r
  ['] CfgInterp is interpret
  bVerboseInclude? >r
  0 -> bVerboseInclude?
  ['] included catch
  if  2drop  endif              	\ clean stack on error
  r> -> bVerboseInclude?
  r> is interpret
  +source-files                 	\ restore source action
;
previous

struct /sc	\ -- len
\ Data for configuration file device.
  /filedev field sc.sid		\ must be first
  int sc.OP			\ old OP-HANDLE
  int sc.base			\ old BASE
  int sc.bVI			\ old bVerboseInclude?
  int sc.out			\ old OUT
end-struct

also system
: [SaveConfig	\ caddr len -- struct|0
\ *G Starts saving a configuration file. Creates a configuration
\ ** file and allocates required resources, returning a structure
\ ** on success or zero on error. On success, the
\ ** returned *\i{struct} contains the *\fo{sid} for the file at
\ ** the start of *\i{struct}.
  2dup delete-file drop			\ delete if exists
  /sc allocate
  if  drop 2drop  0  exit  endif
  dup >r sc.sid initFileDev		\ -- caddr len ; R: -- sid
  op-handle @ r@ sc.OP !		\ preserve current o/p device
  base @ r@ sc.base !			\ base
  bVerboseInclude? r@ sc.bVI !		\ include verbosity
  out @ r@ sc.out !
  w/o r@ open-gio nip
  if  r> free drop  0  exit  endif
  decimal
  0 -> bVerboseInclude?
  out off
  r> dup op-handle !			\ make this the current o/p
;

: SaveConfig]	\ struct --
\ *G Ends saving a file device by closing the file, releasing
\ ** resources and restoring the previous output device.
  ?dup 0= if  exit  endif
  dup sc.sid close-gio drop
  dup sc.OP @ op-handle !
  dup sc.base @ base !
  dup sc.bVI @ -> bVerboseInclude?
  dup sc.out @ out !
  free drop
;
previous

: SaveConfig	\ caddr len xt --
\ *G Save the configuration file, using *\i{xt} to generate the
\ ** text using *\fo{TYPE} and friends. The word defined by
\ ** *\i{xt} must have no stack effect.
  -rot  [SaveConfig dup 0= if		\ -- xt fd|0
    2drop exit
  endif
  >r  catch drop  r> SaveConfig]
;


\ **************************
\ *N Loading and saving data
\ **************************
\ *P We chose to support five type of configuration data:
\ *B Single integers at given addresses. This copes with
\ ** *\fo{variable}s directly and *\fo{value}s with *\fo{addr}.
\ *B Double integers at given addresses.
\ *B Counted strings
\ *B Zero terminated strings
\ *B Memory blocks.

\ *P All numeric output is done in hexadecimal to save space,
\ ** and to avoid problems with *\fo{BASE} overrides. All words
\ ** which generate configuration information *\b{must} be used
\ ** in colon definitions.

: \Emit		\ char --
\ *G Output a printable character in its escaped form.
  dup upc [char] A [char] Z within?	\ check for A..Z, a..z
  if  emit exit  endif
  dup [char] \ =
  if  drop ." \\"  exit  endif
  EscapeTable #26 bounds do		\ -- char
    dup i c@ = if
      drop  [char] \ emit
      [char] a i EscapeTable - + emit
      unloop  exit
    endif
  loop
  emit
;

: \Type		\ caddr len --
\ *G Output a printable string in its escaped form.
  bounds ?do  i c@ \Emit  loop
;

: .cfg$		\ caddr len --
\ *G Output a string in its escaped form, characters in the
\ ** escape table being converted to their escaped form. The
\ ** string is output as Forth source text, e.g.
\ *C   s\" escaped text\n\n"
  S\" s\\\" " type  \Type  S\" \" " type
;

: .sint		\ x --
\ *G Output x as a hex number with a leading '$' and a trailing
\ ** space, e.g.
\ *C   $1234:ABCD
  ." $" .dword space			\ value
;

: SimpleCfg,	\ xt --
\ Compiler for SimpleCfg: below.
  discard-sinline			\ the word will parse ; SFP003
  >body @ postpone [']  compile,
;

: SimpleCfg:	\ xt -- ; --
\ Generates a configuration type that only needs an xt.
  create
    ,  ['] SimpleCfg, set-compiler
  interp>
    @ ' swap execute
;
(( before v4.3
: SimpleCfg:	\ xt -- ; --
\ Generates a configuration type that only needs an xt.
  create immediate
    ,
  does>
    @  state @ if
      postpone [']  compile,
    else
      ' swap execute
    endif
;
))


\ ******************
\ *H Single Integers
\ ******************
\ *P Single integers are saved by *\fo{.SintVar} and
\ ** *\fo{.SintVal}.

: (SIntVar)	\ xt --
  dup execute @ .sint			\ value
  >name .name ." !"			\ name and !
  cr
;

' (SintVar) SimpleCfg: .SIntVar	\ "<name>" --
\ *G Saves a single integer as a string. *\fo{<name>} must
\ ** be a Forth word that returns a valid address. Generates
\ *C  $abcd <name> !
\ *P Use in the form:
\ *C  .SIntVar MyVar

: (SIntVal)	\ xt --
\  dup >body @ .sint			\ value
  dup execute .sint			\ returns contents by default
  ." to " >name .name			\ to name
  cr
;

' (SintVal) SimpleCfg: .SIntVal	\ "<name>" --
\ *G Saves a *\fo{VALUE} called *\fo{<name>}. Generates
\ *C  $abcd to <name>
\ *P Use in the form:
\ *C  .SIntVal MyVal


\ ******************
\ *H Double Integers
\ ******************
\ *P Double integers are saved by *\fo{.DintVar}.

: (DIntVar)	\ xt --
  dup execute 2@ swap .sint .sint	\ value
  >name .name ." 2!"			\ name and !
  cr
;

' (DintVar) SimpleCfg: .DIntVar	\ "<name>" --
\ *G Saves a double integer as a string. *\fo{<name>} must
\ ** be a Forth word that returns a valid address. Generates
\ *C  $01234 $abcd <name> 2!
\ *P Use in the form:
\ *C  .SIntVar MyVar


\ ******************
\ *H Counted strings
\ ******************
\ *P Counted strings are saved by *\fo{.C$CFG}.

: (c$cfg)	\ xt --
  dup execute count .cfg$		\ string
  >name .name ." place"			\ name and place
  cr
;

' (c$cfg) SimpleCfg: .C$var	\ "<name>" --
\ *G Saves a string *\fo{<name>} must
\ ** be a Forth word that returns a valid address. Generates
\ *C  s\" <text>" <name> place
\ *P Use in the form:
\ *C  .C$Var MyCstring


\ **************************
\ *H Zero terminated strings
\ **************************
\ *P Zero terminated strings are saved by *\fo{.Z$var}.

: .max60	\ caddr len -- caddr' len'
\ Display up to 60 characters and return residue.
  2dup #60 min dup >r .cfg$ r> /string
;

: (z$cfg)   \ xt --
  dup >name >r  execute zcount		\ -- caddr len ; R: -- name
  .max60  r@ .name ." zplace" cr
  begin
    dup
   while
    .max60  r@ .name ." zAppend" cr
  repeat
  2drop  r> drop
;

' (z$cfg) SimpleCfg: .Z$var	\ "<name>" --
\ *G Saves a zero terminated string at *\fo{<name>} which must
\ ** be a Forth word that returns a valid address. The output
\ ** consists of one or more lines of source code, following
\ ** lines being appended to the first.
\ *C  s\" <text>" <name> zplace
\ *C  s\" <more text>" <name> zAppend
\ *C  ...
\ *P Use in the form:
\ *C  .Z$var MyZstring


\ ****************
\ *H Memory blocks
\ ****************
\ *P Memory blocks are output by
\ *C   .Mem <name> len
\ *P *\fo{<Name>} must be a Forth word that returns a valid
\ ** address. *\fo{Len} must be a constant or a number.
\ ** The output takes one of three forms, depending on *\fo{len}.
\ *C   bmem <name> num  $ab $cd ...
\ *C   wmem <name> num  $abcd $1234 ...
\ *C   lmem <name> num  $1234:5678 $90ab:cdef ...

: NewLine	\ --
  cr  2 spaces
;

: ?NewLine	\ --
  out @ #66 > if  NewLine   endif
;

: .Prologue	\ xt len -- caddr len
\ Print xt's name and execute it to get the data address.
  swap dup >name .name  execute swap	\ name
  dup .sint  Newline			\ len and CR
;

: .Epilogue	\ --
  out @ if  cr  endif
;

: (.bmem)	\ xt len --
  ." BMEM " .Prologue  bounds ?do
    i c@ ." $" .byte space  ?NewLine
  loop
  .Epilogue
;

: (.wmem)	\ xt len --
  ." WMEM " .Prologue  bounds ?do
    i w@ ." $" .word space  ?NewLine
  2 +loop
  .Epilogue
;

: (.lmem)	\ xt len --
  ." LMEM " .Prologue  bounds ?do
    i @ ." $" .dword space  ?NewLine
  4 +loop
  .Epilogue
;

: (.mem)	\ xt len --
  dup 3 and 0=
  if  (.lmem)  exit  endif
  dup 1 and 0=
  if  (.wmem)  exit  endif
  (.bmem)
;

[undefined] Num/Constant [if]
: Num/Constant	\ caddr -- n
  find if
    execute
  else
    number? 1 <> abort" Not a single integer."
  endif
;
[then]

: getNum	\ -- u
  bl get-word Num/Constant
;

: getRange	\ -- limit start
  ' execute  getNum  bounds
;

: .Mem		\ "<name>" "len" --
\ *P A block of memory is output by
\ *C   .Mem <name> len
\ *P *\fo{<Name>} must be a Forth word that returns a valid
\ ** address. *\fo{Len} must be a constant or a number.
  '  getNum  state @ if		\ -- xt len
    postpone dliteral  postpone (.mem)
  else
    (.mem)
  endif
; immediate

: BMEM		\ "<name>" "len" --
\ *G Imports a memory block output in byte units by *\fo{.Mem}.
  getRange
  ?do  getNum i c!  loop
;

: WMEM		\ "<name>" "len" --
\ *G Imports a memory block output in word (2 byte) units by *\fo{.Mem}.
  getRange
  ?do  getNum i w!  2 +loop
;

: LMEM		\ "<name>" "len" --
\ *G Imports a memory block output in cell (4 byte) units by *\fo{.Mem}.
  getRange
  ?do  getNum i !  4 +loop
;

sin]

Export CfgInterp
Export CfgIncluded
Export [SaveConfig
Export SaveConfig]
Export SaveConfig
Export \Emit
Export \Type
Export .cfg$
Export .Sint
Export .SintVar
Export .SintVal
Export .DIntVar
Export .C$Var
Export .Z$Var
Export .Mem
Export BMEM
Export WMEM
Export LMEM

End-Module


\ ======
\ *> ###
\ ======

decimal
