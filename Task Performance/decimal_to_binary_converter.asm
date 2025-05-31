section .data
    ; Messages and buffers
    prompt db 'Number (0 to quit): ', 0    ; Ask user for input
    binaryMsg db 10, 'Binary: ', 0        ; Label for binary output
    newline db 10, 0                      ; For creating new lines
    buffer times 32 db 0                  ; Store user input
    bitBuffer times 33 db 0               ; Store binary digits (32 bits + null)
    errMsg db 10, 'Invalid input!', 10, 0 ; Error message

section .text
global _start

_start:
    ; Show prompt message
    mov eax, 4        ; System call for write
    mov ebx, 1        ; Standard output
    mov ecx, prompt   ; Message to display
    mov edx, 18       ; Message length
    int 0x80          ; Call kernel
    
    ; Get user input
    mov eax, 3        ; System call for read
    mov ebx, 0        ; Standard input
    mov ecx, buffer   ; Where to store input
    mov edx, 32       ; Maximum input length
    int 0x80          ; Call kernel
    
    ; Check if user entered "0" to quit
    cmp byte [buffer], '0'
    jne convert       ; If not zero, convert to binary
    cmp byte [buffer+1], 10  ; Check if next character is newline
    je exit_program   ; Exit if input is "0"
    
convert:
    ; Convert text to number
    mov esi, buffer   ; Point to user input
    call atoi         ; Convert to integer
    cmp eax, 0x80000000  ; Check for conversion error
    je invalid_input  ; Show error if invalid
    
    ; Show "Binary: " label
    mov eax, 4
    mov ebx, 1
    mov ecx, binaryMsg
    mov edx, 9
    int 0x80
    
    ; Display binary number
    call print_binary
    
    ; Move to next line
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    jmp _start        ; Ask for another number

invalid_input:
    ; Show error message
    mov eax, 4
    mov ebx, 1
    mov ecx, errMsg
    mov edx, 15
    int 0x80
    jmp _start        ; Return to start

exit_program:
    ; End program
    mov eax, 1        ; System call for exit
    xor ebx, ebx      ; Return 0 (success)
    int 0x80          ; Call kernel

; Convert text to number
atoi:
    xor eax, eax      ; Clear result
    xor ebx, ebx      ; Clear temporary storage
    xor ecx, ecx      ; Clear negative flag
    
    ; Check for minus sign
    mov bl, [esi]
    cmp bl, '-'
    jne atoi_digit
    inc ecx           ; Set negative flag
    inc esi           ; Move past '-' sign
    
atoi_digit:
    ; Process each digit
    mov bl, [esi]
    cmp bl, 10        ; Stop at newline
    je atoi_done
    sub bl, '0'       ; Convert character to number
    imul eax, 10      ; Multiply current total by 10
    add eax, ebx      ; Add new digit
    inc esi           ; Move to next character
    jmp atoi_digit
    
atoi_done:
    ; Handle negative numbers
    test ecx, ecx
    jz atoi_end
    neg eax           ; Convert to negative
atoi_end:
    ret
    
atoi_error:
    mov eax, 0x80000000  ; Return error code
    ret

; Convert number to binary and display
print_binary:
    mov ecx, 32       ; We'll print 32 bits
    mov ebx, eax      ; Store the number
    mov edi, bitBuffer ; Where to build binary string
    
bit_loop:
    rol ebx, 1        ; Move leftmost bit to carry flag
    jc set_one        ; If bit is 1, jump
    
    ; Store '0' in buffer
    mov byte [edi], '0'
    jmp next_bit
    
set_one:
    ; Store '1' in buffer
    mov byte [edi], '1'
    
next_bit:
    inc edi           ; Move to next buffer position
    loop bit_loop     ; Repeat for all bits
    
    ; Print the binary string
    mov byte [edi], 0 ; Mark end of string
    mov eax, 4
    mov ebx, 1
    mov ecx, bitBuffer
    mov edx, 32
    int 0x80
    ret
