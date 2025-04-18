section .text
    global _start

_start:
    call get_input      ; Procedure call to get user input
    call compare_to_5   ; Procedure call to compare input to 5
    
    ; Exit program
    mov eax, 1          ; sys_exit
    mov ebx, 0          ; exit code 0
    int 0x80

; Procedure to get single-digit input
get_input:
    ; Print prompt
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, prompt_msg
    mov edx, prompt_len
    int 0x80
    
    ; Read input
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, input
    mov edx, 2          ; read 2 bytes (digit + newline)
    int 0x80
    
    ; Convert ASCII to number
    mov al, [input]
    sub al, '0'         ; Convert ASCII to integer
    mov [input], al     ; Store the input
    ret

; Procedure to compare input to 5
compare_to_5:
    ; Print result prefix
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, result_len
    int 0x80
    
    ; Compare logic
    mov al, [input]
    cmp al, 5           ; Compare input to 5
    jl below_5          ; Jump if less than 5
    je equal_5          ; Jump if equal to 5
    jg above_5          ; Jump if greater than 5

below_5:
    mov ecx, below_msg
    mov edx, below_len
    jmp display_result

equal_5:
    mov ecx, equal_msg
    mov edx, equal_len
    jmp display_result

above_5:
    mov ecx, above_msg
    mov edx, above_len

display_result:
    mov eax, 4          ; Print result
    mov ebx, 1
    int 0x80
    ret

section .data
    prompt_msg db 'Enter a single-digit number (0-9): '
    prompt_len equ $ - prompt_msg
    
    result_msg db 'The number is '
    result_len equ $ - result_msg
    
    below_msg db 'below 5.', 0xA  ; 0xA = newline
    below_len equ $ - below_msg
    
    equal_msg db 'equal to 5.', 0xA
    equal_len equ $ - equal_msg
    
    above_msg db 'above 5.', 0xA
    above_len equ $ - above_msg

section .bss
    input resb 1        ; Reserve 1 byte for input