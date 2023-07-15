.global _start
.extern .func launch

.define thrustpid "$tpid"
.define TPID_KP 0.5
.define TPID_KI 0.0
.define TPID_KD 0.0
.define LAND_V 1.5

.define FBW_THROTTLE "throttle"
.define FBW_STEERING "steering"

.macro FBW 2
    push @
    push &1
    push &2
    call #, "toggleflybywire()"
    pop
.endmacro

.macro STACKDUMP
    .dump:
        push @
        swap
        call #, "print()"
        pop
        jmp .dump
.endmacro

.macro PRINT 1
    push @
    &1
    call #, "print()"
    pop
.endmacro

.macro CLS
    push @
    call #, "clearscreen()"
    pop
.endmacro

.macro SPRINT
    push @
    swap
    call #, "print()"
    pop
.endmacro

.macro HUD
        push @
        swap
        push 0.51
        push 2
        push 12
        push "$white"
        push false
        call #, "hudtext()"
        pop
.endmacro

.section .text

.func
__init:
    ; Init thrust PID loop
    push @
    push TPID_KP
    push TPID_KI
    push TPID_KD
    call #, "pidloop()"
    dup
    stog thrustpid
    

    push LAND_V
    smb "setpoint"
    ret 0

.func
_start:
    call _init, #
    pop

    bscp 1, 0
    
    push true
    sto "$sas"
    push "retrograde"
    sto "$sasmode"
    push true
    sto gravity

    .begin:
    push 0
    wait
    CLS
    
    ; Get acceleration due to gravity (vector) in G (r3)
    push "$ship"
    dup
    gmb "sensors"
    gmb "grav"
    dup
    sto "$data"
    
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
    btr .zerothrust

    swap ; Make $ship top of stack
    gmb "mass"
    div ; thrust / mass
    stol "$r2"
    jmp .thrust
.zerothrust:
    ; store the zero value of ship thrust into the available acceleration
    stol "$r2"
    pop ; remove ship from the stack
.thrust:
    
    ;PRINT(push "Max acceleration is: ")
    ;PRINT(push "$r2")

    ;Get time to impact in seconds (r4)
    push @

    push "$ship"
    gmb "verticalspeed"

    push "$r1"


    push "$alt"
    gmb "radar"

    call time_to_impact, #
    
    dup
    stol "$r4"

    ; Get time to reduce v to 0 in seconds (r5)
    ; -v / (a - g) = t
    push "$ship"
    gmb "verticalspeed"
    neg

    push "$r2"
    push "$r1"
    sub
    div
    dup
    sto "$r5"

    cle
    btr .burn
    
    push "IMPACT: "
    push "$r4"
    add
    SPRINT

    push "DIFF: "

    push "$r4"
    push "$r5"
    sub
    add
    SPRINT 

    PRINT(push "G: ")

    push "$r3"
    gmb "mag"
    dup
    SPRINT

    push 9.802
    div

    push "G"
    add
    SPRINT

    jmp .begin

.burn:
    PRINT(push "OUTTA THE PARK GRAND SLAM")
    FBW(FBW_THROTTLE, true)

.while_high:

    push 0
    sto "$throttle"
    
    PRINT(push "DONE")

    push 0
    wait

    FBW(FBW_THROTTLE, false)
    
    push "$alt"
    gmb "radar"
    push 5
    cle
    bfa .while_high

    escp 1
    eop

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
