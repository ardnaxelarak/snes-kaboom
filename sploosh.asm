lorom

org $008000
incsrc labels.asm
incsrc sprites.asm
incsrc macros.asm

incsrc reset.asm
incsrc init.asm
incsrc graphics.asm
incsrc audio.asm
incsrc gameloop.asm
incsrc spc.asm
incsrc rand.asm
incsrc joypad.asm
incsrc tables.asm

print "NMIHandler: ", pc
NMIHandler:
	PHX : PHY : PHA : PHP
	SEP #$30
	JSR InitBG4
	LDA.w $4210
	JSR UpdateJoypadWram
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
