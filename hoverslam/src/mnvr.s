.global gs_wait_for_slam
.global gs_execute_slam

.define MNVR_S
.include "./src/common.s"

.section .text

.func
gs_wait_for_slam:
CLS
    bscp 2, 0

    ; Get acceleration due to gravity (vector) in G (r3)
    push "$ship"
    dup
    gmb "sensors"
    gmb "grav"
    dup
    stol "$r3"
    
    ; Get steering to the opposite of gravity well (r0)
    dup
    gmb "vec" ; duplicate vector on heap
    gmb "normalized"
    neg
    stol "$r0"
    
    ; Get acceleration due to gravity in m/s^2 (r1)
    ; stk: G vector
    gmb "mag"
    stol "$r1"

    ; Get available acceleration in m/2^2 (r2)
    dup
    gmb "dynamicpressure"
    stol "$r2"

    dup
    gmet "availablethrustat"
    push @
    push "$r2"
    call #, "<indirect>" ; Get max thrust in kN
    
    dup
    push 0
    ceq
    btr .ship_no_thrust
        swap ; Make $ship top of stack
        gmb "mass"
        div ; thrust / mass
        stol "$r2"
        jmp .ship_has_thrust
    .ship_no_thrust:
        ; store the zero value of ship thrust into the available acceleration
        stol "$r2"
        pop ; remove ship from the stack
.ship_has_thrust:

    ;Get time to impact in seconds (r4)
    push @

    push "$ship"
    gmb "verticalspeed"

    push "$r1"

    push "$alt"
    gmb "radar"

    call time_to_impact, #
    
    dup
    push "TTI: "
    swap
    add
    SPRINT

    dup
    stol "$r4"

    ; Get time to reduce v to 0 in seconds (r5)
    ; -v / (a - g) = t
    push "$ship"
    gmb "airspeed"

    push "$r2"
    push "$r1"
    sub
    div
    dup
    sto "$r5"

    dup
    push "TTS: "
    swap
    add
    SPRINT

    sub

    push EXTRA_BURN_TIME
    sub
    
    ret 1

.func
gs_execute_slam:
   nop
   .while_high:
    push thrustpid
    gmet "update"

    push @
    push "$time"
    gmb "seconds"

    push "$ship"
    gmb "verticalspeed"
    

    push "$ship"
    gmb "groundspeed"
    sub

    call #, "<indirect>"
    
    sto "$throttle"
    
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

; params: (top) velocity, acceleration, distance
.func
time_to_impact:
nop
    bscp 3, 0
    dup
    stol "$r0" ; v -> r0

    ; sqrt(v0^2 + 2a(dx))
    push 2
    pow

    ; v^2, a, dx

    stol "$r1" ; v^2 -> r1
    
    ; a, dx
    dup
    stol "$r2" ; a -> r2
    push 2
    mul
    
    ; 2a, dx
    mul

    
    push "$r1"
    add

    ; v^2 + 2a(dx)
    
    push @
    swap
    call #, "sqrt()"
    
    push "$r0"
    add
    
    push "$r2"
    div
    
    ret 1
