.global _start

.define MAIN_S
.include "./src/common.s"

.section .text

.func
init:
    ; Init thrust PID loop
    push @
    push TPID_KP
    push TPID_KI
    push TPID_KD
    call #, "pidloop()"

    dup
    stog thrustpid
    

    push HIGH_ALT_DROP_V
    neg
    smb "setpoint"
    
    push 0
    ret 0

.func
_start:
    call init, #
    pop
    
    call start_gui, #
    pop

    eop
