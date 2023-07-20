; Description of hoverslam algorithm:
; Wait until tti - ttrv <= 0 + ORIENT_TIME
; Begin orientation towards retrograde
; Wait until tti - ttrv <= 0 + EXTRA_BURN_TIME
; Begin Stage 1 suicide burn
;  - Reduce vertical velocity to HIGH_ALT_DROP_V
;  - Reduce horizontal velocity to 0
; Orient towards gravity well
; Maintain HIGH_ALT_DROP_V until AGL altitude is <= HIGH_ALT_FLOOR
; Begin Stage 2 slam
; - Reduce vertical velocity to LANDING_DROP_V
; - Cut engines when lowest part altitude <= CUT_ENGINE_ALT

.ifndef MNVR_S

; Wait until the correct time to execute the hover slam burn
; params - 
; return - time in seconds until S1 burn
.extern .func gs_wait_for_slam

; Execute the hover slam burn
; params -
; return -
.extern .func gs_execute_slam

.endif

.ifndef MAIN_S

; Execute the burn from start to finish
.extern .func engage

; Initialize shared state
.extern .func init

.endif


.ifndef GUI_S

.extern .func start_gui

.endif

.define thrustpid "$tpid"
.define TPID_KP 0.092
.define TPID_KI 0.0
.define TPID_KD 0.001

; Velocity to terminate the landing at
.define LANDING_DROP_V 1.5
; At what height AGL the craft is considered low altitude
.define HIGH_ALT_FLOOR 20
; Maximum fall velocity at high altitude
.define HIGH_ALT_DROP_V 20.0

; The amount of seconds earlier to burn than the minimum required time to reduce velocity to 0,
; used to compensate for PID slop and as a safety stopgap
.define EXTRA_BURN_TIME 0.3

; Amount of time to allow the craft to orient retrograde
.define ORIENT_TIME 10.0

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
