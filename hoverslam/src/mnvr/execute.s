.global gs_execute_slam

.define MNVR_S
.include "src/common.s"

.section .text

.func
gs_execute_slam:
   nop
   .while_high:
    CLS
    push thrustpid
    gmet "update"

    push @
    push "$time"
    gmb "seconds"
    
    push @

    push "$ship"
    gmb "velocity"
    gmb "surface"

    push "$ship"
    gmb "facing"
    gmb "forevector"

    call #, "vdot"
     
    dup
    push "V IN DIR: "
    swap
    add
    SPRINT

    call #, "<indirect>"

    dup
    push "THROT: "
    swap
    add
    SPRINT
    
    sto "$throttle"

    push "$ship"
    gmb "velocity"
    gmb "surface"
    gmb "normalized"
    neg 

    sto "$steering"
    
    push 0
    wait

    push "$alt"
    gmb "radar"
    dup

    push HIGH_ALT_FLOOR
    cle
    bfa .keep_going_fast
    push thrustpid
    push LANDING_DROP_V
    neg
    smb "setpoint"

.keep_going_fast:

    push 5
    cle
    bfa .while_high

    push 0
    ret 0

