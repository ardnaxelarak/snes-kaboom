print "ResetHandler: ", pc
ResetHandler:
	SEI
	CLC
	XCE
	LDA #$8F
	STA !INIDISP
	STZ $4200

	JSR UploadSamples

	JSR CopyVRAM
	JSR CopyCGRAM
	JSR ClearOAMMirror
	JSR ClearBG2
	JSR InitBoard
	JSR InitCrosshair

	LDA #$00 : STA !CGADD
	LDA #$9C : STA !CGDATA
	LDA #$73 : STA !CGDATA

	LDA #$00 : STA $2105 ; Mode 0; BG1-4 all 8x8
	LDA #$08 : STA $2107 ; BG1 tilemap is at $1000 in VRAM
	LDA #$0C : STA $2108 ; BG2 tilemap is at $1800 in VRAM
	LDA #$10 : STA $2109 ; BG3 tilemap is at $2000 in VRAM
	LDA #$14 : STA $210A ; BG4 tilemap is at $2800 in VRAM
	LDA #$00 : STA $210B ; BG1 & BG2 tilesets are at $0000 in VRAM
	LDA #$00 : STA $210C ; BG3 & BG4 tilesets are at $0000 in VRAM

	LDA #$1A : STA $212C ; enable Sprites, BG4 & BG2
	LDA #$0F : STA !INIDISP
	LDA #$81 : STA $4200

	REP #$20
	LDA.l SaveCheck
	CMP.w #$1312
	BEQ +
	LDA.w #$1312
	STA.l SaveCheck
	LDA.w #$00FF
	STA.l SaveBest
+
	SEP #$20
	JMP GameLoop
