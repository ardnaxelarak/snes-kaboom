; $F0           : AXLR ----
; $F1           : BYsS udlr
; $0300         : frames left held
; $0301         : frames right held
; $0302         : frames up held
; $0303         : frames down held
; $0304         : frames A held

UpdateJoypadWram:
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


HandleJoypadMovement:
;	check left
	LDA.w $0300
	AND.b #$0F
	CMP.b #$01
	BNE +
	LDA.b Crosshair
	AND.b #$07
	BEQ +
	DEC Crosshair
+

;	check right
	LDA.w $0301
	AND.b #$0F
	CMP.b #$01
	BNE +
	LDA.b Crosshair
	AND.b #$07
	CMP.b #$07
	BEQ +
	INC Crosshair
+

;	check up
	LDA.w $0302
	AND.b #$0F
	CMP.b #$01
	BNE +
	LDA.b Crosshair
	AND.b #$38
	BEQ +
	LDA.b Crosshair
	SEC : SBC.b #$08
	STA.b Crosshair
+

;	check down
	LDA.w $0303
	AND.b #$0F
	CMP.b #$01
	BNE +
	LDA.b Crosshair
	AND.b #$38
	CMP.b #$38
	BEQ +
	LDA.b Crosshair
	CLC : ADC.b #$08
	STA.b Crosshair
+
	RTS
