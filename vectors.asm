;     COP,    BRK,    ABT,        NMI,          RST,    IRQ
dw #$0000, #$0000, #$0000, NMIHandler,       #$0000, IRQHandler
dw #$0000, #$0000
dw #$0000, #$0000, #$0000,     #$0000, ResetHandler,     #$0000
