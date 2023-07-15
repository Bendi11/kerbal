.ifndef MNVR_S

; Wait until the correct time to execute the hover slam burn
; params - 
; return - time in seconds until burn
.extern .func gs_wait_for_slam

; Execute the hover slam burn
; params -
; return -
.extern .func gs_execute_slam

.endif

.ifndef MAIN_S

; Initialize shared state
.extern .func init

.endif


.ifndef GUI_S

.extern .func start_gui

.endif

.define thrustpid "$tpid"
.define TPID_KP 0.5
.define TPID_KI 0.0
.define TPID_KD 0.0
.define LAND_V 10.0

.define EXTRA_BURN_TIME 1.5

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
