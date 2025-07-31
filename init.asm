InitCrosshair:
	LDA.b #$AA
	STA.w OAM.x+$0200
	LDA.b #$40
	STA.w OAM[0].index
	LDA.b #$42
	STA.w OAM[1].index
	LDA.b #$60
	STA.w OAM[2].index
	LDA.b #$62
	STA.w OAM[3].index
	STZ.w OAM[0].props
	STZ.w OAM[1].props
	STZ.w OAM[2].props
	STZ.w OAM[3].props
	RTS

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
