GetRandomInt:
	LDA.w $2137
	LDA.w $213C
	ADC.b FrameCounter
	ADC.w $0FA1
	STA.w $0FA1
	RTS

GetBoundedRand:
	BNE + : JMP GetRandomInt : +
	STA.w $4202
	JSR GetRandomInt
	STA.w $4203
	NOP #4
	LDA.w $4217
	RTS
