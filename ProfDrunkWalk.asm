COMMENT !
Joseph Work
11/1/24
CSC 3000 X00
HW Assignment 9
This program simulates a fake professors drunken walk where she has a 50% chance of going in the same direction, 20% of turning left
20% of turning right, and 10% of turning around. Each step in her path is represented by an X, at each step she has a 1/25th chance
of dropping her phonw which is represented by a Y
Source code from:
Irvine, K. R. (2019). Assembly Language for X86 Processors.
!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

WalkMax = 100                   ; the max number of steps is 100
StartX = 15                     ; I wanted to the walk to start towards the middle of the console so X starts at 15
StartY = 50                     ; and Y starts at 50
DrunkardWalk STRUCT             ; this structure will hold the coordinates of each step
    path COORD WalkMax DUP(<0,0>) ; the coord structure holds the steps
    pathsUsed WORD 0              ; path used stores how many steps were taken
DrunkardWalk ENDS               ; the end of the structure
DisplayPosition PROTO currX:BYTE, currY:BYTE    ; prototyping the displayPosition procedure
phoneDrop PROTO currX:BYTE, currY:BYTE          ; prototypig the phonedrop procedure
.data
welcomeMsg BYTE "Welcome to the professor's drunk walk, this program simulates the path taken by a not-too-sober professor on her way home from a Computer Science holiday party." ; this message is displayed at the start of the program
welcomeMsg2 BYTE " The professor's path is represented by a X, she will drop her phone which is represented by a !.", 0                 ; it is too long for one string so I left the first string without a null terminating string to display both
continueMsg BYTE "Restart? (Y/y): ", 0          ; message prompting the user if they want to run it again

lastDirection DWORD 0                           ; used to store the last direction the prof went to properly reverse directions
currentWalkMax DWORD ?                          ; the range of steps will be between 50-100 and this var will store it
colors DWORD green, red, yellow, lightRed, blue, magenta, green, Yellow, brown, cyan, white     ; an array of colors that will alternate each time the prof reverses
colorSwitch DWORD 0                             ; var used to index colorSwitch
aWalk DrunkardWalk <>                           ; a Drunkard walk structure used in the program
phoneDropped DWORD 0                            ; bool to see if phone has been dropped yet

.code

main PROC
start:                      ; label jumped to when restarting the program
call clrscr                 ; clear the screen at the start of each run
call Randomize              ; seed the random functions
mov edx, OFFSET welcomeMsg  ; point edx to the welcome messages
call WriteString            ; write them to the screen

mov eax, 50                 ; now we will generate the amount of steps between 50-100
call RandomRange            ; create a random numbr between 0-49
add eax, 51                 ; add 51 to make the range 50-100
mov currentWalkMax, eax     ; and store that number as the number of steps
mov esi,OFFSET aWalk        ; now point esi to the struct

call TakeDrunkenWalk        ; and perform the drunk walk
mov dh, 3                   ; the previous proc moves the cursor around so we need to move it back, set X to 3
mov dl, 0                   ; and Y to zero
call goToXy                 ; then go to that position
mov edx, OFFSET continueMsg ; point edx to the continue message
call WriteString            ; write it to the screen
 call ReadChar				; take user input
   cmp al, 'Y'				; if it's Y then restart from the beginning
   je start					; jump to start
   cmp al, 'y'				; it's not case senstive so lowercase y also works
   je start					; jump back to the start 
exit
main ENDP

;-------------------------------------------------------
TakeDrunkenWalk PROC
LOCAL currX:BYTE, currY:BYTE
;
; Takes a walk in random directions (50% to continue current direction)
; 20% to turn left or right respectively, 10% to turn around
; Uses: edi esi as struct pointers, eax ebx to store values
; Receives: ESI points to a DrunkardWalk structure
; Returns: the structure is initialized with random
; values
;-------------------------------------------------------
pushad                                  ; push all registers 

mov edi,esi                             ; point edi to the struct as well
add edi,OFFSET DrunkardWalk.path        ; now move the address to the actual path coord struct
mov ecx,currentWalkMax                  ; loop counter will be 50-100
mov currX,StartX                        ; current X-location
mov currY,StartY                        ; current Y-location
mov colorSwitch, 0                      ; index used to switch colors
mov phoneDropped, 0                     ; bool used to see if phone has been dropped

Again:                                  ; will loop ecx number of times
movzx ax,currX                          ; move the current X position into ax
mov (COORD PTR [edi]).X,ax              ; then move that into the structure
movzx ax,currY                          ; move the current Y position into ax
mov (COORD PTR [edi]).Y,ax              ; then move that into the structure
INVOKE DisplayPosition, currX, currY    ; now display an X at that position to show the prof's path
.IF phoneDropped == 0                   ; each loop check if the phone has already been dropped
    mov eax, 25                         ; if not we'll generate a random number between 0-24
    call RandomRange                    ; get the random number
        .IF eax == 1                    ; each run will have a 1 in 25 chance to drop the phone
            inc phoneDropped            ; if eax is 1 then set the bool to show that it has already been dropped
            invoke phoneDrop, currx, currY  ; and then display the phone in the right position
        .ENDIF
.ENDIF
mov eax, 500                            ; after displaying set eax to 500
call delay                              ; then delay by 500ms

mov eax, 10                             ; now we will generate another number to decide what direction prof will move  
call RandomRange                        ; get the number 0-9

.IF eax <= 4                            ; if it's 0-4 (50%)
    mov eax, lastDirection              ; continue in the same direction
.ELSEIF eax <= 6                        ; else if it's 5-6
                                        ; turn left (20%)
    .IF lastDirection == 0              ; if North
        mov eax, 2                      ; turn left to West
    .ELSEIF lastDirection == 1          ; if South turn 
        mov eax, 3                      ; left to East
    .ELSEIF lastDirection == 2          ; if West 
        mov eax, 1                      ; turn left to South
    .ELSE                               ; if East 
        mov eax, 0                      ; turn left to North
    .ENDIF
.ELSEIF eax <= 8                        ; else if 7-8
                                        ; turn right (20%)
    .IF lastDirection == 0              ; if North 
        mov eax, 3                      ; turn right to East
    .ELSEIF lastDirection == 1          ; if South 
        mov eax, 2                      ; turn right to West
    .ELSEIF lastDirection == 2          ; if West 
        mov eax, 0                      ; turn right to North
    .ELSE                               ; if East 
        mov eax, 1                      ; turn right to South
    .ENDIF
.ELSE                                   ; else the prof will reverse (10%) and change the text color
    .IF colorSwitch == 11               ; there are only 11 colors in the array so if the switch is 11
        mov colorSwitch, 0              ; reset it
    .ENDIF
    mov ebx, colorSwitch                ; move the switch into ebx
    mov eax, [colors+ebx*4]             ; then move the color at the index into eax
    call setTextColor                   ; and set the text color
    inc colorSwitch                     ; increment the color switch
                   
    .IF lastDirection == 0              ; if direction is 0
        mov eax, 1                      ; then switch from north to south
    .ELSEIF lastDirection == 1          ; else if it's 1
        mov eax, 0                      ; switch from south to north
    .ELSEIF lastDirection == 2          ; else if it's 2 
        mov eax, 3                      ; switch from west to east
    .ELSE                               ; else 
        mov eax, 2                      ; switch from east to west
    .ENDIF
.ENDIF

.IF eax == 0                            ; if eax is 0
    dec currY                           ; go north
.ELSEIF eax == 1                        ; else if it's 1 
    inc currY                           ; then go south
.ELSEIF eax == 2                        ; else if it's 2 
    dec currX                           ; then go west
.ELSE                                   ; else if it's 4
    inc currX                           ; go east
.ENDIF

mov lastDirection, eax                  ; update the last direction
add edi, TYPE COORD                     ; and move to the next coord
dec ecx                                 ; decrement the loop counter
    jnz Again                           ; and restart if it's not zero

Finish:                                 ; once done
.IF phoneDropped == 0                   ; if the phone still hasn't been dropped
    invoke phoneDrop, currX, currY      ; drop it at the last position
.ENDIF
mov (DrunkardWalk PTR [esi]).pathsUsed, WalkMax ; update the struct with the walkMax
popad                                           ; pop the registers
ret                                     ; and return
TakeDrunkenWalk ENDP

;-------------------------------------------------------
DisplayPosition PROC currX:BYTE, currY:BYTE
; Display a X at the current X and Y positions.
; uses: edx to store values
; receieves: currX and currY set
; returns: none
;-------------------------------------------------------
.data
profStr BYTE "X",0              ; local var used to display an X at the professors positions
.code
pushad                          ; push the registers
mov dh, currX                   ; move the x position into dh
mov dl, currY                   ; and the Y into dl
call goToXy                     ; go to the position
mov edx, OFFSET profStr         ; point edx to the X
call WriteString                ; and write it at that position
popad                           ; pop the registers
ret
DisplayPosition ENDP



;-------------------------------------------------------
phoneDrop PROC currX:BYTE, currY:BYTE
; Display a ! at the current X and Y positions to show where the phone dropped
; uses: edx to store values
; receieves: currX and currY set
; returns: none
;-------------------------------------------------------
.data
phoneStr BYTE "!",0                 ; ! to be displayed when the phone drops
.code
    pushad                          ; push the registers
    mov dh, currX                   ; move the x position into dh
    mov dl, currY                   ; and the y into dl
    call goToXy                     ; go to that position
    mov edx, OFFSET phoneStr        ; point edx to the !
    call WriteString                ; write the ! to the screen

    ret
phoneDrop ENDP

END main