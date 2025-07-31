CopyVRAM:
	LDA #$80 : STA !VMAINC
	REP #$30
	LDA #$00 : STA !VMADDL
	LDX #$0000
-
	LDA BGData, X
	STA !VMDATAL
	INX : INX
	CPX #$0800
	BCC -

	LDX #$0000
-
	LDA SpriteData, X
	STA !VMDATAL
	INX : INX
	CPX #$0800
	BCC -
	SEP #$30
	RTS

CopyCGRAM:
	LDA #$00
	STA !CGADD
	REP #$10
	LDX #$0000
.loop
	LDA ColorData, X
	STA !CGDATA
	INX
	LDA ColorData, X
	STA !CGDATA
	INX
	CPX.w #$0200
	BCC .loop
	RTS

ClearOAMMirror:
	REP #$10
	LDX #$0000
-
	LDA #$00 : STA OAM.x, X
	LDA #$00 : STA OAM.y, X
	LDA #$2E : STA OAM.index, X
	LDA #$00 : STA OAM.props, X
	INX #4
	CPX #$0200
	BCC -
-
	LDA #$00 : STA OAM.x, X
	INX
	CPX #$0220
	BCC -
	SEP #$30
	RTS

ClearBG2:
	REP #$30
	LDX #$0000
-
	LDA #$000E : STA BG2, X ; $000E = blank tile
	INX : INX
	CPX #$0800
	BCC -
	SEP #$30
	RTS

InitBG4:
	%CopyToVRAM(0, BG4Tilemap, $2800, $0800)
	RTS

CopyOAM:
	%CopyToOAM(0, OAM.x, $0220)
	RTS

print "CopyBoardToVRAM: ", pc
CopyBoardToVRAM:
	; %CopyToVRAM(0, BG1, $1000, $0800)
	%CopyToVRAM(0, BG2, $1800, $0800)
	; %CopyToVRAM(0, BG3, $2000, $0800)
	RTS
