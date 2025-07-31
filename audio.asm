PlaySploosh:
	PHP
	SEP #$20
	REP #$10
	%WriteDsp($00, $04)
	%WriteDsp($01, $4C)
	PLP
	RTS

PlayKaboom:
	PHP
	SEP #$20
	REP #$10
	%WriteDsp($01, $04)
	%WriteDsp($01, $4C)
	PLP
	RTS

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

	%WriteDsp($00, $05)
	%WriteDsp($00, $06)
	%WriteDsp($7F, $07)

	%WriteDsp($00, $5C)
	%WriteDsp($00, $0D)
	%WriteDsp($00, $2D)
	%WriteDsp($00, $3D)
	%WriteDsp($00, $4D)

	PLP
	RTS
