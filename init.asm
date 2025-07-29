InitBoard:
	LDX.b #$40
-	STZ.w Board, X
	DEX
	BPL -
	STZ.b ShotsTaken
	STZ.b ShotsTaken+1
	STZ.b Crosshair
	STZ.b Crosshair+1
	STZ.b Squid4Killed
	STZ.b Squid3Killed
	STZ.b Squid2Killed
	STZ.b SquidsKilled
	JSR PlaceSquids
	RTS

PlaceSquids:
	LDX.b #$04
	LDY.b #Squid4Dir
	JSR PlaceSquid
	LDX.b #$03
	LDY.b #Squid3Dir
	JSR PlaceSquid
	LDX.b #$02
	LDY.b #Squid2Dir
	JSR PlaceSquid
	RTS

; X = size, Y = dataAddr
PlaceSquid:
	STX.b $00
	STY.b $03
	STZ.b $04
.retry
	LDA.b #$09
	SEC : SBC.b $00
	JSR GetBoundedRand
	STA.b $01
	LDA.b #$08
	JSR GetBoundedRand
	STA.b $02

	LDA.b #$02
	JSR GetBoundedRand
	BEQ .vertical
.horizontal
	LDA.b $02
	ASL #3
	CLC : ADC.b $01
	PHA
	LDY.b $00
	TAX
-	LDA.w Board, X
	BEQ +
	PLA : BRA .retry
+	INX
	DEY
	BNE -
..place
	LDA.b #$01
	STA.b ($03)

	LDY.b $00
	PLX
-	LDA.b #$01
	STA.w Board, X
	TXA
	STA.b ($03), Y
	INX
	DEY
	BNE -
	RTS

.vertical
	LDA.b $01
	ASL #3
	CLC : ADC.b $02
	PHA
	LDY.b $00
	TAX
-	LDA.w Board, X
	BEQ +
	PLA : BRA .retry
+	TXA : CLC : ADC.b #$08 : TAX
	DEY
	BNE -
..place
	LDA.b #$00
	STA.b ($03)
	LDY.b $00
	PLX
-	LDA.b #$01
	STA.w Board, X
	TXA
	STA.b ($03), Y
	CLC : ADC.b #$08
	TAX
	DEY
	BNE -
	RTS

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

print "UploadSamples: ", pc
UploadSamples:
	PHP
	REP #$10
	SEP #$20
	JSR SpcWaitBoot

	LDY.w #$0200
	JSR SpcBeginUpload
-
	TYX
	LDA.l SplooshBrr, X
	JSR SpcUploadByte
	CPY #SplooshBrr_end-SplooshBrr
	BNE -

	LDY.w #$2000
	JSR SpcBeginUpload
-	TYX
	LDA.l KaboomBrr, X
	JSR SpcUploadByte
	CPY #KaboomBrr_end-KaboomBrr
	BNE -

	print "DisableEcho: ", pc
	; Disable Echo
	%WriteDsp($20, $6C)

	%WriteDsp($FF, $5C)

	; Set source location
	%WriteDsp($02, $5D)
 
	; Set Volumes
	%WriteDsp($7F, $0C) ; left main
	%WriteDsp($7F, $1C) ; right main
	%WriteDsp($00, $2C) ; left echo
	%WriteDsp($00, $3C) ; right echo
	%WriteDsp($7F, $00) ; left voice 0
	%WriteDsp($7F, $01) ; right voice 0

	; set pitch?
	%WriteDsp($00, $02)
	%WriteDsp($04, $03)

	%WriteDsp($00, $04)

	; %WriteDsp($C3, $05)
	; %WriteDsp($2F, $06)
	; %WriteDsp($CF, $07)
	%WriteDsp($00, $05)
	%WriteDsp($00, $06)
	%WriteDsp($7F, $07)

	%WriteDsp($00, $5C)
	%WriteDsp($00, $0D)
	%WriteDsp($00, $2D)
	%WriteDsp($00, $3D)
	%WriteDsp($00, $4D)

;	%WriteDsp($01, $4C)

	PLP
	RTS
