lorom

incsrc labels.asm
incsrc sprites.asm
incsrc macros.asm

org $008000
incsrc init.asm
incsrc gameloop.asm
incsrc spc.asm
incsrc rand.asm

struct OAM $000400
	.x: skip 1
	.y: skip 1
	.index: skip 1
	.props: skip 1
endstruct

; $F0           : AXLR ----
; $F1           : BYsS udlr
; $0300         : frames left held
; $0301         : frames right held
; $0302         : frames up held
; $0303         : frames down held
; $0304         : frames A held
; $0400 - $061F : OAM Mirror
; $0700 - $077F : Board data


HandleJoypad:
-	LDA.w $4212 : BIT.b #$01 : BNE -
	LDA.w $4218 : STA.b $F0
	LDA.w $4219 : STA.b $F1

	LDA.b $F1 : BIT.b #$02 : BEQ +
	INC.w $0300 : BRA ++
+	STZ.w $0300
++
+	LDA.b $F1 : BIT.b #$01 : BEQ +
	INC.w $0301 : BRA ++
+	STZ.w $0301
++
+	LDA.b $F1 : BIT.b #$08 : BEQ +
	INC.w $0302 : BRA ++
+	STZ.w $0302
++
+	LDA.b $F1 : BIT.b #$04 : BEQ +
	INC.w $0303 : BRA ++
+	STZ.w $0303
++
+	LDA.b $F0 : BIT.b #$80 : BEQ +
	INC.w $0304 : BRA ++
+	STZ.w $0304
++
	RTS

print "NMIHandler: ", pc
NMIHandler:
	PHX : PHY : PHA : PHP
	SEP #$30
	JSR InitBG4
	LDA.w $4210
	JSR HandleJoypad
	JSR CopyBoardToVRAM
	JSR CopyOAM
	PLP : PLA : PLY : PLX
	RTI

IRQHandler:
	RTI

warnpc $FFC0

org $FFC0
db "SPLOOSH KABOOM       "
db $20 ; lorom
db $02 ; ROM + RAM + Battery
db $0A ; ROM size
db $03 ; RAM size
db $00
db $00
db $00

org $00FFE4
incsrc vectors.asm

org $018000
padbyte $00
pad $020000

org $028000
pad $030000

org $018000
BGData:
	incbin gfx.2bpp

org $018800
SpriteData:
	incbin sprites.4bpp

org $01A000
ColorData:
	incbin palette.pal

org $01B000
BG4Tilemap:
	incbin bg4.bin

org $028000
SplooshBrr:
	dw $0208
	dw $0208
	dw $2000
	dw $2002
	incbin sploosh.brr
	.end
print hex(SplooshBrr_end-SplooshBrr)

KaboomBrr:
	incbin kaboom.brr
	.end
