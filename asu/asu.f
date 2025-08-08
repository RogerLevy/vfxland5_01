\ Audio Synthesis Unit
\ v1.00

fload asutables

\ ---------------------------------------------------

0 value csound
0 value chn

variable csound-status
variable csound-time


fvariable delaydecay 0.5e delaydecay f!
fvariable delaytime 1000e delaytime f!
fvariable lfreq 1e lfreq f!
fvariable lres 0e lres f!
fvariable globlp 1e globlp f!
fvariable globhp 0e globhp f!


: file,
   R/O open-file throw >r
   here
   r@ file-size 2drop dup allot 0 c,
               r@ read-file throw drop
   r> close-file throw ;

create orc " asu.orc" file,
create sco " asu.sco" file,


: init-audio
   [[
      0 csoundCreate to csound
      csound z" -B256" csoundSetOption throw
      csound z" -odac" csoundSetOption throw
      csound orc csoundCompileOrc throw
      csound sco csoundReadScore throw
      csound csoundStart throw
   ]] catch abort" There was a problem in init-audio"
   ;


: apu!   chn 2 cells * + f! ;
: apu[]   2 cells * + ;


\ : create-struct-ifield  ( n size -- <name> n+size )
\   create over , + does> @ struct + ;
\
\ ['] create-struct-ifield is create-ifield ;

0
   prop addr
   8 nprop destval  \ float
   8 nprop stepval  \ float
constant /rampctl

\ general-structs

create ampramps 10 /rampctl array,
create freqramps 10 /rampctl array,

: stop-ramp
   dup >destval f@ dup >addr @ f! 0e dup >stepval f! ;


: do-ramp
   to struct
   stepval f@ 0e f= ?exit
   stepval f@ addr @ f+!
   stepval f@ f0< if
        addr @ f@ destval f@ f< if stop-ramp then
   else
        addr @ f@ destval f@ f> if stop-ramp then
   then ;

: do-ramp
   dup >stepval f@ 0e f= if drop exit then
   dup >stepval f@ dup >addr @ f+!
   dup >stepval f@ f0< if
        dup >addr @ f@ dup >destval f@ f< if stop-ramp then
   else
        dup >addr @ f@ dup >destval f@ f> if stop-ramp then
   then  drop ;

\ ugly workaround - we have to avoid touching any "current" variables outside of the task
\ this creates a nasty coupling to array.f but ... i don't see any changes being made to that file in this project.
0 value arr
: _EACH   ( XT array -- ) ( ... addr -- ... ) \ itterate on array
   dup >#items @ 0= if 2drop EXIT then
   to arr
   arr >items arr (#items) arr >itemsize @ * BOUNDS DO
      i over >r swap EXECUTE r>
   arr >itemsize @ +LOOP
   DROP ;


: init-ramps
   0 locals| i |
   [[ 0e dup >stepval f! chnamp i apu[] swap >addr ! 1 +to i  ]] ampramps _each
   0 to i
   [[ 0e dup >stepval f! chnfreq i apu[] swap >addr ! 1 +to i ]] freqramps _each ;

: do-ramps
   ['] do-ramp ampramps _each
   ['] do-ramp freqramps _each ;


defer musictick  ' noop is musictick

: apuupd
   csound z" amp" chnamp csoundSetAudioChannel
   csound z" wave" chnwave csoundSetAudioChannel
   csound z" pitch" chnfreq csoundSetAudioChannel
   csound z" send1" chnsend1 csoundSetAudioChannel
   csound z" send2" chnsend2 csoundSetAudioChannel
   csound z" send3" chnsend3 csoundSetAudioChannel
   csound z" send4" chnsend4 csoundSetAudioChannel
   csound z" delaydecay" delaydecay 2@ csoundSetControlChannel
   csound z" delaytime" delaytime 2@ csoundSetControlChannel
   csound z" ladderfreq" lfreq 2@ csoundSetControlChannel
   csound z" ladderres" lres 2@ csoundSetControlChannel
   csound z" globallp" globlp 2@ csoundSetControlChannel
   csound z" globalhp" globhp 2@ csoundSetControlChannel
;

: soundframe
   csound csoundPerformKsmps csound-status !
;

: apuframe
   [[ musictick do-ramps apuupd soundframe ]] exectime csound-time !   ;

[[ drop   64 fstack begin apuframe csound-status @ until  1 ]] 1 cb: mycb

: apugo   mycb 0 csoundCreateThread ;

: /sec   300e f/ ;

: ?neg   chn apu[] f@ f< if fnegate then ;


\ ---------------------------------------------------------------

: ch   63 and to chn ;
: wtosc   7 and to chn ;
: dnois   1 and 8 + to chn ;
: send1   59 to chn ;
: send2   60 to chn ;
: send3   61 to chn ;
: send4   62 to chn ;
: master  63 to chn ;

: amp  chnamp apu! ;
: pitch   ( note -- ) etfreq chnfreq apu! ;
: wave   15 and 1 + s>f chnwave apu!  ;

: glide  ( destnote  f:rate/sec -- )  /sec fover etfreq chnfreq ?neg   chn freqramps [] =>   stepval f!  etfreq destval f! ;
: atten  ( f:destamp  f:rate/sec -- ) /sec fover chnamp ?neg   chn ampramps [] =>   stepval f!  destval f! ;

: muteall  16 0 do 0e i to chn amp loop ;

: change   ( n. length. addr -- ) fdrop f! ;


: init-asu
   init-audio
   init-ramps
   muteall
   apugo ;

: close-asu
   csound csoundStop
   csound csoundDestroy
   ;

:prune ?prune if close-asu then ;

init-asu
