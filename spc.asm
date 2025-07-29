; High-level interface to SPC-700 bootloader
;
; 1. Call spc_wait_boot
; 2. To upload data:
;	   A. Call spc_begin_upload
;	   B. Call spc_upload_byte any number of times
;	   C. Go back to A to upload to different addr
; 3. To begin execution, call spc_execute
;
; Have your SPC code jump to $FFC0 to re-run bootloader.
; Be sure to call spc_wait_boot after that.


; Waits for SPC to finish booting. Call before first
; using SPC or after bootrom has been re-run.
; Preserved: X, Y
SpcWaitBoot:
	LDA.b #$AA
.wait
	CMP.w $2140
	BNE .wait

	; Clear in case it already has $CC in it
	; (this actually occurred in testing)
	STA.w $2140

	LDA.b #$BB
.wait2
	CMP.w $2141
	BNE .wait2

	RTS


print "SpcBeginUpload: ", pc
; Starts upload to SPC addr Y and sets Y to
; 0 for use as index with spc_upload_byte.
; Preserved: X
SpcBeginUpload:
	STY.w $2142

	; Send command
	LDA.w $2140
	CLC : ADC.b #$22
	BNE .skip         ; special case fully verified
	; INC
.skip
	STA.w $2141
	STA.w $2140

	; Wait for acknowledgement
.wait
	CMP.w $2140
	BNE .wait

	; Initialize index
	LDY.w #$0000

	RTS


; Uploads byte A to SPC and increments Y. The low byte
; of Y must not changed between calls.
; Preserved: X
SpcUploadByte:
	STA.w $2141

	; Signal that it's ready
	TYA
	STA.w $2140
	INY

	; Wait for acknowledgement
.wait
	CMP.w $2140
	BNE .wait

	RTS


; Starts executing at SPC addr Y
; Preserved: X, Y
SpcExecute:
	STY.w $2142

	STZ.w $2141

	LDA.w $2140
	CLC : ADC.b #$22
	STA.w $2140

	; Wait for acknowledgement
.wait
	CMP.w $2140
	BNE .wait

	RTS

; Writes high byte of X to SPC-700 DSP register in low byte of X
WriteDsp:
	PHX
	; Just do a two-byte upload to $00F2-$00F3, so we
	; set the DSP address, then write the byte into that.
	LDY.w #$00F2
	JSR SpcBeginUpload
	PLA
	JSR SpcUploadByte     ; low byte of X to $F2
	PLA
	JSR SpcUploadByte     ; high byte of X to $F3
	RTS
