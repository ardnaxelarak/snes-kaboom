RestartGame:
	JSR ClearOAMMirror
	JSR ClearBG2
	JSR InitBoard
	JSR InitCrosshair
	RTS

print "GameLoop: ", pc
GameLoop:
	WAI
	INC FrameCounter

	JSR HandleJoypadMovement

; check A press
	LDA.b ShotsTaken
	CMP.b #24
	BCS + ; no more shots

	LDA.w $0304
	CMP.b #$01
	BNE +
	LDX Crosshair
	LDA.w Board, X
	BIT.b #$02
	BNE +
	JSR Fire
+

	JSR UpdateBoard
	LDA.b SquidsKilled
	CMP.b #3
	BEQ .win
	LDA.b ShotsTaken
	CMP.b #24
	BEQ .gameover
	BRA .next
.win
	LDA.l SaveBest
	CMP.b ShotsTaken
	BCC .gameover
	LDA.b ShotsTaken
	STA.l SaveBest
	
.gameover
	JSR DrawRestart
	JSR DrawSquids
	LDA.b $F1
	BIT.b #$10
	BEQ .next
	JSR RestartGame
.next
	JMP GameLoop

Fire:
	INC.b ShotsTaken
	LDX Crosshair
	LDA.w Board, X
	ORA.b #$02
	STA.w Board, X
	CMP.b #$03
	BEQ .kaboom
.sploosh
	JSR PlaySploosh
	RTS
.kaboom
	JSR PlayKaboom
	JSR CountSquids
	RTS

CountSquids:
	LDX.b #$04
	LDY.b #Squid4Dir
	JSR CheckSquid
	STA.b Squid4Killed

	LDX.b #$03
	LDY.b #Squid3Dir
	JSR CheckSquid
	STA.b Squid3Killed

	LDX.b #$02
	LDY.b #Squid2Dir
	JSR CheckSquid
	STA.b Squid2Killed

	CLC : ADC.b Squid3Killed : ADC.b Squid4Killed
	STA.b SquidsKilled
	RTS

; X = size, Y = dataAddr
CheckSquid:
	STY.b $03
	STZ.b $04
	TXY
-	LDA.b ($03), Y
	TAX
	LDA.w Board, X
	BIT.b #$02
	BEQ .alive
	DEY
	BNE -
.dead
	LDA.b #$01 : RTS
.alive
	LDA.b #$00 : RTS

UpdateBoard:
	JSR UpdateShots
	JSR UpdateBest
	JSR DrawBombs
	JSR DrawBoard
	JSR UpdateCrosshair
	JSR ShowKilledSquids
	RTS

DrawRestart:
	REP #$30
	LDX.w #$0062
	LDA.w #$0C40
	%DrawBG2_16()
	LDX.w #$0066
	LDA.w #$0C42
	%DrawBG2_16()
	SEP #$30
	RTS

print "UpdateShots: ", pc
UpdateShots:
	LDA.b ShotsTaken
	%DrawBG2_2Digit($46)
	RTS

print "UpdateBest: ", pc
UpdateBest:
	LDA.l SaveBest
	CMP.b #$FF
	BEQ .no_best
	%DrawBG2_2Digit($58)
	RTS
.no_best
	LDA.b #$0F
	STA.l BG2+$58
	STA.l BG2+$5A
	LDA.b #$1F
	STA.l BG2+$98
	STA.l BG2+$9A
	RTS

print "DrawBombs: ", pc
DrawBombs:
	REP #$30
	LDX.w #$010A
	LDY.w #$0000
-
	LDA.w #$0408
	CPY.b ShotsTaken
	BCS +
	LDA.w #$0808
+	%DrawBG2_16()
	INY

	TXA
	CLC : ADC.w #$00C0
	TAX

	TYA
	AND.w #$0007
	BNE +
	TXA
	SEC : SBC.w #$0604
	TAX

+	CPY.w #$0018
	BCC -
	SEP #$30
	RTS

DrawBoard:
	REP #$30
	LDX.w #$0110
	LDY.w #$0000
-
	LDA.w Board, Y
	AND.w #$0003
	BIT.w #$0002
	BEQ .empty
	BIT.w #$0001
	BEQ .sploosh
.kaboom
	LDA.w #$0000
	BRA .draw
.sploosh
	LDA.w #$0402
	BRA .draw
.empty
	LDA.w #$002E
.draw
	%DrawBG2_16()
	INY

	TXA
	CLC : ADC.w #$0006
	TAX

	TYA
	AND.w #$0007
	BNE +
	TXA
	CLC : ADC.w #$0090
	TAX

+	CPY.w #$0040
	BCC -
	SEP #$30
	RTS

ShowKilledSquids:
	REP #$30
	LDA.b SquidsKilled : AND.w #$00FF
	TAY
	BEQ .done

	LDX.w #$006E
-
	LDA.w #$0002
	%DrawBG2_16()
	TXA
	CLC : ADC.w #$0006
	TAX
	DEY
	BNE -

.done
	SEP #$30
	RTS

UpdateCrosshair:
	REP #$20

	LDA.b Crosshair
	AND.w #$0007
	ASL #3
	STA.b $00
	ASL
	CLC : ADC.b $00
	STA.b $00

	LDA.b Crosshair
	AND.w #$0038
	XBA
	STA.b $02
	ASL
	CLC : ADC.b $02
	CLC : ADC.b $00
	CLC : ADC.w #$1838

	STA.w OAM[0].x
	CLC : ADC.w #$0010
	STA.w OAM[1].x
	CLC : ADC.w #$0FF0
	STA.w OAM[2].x
	CLC : ADC.w #$0010
	STA.w OAM[3].x
	SEP #$20
	RTS

DrawSquids:
	LDA.b #$AA
	STA.w OAM.x+$0201
	STA.w OAM.x+$0202
	STA.w OAM.x+$0203
	STA.w OAM.x+$0204

	; Squid 4
	STZ.w OAM[4].props
	STZ.w OAM[5].props
	STZ.w OAM[6].props
	STZ.w OAM[7].props
	STZ.w OAM[8].props
	STZ.w OAM[9].props
	LDA.b Squid4Dir
	BNE .h4
.v4
	LDA.b #$64
	STA.w OAM[4].index
	LDA.b #$66
	STA.w OAM[5].index
	STA.w OAM[6].index
	STA.w OAM[7].index
	LDA.b #$46
	STA.w OAM[8].index
	LDA.b #$44
	STA.w OAM[9].index

	LDA.b Squid4Blocks
	AND.b #$07
	ASL #3
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$40
	STA.w OAM[4].x
	STA.w OAM[5].x
	STA.w OAM[6].x
	STA.w OAM[7].x
	STA.w OAM[8].x
	STA.w OAM[9].x

	LDA.b Squid4Blocks
	AND.b #$38
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$1F
	STA.w OAM[4].y
	SEC : SBC.b #$10
	STA.w OAM[5].y
	SEC : SBC.b #$10
	STA.w OAM[6].y
	SEC : SBC.b #$10
	STA.w OAM[7].y
	SEC : SBC.b #$08
	STA.w OAM[8].y
	SEC : SBC.b #$10
	STA.w OAM[9].y
	BRA +
.h4
	LDA.b #$4A
	STA.w OAM[4].index
	LDA.b #$6A
	STA.w OAM[5].index
	STA.w OAM[6].index
	STA.w OAM[7].index
	LDA.b #$68
	STA.w OAM[8].index
	LDA.b #$48
	STA.w OAM[9].index

	LDA.b Squid4Blocks
	AND.b #$38
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$1F
	STA.w OAM[4].y
	STA.w OAM[5].y
	STA.w OAM[6].y
	STA.w OAM[7].y
	STA.w OAM[8].y
	STA.w OAM[9].y

	LDA.b Squid4Blocks
	AND.b #$07
	ASL #3
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$40
	STA.w OAM[4].x
	SEC : SBC.b #$10
	STA.w OAM[5].x
	SEC : SBC.b #$10
	STA.w OAM[6].x
	SEC : SBC.b #$10
	STA.w OAM[7].x
	SEC : SBC.b #$08
	STA.w OAM[8].x
	SEC : SBC.b #$10
	STA.w OAM[9].x
+

	; Squid 3
	STZ.w OAM[10].props
	STZ.w OAM[11].props
	STZ.w OAM[12].props
	STZ.w OAM[13].props
	LDA.b Squid3Dir
	BNE .h3
.v3
	LDA.b #$64
	STA.w OAM[10].index
	LDA.b #$66
	STA.w OAM[11].index
	STA.w OAM[12].index
	LDA.b #$44
	STA.w OAM[13].index

	LDA.b Squid3Blocks
	AND.b #$07
	ASL #3
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$40
	STA.w OAM[10].x
	STA.w OAM[11].x
	STA.w OAM[12].x
	STA.w OAM[13].x

	LDA.b Squid3Blocks
	AND.b #$38
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$1F
	STA.w OAM[10].y
	SEC : SBC.b #$10
	STA.w OAM[11].y
	SEC : SBC.b #$10
	STA.w OAM[12].y
	SEC : SBC.b #$10
	STA.w OAM[13].y
	BRA +
.h3
	LDA.b #$4A
	STA.w OAM[10].index
	LDA.b #$6A
	STA.w OAM[11].index
	STA.w OAM[12].index
	LDA.b #$48
	STA.w OAM[13].index

	LDA.b Squid3Blocks
	AND.b #$38
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$1F
	STA.w OAM[10].y
	STA.w OAM[11].y
	STA.w OAM[12].y
	STA.w OAM[13].y

	LDA.b Squid3Blocks
	AND.b #$07
	ASL #3
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$40
	STA.w OAM[10].x
	SEC : SBC.b #$10
	STA.w OAM[11].x
	SEC : SBC.b #$10
	STA.w OAM[12].x
	SEC : SBC.b #$10
	STA.w OAM[13].x
+

	; Squid 2
	STZ.w OAM[14].props
	STZ.w OAM[15].props
	STZ.w OAM[16].props
	LDA.b Squid2Dir
	BNE .h2
.v2
	LDA.b #$64
	STA.w OAM[14].index
	LDA.b #$46
	STA.w OAM[15].index
	LDA.b #$44
	STA.w OAM[16].index

	LDA.b Squid2Blocks
	AND.b #$07
	ASL #3
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$40
	STA.w OAM[14].x
	STA.w OAM[15].x
	STA.w OAM[16].x

	LDA.b Squid2Blocks
	AND.b #$38
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$1F
	STA.w OAM[14].y
	SEC : SBC.b #$08
	STA.w OAM[15].y
	SEC : SBC.b #$10
	STA.w OAM[16].y
	BRA +
.h2
	LDA.b #$4A
	STA.w OAM[14].index
	LDA.b #$68
	STA.w OAM[15].index
	LDA.b #$48
	STA.w OAM[16].index

	LDA.b Squid2Blocks
	AND.b #$38
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$1F
	STA.w OAM[14].y
	STA.w OAM[15].y
	STA.w OAM[16].y

	LDA.b Squid2Blocks
	AND.b #$07
	ASL #3
	STA.b $00
	ASL
	CLC : ADC.b $00 : ADC.b #$40
	STA.w OAM[14].x
	SEC : SBC.b #$08
	STA.w OAM[15].x
	SEC : SBC.b #$10
	STA.w OAM[16].x
+
	RTS
