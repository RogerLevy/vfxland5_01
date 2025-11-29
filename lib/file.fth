\ Lib\Genio\file.fth - Generic I/O file device

((
Copyright (c) 2003, 2006, 2007, 2008
MicroProcessor Engineering
133 Hill Lane
Southampton SO15 5AF
England

tel: +44 (0)23 8063 1441
net: mpe@mpeforth.com
     tech-support@mpeforth.com
web: www.mpeforth.com

From North America, our telephone and fax numbers are:
  011 44 23 8063 1441


To do
=====
Rewrite to buffer output.

AddIOCTL to control OUT handling, CREATE/OPEN behaviour, and buffering.

Change history
==============
20111025 SFP005 Updated OUT in FILEDEV-TYPE.
20080416 SFP004 Replaced RFU function with READEX function.
20071106 SFP003 Added handling of OUT to EMIT/TYPE.
20060118 SFP002 Removed scratch cells from SID.
		Used common "not implemented" abort.
		Added initFileDev ( sid -- ).
		Added /FileDev ( -- len ).
20030402 SFP001 Use generic I/O handle location.
))

\ =======================================================================
( *> GENIO                                                              )
( **                                                                    )
( *N File Device                                                        )
( **                                                                    )
\ *P This Generic IO Device operates on a disk file for input
\ ** and/or output. The source code can be found in
\ ** *\i{:Lib\Genio\file.fth:}. Neither input nor output are buffered,
\ ** so that this device should not be used when speed is required.
\ ** A buffered version is available in *\i{:Lib\Genio\FileBuff.fth:}.

\ *P In order to create a device use the *\fo{:FILEDEV:} definition
\ ** given later. *\fo{:FILEDEV:} is compatible with ProForth 2.

\ *P When opening a file device the parameters to OPEN-GEN have
\ ** the following meaning:
( *E    ADDR            Address of string for filename.                 )
( **    LEN             Length of string at ADDR.                       )
( **    ATTRIBS         Open flags. These match the ANS r/o r/w etc.    )

\ *P The ReadEx function is now implemented.
\ =======================================================================

MODULE GENIO-FILE

struct /FileDev	\ -- len ; defines the SID of a file device
  gen-sid +		\ reuse field names of GEN-SID
  2 cells +		\ reserved for future use
end-struct

: >zaddr                \ addr len zaddr -- ; Copy string as 0 terminated
  2dup + 0 swap c!                      \ store 0 terminator
  swap move                             \ and move string data
;

[defined] Target_386_Windows [if]
: filedev-open          {: caddr len fam sid | zname[ MAX_PATH ] -- sid ior :}
  caddr len zname[ >zaddr               \ Make 0 terminated name string
  zname[ fam NULL NULL                  \ open or create file
  OPEN_ALWAYS NULL NULL CreateFile
  dup sid gen-handle !			\ store handle ; SFP001
  INVALID_HANDLE_VALUE =                \ set ior
  sid swap
;
[else]
: filedev-open	\ caddr len fam sid -- sid ior
  >r  3dup open-file if			\ -- caddr len fam handle : R: -- sid
    drop  create-file if		\ -- handle ; R: -- sid
      drop  r> -1
    else
      r> tuck gen-handle !  0
    endif
  else
    nip nip nip				\ -- handle ; R: -- sid
    r> tuck gen-handle !  0
  endif
;
[then]

: filedev-close         \ sid -- ior
  dup gen-handle @ >r			\ get handle and keep
  INVALID_HANDLE_VALUE swap             \ write default (INVALID) back
  gen-handle !				\ SFP001
  r> Close-File
;

: filedev-read          \ addr len sid -- ior
  gen-handle @ read-file nip
;

: filedev-write         \ addr len sid -- ior
  gen-handle @ write-file
;

: filedev-key	\ sid -- char
  {: | temp[ cell ] -- :}
  temp[ 1 rot filedev-read drop
  temp[ c@
;

: filedev-key?          \ sid -- flag
  gen-handle @ dup >r			\ SFP001
  file-size drop			\ -- ud1
  r> file-position drop			\ -- ud1 ud2
  d= 0=
;

: NotFileDev	\ --
\ Issue a FileDev error message
  1 abort" operation not supported for FILE DEVICE"
;

: filedev-ekey          \ sid -- echar
  NotFileDev	\ 1 abort" EKEY not supported for FILEDEV"
;

: filedev-ekey?         \ sid -- flag
  NotFileDev	\ 1 abort" EKEY? not supported for FILEDEV"
;

: filedev-accept        \ addr len sid -- len'
  NotFileDev	\ 1 abort" ACCEPT not supported for FILEDEV"
;

: filedev-emit?         \ sid -- flag
  drop TRUE
;

: filedev-type          \ addr len sid --
  over out +!				\ SFP005
  filedev-write drop
;

: filedev-emit          \ char sid --
  {: | temp[ cell ] -- :}
   swap temp[ c!			\ -- sid
   temp[ 1 rot filedev-write drop
   1 out +!				\ SFP003
;

: filedev-cr            \ sid --
  #13 over filedev-emit
  #10 over filedev-emit
  drop
  out off  op-line# incr
;

: filedev-lf            \ sid --
  #10 swap filedev-emit  -1 out +!	\ SFP003
;

: filedev-ff            \ sid -- ; page/cls on display devices
  #12 swap filedev-emit
;

: filedev-bs            \ sid -- ; destructive on display devices
  #8 swap filedev-emit
;

: filedev-bell          \ sid -- ; audible beeper
  NotFileDev	\ 1 abort" BELL not supported for FILEDEV"
;

: filedev-setpos        \ x y mode sid -- ior
  NotFileDev	\ 1 abort" SETPOS not supported for FILEDEV"
;

: filedev-getpos        \ mode sid -- x y ior
  NotFileDev	\ 1 abort" GETPOS not supported for FILEDEV"
;

: filedev-ioctl         \ addr len fn sid -- ior
  NotFileDev	\ 1 abort" IOCTL not supported for FILEDEV"
;

: filedev-flushOP       \ sid -- ior
  drop 0
;

: filedev-readex	\ addr len sid -- u2 ior ; SFP004
  gen-handle @ read-file
;

: filedev-init          \ addr len sid -- ior
  3drop 0	\ 1 abort" INIT not supported for FILEDEV"
;

: filedev-term          \ sid -- ior
  drop 0	\ 1 abort" TERM not supported for FILEDEV"
;

: filedev-config        \ sid -- ior ; produces a dialog
  drop 0	\ 1 abort" CONFIG not supported for FILEDEV"
;

create filedev-vectors
  ' filedev-open ,
  ' filedev-close ,
  ' filedev-read ,
  ' filedev-write ,
  ' filedev-Key ,
  ' filedev-Key? ,
  ' filedev-Ekey ,
  ' filedev-EKey? ,
  ' filedev-Accept ,
  ' filedev-Emit ,
  ' filedev-Emit? ,
  ' filedev-Type ,
  ' filedev-CR ,
  ' filedev-LF ,
  ' filedev-FF ,
  ' filedev-BS ,
  ' filedev-Bell ,
  ' filedev-setpos ,
  ' filedev-Getpos ,
  ' filedev-Ioctl ,
  ' filedev-FlushOP  ,
  ' filedev-readex ,
  ' filedev-Init ,
  ' filedev-Term ,
  ' filedev-Config ,


\ ==================
\ *H Device Creation
\ ==================

(( for DocGen
struct /FileDev	\ -- len
\ *G Returns the size of the sid structure for a file device.
))

: initFileDev	\ sid --
\ *G Initialise the sid for a file device. Mostly used when
\ ** the structure has been allocated from the heap.
  dup /filedev erase
  filedev-vectors -1 rot 2!
;

: filedev:	\ "name" -- ; Exec: -- sid
\ *G Create a File based Generic IO device in the dictionary.
  create
    here  /filedev allot  initFileDev
;

Export /filedev
Export initFileDev
EXPORT filedev:

END-MODULE


\ ======
\ *> ###
\ ======

