.global start_gui

.define GUI_S

.include "./src/common.s"

.define gui "$gui"
.define engage "$enbtn"

.section .text

.func
start_gui:
    ; Create the GUI structure
    push @
    push 200
    call #, "gui()"

    dup
    stog gui
    
    dup
    gmet "addbutton"
    push @
    push "ENGAGE"
    call #, "<indirect>"
    
    dup
    stog engage
    
    pdrl on_engage, true
    smb "onclick"

    gmet "show"
    push @
    call #, "<indirect>"
    pop
    
    push 100000000
.loop:
    dup
    wait
    jmp .loop

    push 0
    ret 0

.func
on_engage:
    push "retrograde"
    sto "$sasmode"
     
.wait:
    push 0
    wait
    
    push @
    call gs_wait_for_slam, #
    dup
    push "TTB: "
    swap
    add
    SPRINT
    push 0
    cle
    bfa .wait
    
    push @
    call gs_execute_slam, #
    pop

    push 0
    ret 0
