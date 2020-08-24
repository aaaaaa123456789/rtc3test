; Mostly taken from hardware.inc (https://github.com/gbdev/hardware.inc)

rDIV  EQU $FF04
rTIMA EQU $FF05
rTMA  EQU $FF06
rTAC  EQU $FF07
rIF   EQU $FF0F
rNR52 EQU $FF26
rLCDC EQU $FF40
rSCY  EQU $FF42
rSCX  EQU $FF43
rBGP  EQU $FF47
rVBK  EQU $FF4F
rBCPS EQU $FF68
rBCPD EQU $FF69
rIE   EQU $FFFF

; MBC3 constants

rRAMG EQU $0000
rRAMB EQU $4000
rRTCL EQU $6000 ; no standard name... hardware.inc only cares about MBC5 :(

; there's no sensible prefix for these, so just leave them unprefixed as the constants they are
RTCS  EQU 8
RTCM  EQU 9
RTCH  EQU 10
RTCDL EQU 11
RTCDH EQU 12
