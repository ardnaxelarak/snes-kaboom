struct OAM $000400
	.x: skip 1
	.y: skip 1
	.index: skip 1
	.props: skip 1
endstruct

BG1 = $7E2000
BG2 = $7E2800
BG3 = $7E3000
Board = $000700
; 0 = Empty, unfired
; 1 = Squid, unfired
; 2 = Empty, fired
; 3 = Squid, fired

ShotsTaken = $10
Crosshair = $12

FrameCounter = $1A

Squid4Dir = $20
Squid4Blocks = $21

Squid3Dir = $25
Squid3Blocks = $26

Squid2Dir = $29
Squid2Blocks = $2A

Squid4Killed = $2C
Squid3Killed = $2D
Squid2Killed = $2E
SquidsKilled = $2F

SaveCheck = $700000
SaveBest = $700002
