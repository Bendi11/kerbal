.global _start
.global engage

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
    neg
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

.define ORIENT_RETRO "$orrtro"

.func
engage:
    bscp 2, 0

.wait_to_orient_retro:
    push @
    call gs_wait_for_slam, #

    push ORIENT_TIME
    cle
    bfa .wait_to_orient_retro
    
    push false
    stog "$sas"
    FBW(FBW_STEERING, true)

    ; Steer retrograde
    prl lock_steer_retro
    addt false, 1000

; Wait to execute burn while steering retrograde
.wait_to_burn:
    push @
    call gs_wait_for_slam, #

    push EXTRA_BURN_TIME
    cle
    bfa .wait_to_burn

; Execute the maneuver
    prl lock_steer_retro
    rmvt

    push @
    call gs_execute_slam, #
    pop
    
    push "kill"
    sto "$steering"

    push 0
    sto "$throttle"
    FBW(FBW_STEERING, false)
    FBW(FBW_THROTTLE, false)
    
    push 0
    ret 1

.func
lock_steer_retro:
    push "$ship"
    gmb "velocity"
    gmb "surface"
    gmb "normalized"
    neg 

    sto "$steering"
    
    push 0
    ret 0
