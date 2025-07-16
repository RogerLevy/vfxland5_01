<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; to start, everything is controlled with forth (and potentially portmidi)
;  communication is with a-rate channels (audio buffers) - in effect, the system supports up to 64 of any one thing.

; wave osc  - wave, pitch, amp, sends
;  the first 4 wave oscillators have interpolation, and the last 4 don't (more high frequency content)
; noise osc -        pitch, amp, sends

; 4 "sends" dry <- reverb <- delay <- moogladder
; each send except dry has a dry/wet send value

; the global mixer has lowpass, highpass, and clip



sr = 44100 ;44.1khz sample rate
ksmps = 128 ;# of samples in control frame (300/sec, or 5 times a 60hz frame)
nchnls = 1 ;mono output
0dbfs = 1  ;industry standard 1.0 = full amplitude

; to update function tables, the Forth client will send string messages (orchestra code)



alwayson "glob"

;#define send1ndx #59#
;#define send2ndx #60#
;#define send3ndx #61#
;#define send4ndx #62#
;#define globalndx #63#

; Global vars
gaPitch init 500
gaWave init 3
gaAmp init 1
; the fx stages can also send (but not all sends will work, because of feedback loops)
gaSend1 init 0  ;moog
gaSend2 init 0  ;delay
gaSend3 init 0  ;reverb
gaSend4 init 1  ;dry     - default is every fx stage goes straight to the final mix stage
gkDelaytime init 250
gkDelaydecay init .5
gkLadderlpfreq init 1
gkLadderlpres init .25
gkGloballpfreq init 1
gkGlobalhpfreq init 0

gaDelaybuf init 0

; ============================ OSCILLATORS ====================================

; no interpolation - wave is crisper when playing low notes, but sounds bad on high notes
instr 10, waveosc
   kndx     = p4
   kamp     vaget kndx, gaAmp
   kpitch   vaget kndx, gaPitch
   kwave    vaget kndx, gaWave
   aphs     phasor kpitch
   a1       tablekt aphs, kwave, 1, 0, 1 ; none
   a1 = a1 * kamp
   ksend1   vaget kndx, gaSend1
   ksend2   vaget kndx, gaSend2
   ksend3   vaget kndx, gaSend3
   ksend4   vaget kndx, gaSend4
            MixerSend a1*ksend1, 10, 100, 0
            MixerSend a1*ksend2, 10, 101, 0
            MixerSend a1*ksend3, 10, 102, 0
            MixerSend a1*ksend4, 10, 103, 0
            out a1
endin

; interpolation - sounds better on high notes, and low notes are "soft" sounding
instr 11, waveosci
   kndx     = p4
   kamp     vaget kndx, gaAmp
   kpitch   vaget kndx, gaPitch
   kwave    vaget kndx, gaWave
   aphs     phasor kpitch
   a1       tablexkt aphs, kwave, 1, 4, 1, 0, 1 
   a1 = a1 * kamp
   ksend1   vaget kndx, gaSend1
   ksend2   vaget kndx, gaSend2
   ksend3   vaget kndx, gaSend3
   ksend4   vaget kndx, gaSend4
            MixerSend a1*ksend1, 11, 100, 0
            MixerSend a1*ksend2, 11, 101, 0
            MixerSend a1*ksend3, 11, 102, 0
            MixerSend a1*ksend4, 11, 103, 0
            out a1
endin


instr 20, dnoiseosc
   kndx     = p4
   kamp     vaget kndx, gaAmp
   kpitch   vaget kndx, gaPitch
   kwave    vaget kndx, gaWave
   ash      mpulse 1, 1/kpitch
   anois    noise 1, 0
   anois    round anois
   anois = anois * kamp
   a1       samphold anois, ash
   ksend1   vaget kndx, gaSend1
   ksend2   vaget kndx, gaSend2
   ksend3   vaget kndx, gaSend3
   ksend4   vaget kndx, gaSend4
            MixerSend a1*ksend1, 20, 100, 0
            MixerSend a1*ksend2, 20, 101, 0
            MixerSend a1*ksend3, 20, 102, 0
            MixerSend a1*ksend4, 20, 103, 0

            out a1
endin

; ================================ FX ====================================

instr 100, moogfx
   kndx     = p4
   ain      MixerReceive 100, 0
   a1       moogladder ain, gkLadderlpfreq*22050, gkLadderlpres
   ksend2   vaget kndx, gaSend2
   ksend3   vaget kndx, gaSend3
   ksend4   vaget kndx, gaSend4
            MixerSend a1*ksend2, 59, 101, 0
            MixerSend a1*ksend3, 59, 102, 0
            MixerSend a1*ksend4, 59, 103, 0
endin

instr 101, delayfx
   kndx     = p4
   ain MixerReceive 101, 0
   ain sum ain, gaDelaybuf
   gaDelaybuf vdelay ain*gkDelaydecay, gkDelaytime, 10000 ; 10 second maximum
   ; gaDelaybuf vdelay ain, gkDelaytime, 10000 ; 10 second maximum
   ksend3   vaget kndx, gaSend3
   ksend4   vaget kndx, gaSend4
            MixerSend gaDelaybuf*ksend3, 60, 102, 0
            MixerSend gaDelaybuf*ksend4, 60, 103, 0
endin

instr 102, reverbfx
   kndx     = p4
   a1 MixerReceive 102, 0
   ; NOOP for now
   ksend4   vaget kndx, gaSend4
            MixerSend a1*ksend4, 61, 103, 0
endin

; =============================== MIXER ====================================

instr 200, glob

   ;get software channel data
   gaPitch chnget "pitch"
   gaWave chnget "wave"
   gaAmp chnget "amp"
   gaSend1 chnget "send1"
   gaSend2 chnget "send2"
   gaSend3 chnget "send3"
   gaSend4 chnget "send4"
   ; gaDelaytime chnget "delaytime"
   gkDelaytime chnget "delaytime"
   gkDelaydecay chnget "delaydecay"
   gkLadderlpfreq chnget "ladderfreq"
   gkLadderlpres chnget "ladderres"
   gkGloballpfreq chnget "globallp"
   gkGlobalhpfreq chnget "globalhp"
   

   ;osc-out sends
   MixerSetLevel_i 10, 100, 1
   MixerSetLevel_i 10, 101, 1
   MixerSetLevel_i 10, 102, 1
   MixerSetLevel_i 10, 103, 1
   MixerSetLevel_i 11, 100, 1
   MixerSetLevel_i 11, 101, 1
   MixerSetLevel_i 11, 102, 1
   MixerSetLevel_i 11, 103, 1
   ; fx-out sends
   MixerSetLevel_i 59, 101, 1
   MixerSetLevel_i 59, 102, 1
   MixerSetLevel_i 59, 103, 1
   MixerSetLevel_i 60, 102, 1
   MixerSetLevel_i 60, 103, 1
   MixerSetLevel_i 61, 103, 1

   a1 subinstr "waveosci", 0
   a1 subinstr "waveosci", 1
   a1 subinstr "waveosci", 2
   a1 subinstr "waveosci", 3
   a1 subinstr "waveosci", 4
   a1 subinstr "waveosc", 5
   a1 subinstr "waveosc", 6
   a1 subinstr "waveosc", 7
   a2 subinstr "dnoiseosc", 8
   a2 subinstr "dnoiseosc", 9

   aret1 subinstr "moogfx", 59;$send1ndx
   aret2 subinstr "delayfx", 60;$send2ndx
   aret3 subinstr "reverbfx", 61;$send3ndx
   aret4 MixerReceive 103, 0

   aglobal sum aret1, aret2, aret3, aret4
   aout = aglobal * .05

   aout clip aout, 0, 1.0

   aout butterlp aout, gkGloballpfreq*sr*.5
   aout butterhp aout, gkGlobalhpfreq*sr*.5

   kglobamp vaget 63,gaAmp
   out aout*kglobamp

   MixerClear

endin

</CsInstruments>
<CsScore>
; test wavetables


; uhhhh
f 0 0 32 10 1

; sine
f1 0 32 10 1

; triangle
f2 0 32 2 \
 -1.0000000 -0.8666666 -0.7333333 -0.6000000 -0.4666666 -0.3333333 -0.2000000 -0.0666666 0.0666666 0.1999999 0.3333333 0.4666666 0.5999999 0.7333333 0.8666666 1.0000000
 1.0000000 0.8666666 0.7333333 0.5999999 0.4666666 0.3333333 0.1999999 0.0666666 -0.0666666 -0.2000000 -0.3333333 -0.4666666 -0.6000000 -0.7333333 -0.8666666 -1.0000000

; pwm50
f3 0 32 2 \
   1.0 0.7999999 0.7999999 0.7999999  0.7999999 0.7999999 0.7999999 0.7999999  0.7999999 0.7999999 0.7999999 0.7999999  0.7999999 0.7999999 0.7999999 1.0 \
   -1 -0.8000000 -0.8000000 -0.8000000  -0.8000000 -0.8000000 -0.8000000 -0.8000000  -0.8000000 -0.8000000 -0.8000000 -0.8000000  -0.8000000 -0.8000000 -0.8000000 -1

; saw
f4 0 32 7    1 32 -1

; f4 0 32 16 1 32 0 0
;f4 0 32 2 \
; -1.0000000 -0.8666666 -0.7333333 -0.6000000 -0.4666666 -0.3333333 -0.2000000 -0.0666666 0.0666666 0.1999999 0.3333333 0.4666666 0.5999999 0.7333333 0.8666666 1.0000000 \
; -1.0000000 -0.8666666 -0.7333333 -0.6000000 -0.4666666 -0.3333333 -0.2000000 -0.0666666 0.0666666 0.1999999 0.3333333 0.4666666 0.5999999 0.7333333 0.8666666 1.0000000
;   42 34 29 28  27 26 25 24  23 22 21 20  19 18 17 16 \
;   15 14 13 12  11 10 9 8    7 6 5 4      3 2 -3 -10

; user1

f5 0  32  2   \
00.000000 -0.5000000 0.5000000 -0.3400000 0.3199999 0.5399999 0.7599999 0.8999999 1.0000000 -1.0000000 -0.6000000 00.000000 -0.6000000 -1.0000000 -0.6000000 -0.4000000 0.1999999 0.3999999 0.5999999 0.7999999 0.5999999 -0.8000000 00.000000 \
-0.6000000 0.1999999 -0.4000000 0.3999999 0.5999999 -1.0000000 -1.0000000 -0.6000000 -0.4000000 



; user2
f6 0  32  2   \
-1.0000000 0.7999999 -0.1200000 0.0999999 0.3199999 0.5399999 -0.5600000 -1.0000000 1.0000000 00.000000 -1.0000000 00.000000 -0.6000000 1.0000000 -1.0000000 -0.4000000 0.1999999 0.3999999 0.5999999 -0.2000000 -0.4000000 -0.8000000 1.0000000 \
-0.6000000 -1.0000000 -1.0000000 -1.0000000 1.0000000 -1.0000000 00.000000 -1.0000000 -1.0000000  

; user3
;   __--
; + _-_-
; =  __-
;   _
f7 0  32  2   \
   -1 -1 -1 -1  -1 -1 -1 -1  0 0 0 0  0 0 0 0 \
   0 0 0 0  0 0 0 0  1.0 1.0 1.0 1.0  1.0 1.0 1.0 1.0

; user4
f8 0  32  2 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1

; user5
f9 0  32  2 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1 1

; user6
f10 0  32  2 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1 1 1

; user7
f11 0  32  2 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1 1 1 1

; user8
f12 0  32  2 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1 1 1 1 1


f13 0  32  2   \
00.000000 -0.5000000 0.5000000 -0.3400000 0.3199999 0.5399999 0.7599999 0.8999999 1.0000000 -1.0000000 -0.6000000 00.000000 -0.6000000 -1.0000000 -0.6000000 -0.4000000 0.1999999 0.3999999 0.5999999 0.7999999 0.5999999 -0.8000000 00.000000 \
-0.6000000 0.1999999 -0.4000000 0.3999999 0.5999999 -1.0000000 -1.0000000 -0.6000000 -0.4000000 

f14 0  32  2   \
-1.0000000 0.7999999 -0.1200000 0.0999999 0.3199999 0.5399999 -0.5600000 -1.0000000 1.0000000 00.000000 -1.0000000 00.000000 -0.6000000 1.0000000 -1.0000000 -0.4000000 0.1999999 0.3999999 0.5999999 -0.2000000 -0.4000000 -0.8000000 1.0000000 \
-0.6000000 -1.0000000 -1.0000000 -1.0000000 1.0000000 -1.0000000 00.000000 -1.0000000 -1.0000000  

f15 0  32  2   \
   -1 -1 -1 -1  -1 -1 -1 -1  0 0 0 0  0 0 0 0 \
   0 0 0 0  0 0 0 0  1.0 1.0 1.0 1.0  1.0 1.0 1.0 1.0

f16 0  32  2 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \
   -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1



;i10 0 1 0

e 999999999999999
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
