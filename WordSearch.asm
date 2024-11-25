COMMENT !
Joseph Work
10/25/24
CSC 3000 X00
HW Assignment 8
This program randomly picks 6 words from an array of animal names, then embeds those words into a 10x10
grid of random characters. The user can search this grid and enter any words they think they've found
they have ten tries to find all six word to either win or lose the game
I wasn't able to get the highlighting of found words working unfortunately 
!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data

words BYTE "TIGER", 0, "ZEBRA", 0, "SHARK", 0, "WHALE", 0, "SNAKE", 0
            BYTE "FALCON", 0, "RABBIT", 0, "LIZARD", 0, "PARROT", 0, "GIRAFFE", 0
            BYTE "OCTOPUS", 0, "LEOPARD", 0, "DOLPHIN", 0, "GAZELLE", 0, "JAGUAR", 0
            BYTE "BUFFALO", 0, "KOALA", 0, "PELICAN", 0, "TARANTULA", 0, "ALLIGATOR", 0

; Array of pointers to the words (each pointer holds the address of a string)
    wordPtrs DWORD OFFSET words+0      ; Pointer to "Tiger"
             DWORD OFFSET words+6      ; Pointer to "Zebra"
             DWORD OFFSET words+12     ; Pointer to "Shark"
             DWORD OFFSET words+18     ; Pointer to "Whale"
             DWORD OFFSET words+24     ; Pointer to "Snake"
             DWORD OFFSET words+30     ; Pointer to "Falcon"
             DWORD OFFSET words+37     ; Pointer to "Rabbit"
             DWORD OFFSET words+44     ; Pointer to "Lizard"
             DWORD OFFSET words+51     ; Pointer to "Parrot"
             DWORD OFFSET words+58     ; Pointer to "Giraffe"
             DWORD OFFSET words+66     ; Pointer to "Octopus"
             DWORD OFFSET words+74     ; Pointer to "Leopard"
             DWORD OFFSET words+82     ; Pointer to "Dolphin"
             DWORD OFFSET words+90     ; Pointer to "Gazelle"
             DWORD OFFSET words+98     ; Pointer to "Jaguar"
             DWORD OFFSET words+105    ; Pointer to "Buffalo"
             DWORD OFFSET words+113    ; Pointer to "Koala"
             DWORD OFFSET words+119    ; Pointer to "Pelican"
             DWORD OFFSET words+127    ; Pointer to "Tarantula"
             DWORD OFFSET words+137    ; Pointer to "Alligator"

locationsX BYTE 1, 3, 5, 7, 9, 11, 13, 15, 17, 19
startingSpot DWORD 0
indexes DWORD 6 DUP(21)
iteration DWORD 0
grid BYTE 100 DUP('-')    ; 10x10 grid initialized with '-'
promptMsg BYTE "Enter any words you have found: ", 0
incorrectMsg BYTE "That word isn't in the puzzle.", 0
foundMsg BYTE "You found the word: ", 0
numTries DWORD 0
inputBuffer BYTE 9 DUP (0)
foundWords DWORD 0
startingSpots DWORD 6 DUP(100)
counter DWORD 0
trackingGrid BYTE 100 DUP(0)        ; 10x10 tracking grid initialized with 0 (free spots)
welcomeMsg BYTE "Welcome to word search! There are six hidden animal names in the puzzle, you have ten tries, find them all to win!", 0
winMsg BYTE "You found all the words, congratulations!", 0
loseMsg BYTE "You ran out of tries!", 0
continueMsg BYTE "Play again? (Y/y): "

.code
main proc
    start:
    call clrscr
    mov edx, OFFSET welcomeMsg
    call WriteString
    call crlf
    call Randomize                  ; seed the randomization functions
    mov ecx, 6                      ; first we will create 6 random indexes
    mov edi, OFFSEt indexes         ; point edi to the indexes array
    getIndexes:
    mov eax, 20                     ; an index can be 0-19 because we have 20 words to chose from
    call RandomRange                ; get a random number from 0-19
    push ecx                        ; L2 will change the values of both ecx and edi so push them to preserve them
    push edi                        ; push edi as well
    mov ecx, 6                      ; reset ecx to 6 for loop 2
    mov edi, OFFSEt indexes         ; and point edi back to the start of the array
    L2:                             ; L2 ensures that there are no duplicate indexes
        mov ebx, [edi]              ; move the current index into ebx
        cmp eax, ebx                ; and compare the generated index to the previously created ones
            je matchFound           ; if a match is found we need to restart from the beginning
        add edi, 4                  ; else move to the next index 
        loop l2                     ; and loop 6 times
        pop edi                     ; if no matches are found pop edi
        pop ecx                     ; and ecx to return them to their original values
        jmp putInArray              ; and skip the next part
        matchFound:
            pop edi                 ; if a match is found pop edi 
            pop ecx                 ; and ecx again to regain their original values
            jmp getIndexes          ; and then generate a different index
    putInArray:
        mov [edi], eax              ; put the index into the array
        add edi, 4                  ; move t tyhe next position in the array
        
        loop getIndexes             ; and loop 6 times
   mov edi, OFFSET grid             ; now we will populate the grid array with random characters so point edi to it
   mov ecx, 100                     ; and set ecx to 100
   makeGrid:
    mov eax, 26                     ; set the range to 26 because there are 26 letters in the alphabet           
    call RandomRange                ; generate the random number
    add al, 'A'                     ; and add ASCII A to the value to turn it into an uppercase letter
   mov [edi], al                    ; then put the new generated character into the array
    inc edi                         ; move to the next spot in the array
   loop makeGrid                    ; repeat 100 times
   
   call putWords                    ; put the words into the grid
   call dispGrid                    ; and then display the grid for the user
   call playGame                    ; now finally play the game
   mov edx, OFFSET continueMsg		; prompt the user if they want to continue
   call WriteString					; write it to the screen
   call ReadChar					; take user input
   cmp al, 'Y'						; if it's Y then restart from the beginning
   je start							; jump to start
   cmp al, 'y'						; it's not case senstive so lowercase y also works
   je start							; jump back to the start 
	exit

main endp

;-----------------------------------------------------
playGame PROC
; allows the user to guess for words in the grid 10 times or until they find 6 words
; Uses: esi as array pointer, edx as string pointer, ebx eax to store values, ecx as loop counter
; Receives:  grid array with words embedded into it, wordPtrs array
; Returns: none
;-----------------------------------------------------
    mov numTries, 10                 ; Number of attempts user can make
    mov foundWords, 6                ; number of words they need to find
startGuess:
        
    mov edx, OFFSET promptMsg        ; point edx to the prompt
    call WriteString                 ; write the prompt to the screen
    
    ; Read user input
    mov edx, OFFSET inputBuffer      ; set buffer for input
    mov ecx, 9                       ; max length of word input is 8 + null terminator
    call ReadString                  ; take user input
    
                                     ; now compare the input with the words in the grid
    mov edi, OFFSET indexes          ; start with first word index
    mov esi, OFFSET wordPtrs         ; start with first word pointer
    mov ebx, 6                       ; loop through the 6 embedded words
checkGuess:
    mov eax, [edi]                   ; get the index of an embedded word
    mov esi, [wordPtrs + eax*4]      ; get the pointer to the embedded word
    mov edx, OFFSET inputBuffer      ; compare to user input
    call StrCompare                  ; compare strings
    cmp eax, 0                       ; if strings match (StrCompare returns 0), eax will be 0
    je correctGuess                  ; if guess is correct, jump to correctGuess
    
                                     ; if not correct, move to next word
    add edi, 4                       ; move to the next word index
    dec ebx                          ; decrement the word counter
    jnz checkGuess                   ; continue if there are more words to check

    
    mov edx, OFFSET incorrectMsg     ; if no match has been found point edx to the incorrect message
    call WriteString                 ; display that
    call crlf                        ; new line
    dec numTries                     ; decrement number of tries
    jnz startGuess                   ; repeat until out of tries
    mov edx,OFFSET loseMsg           ; if they've runout of tries point edx to the lose message
    call WriteString                 ; display it
    jmp endGame                      ; and end the procedure

correctGuess:
    mov edx, OFFSET foundMsg         ; if they found a word point edx to the found message
    call WriteString                 ; display it
    mov edx, OFFSET inputBuffer      ; then display the word they guessed
    call WriteString                 ; write the word to the screen
    call crlf                        ; new line
    dec foundWords                   ; decrement the number of found words 
        jnz startGuess               ; if they haven't found six words restart
     mov edx, OFFSET winMsg          ; if they have point edx to the win message
     call WriteString                ; display it
     call crlf                       ; new line
    jmp endGame                      ; go back to main

endGame:
    ret 
playGame ENDP


;-----------------------------------------------------
StrCompare PROC
; compares the user's input to the string in the grid to see if they match
; Uses: esi as array pointer, edx as string pointer, ebx eax to store values
; Receives: indexes array filled with random indexes
; Returns: eax as 0 to show a match, or as 1 to show a fail
;-----------------------------------------------------
    push esi                    ; esi  holds the word from the grid
    push edx                    ; edx holds the user's input
    push ebx                    ; preserve ebx 

    L1:
        mov al, [esi]           ; load the first char from the grid
        mov bl, [edx]           ; then the one from the input
        cmp bl, 'Z'             ; but the grid is all uppercase so if the input isn't we need to convert
            jg makeUpper        ; lowercase are > than upper in ASCII so jump if it's greater than Z
        continue:

        cmp al, bl              ; else compare the two chars
        jne not_equal           ; if they're not equal the comparison is over
        test al, al             ; test if al is 0 which means end of string
        jz equal                ; if we have reached the end of the string the two strings are equal
        inc esi                 ; else move to the char in the grid
        inc edx                 ; and the next in the input
        jmp L1

    not_equal:
        mov eax, 1              ; if not equal move 1 into eax to signify that 
        jmp done                ; and end the function

    equal:                      ; if they are equal
        xor eax, eax            ; zero out eax      

    done:
        pop ebx                 ; pop ebx to return it's original balue
        pop edx                 ; same with edx
        pop esi                 ; and esi
        
        ret

    makeUpper:
        sub bl, 32               ; to convert from lower to uppercase subtract 32
        jmp continue             ; and then go back
StrCompare ENDP

;-----------------------------------------------------
putWords PROC
; places the words picked randomlu at random locations either horizontal, diagonal, or bertica;
; Uses: esi as array pointer, ecx as loop counter, eax to store values, edx as string pointer, ebx to store values
; Receives: indexes array filled with random indexes
; Returns: grid array with words embedded into it
;-----------------------------------------------------
    mov esi, OFFSET indexes             ; point esi to the indexes
    mov ecx, 6                          ; and set the loop counter to 6 for 6 words
    
    L1:
        mov eax, 90                     ; we will generate a random position between 0-89
        call RandomRange                ; create the random number
        mov startingSpot, eax           ; and move it into a var for storage
        mov eax, [esi]                  ; now move the current index into eax
        mov edx, [wordPtrs+eax*4]       ; and the word at that index into edx
        cmp startingSpot, 2             ; diagonal and horizontal words can easily be cut off if placed in the wrong spots
            jle diagonal                ; so if the value is < 2 then we make sure it will be diagonal
        cmp startingSpot, 9             ; else if it's between 3 and 9
            jle vertical                ; it must be vertical
        cmp startingSpot, 10            ; else if it's 10 
            jle diagonal                ; it should be diagonal
        cmp startingSpot, 19            ; in the second row if it's between 11 and 19 
            jle vertical                ; then it should be vertical
        

        horizontal:                     ; anything above that might cause cutoffs so it'll be horizontal
            mov al, [edx]               ; move the first character from the string into al
            cmp al, 0                   ; if it's zero then it's the end of the string
                jz endLoop2             ; so end the loop
            mov ebx, startingSpot       ; otherwise move the starting spot into ebx
            mov [grid+ebx], al          ; and then move the character from the string into the grid at that position

            inc edx                     ; to move horizontal just increment edx
            inc startingSpot            ; and increment the starting spot
       
            jmp horizontal              ; then restart the loop
        vertical:
            mov al, [edx]               ; for vertical move the character from the string into al
            cmp al, 0                   ; check if it's the end of the string
                jz endLoop2             ; if it is then end the loop
            mov ebx, startingSpot       ; else move the starting spot into ebx 
            mov [grid+ebx], al          ; and place the character into the spot in the griod

            inc edx                     ; increment the starting spot
            add startingSpot, 10        ; to move vertical just add ten to move one row down
       
            jmp vertical                ; restart the loop
        diagonal:
            mov al, [edx]               ; move the character into al
            cmp al, 0                   ; check if it's the end of the string
                jz endLoop2             ; if so end the loop
            mov ebx, startingSpot       ; else move the starting spot into ebx
            mov [grid+ebx], al          ; move the char into it's position in the grid

            inc edx                     ; increment the spot
            add startingSpot, 11        ; to move diagonal add 11 to move one row down
       
            jmp diagonal                ; continue the loop

            endLoop2:
                add esi, 4              ; move to the next index 
                dec ecx                 ; decrement the loop counter
                   jnz L1               ; if it's not zero continue
    ret
putWords ENDP


;-----------------------------------------------------
dispGrid PROC
; displays the word search board
; Uses: esi as array pointer, ecx as loop counter, al to store chars
; Receives: grid array populated with values
; Returns: none
;-----------------------------------------------------
    mov esi, OFFSET grid        ; point to the start of the Grid array
    mov ecx, 10                 ; loop counter for 10 rows

PrintGrid:
    
    mov ebx, 10                 ; number of characters to print in one row
PrintRow:
        mov al, [esi]           ; move the letter from esi into al
        call WriteChar          ; write it to the screen
       
        mov al, ' '             ; then follow up with an empty space
        call WriteChar          ; and write that to the screen
        inc esi                 ; move to the next character in the Grid
        dec ebx                 ; decrease the count for the row
        jnz printRow            ; repeat until 10 characters are printed

        call crlf               ; print a new line after each row

        loop printGrid          ; repeat for the next row
        ret                     ; return to main
dispGrid ENDP

end main