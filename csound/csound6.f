library csound64.dll

function: csoundCreate ( options -- csound )
function: csoundCompile ( csound argc argv -- result )
function: csoundPerformKsmps ( csound -- result )
function: csoundStart ( csound -- int )
function: csoundStop ( csound -- )
function: csoundDestroy ( csound -- )
function: csoundCreateThread ( routine[ptr--ptr] userdata -- )
function: csoundScoreEvent ( csound type pfields count -- )
function: csoundGetChannelPtr ( CSOUND >pointerprop *name type -- n )  \ maybe not safe
function: csoundGetAudioChannel ( csound *name *samples -- )
function: csoundSetAudioChannel ( csound *name *samples -- )
function: csoundSetControlChannel ( csound *name floatval floatval -- )
function: csoundGetKsmps ( csound -- n )  \ # of samples per control frame
function: csoundSetScorePending ( csound flag -- )  \ used to stop further score events (may not be needed)
function: csoundScoreEvent ( csound type *float-pfields long-numfields -- )  \ used to update function tables (waveforms)
function: csoundTableCopyIn ( csound table# *floats -- )  \ direct alternative way (non-generative, non-normalizing)
function: csoundTableCopyOut ( csound table# *floats -- )

function: csoundPerform ( csound -- int )
function: csoundReadScore ( csound *code -- int )
function: csoundSetOption ( csound *option -- int )

\ both can be called during performance...
function: csoundCompileOrc ( csound *code -- int )
function: csoundEvalCode ( csound *code -- flt )  \ may be useful - allows return values


report( Loaded Csound 6 bindings )
