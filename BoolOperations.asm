COMMENT !
Joseph Work
9/11/24
CSC 3000 X00
HW Assignment 3
Program that first prompts the user to enter two hexadecimal integers and then displays a variety of operations to perform on them
the operations are AND, NAND, OR, NOR, NOT x or NOT y, XNOR, XOR
the program will generate random number and assign a color based on the number, Light Purple is 30%.  Light Blue is 60% Light Green is 10%
it will then display the two numbers and the operation in that color before prompting the user if they want to repeat the process

!


INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
CaseTable  BYTE  'a'                    ; the case table that will be used to select one of the 8 procedures based on user input
           DWORD xAndY
EntrySize  = ($ - CaseTable)
            BYTE  'b'                   ; look up value
            DWORD xNandY                ; address of procedure
            BYTE  'c'
            DWORD xOrY
            BYTE  'd'
            DWORD xNorY
            BYTE 'e'
            DWORD notX
            BYTE 'f'
            DWORD notY
            BYTE 'g'
            DWORD xXorY
            BYTE 'h'
            DWORD xXnorY
NumberOfEntries = ($ - CaseTable) / EntrySize


MenuPrompt   BYTE "Make a selection:",0dh,0ah          ; menu prompt that displays the user's options to them
			 BYTE "a: x AND y",0dh,0ah				
             BYTE "b: x NAND y"     ,0dh,0ah   
             BYTE "c: x OR y"      ,0dh,0ah 
             BYTE "d: x NOR y"      ,0dh,0ah 
             BYTE "e: NOT x"      ,0dh,0ah 
             BYTE "f: NOT y"      ,0dh,0ah 
             BYTE "g: x XOR y"      ,0dh,0ah 
             BYTE "h: x XNOR y "       ,0dh, 0ah          
            BYTE "Enter your selection (a,b,c,d,e,f,g,h): ", 0


andMsg BYTE " AND ", 0                              ; message to be used in and operations
nandMsg BYTE " NAND ", 0                            ; message to be used in NAND operations
orMsg BYTE " OR ", 0                                ; message to be used in OR operations
norMsg BYTE " NOR ", 0                              ; message to be used in NOR operations
notMsg BYTE " NOT ", 0                              ; message to be used in NOT operations
xorMsg BYTE " XOR ", 0                              ; message to be used in XOR operations
xnorMsg BYTE " XNOR ", 0                            ; message to be used in XNOR operations
equalSign BYTE " = ", 0                             ; equal sign used to display in operations
    
hexPrompt1 BYTE "Enter a maximum 32 bit Hexadecimal integer(x): ", 0        ; prompt for initial hex value
hexPrompt2 BYTE "Enter another max 32 bit Hexadecimal integer(y): ", 0      ; prompt for second hex value
errMsg BYTE "Invalid Input", 0                                              ; error message for invalid input
hexVal1 DWORD 0                                                             ; var to store first hex value (x)
hexVal2 DWORD 0                                                             ; var to store second hex value (y)
hexResult DWORD 0                                                           ; var to store result of hex operations
continueMsg BYTE "Enter Y/y to continue, or exit with anything else: ", 0	; prompt for the user if they want to continue or not


.code
main proc
start:
    call crlf                                   ; new line
    call takeInput                              ; get both hex numbers from user
    call crlf                                   ; new line
	mov edx, OFFSET MenuPrompt                  ; set edx to display the menu prompt
    call WriteString                            ; display it
    call ReadChar                               ; get a character from the user
    mov ebx, OFFSET CaseTable                   ; point ebx to the case table
    mov ecx, NumberOfEntries                    ; and set ecx to the number of entries for loop counting

    L1:         
    cmp al, [ebx]                               ; compare user input to the value in the case table
    jne L2                                      ; if it's not equal then compare it to the next
    call NEAR PTR [ebx +1]                      ; if it does equal then go to the address of the procedure
    call Crlf                                   ; new line
    jmp L3                                      ; skip L2

    L2:                                         
    add ebx, EntrySize                          ; go to the next entry of the case table
    loop l1                                     ; and continue loop

    L3:
    mov edx, OFFSET continueMsg						    ; prompt the user if they want to continue
		call WriteString								; write it to the screen
		call ReadChar									; take user input
		cmp al, 'Y'										; if it's Y then restart from the beginning
		je start										; jump to initProc
		cmp al, 'y'										; it's not case senstive so lowercase y also works
		je start										; also jump to initProc
    exit
	
main ENDP


;-----------------------------------------------------
takeInput PROC
; take input gets user input for two hexadecimal integers
; Uses: edx to store values, eax to store user input
; Receives: nothing
; Returns: hexVal1 and hexVal2 set to user input
;-----------------------------------------------------
    start:              
    mov edx, OFFSET hexPrompt1                          ; set edx to display the inital hex prompt
    call WriteString                                    ; write it to the screen
    call ReadHex                                        ; get hex value from the user
    cmp eax, 0                                          ; if the input is not valid ReadHex returns eax as 0
    je invalidInput                                     ; so if eax is 0 then the user entered something invalid
    mov hexVal1, eax                                    ; else set the first hex value

    call crlf                                           ; new line
    mov edx, OFFSET hexPrompt2                          ; set edx to displau the second prompt
    call WriteString                                    ; write it to the screen
    call ReadHex                                        ; read the second hex value from the user
    cmp eax, 0                                          ; if it's invalid eax will = 0
    je invalidInput                                     ; so go to invalid input
    call crlf                                           ; new line                                         
    mov hexVal2, eax                                    ; set the second hex value

    ret
    
    invalidInput:                                       
        mov edx, OFFSET errMsg                          ; point edx to the error message
        call WriteString                                ; display it
        call crlf                                       ; new line
        jmp start                                       ; restart by prompting user
takeInput ENDP


;-----------------------------------------------------
randTextColor PROC
; generates a random number 0-9 and assigns a text color based on probability,
; The probability of Light Purple is 30%. The probability of Light Blue is 60% and the probability of Light Green is 10%.
; Uses: eax to store values
; Receives: nothing
; Returns: text color set to appropriate color
;-----------------------------------------------------

call Randomize                                          ; seed the random function
mov eax, 10                                             ; set the range to 0-9
call RandomRange                                        ; and get a random number in that range
cmp eax, 2                                              ; numbers 0 - 2 means the text is purple
jle purpleText                                          ; so if it's 2 or less jump to purple

cmp eax, 3                                              ; 3 = green text
je greenText                                            ; so jump to green

cmp eax, 4                                              ; anything above 3 = blue text                          
jge blueText                                            ; so go to blue

purpleText:
mov eax, lightMagenta                                   ; set eax = light magenta 
call SetTextColor                                       ; and set the text color
jmp endProc                                             ; go straight to the end

greenText:
mov eax, lightGreen                                     ; set eax = light green
call SetTextColor                                       ; set the text to that color  
jmp endProc                                             ; go straight to the end

blueText:
mov eax, lightBlue                                      ; set eax to light blue
call SetTextColor                                       ; and set that to the text color

endProc:
ret
randTextColor ENDP

;-----------------------------------------------------
xAndY PROC
; performs and displays the operation x AND y
; Uses: ead, edx, edi to store values
; Receives: hexVal1 and hexVal2 set to user input
; Returns: hexResult set to result of operation
;-----------------------------------------------------
    call randTextColor                          ; first get the random text color
    call crlf                                   ; new line

    mov eax, hexVal1                            ; set eax to x value
    call WriteHex                               ; display that
    mov edx, OFFSET andMsg                      ; set edx to AND
    call WriteString                            ; write that
    mov eax, hexVal2                            ; set eax to y
    call WriteHex                               ; write that
    mov edx, OFFSET equalSign                   ; and set edx to = 
    call WriteString                            ; this all creates the display x AND y = 

    mov eax, hexVal1                            ; set eax to x
    mov edi, hexVal2                            ; and edi to y
    and eax, edi                                ; perform the and operation
    mov hexResult, eax                          ; and store the result in the var
    mov eax, hexResult                          ; move the result back to be displayed
    call WriteHex                               ; and display it
    call crlf
    ret
xAndY ENDP

;-----------------------------------------------------
xNandY PROC
; performs and displays the operation x NAND y
; Uses: ead, edx, edi to store values
; Receives: hexVal1 and hexVal2 set to user input
; Returns: hexResult set to result of operation 
;-----------------------------------------------------
    call randTextColor                                      ; get the random text color
    call crlf

                                                            ; this displays x NAND y =
    mov eax, hexVal1
    call WriteHex
    mov edx, OFFSET nandMsg
    call WriteString
    mov eax, hexVal2
    call WriteHex
    mov edx, OFFSET equalSign
    call WriteString

    mov eax, hexVal1                                        ; set eax to x
    mov edi, hexVal2                                        ; and edi to y
    and eax, edi                                            ; to perform nand first you do x AND y
    not eax                                                 ; and then do NOT on the result
    mov hexResult, eax                                      ; store the result
    mov eax, hexResult                                      ; put it back into eax to be displayed
    call WriteHex                                           
    call crlf
    ret
xNandY ENDP

;-----------------------------------------------------
xOrY PROC
; performs and displays the operation x OR y
; Uses: ead, edx, edi to store values
; Receives: hexVal1 and hexVal2 set to user input
; Returns: hexResult set to result of operation 
;-----------------------------------------------------
    call randTextColor
    call crlf

    mov eax, hexVal1                                        ; this all displays x OR y =
    call WriteHex
    mov edx, OFFSET orMsg
    call WriteString
    mov eax, hexVal2
    call WriteHex
    mov edx, OFFSET equalSign
    call WriteString

    mov eax, hexVal1                                        ; set eax = x
    mov edi, hexVal2                                        ; and edi = y
    or eax, edi                                             ; perform the OR operation
    mov hexResult, eax                                      ; store the result
    mov eax, hexResult                                      
    call WriteHex                                           ; display the result
    call crlf
    ret
xOrY ENDP

;-----------------------------------------------------
xNorY PROC
; performs and displays the operation x NOR y
; Uses: ead, edx, edi to store values
; Receives: hexVal1 and hexVal2 set to user input
; Returns: hexResult set to result of operation
;-----------------------------------------------------
    call randTextColor                                  ; get the random text color
    call crlf

    mov eax, hexVal1                                    ; this displays x NOR y = 
    call WriteHex
    mov edx, OFFSET norMsg
    call WriteString
    mov eax, hexVal2
    call WriteHex
    mov edx, OFFSET equalSign
    call WriteString

    mov eax, hexVal1                                     ; set eax = to x
    mov edi, hexVal2                                     ; and edi = to y
    or eax, edi                                          ; to do nor first perform the OR operation
    not eax                                              ; then NOT the result
    mov hexResult, eax                                   ; store the result
    mov eax, hexResult
    call WriteHex                                        ; display it
    call crlf
    ret
xNorY ENDP

;-----------------------------------------------------
notX PROC
; performs and displays the operation NOT X
; Uses: ead, edx, edi to store values
; Receives: hexVal1 set to user input
; Returns: hexResult set to result of operation 
;-----------------------------------------------------
    call randTextColor                                  ; get the random text color
    call crlf

    mov edx, OFFSET notMsg                              ; display NOT x = 
    call WriteString
    mov eax, hexVal1
    call WriteHex
    mov edx, OFFSET equalSign
    call WriteString
        
    mov eax, hexVal1                                    ; set eax to x
    not eax                                             ; perform the NOT operation
    mov hexResult, eax                                  ; store the result
    mov eax, hexResult
    call WriteHex                                       ; display the result
    call crlf
    ret
notX ENDP

;-----------------------------------------------------
notY PROC
; performs and displays the operation NOT y
; Uses: ead, edx, edi to store values
; Receives: hexVal1 and hexVal2 set to user input
; Returns: hexResult set to result of operation
;-----------------------------------------------------
    call randTextColor                                  ; get the random text color
    call crlf

    mov edx, OFFSET notMsg                              ; display NOT y =
    call WriteString
    mov eax, hexVal2
    call WriteHex
    mov edx, OFFSET equalSign
    call WriteString

    mov eax, hexVal2                                    ; move y into eax
    not eax                                             ; perform the not operation
    mov hexResult, eax                                  ; store the result
    mov eax, hexResult
    call WriteHex                                       ; display the result
    call crlf
ret
notY ENDP

;-----------------------------------------------------
xXorY PROC
; performs and displays the operation x XOR y
; Uses: ead, edx, edi to store values
; Receives: hexVal1 and hexVal2 set to user input
; Returns: hexResult set to result of operation
;-----------------------------------------------------
    call randTextColor                                  ; get the random text color
    call crlf

    mov eax, hexVal1                                    ; display x XOR y = 
    call WriteHex
    mov edx, OFFSET xorMsg
    call WriteString
    mov eax, hexVal2
    call WriteHex
    mov edx, OFFSET equalSign
    call WriteString

    mov eax, hexVal1                                    ; set eax to x
    mov edi, hexVal2                                    ; set edi to y
    xor eax, edi                                        ; perform the xor operation
    mov hexResult, eax                                  ; store the result
    mov eax, hexResult
    call WriteHex                                       ; display the result
    call crlf
    ret
xXorY ENDP

;-----------------------------------------------------
xXnorY PROC
; performs and displays x XNOR y
; Uses: ead, edx, edi to store values
; Receives: hexVal1 and hexVal2 set to user input
; Returns: hexResult set to result of operation
;-----------------------------------------------------
    call randTextColor                                  ; get random text color
    call crlf

    mov eax, hexVal1                                    ; display x XNOR y
    call WriteHex
    mov edx, OFFSET xnorMsg
    call WriteString
    mov eax, hexVal2
    call WriteHex
    mov edx, OFFSET equalSign
    call WriteString

    mov eax, hexVal1                                    ; set eax to x
    mov edi, hexVal2                                    ; and edi to y
    xor eax, edi                                        ; to do XNOR first perform the XOR
    not eax                                             ; then not the result
    mov hexResult, eax                                  ; store the result
    mov eax, hexResult
    call WriteHex                                       ; display the result
    call crlf
    ret
xXnorY ENDP


end main