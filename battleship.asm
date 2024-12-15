COMMENT !
Joseph Work
12/7/24
CSC 3000 X00
Final Part 2
This program plays a game of battle ship against an ai, where the player has to attempt to find and destroy five ships
before the computer destroys theirs, the two main problems with this program that I was not able to fix are that
the ships will spawn overlapping each other and the AI does not have any logic behind it's shots besides shooting randomly
!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

putCarriers PROTO modifier:BYTE, upperLimit:BYTE			
putBShips PROTO modifier:BYTE, upperLimit:BYTE
putCruisers PROTO modifier:BYTE, upperLimit:BYTE
putDestroyers PROTO modifier:BYTE, upperLimit:BYTE

.data

pwallX BYTE 42, 42, 53, 53									; the X positions of the corners of the 10x10 wall
pwallY BYTE 5, 16, 5, 16									; the Y positions of the corners of the 10x10 wall
cWallX BYTE 64, 64, 75, 75									; the X positions of the corners of the 10x10 wall
wallArr BYTE 11 DUP("-"),0									; this array is used to display both horinzontal walls
pCarrierCoordsX BYTE 0,0,0,0,0								; array to hold the x coords of the players carrier
pCarrierCoordsY BYTE 0,0,0,0,0								; array to hold the y coords of the players carrier
pBShipCoordsX BYTE 0,0,0,0									; array to hold the x coords of the player's battleship
pBShipCoordsY BYTE 0,0,0,0									; array to hold the y coords of the player's battleship
pCruiserCoordsX BYTE 0,0,0									; array to hold the x coords of the player's cruiser
pCruiserCoordsY BYTE 0,0,0									; array to hold the y coords of the player's cruiser
pSubCoordsX BYTE 0,0,0										; array to hold the x coords of the player's submarine
pSubCoordsY BYTE 0,0,0										; array to hold the y coords of the player's submarine
pDesCoordsX BYTE 0,0										; array to hold the x coords of the player's destroyer
pDesCoordsY BYTE 0,0										; array to hold the y coords of the player's destroyer

cCarrierCoordsX BYTE 0,0,0,0,0								; array to hold the x coords of the ai's carrier
cCarrierCoordsY BYTE 0,0,0,0,0								; array to hold the y coords of the ai's carrier
cBShipCoordsX BYTE 0,0,0,0									; array to hold the x coords of the ai's battleship
cBShipCoordsY BYTE 0,0,0,0									; array to hold the y coords of the ai's battleship
cCruiserCoordsX BYTE 0,0,0									; array to hold the x coords of the ai's cruiser
cCruiserCoordsY BYTE 0,0,0									; array to hold the y coords of the ai's cruiser
cSubCoordsX BYTE 0,0,0										; array to hold the x coords of the ai's submarine
cSubCoordsY BYTE 0,0,0										; array to hold the y coords of the ai's submarine
cDesCoordsX BYTE 0,0										; array to hold the x coords of the ai's destroyer
cDesCoordsY BYTE 0,0										; array to hold the y coords of the ai's destroyer

playerBoardMod BYTE 43										; the amount to be added to a random number to place it within the player's board
compBoardMod BYTE 65										; the amount to be added to a random number to place it within the ai's board																				
playerPrompt BYTE "Enter the row to shoot at(A-J): ", 0		; prompt for the player's first input
playerPrompt2 BYTE "Enter the column to shoot at(1-10): ", 0; prompt for the player's second input
clearMessage BYTE "                                     ", 0; string used to delete the last two prompts
errMsg BYTE "Invalid Input", 0								; string displayed when user enteres invalid input
instructMsg BYTE "X - Miss", 0								; message displayed in white to show the player what a miss looks like
instructMsg2 BYTE "X - Hit", 0								; message displayed in red to shot the player what a hit looks like

carrierMsg BYTE "Aircraft Carrier - XXXXX", 0				; message showing how much health an aircraft carrier has
bShipMsg BYTE "BattleShip - XXXX", 0						; message showing how much health a battleship has
cruiserMsg BYTE "Cruiser - XXX", 0							; message showing how much health a cruiser has
subMsg BYTE "Submarine - XXX", 0							; message showing how much health a sub has
destroyerMsg BYTE "Destroyer - XX", 0						; message showing how much health a destroyer has
welcomeMsg BYTE "Welcome to battleship, you have 5 ships, an Aircraft Carrier,",0dh,0ah	; message displayed at the start of the game
			BYTE"a BattleShip, a Cruiser, a Submarine, and a Destroyer. Sink", 0dh,0ah
			BYTE "the enemy ships before they sink yours!", 0

column BYTE 0			; var to hold user entered column
row BYTE 0				; var to hold user entered row
hitflag BYTE 0			; bool used to show if a hit landed or not

pCarHealth BYTE 5		; health of the player's carrier
pBShipHealth BYTE 4		; health of the player's battle ship
pCruHealth BYTE 3		; health of the player's cruiser
pSubHealth BYTE 3		; health of the player's submarine
pDesHealth BYTE 2		; health of the player's destroyer

cCarHealth BYTE 5		; health of the ai's carrier
cBShipHealth BYTE 4		; health of the ai's battleship
cCruHealth BYTE 3		; health of the ai's cruiser
cSubHealth BYTE 3		; health of the ai's submarine
cDesHealth BYTE 2		; health of the ai's destroyer

playerWin BYTE "You won!", 0				; displayed when the player wins
compWin BYTE "You lost!", 0					; displayed when the ai wins
continueMsg BYTE "Play again? (Y/y): ", 0	; continue message

.code
main proc
	startMain:								; label jumped to when restarting
	call clrscr								; clear the screen
	mov edx, OFFSET welcomeMsg				; put the welcome message at the top left
	call WriteString						; write it
	mov edi, OFFSET pWallX					; point edi to the player's board X corners
	mov esi, OFFSET pWallY					; and esi to the player's board Y corners
	call dispWalls							; display the board
	mov edi, OFFSET cWallX					; now point edi to the computer's board X corners
	mov esi, OFFSET pWallY					; and esi to the Y corners
	call dispWalls							; display those
	call dispControls						; display the labels of the rows and columns
	call Randomize							; seed the random functions
											; now we place all of the ships
	mov edi, OFFSET pCarrierCoordsX			; point edi to the carrier's X coords
	mov esi, OFFSET pCarrierCoordsY			; and esi to it's Y coords
	invoke putCarriers, playerBoardMod, 45	; call the put carriers, passing edi, esi, playerBoardmod, and 45

	mov edi, OFFSET pBshipCoordsx			; now point edi to the bship'sX  coords
	mov esi, OFFSET pBShipCoordsY			; esi to Y coords
	invoke putBShips, playerBoardMod, 46	; invoke the function, passing edi esi playerboardmod and 44

	mov edi, OFFSET pCruiserCoordsX			; point edi to the cruiser's X coords
	mov esi, OFFSET pCruiserCoordsY			; esi to it's Y coords
	invoke putCruisers, playerBoardMod, 47	; call the function passing edi esi the boardmod and 43

	mov edi, OFFSET pSubCoordsX				; point edi to the sub's X coords
	mov esi, OFFSET pSubCoordsY				; and esi to it's Y coords
	invoke putCruisers, playerBoardMod, 47	; invoke the cruiser function because subs and cruisers are the same size 

	mov edi, OFFSET pDesCoordsX				; point edi to the destroyer's X array
	mov esi, OFFSET pDesCoordsY				; and esi to it's Y array
	invoke putDestroyers, playerBoardMod, 48; invoke the destroyer function 

											; now we do the same for the computer's ships
	mov edi, OFFSET cCarrierCoordsX			; point edi to the carrier's X coords
	mov esi, OFFSET cCarrierCoordsY			; and esi to it's Y coords
	invoke putCarriers, compBoardMod, 69	; call the function, passing edi esi the computer modifier and 69

	mov edi, OFFSET cBshipCoordsx			; now point edi to the bship'sX  coords
	mov esi, OFFSET cBShipCoordsY			; esi to Y coords
	invoke putBShips, compBoardMod, 70		; invoke the function passing edi esi and 70

	
	mov edi, OFFSET cCruiserCoordsX			; point edi to the cruiser's X coords
	mov esi, OFFSET cCruiserCoordsY			; esi to it's Y coords
	invoke putCruisers, compBoardMod, 71	; invoke the function passing  edi esi and 71

	mov edi, OFFSET cSubCoordsX				; point edi to the sub's X coords
	mov esi, OFFSET cSubCoordsY				; and esi to it's Y coords
	invoke putCruisers, compBoardMod, 71	; invoke the function passing edi esi and 71

	mov edi, OFFSET cDesCoordsX				; point edi to the destroyer's X array
	mov esi, OFFSET cDesCoordsY				; and esi to it's Y array
	invoke putDestroyers, compBoardMod, 72  ; invoke the function passing edi esi and 72
											; now we display the player's ships
	mov eax, gray + (black*16)				; set the text color to grey 
	call settextcolor						; set the color
	mov ecx, 5								; set ecx to 5
	mov edi, OFFSET pCarrierCoordsX			; point edi to the carrier's X array
	mov esi, OFFSET pCarrierCoordsY			; esi to it's Y array
	call dispShip							; display the carrier, passing esi edi and ecx

	mov ecx, 4								; bShip is one length shorter than carrier
	mov edi, OFFSET pBShipCoordsX			; point edi to the Bships X array
	mov esi, OFFSET pBShipCoordsY			; esi to it's Y array
	call dispShip							; display the Bship, passing edi esi and ecx

	mov ecx, 3								; cruiser is one less than bShip
	mov edi, OFFSET pCruiserCoordsX			; point edi to it's X array
	mov esi, OFFSET pCruiserCoordsY			; esi to it's Y array
	call dispShip							; display the cruiser
			
	mov ecx, 3								; sub is same length as cruiser
	mov edi, OFFSET pSubCoordsX				; poin edi to the sub's X 
	mov esi, OFFSET pSubCoordsY				; esi to it's Y
	call dispShip							; display the sub

	mov ecx, 2								; des is one shorter than sub
	mov edi, OFFSET pDesCoordsX				; point edi to des X array
	mov esi, OFFSET pDesCoordsY				; esi to the Y array
	call dispShip							; display the destroyer
	
	mov eax, white + (black*16)				; set the text color back to white
	call settextcolor						; set the color
		
	call playGame							; play the game, returns when game is over
			
	mov edx, OFFSET continueMsg				; point edx to the continue message
	call WriteString						; write it to the screen
	call ReadChar							; take user input
	.IF al == 'Y' || al == 'y'				; if it's a Y or Y 
		call resetGame						; they wanted to restart so call resetGame
		jmp startMain						; then restart main
	.ELSE
		exit								; else exit the game
	.ENDIF

main endp

;-------------------------------------------------------
resetGame PROC
; resets all relevant variables to allow the game to run more than once
; Uses: wallX and Y arrays, all health variables
; Receives: above vars set by game
; Returns:  variables reset to default valules
;-------------------------------------------------------
	mov pWallX[0], 42			; reset the first spot in pwallX to 42
	mov pWallX[1], 42			; reset the second spot to 42
	mov pWallX[2], 53			; reset the third spot to 53
	mov pWallX[3], 53			; reset the fourth spot to 53
	mov pWallY[0], 5			; reset the first spot in pwallY to 5
	mov pWallY[1], 16			; reset the second spot to 16
	mov pWallY[2], 5			; third to 5
	mov pWallY[3], 16			; fourth to 16

	mov cWallX[0], 64			; now reset cwallX to 64
	mov cWallX[1], 64			; then 64
	mov cWallX[2], 75			; then 75
	mov cWallX[3], 75			; and finally 75

	mov pCarHealth, 5			; reset the p carrier health to 5
	mov pBShipHealth, 4			; the bship to 4
	mov pCruHealth, 3			; cruiser to 3
	mov pSubHealth, 3			; sub to 3
	mov pDesHealth, 2			; destroyer to 2

	mov cCarHealth, 5			; ai's carrier health to 5
	mov cBShipHealth, 4			; bship health to 4
	mov cCruHealth, 3			; cruiser to 3
	mov cSubHealth, 3			; sub to 3
	mov cDesHealth, 2			; destroyer to 2
	ret
resetGame ENDP


;-------------------------------------------------------
dispShip PROC
; labels the X and Y of the board so that the player knows where to shoot
; Uses: edx to store values, edi esi as array pointers
; Recieves: edi set to X array, esi set to Y, ecx as loop counter
; Returns: none
;-------------------------------------------------------
	L1:								; runs ecx # of times (passed by caller)
		mov dl, [edi]				; put the X value from the passed array into dl
		mov dh, [esi]				; and the Y into dh	
		call gotoxy					; go there
		mov al, '|'					; put a | into al to represent the ship
		call WriteChar				; display the |
		inc edi						; move to the next X coordinate
		inc esi						; and the next Y
		loop l1						; loop ecx # of times
	ret
dispShip ENDP

;-------------------------------------------------------
dispControls PROC
; labels the X and Y of the board so that the player knows where to shoot
; Uses: edx ebx eax to store values, ecx as loop pointer
; Receives: none
; Returns: none
;-------------------------------------------------------
mov ecx, 10			; set the loop counter to 10
mov bl, 74			; set bl to 74 to move to the ed of the computer's board
mov bh, 4			; and bh to 4 to one above the walls
L1:
	mov dl, bl		; set the X value to bl
	mov dh, bh		; and the Y to dl
	call gotoxy		; go there
	mov eax, ecx	; put ecx into eax to serve as a countdown
	call WriteDec	; display it (1234567810)
	dec bl			; move to the left
	loop l1			; loop ten times
mov bl, 63			; now go to the start of the computer's board, one to the left of the walls
mov bh, 6			; and down to the first actual space
mov ecx, 10			; set the counter back to 10

mov al, 'A'			; set al to A which is how we label that side
L2:
	mov dl, bl		; put the X val into dl
	mov dh, bh		; and the Y into dh
	call gotoxy		; go there
	call WriteChar	; display al(A B C D E F G H I J)
	inc al			; increment al to move to the next letter
	inc bh			; inc bh to move down one space
	loop L2

	mov dl, 80					; go to the right side of the screen
	mov dh, 2					; and row 2
	call gotoxy					; go there
	mov edx, OFFSET instructMsg	; point edx to the miss message
	call WriteString			; display it

	mov dl, 80					; set dl back to 80				
	mov dh, 3					; but go one row down
	call gotoxy					; go there
	mov eax, red + (black*16)	; set eax to red on black
	call settextcolor			; set the text color
	mov edx,OFFSET instructMsg2	; set edx to the hit message
	call WriteString			; display it 
	
	mov dl, 80					; back to the right
	mov dh, 4					; and one row down
	call gotoxy					; go there
	mov edx, OFFSET carrierMsg	; point edx to the carrier message
	call WriteString			; and display it
	mov dl, 80					; back to the right
	mov dh, 5					; another row down
	call gotoxy					; go there
	mov edx, OFFSET bShipMsg	; point edx to the battle ship message
	call WriteString			; display it 
	mov dl, 80					; back to the right
	mov dh, 6					; one row down
	call gotoxy					; go there
	mov edx, OFFSET cruiserMsg	; point edx to the cruiser message
	call WriteString			; display it
	mov dl, 80					; back to the right
	mov dh, 7					; another row down
	call gotoxy					; go there
	mov edx, OFFSET subMsg		; point edx to the submarine message
	call WriteString			; display
	mov dl, 80					; back to the right
	mov dh, 8					; another row down
	call gotoxy					; go there
	mov edx, OFFSET destroyerMsg; set edx to the destroyer message
	call WriteString			; display it
	mov eax, white + (black*16)	; set the text color back to white
	call settextcolor			; set the color
ret

dispControls ENDP

;-------------------------------------------------------
playGame PROC
; alternates turns between the player and AI until one of their fleets are destroyed
; Uses: edx as string pointer, eax to store values, edx to store values
; Receives: none
; Returns: none
;-------------------------------------------------------
	call crlf
	infLoop:								; runs until the game is over
		mov dl, 1							; move one column over
		mov dh, 5							; and five rows down
		call gotoxy							; go there
		mov edx, OFFSET playerPrompt		; point edx to the player prompt
		call WriteString					; write the string		
		call ReadChar						; and get the player's column choice
		mov dl, 1							; move one column over
		mov dh, 5							; five rows down
		call gotoxy							; go there
		mov edx, OFFSET clearMessage		; point edx to the clear prompt
		call WriteString					; write the string, erasing the previous message
		.IF al > 'j' || al < 'a'			; if they didn't enter lowercase a-j
			.IF al <= 'J'					; check if they entered uppercase A-J
				add al, 'a'					; if so convert to lowercase
			.ELSE							; else they did not enter valid input
				jmp invalidInput			; so jump there
			.ENDIF	
		.ENDIF
		sub al, 91							; the Y value is 6-15 so subtract 91 from the char to put it in that range
		mov row, al							; then store that in row
		mov dl, 1							; one row over
		mov dh, 6							; 6 down
		call gotoxy							; go there
		mov edx,OFFSET playerPrompt2		; point edx to the second prompt
		call WriteString					; display that
		call ReadInt						; get an integer from the user
		mov dl, 1							; go back one row oveer
		mov dh, 6							; and six rows down
		call gotoxy							; go there
		mov edx, OFFSET clearMessage		; point edx the clear string
		call WriteString					; write the string, erasing the second prompt
		.IF eax > 10 || eax < 1				; they can only enter 1-10, so if it's outside that
			jmp invalidInput				; it's invalid
		.ENDIF
		add al, 64							; add 64 to the input to place it within the computer's board
		mov column, al						; store that value in the variable

		mov dl, column						; put column in dl
		mov dh, row							; and row into dh
		push edx							; push edx to preserve it
		call playerShot						; now call playershot to see if they landed anytghing
		pop edx								; pop edx to restore, playershot will set the text to red if they landed a hit
		call gotoxy							; go to dh dl
		mov al, 'X'							; put a X into al
		call WriteChar						; and display that at the coords entered by user
		call crlf							; new line
		mov eax, white+(black*16)			; set the text color vack to white on vlack
		call settextcolor					; set the color
		mov eax, 500						; set eax to 500 for 500 ms
		call delay							; delay for half a sec
		mov eax, 10							; then set eax to 10
		call RandomRange					; create a random number within 0-9
		add al, 43							; then add 43 to place that within the player's board
		mov dl, al							; put that into dl
		mov eax, 10							; set eax back to 10
		call RandomRange					; make another random number
		add al, 6							; and add 6 to put it within the board
		mov dh, al							; put that in dh
				
		push edx							; push edx to retain it
		call compShot						; and call comp shot, which will return text color as red if a hit landed
		pop edx								; restore edx
		call gotoxy							; go to dh dl
		mov al, 'X'							; put an X into al
		call WriteChar						; and display that
		call crlf							; new line
		mov eax, white+(black*16)			; set the text color back to white
			call settextcolor				; set the color

		mov ah, 0							; set ah to 0 for comparison
		.IF pCarHealth == ah && pBShipHealth == ah && pCruHealth == ah && pSubHealth == ah && pDesHealth == 0	; if all of the player's ships are destroyed
			call clrscr					; clear the screen
			mov dh, 50					; go to the middle of the screen
			mov dl, 5					; five rows down
			mov edx, OFFSET playerWin	; point edx to the player win string
			call WriteString			; write it
			mov eax, 2000				; set eax to 2 seconds
			call delay					; delay for 2 seconds
			ret
		.ELSEIF cCarHealth == ah && cBShipHealth == ah && cCruHealth == ah && cSubHealth == ah && cDesHealth == 0	; else if all of the ai's ships are gone
			call clrscr					; clear the screen
			mov dh, 50					; go to the middle
			mov dl, 5					; and five rows down
			mov edx, OFFSET compWin		; point edx to the comp win string
			call WriteString			; write it
			mov eax, 2000				; set eax to 2 seconds
			call delay					; delay for that long
			ret
		.ENDIF
		
		mov eax, 500					; set eax to 500 for a half second delay
		call delay						; delay for half a sec
		jmp infLoop						; then restart from the beginning

		invalidInput:					; if they entered invalid input
			mov dh, 7					; go one row below the prompts
			mov dl, 1					; the same X
			call gotoxy					; go there
			mov edx, OFFSET errMsg		; point edx to the error message
			call WriteString			; display it
			call crlf					; new line
			jmp infLoop					; restart loop
playGame ENDP

;-------------------------------------------------------
playerShot PROC 
; handles checking whether the player's shot hit any computer ships
; Uses: edi esi as array pointers, ecx as parameter to check hit
; Receives: dh and dl set to shotX and shotY
; Returns:  text color set to red if a shot landed
;-------------------------------------------------------

		mov hitFlag, 0						; set the hitFlag to false by default
		mov edi, OFFSET cCarrierCoordsX		; point edi to the carrier's X coords
		mov esi, OFFSEt cCarrierCoordsY		; and esi to it's Y coords
		mov ecx, 5							; set the loop counter to ecx
		call checkHit						; call checkhit, passing edi, esi, and ecx	
		.IF hitFlag == 1 && cCarHealth != 0	; if hitFlag is set to 1
			mov eax, red+(black*16)			; set the text color to red to show a hit
			call settextcolor				; set the text color
			dec cCarHealth					; decrement the carrier's health
			jmp endProcedure				; and skip the other checks
		.ENDIF

		mov edi, OFFSET cBShipCoordsX		; point edi to the battleship's X coords
		mov esi, OFFSEt cBShipCoordsY		; point esi to the Bship's Y coords
		mov ecx, 4							; set the loop counter to 4
		call checkHit						; call checkhit, passing edi esi and ecx			
		.IF hitFlag == 1 && cBshipHealth != 0; if hitflag returns as 1
			mov eax, red+(black*16)			; set eax to red on black
			call settextcolor				; set the text color to that
			dec cBShipHealth				; decrmeent the Bship's health
			jmp endProcedure				; and end the procedure
		.ENDIF

		mov edi, OFFSET cCruiserCoordsX		; point edi to the cruiser's X coords	
		mov esi, OFFSEt cCruiserCoordsY		; and esi to it's Y coords
		mov ecx, 3							; set the loop counter to 3
		call checkHit						; call checkhit passing edi esi and ecx
		.IF hitFlag == 1 && cCruHealth != 0	; if hitflag returns as 1
			mov eax, red+(black*16)			; set eax to red on black
			call settextcolor				; set the text color
			dec cCruHealth					; decrement the cruiser's health
			jmp endProcedure				; skip the other checks
		.ENDIF

		mov edi, OFFSET cSubCoordsX			; set edi to the sub's X coords
		mov esi, OFFSEt cSubCoordsY			; and esi to the Y coords
		mov ecx, 3							; set ecx to 6
		call checkHit						; call checkhit, passing edi esi and ecx
		.IF hitFlag == 1 && cSubHealth != 0	; if hitflag returns as 1
			mov eax, red+(black*16)			; set eax to red on black
			call settextcolor				; set the text color to that
			dec cSubHealth					; decrement the sub's health
			jmp endProcedure				; end the procedure
		.ENDIF

		mov edi, OFFSET cDesCoordsX			; point edi to the destroyer's X coords
		mov esi, OFFSEt cDesCoordsY			; esi to the Y coords
		mov ecx, 2							; loop counter to 2
		call checkHit						; call checkHit, passing edi esi and ecx
		.IF hitFlag == 1 && cDesHealth != 0	; if the hitflag returns as 1
			mov eax, red+(black*16)			; set the text color to red
			call settextcolor				; set the color
			dec cDesHealth					; decrement the destroyer's health
		.ENDIF

		endProcedure:
			ret
playerShot ENDP

;-------------------------------------------------------
compShot PROC 
; handles checking whether the computer's shot hit any player ships
; Uses: edi esi as array pointers, ecx as parameter to check hit
; Receives: dh and dl set to shotX and shotY
; Returns:  text color set to red if a shot landed
;-------------------------------------------------------

	mov hitFlag, 0							; set the hitFlag to false by default
		mov edi, OFFSET pCarrierCoordsX		; point edi to the carrier's X coords
		mov esi, OFFSEt pCarrierCoordsY		; and esi to it's Y coords
		mov ecx, 5							; set the loop counter to ecx
		call checkHit						; call checkhit, passing edi, esi, and ecx	
		.IF hitFlag == 1 && pCarHealth != 0	; if hitFlag is set to 1
			mov eax, red+(black*16)			; set the text color to red to show a hit
			call settextcolor				; set the text color
			dec pCarHealth					; decrement the carrier's health
			jmp endProcedure				; and skip the other checks
		.ENDIF

		mov edi, OFFSET pBShipCoordsX		; point edi to the battleship's X coords
		mov esi, OFFSEt pBShipCoordsY		; point esi to the Bship's Y coords
		mov ecx, 4							; set the loop counter to 4
		call checkHit						; call checkhit, passing edi esi and ecx			
		.IF hitFlag == 1  && pBshipHealth != 0; if hitflag returns as 1
			mov eax, red+(black*16)			; set eax to red on black
			call settextcolor				; set the text color to that
			dec pBShipHealth				; decrmeent the Bship's health
			jmp endProcedure				; and end the procedure
		.ENDIF

		mov edi, OFFSET pCruiserCoordsX		; point edi to the cruiser's X coords	
		mov esi, OFFSEt pCruiserCoordsY		; and esi to it's Y coords
		mov ecx, 3							; set the loop counter to 3
		call checkHit						; call checkhit passing edi esi and ecx
		.IF hitFlag == 1  && pCruHealth != 0; if hitflag returns as 1
			mov eax, red+(black*16)			; set eax to red on black
			call settextcolor				; set the text color
			dec pCruHealth					; decrement the cruiser's health
			jmp endProcedure				; skip the other checks
		.ENDIF

		mov edi, OFFSET pSubCoordsX			; set edi to the sub's X coords
		mov esi, OFFSEt pSubCoordsY			; and esi to the Y coords
		mov ecx, 3							; set ecx to 6
		call checkHit						; call checkhit, passing edi esi and ecx
		.IF hitFlag == 1  && pSubHealth != 0; if hitflag returns as 1
			mov eax, red+(black*16)			; set eax to red on black
			call settextcolor				; set the text color to that
			dec pSubHealth					; decrement the sub's health
			jmp endProcedure				; end the procedure
		.ENDIF

		mov edi, OFFSET pDesCoordsX			; point edi to the destroyer's X coords
		mov esi, OFFSEt pDesCoordsY			; esi to the Y coords
		mov ecx, 2							; loop counter to 2
		call checkHit						; call checkHit, passing edi esi and ecx
		.IF hitFlag == 1  && pDesHealth != 0; if the hitflag returns as 1
			mov eax, red+(black*16)			; set the text color to red
			call settextcolor				; set the color
			dec pDesHealth					; decrement the destroyer's health
		.ENDIF

		endProcedure:
			ret
compShot ENDP

;-------------------------------------------------------
checkHit PROC
; checks whether a hit has landed on the provided coordinates in edi and esi
; Uses: edi esi as array pointers, ecx as loop counter
; Receives: edi as pointer to x array, esi as pointer to y array,
; dl set to shot X, dh set to shot Y, ecx set to loop counter
; Returns: hitflag set to 0 or 1 depending on if there was a hit
;-------------------------------------------------------
CheckLoop:
    
    .IF dl == [edi] && dh == [esi]		; if the X and Y match up then a hit has landed
		mov hitFlag, 1					; Set hitFlag to 1 if a hit landed
		jmp EndLoop						; end the loop
	.ENDIF

    inc edi								; else move to next X coordinate
    inc esi								; and move to next Y coordinate
    loop CheckLoop						; loop ecx # of times

EndLoop:
        ret

checkHit ENDP


;-------------------------------------------------------
putCarriers PROC modifier:BYTE, upperLimit:BYTE
; places a five space carrier on the board
; Uses: edi esi as aray pointers, edx to store values, eax to store value
; Receives: edi as pointer to x array, esi as pointer to y array
; modifier set to value that will place piece on either board
; upper limit to decide whether ship will be vertical or horizontal
; Returns: carrier X and Y coordinate arrays populated
;-------------------------------------------------------

		placeShip:
		mov eax, 10					; set the range for a rand num 0-9
		call RandomRange			; get the random number
		add al, modifier			; add the modifier to it to move it within the game board
		mov dl, al					; now set that to dl or the X val
		mov eax, 10					; set eax back to 10
		call RandomRange			; get anothe random number
		add eax, 6					; and add 6 to move it within the board
		mov dh, al					; now set that to Y value
		mov [edi], dl				; store the X in the X array passed in edi
		mov [esi], dh				; and the Y in the Y array passed in edi
		

		
		.IF dl < upperLimit			; now check if it can fit horizontally without overlapping the walls
			inc dl					; if yes move one to the right
			mov [edi+1], dl			; put the new x into the array
			inc dl					; move right again
			mov [edi+2], dl			; put new x
			inc dl					; move right again
			mov [edi+3], dl			; put the new x
			inc dl					; move right one final time
			mov [edi+4], dl			; put the final x
			mov [esi+1], dh			; the Y will be the same so put the next Y
			mov [esi+2], dh			; and the next
			mov [esi+3], dh			; and the next Y
			mov [esi+4], dh			; and the final Y

		.ELSEIF dh < 10				; else we will go vertically if that fits
			inc dh					; increment the Y
			mov [esi+1], dh			; store in it in the Y array
			inc dh					; increment it again
			mov [esi+2], dh			; store it again
			inc dh					; inc again
			mov [esi+3], dh			; store again
			inc dh					; inc again
			mov [esi+4], dh			; store again
			mov [edi+1], dl			; X will be the same so store the x
			mov [edi+2], dl			; store next x
			mov [edi+3], dl			; store next x
			mov [edi+4], dl			; store next X
		.ELSE						; else the placement is invalid so get another one
			jmp placeShip
		.ENDIF
		
		ret

putCarriers ENDP

;-------------------------------------------------------
putBShips PROC modifier:BYTE, upperLimit:BYTE
; places a four space battle ship on the board
; Uses: edi esi as aray pointers, edx to store values, eax to store value
; Receives: edi as pointer to x array, esi as pointer to y array
; modifier set to value that will place piece on either board
; upper limit to decide whether ship will be vertical or horizontal
; Returns: battleship X and Y coordinate arrays populated
;-------------------------------------------------------
placeShip:
mov eax, 10							; set the range for a rand num 0-9
		call RandomRange			; get the random number
		add al, modifier			; add the modifier to it to move it within the game board
		mov dl, al					; now set that to dl or the X val
		mov eax, 10					; set eax back to 10
		call RandomRange			; get anothe random number
		add eax, 6					; and add 6 to move it within the board
		mov dh, al					; now set that to Y value
		mov [edi], dl				; store the X in the X array passed in edi
		mov [esi], dh				; and the Y in the Y array passed in edi
		call gotoxy					; go to that position
		
		.IF dl < upperLimit			; now check if it can fit horizontally without overlapping the walls
			inc dl					; if yes move one to the right
			mov [edi+1], dl			; put the new x into the array
			inc dl					; move right again
			mov [edi+2], dl			; put new x
			inc dl					; move right again
			mov [edi+3], dl			; put the new x
		
			mov [esi+1], dh			; the Y will be the same so put the next Y
			mov [esi+2], dh			; and the next
			mov [esi+3], dh			; and the next Y

		.ELSEIF dh < 11				; else we will go vertically if that fits
			inc dh					; increment the Y
			mov [esi+1], dh			; store in it in the Y array
			inc dh					; increment it again
			mov [esi+2], dh			; store it again
			inc dh					; inc again
			mov [esi+3], dh			; store again
	
			mov [edi+1], dl			; X will be the same so store the x
			mov [edi+2], dl			; store next x
			mov [edi+3], dl			; store next x
		.ELSE						; else the placement is invalid so get another one
			jmp placeShip
		.ENDIF
		ret

putBShips ENDP

;-------------------------------------------------------
putCruisers PROC modifier:BYTE, upperLimit:BYTE
; places a three space ship on the board, either a cruiser or submarine
; Uses: edi esi as aray pointers, edx to store values, eax to store value
; Receives: edi as pointer to x array, esi as pointer to y array
; modifier set to value that will place piece on either board
; upper limit to decide whether ship will be vertical or horizontal
; Returns: cruiser/submarine X and Y coordinate arrays populated
;-------------------------------------------------------
placeShip:
mov eax, 10						; set the range for a rand num 0-9
		call RandomRange			; get the random number
		add al, modifier			; add the modifier to it to move it within the game board
		mov dl, al					; now set that to dl or the X val
		mov eax, 10					; set eax back to 10
		call RandomRange			; get anothe random number
		add eax, 6					; and add 6 to move it within the board
		mov dh, al					; now set that to Y value
		mov [edi], dl				; store the X in the X array passed in edi
		mov [esi], dh				; and the Y in the Y array passed in edi
		call gotoxy					; go to that position
		
		.IF dl < upperLimit			; now check if it can fit horizontally without overlapping the walls
			inc dl					; if yes move one to the right
			mov [edi+1], dl			; put the new x into the array
			inc dl					; move right again
			mov [edi+2], dl			; put new x
			
		
			mov [esi+1], dh			; the Y will be the same so put the next Y
			mov [esi+2], dh			; and the next
		.ELSEIF dh < 12				; else we will go vertically if that fits
			inc dh					; increment the Y
			mov [esi+1], dh			; store in it in the Y array
			inc dh					; increment it again
			mov [esi+2], dh			; store it again
			mov [edi+1], dl			; X will be the same so store the x
			mov [edi+2], dl			; store next x
		.ELSE						; else the placement is invalid so get another one
			jmp placeShip
			
		.ENDIF
		ret
putCruisers ENDP

;-------------------------------------------------------
putDestroyers PROC modifier:BYTE, upperLimit:BYTE
; places a two space destroyer on the board
; Uses: edi esi as aray pointers, edx to store values, eax to store value
; Receives: edi as pointer to x array, esi as pointer to y array
; modifier set to value that will place piece on either board
; upper limit to decide whether ship will be vertical or horizontal
; Returns: destroyer X and Y coordinate arrays populated
;-------------------------------------------------------
placeShip:
	mov eax, 10						; set the range for a rand num 0-9
		call RandomRange			; get the random number
		add al, modifier			; add the modifier to it to move it within the game board
		mov dl, al					; now set that to dl or the X val
		mov eax, 10					; set eax back to 10
		call RandomRange			; get anothe random number
		add eax, 6					; and add 6 to move it within the board
		mov dh, al					; now set that to Y value
		mov [edi], dl				; store the X in the X array passed in edi
		mov [esi], dh				; and the Y in the Y array passed in edi
		call gotoxy					; go to that position
		
		.IF dl < upperLimit			; now check if it can fit horizontally without overlapping the walls
			inc dl					; if yes move one to the right
			mov [edi+1], dl			; put the new x into the array
			mov [esi+1], dh			; the Y will be the same so put the next Y
		.ELSEIF dh < 13				; else we will go vertically
			inc dh					; increment the Y
			mov [esi+1], dh			; store in it in the Y array
			mov [edi+1], dl			; X will be the same so store the x	
		.ELSE
			jmp placeShip
		.ENDIF
		ret
putDestroyers ENDP


;-------------------------------------------------------
dispWalls PROC	
; displays both the player's and computer's boards
; Uses: eax to store values, edx as string pointer
; Receives: edi as pointer to x array, esi as pointer to y array
; Returns: none
;-------------------------------------------------------
	
	mov dl,[edi]					; move the first x wall corner into dl
	mov dh,[esi]					; then the first y wall corner into dh
	call Gotoxy						; go to that position
	mov edx,OFFSET wallArr			; point edx to the wall array
	call WriteString				; display the upper wall

	mov dl,[edi+1]					; move the next x corner into dl
	mov dh,[esi+1]					; and the next y corner
	call Gotoxy						; go to that spot
	mov edx,OFFSET wallArr			; move the wall array into edx
	call WriteString				; and display the lower wall

	mov dl, [edi+2]					; now move the next x corner into dl
	mov dh, [esi+2]					; the next y into dh
	mov eax,"|"						; and move the character '|' into eax
	mov bh, [esi+3]					; move the next corner into bh
	inc bh							; increment the next wall Y to move it one way from the corner
	mov [esi+3], bh					; move the updated corner back into the array
	L1:					
	call Gotoxy						; go to the spot in dl, dh
	call WriteChar					; display the | there
	inc dh							; then increment the y 
	cmp dh, [esi+3]					; and compare it to the next corner to know when to stop	
	jl L1							; if it's less than continue looping

	mov dl, [edi]					; move the next corner into dl
	mov dh, [esi]					; and dh
	mov eax,"|"						; and move the | back into eax

	L2:		
	call Gotoxy						; go to dh dl
	call WriteChar					; display the | there
	inc dh							; inc dh to move up 
	cmp dh, [esi+3]					; compare it to the corner 
	jl L2							; loop while it's less than the corner
	
	ret
dispWalls ENDP


end main