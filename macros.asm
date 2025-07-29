macro CopyToVRAM(channel, source, destination, length)
	PHP
	LDA.b #$80 : STA.w $2115
	REP #$20
	LDA.w #<destination>>>1 : STA.w $2116
	LDA.w #$1801 : STA.w $4300|(<channel><<4)

	LDA.w #<source> : STA.w $4302|(<channel><<4)
	LDA.w #<length> : STA.w $4305|(<channel><<4)

	SEP #$20
	LDA.b #<source>>>16 : STA.w $4304|(<channel><<4)
	LDA.b #(1<<<channel>) : STA $420B
	PLP
endmacro

macro CopyToOAM(channel, source, length)
	PHP
	REP #$20
	STZ.w $2102
	LDA.w #$0400 : STA.w $4300|(<channel><<4)

	LDA.w #<source> : STA.w $4302|(<channel><<4)
	LDA.w #<length> : STA.w $4305|(<channel><<4)

	SEP #$20
	LDA.b #<source>>>16 : STA.w $4304|(<channel><<4)
	LDA.b #(1<<<channel>) : STA $420B
	PLP
endmacro

macro DrawBG2_16()
	STA.l BG2, X
	INC
	STA.l BG2+$02, X
	CLC : ADC.w #$000F
	STA.l BG2+$40, X
	INC
	STA.l BG2+$42, X
endmacro

macro WriteDsp(value, address)
	LDX.w #<address>|(<value><<8)
	JSR WriteDsp
endmacro
