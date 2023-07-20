.global time_to_impact

.section .text

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
