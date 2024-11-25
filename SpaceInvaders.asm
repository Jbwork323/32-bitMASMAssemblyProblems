COMMENT !
Joseph Work
11/23/24
CSC 3000 X00
HW Assignment 12
This program plays the space invaders game, where a player has to defend themselves from aliens by shooting lazers
if the alien gets to the ground where the player is they lose the game
!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
wallArr BYTE 17 DUP("-"),0									; this array is used to display both horinzontal walls
wallX BYTE 52,52,68,68										; the X positions of the corners of the wall
wallY BYTE 5,24,5,24										; the Y positions of the corners of the wall
alien BYTE "W", 0											; the alien's symbol
AlienX BYTE ?												; var to store the x position of a generated alien
AlienY BYTE ?												; var to hold the Y position of a generated alien
player BYTE "^", 0											; the player's symbol
playerX BYTE 60												; var to the hold the player's X 
playerY BYTE 23												; var to hold the player's Y
input BYTE " ", 0											; var to hold the player's input
bullet BYTE "|", 0											; the laser symbol
bulletX BYTE 0												; the bullet'x X position
bulletY BYTE 0												; the bullet's Y position
hitLanded BYTE 0											; bool to hold whether the bullet hit an alien or not
gameOver BYTE 0												; bool to hold whether the alien hit the ground or not
delayVal DWORD 350											; var to hold the amount of delay to be multipled by the user entered speed
score DWORD 0												; var to hold the user's score
scoreMsg BYTE "Score: ", 0									; string displayed with the score
speed DWORD 0												; the player entered speed
speedMsg BYTE "Enter a 1 for a fast speed, or 2 for slow: ", 0 ; message prompting the player for the speed
leftMsg BYTE "a - move left", 0								; message explaining how to move left
rightMsg BYTE "d- move right", 0							; message explaning how to move right
shootMsg BYTE "spacebar - shoot lazer", 0					; message explaining how to shoot a lazer
lastScore DWORD 0											; var to hold the user's previous score
titleMsg BYTE "SPACE INVADERS", 0							; title message
continueMsg BYTE "Play again? (Y/y): ", 0					; continue message
highScore DWORD 0											; var to hold the user's high score
highScoreMsg BYTE "High Score: ", 0							; message displayed with high score
gameOverMsg BYTE "GAME OVER", 0								; message displayed when game ends
quitMsg BYTE "0 - Quit Game", 0								; message explaining how to quit the game
errMsg BYTE "Invalid Input", 0								; message displayed when the user enters an invalid speed


welcomeMsg BYTE "Welcome to Space invaders, where aliens are trying to invade your space by making it past your defenses!", 0dh,0ah
			BYTE "Destroy the aliens with lazers! Lazers shoot faster than light but you can", 0dh, 0ah
			BYTE "only shoot one at a time so line up your shots! Press any key when you're ready...", 0
.code
main proc
	startMain:
	call startUp							; first call start up to display all messages and get the speed
	call dispWalls							; then display the board
	call Randomize							; seed the random functions
	call getAlienPosition					; spawn the first alien
	call playGame							; and finally play the game
	mov ebx, score							; once the game is over store the score in ebx
	.IF ebx > highScore						; if it's higher than the high score
		mov highScore, ebx					; set the new high score
	.ENDIF
	call clrscr								; clear the game board once the game ends
	mov dh, 10								; move to the middle of the screen
	mov dl, 54								; move to the middle
	call gotoxy								; go to the middle
	mov edx, OFFSET gameOvermsg				; set edx to the game over message
	call WriteString						; display the string
	mov dh, 11								; go directly under that message
	mov dl, 54								; same X
	call gotoxy								; go there
	mov edx, OFFSET scoreMsg				; point edx to the score message
	call WriteString						; write the string
	mov eax, score							; now store the score in eax
	call WriteDec							; and display the score next to the score message
	mov dh, 12								; go right under that
	mov dl, 54								; same x
	call gotoxy								; go to that position
	mov edx, OFFSET highscoreMsg			; display the high score message
	call WriteString						; write the string
	mov eax, highScore						; store the high score in eax
	call WriteDec							; display the high score
	mov eax, 2000							; now set eax to 2 seconds
	call Delay								; delay
	call crlf								; new line then prompt the user to continue
		mov edx, OFFSET continueMsg			; point edx to the continue message
		call WriteString					; write it to the screen
		call ReadChar						; take user input
		.IF al == 'Y' || al == 'y'			; if it's a Y or Y 
			call resetGame					; they wanted to restart so call resetGame
			jmp startMain					; then restart main
		.ELSE
			exit							; else exit the game
		.ENDIF
	
main endp

;-------------------------------------------------------
resetGame PROC
; resets all relevant variables to allow the game to run more than once
; Uses: wallX and Y arrays, score and gameOver vars
; Receives: above vars set by game
; Returns:  variables reset to default valules
;-------------------------------------------------------
	mov wallX[0], 52		; reset the top right corner
	mov wallX[1], 52		; and the bottom right
	mov wallX[2], 68		; reset top left
	mov wallX[3], 68		; and bottom left
	mov wallY[0], 5			; now reset the top right Y
	mov wallY[1], 24		; reset the bottom right Y
	mov wallY[2], 5			; reset the top left Y
	mov wallY[3], 24		; reset the bottom left Y
	mov score, 0			; reset the score
	mov gameOver, 0			; and reset the gameOver bool
	ret	

resetGame ENDP

;-------------------------------------------------------
startUp PROC
; displays a series of messages and allows the user to enter a speed of 1 or 2
; Uses: eax to store values, edx as string pointer
; Receives: none
; Returns:  speed set to user input
;-------------------------------------------------------
	call clrscr						; clear the screen in case any previous games have been played
	mov edx, OFFSET welcomeMsg		; now point edx to the welcome message
	call WriteString				; display it
	call ReadChar					; and wait for input from the user to continue

	speedLabel:
	call crlf						; new line
	mov edx, OFFSET speedMsg		; now point edx to the speed prompt
	call WriteString				; display it
	call ReadInt					; and get an integer from the user
	.IF eax != 1 && eax != 2		; the user can only enter a 1 or a 2
		mov edx, OFFSET errMsg		; so if it's not those things then set edx to the error message
		call WriteString			; write the string
		jmp speedLabel				; and restart
	.ENDIF
	mov speed, eax					; else store the speed in eax	
	call clrscr						; then clear the screen
	mov dh, 5						; set dh to 5
	mov dl, 1						; and dl to 1
	call gotoxy						; go there
	mov edx, OFFSET leftMsg			; point edx to the left control message
	call WriteString				; display it
	mov dh, 6						; move one Y pos down
	mov dl, 1						; same x
	call gotoxy						; go there
	mov edx, OFFSET rightMsg		; point edx to the right controls message
	call WriteString				; write the string
	mov dh, 7						; move one Y down
	mov dl, 1						; same x
	call gotoxy						; go there
	mov edx, OFFSEt shootMsg		; and point edx to the space bar message
	call WriteString				; display that message
	mov dh, 8						; move one more y down
	mov dl, 1						; same x
	call gotoxy						; go there
	mov edx, OFFSET quitMsg			; now point edx to the 0 quit message
	call WriteString				; display it 
	mov dh, 1						; go back to the top of the screen
	mov dl, 53						; and then to the top middle
	call gotoxy						; go there
	mov eax, green + (black*16)		; set eax to green
	call setTextcolor				; set the text color
	mov edx, OFFSET titleMsg		; point edx to the title
	call WriteString				; display the title
	mov eax, white + (black*16)		; then reset eax to white on black
	call setTextcolor				; set the text color
	ret								; return to main


startUp ENDP

;-------------------------------------------------------
dispAlien PROC
; moves the alien from right to left until it hits the right wall 
; when it then begins coming down towards the player
; Uses: eax to store values edx to store values
; Receives: none
; Returns: gameOver boolean set to true if the game is over
;-------------------------------------------------------
	mov eax, green + (black*16)			; the aliens are green so set eax to that
	call settextcolor					; then set the text color
	mov dl, alienX						; set dl to the alien's X position
	mov dh, alienY						; and dh to it's Y pos
	call Gotoxy							; go to that spot
	mov al, " "							; set al to an empty space
	call WriteChar						; and erase the previous alien 
	.IF alienX <= 53					; now we need to create it's new spot
		inc alienX						; if the alien has reached the left wall it should always move right
	.ELSEIF alienX >= 67 || alienY > 6	; else if it has already hit the right wall or it's Y is below 6(meaning it's already moved down before)
		inc alienY						; the Y to move the alien down
		mov eax, 1						; set eax to 1 for random numbr
		call RandomRange				; create a random number 0 or 1
		.IF eax == 0					; if it's 0 
			dec alienX					; then have the alien move left
		.ELSE							; else 
			inc alienX					; have it move to the right
		.ENDIF
	.ELSE								; else the alien is still moving along the top wall
		mov eax, 5						; so set eax to five for a random range
		call RandomRange				; create a random num 0-4
		.IF eax == 0					; if it's 0
			dec alienX					; then have the alien move left
		.ELSE							; else
			inc alienX					; have it move right, this should make the alien reach the right wall quickly
		.ENDIF
	.ENDIF

	mov dl, alienX						; once the positions have been set put the X into dl
	mov dh, alienY						; and the Y into dh
	call goToXy							; go to that position
	mov al, alien						; move the alien's char "W" into al
	call WriteChar						; display it at the new position
	.IF alienY >=24						; if the Y is >= 24 then the alien has reached the bottom 
		mov gameOver, 1					; meaning the player lost so set the boolean
	.ENDIF
	mov eax, white+(black*16)			; now set eax back to white on black
	call settextcolor					; set the text color
	ret									; and return
dispAlien ENDP


;-------------------------------------------------------
dispPlayer PROC
; displays the player in the new position set by their input
; Uses: eax to store values, edx to store values
; Receives: bl set to player's old X, playerX and Y set by playGame
; Returns: none
;-------------------------------------------------------
	mov eax, blue + (black*16)			; the player's color is blue so set eax to that
	call setTextColor					; set the text color
	mov dl, bl							; bl stores the player's old x so set dl to that
		mov dh, playerY					; the Y will always be the same so store that in dh
		call goToXy						; go to that position
		mov al, " "						; set al to an empty space
		call WriteChar					; write the space on the player;s prev position to erase it
		mov dl, playerX					; now set dl to the player's new X
		mov dh, playerY					; and dh to their new Y
		call goToXy						; go to the new position
		mov al, player					; now set al to the player's icon ^
		call WriteChar					; display that
		mov eax, white + (black*16)		; set eax to white on black
		call setTextColor				; now set the text color to that
		ret								; and return to play game
dispPlayer ENDP

;-------------------------------------------------------
dispBullet PROC
; displays a lazer going upwards on the screen from where the player shot it
; setting a boolean if they hit the alien
; Uses: eax to store values, ecx as looop counter, ebx to store values
; Receives: bulletX and bulletY set by playGame
; Returns: hitLanded set to true or false
;-------------------------------------------------------
		mov eax, red + (black*16)			; the lazer should appear as red so set eax to that
		call settextcolor					; then set the text color
		mov ecx, 16							; set the loop counter to 16
		mov hitLanded, 0					; and set the hit landed bool to false
		L1:
			mov dl, bulletX					; move the bullet's X into dl
			mov dh, bulletY					; and the y into dh
			call gotoxy						; go to that position
			mov al, " "						; set al to an empty space to erase the previous bullet position
			call WriteChar					; erase it
			dec bulletY						; decrement the Y to move the bullet upwards
			mov dl, bulletX					; now set dl back to the X
			mov dh, bulletY					; and dh to the now updated Y
			call GoToXy						; go to that position
			mov al, bullet					; store a | in al to display the bullet
			call WriteChar					; display it 
			mov eax, 50						; set eax to 50 for a delay of 50ms between each bullet updated
				
			call delay						; call the delay
			mov al, alienX					; now set al to the alien's x
			mov bl, bulletX					; and bl to the bullet's x
			mov ah, alienY					; ah to the alien's y
			mov bh, bulletY					; bh to bullet's y
			.IF bl == al && bh == ah		; if all four match then the bullet has hit the alien
				mov hitLanded, 1			; so update the bool
				inc score					; increment the score
				jmp endLoop					; and end the procedure
			.ENDIF

			dec ecx							; decrement ecx
			jnz L1							; and loop until it reaches 0 (16 times)
	endLoop:
		mov dl, bulletX						; set dl back to the bullet's x
		mov dh, bulletY						; and dh back to its y
		call gotoxy							; go to that spot
		mov al, " "							; set al to an empty space
		call WriteChar						; and erase the bullet
		mov bulletX, 0						; reset the bullet's x to 0
		mov bulletY, 0						; and the y to 0
		mov eax, white + (black*16)			; now reset eax to white on black
		call setTextColor					; set the text color
		ret									; and return to main

dispBullet ENDP

;-------------------------------------------------------
playGame PROC
; runs an infinite loop that iterates until the game is over or the player quits
; Uses: eax, ebx to store values, edx as string pointer
; Receives: hitlanded and gameOver bools for certain checks
; Returns: none
;-------------------------------------------------------
	mov dl, 2
	mov dh, 2
	call gotoxy
	mov edx, OFFSET highScoreMsg
	call WriteString
	mov eax, highScore
	call WriteDec

infiniteLoop:
	mov dl, 2							; we update the score message every iteration
	mov dh, 1							; so go to 2,1
	call gotoxy							; go to those coordinates
	mov edx, OFFSET scoreMsg			; point edx to the score label
	call WriteString					; display it
	mov eax, score						; then set eax to the score
	call WriteDec						; display the score
	call ReadKey						; now call read key which does not wait for input
	jz noKey							; if there's no key then jump there
		
	mov input, al						; else store the key inside input
	cmp input, "a"						; if it was a then the player wanted to move left
		je moveLeft						; so jump there
	cmp input, "d"						; if it was d then they wanted to move right
		je moveRight					; so jump there
	cmp input, " "						; if it was space then they wanted to shoot
		je shoot						; so jump there
	.IF input == '0'					; finally if they entered a 0 they wanted to quit
		ret								; so jump there
	.ENDIF						

	noKey:								; if they did not enter a key 
	jmp movePlayer						; jump straight to move player which will display them in the same place
		
	moveLeft:							; if they wanted to move left
		mov al, playerX					; first store the player x in al
		.IF playerX <= 53				; then compare it to 53(the edge of the wall)
			mov bl, playerX				; if it's equal or below then they cannot move again
			jmp movePlayer				; so go straight to move player without updating their X 
		.ENDIF	
		mov bl, playerX					; else store playerX in bl
		dec playerX						; then decrement playerX
		jmp movePlayer					; and finally go to move the player

	moveRight:							; if they wanted to move right
		mov al, playerX					; store the player's x in al to check against the wall
		.IF playerX >= 67				; if the X is equal or above 67 then they have hit the right wall
			mov bl, playerX				; so they cannot move anymore
			jmp movePlayer				; jup straight to moving the player without updating anything
		.ENDIF
		mov bl, playerX					; else store their X in bl
		inc playerX						; increment the player x to move right
		jmp movePlayer					; and then go to move the player 

	shoot:								; if they entered space
		mov bl, playerX					; store the player's x in bl
		mov bulletX, bl					; then store the player's X in bulletX
		mov al, playerY					; move the player's y into al
		dec al							; then decrement it to move one spot above the player
		mov bulletY, al					; and finally move that into the bullet's Y
		
		call dispBullet					; now display the bullet
		.IF hitLanded == 1				; the proc will return a 1 if they hit the alien
			call getAlienPosition		; so if they did we need to spawn a new alien
		.ENDIF

	movePlayer:							; if they entered either a or d
		call dispPlayer					; call disp player with the current X and Y
		mov eax, delayVal				; once it returns move the delay value into eax
		mov ebx, speed					; and then the speed they selected into ebx
		mul ebx							; multiply the two to get the current speed
		call Delay						; then delay by that many milliseconds
		call dispAlien					; after the delay update the alien's pos
		mov eax, score					; now we need to check how many aliens they have killed
		.IF eax > 0 && lastScore != eax ; every five rounds the score increases, so this IF will only
										; run if the score has been updated since the last time it was % 5
			mov lastScore, eax			; move the lastscore into eax for the next round of checks
			mov ebx, 5					; move 5 into ebx for division
			xor edx, edx				; xor edx to zero it out
			cdq							; sign extend for division
			div ebx						; divide their score by 5
			.IF edx == 0				; if edx = 0 then they have reached another five round interval
				sub delayVal, 50		; so subtract 50 from the delay val to make it faster
			.ENDIF
		.ENDIF
		.IF gameOver == 1				; if the alien ended up hitting the bottom this bool will be set
			ret							; so return if it is
		.ENDIF
		jmp infiniteLoop				; else continue the loop
playGame ENDP

;-------------------------------------------------------
getAlienPosition PROC	
; generates a random position to place an alien at the top of the wall
; Uses: eax and esi to store values, ecx as loop counter 
; Receives: none
; Returns: AlienX and AlienY set to random integers 
;-------------------------------------------------------
	generateX:						; loop to generate a valid alien X spot
	mov eax,17						; start by setting the range 0-16
	call RandomRange				; create a number in that range
	add eax, 51 					; then add 50 to make the range 53-67
	mov AlienX,al					; then store the value in AlienX to 

	mov AlienY, 6					; set Y to six because the alien will always spawn on the top row
	mov dl,AlienX					; now that we have the x and y set move the x into dl
	mov dh,AlienY					; and the y into dh
	call Gotoxy						; go to that position
	mov eax, green + (black*16)		; set the text color to green for the aliens
	call settextcolor				; set that text color
	mov al,alien					; put a W into al for the alien ship
	call WriteChar					; display the alien
	mov eax, white + (black*16)		; now reset eax to white on black
	call settextcolor				; set the text color
	ret								; and return
								
getAlienPosition ENDP




;-------------------------------------------------------
dispWalls PROC	
; displays the top and bottom walls of the game 
; Uses: eax to store values, edx as string pointer
; Receives: none
; Returns: none
;-------------------------------------------------------
	
	mov dl,wallX[0]					; move the first x wall corner into dl
	mov dh,wallY[0]					; then the first y wall corner into dh
	call Gotoxy						; go to that position
	mov edx,OFFSET wallArr			; point edx to the wall array
	call WriteString				; display the upper wall

	mov dl,wallX[1]					; move the next x corner into dl
	mov dh,wallY[1]					; and the next y corner
	call Gotoxy						; go to that spot
	mov edx,OFFSET wallArr			; move the wall array into edx
	call WriteString				; and display the lower wall

	mov dl, wallX[2]				; now move the next x corner into dl
	mov dh, wallY[2]				; the next y into dh
	mov eax,"|"						; and move the character '|' into eax
	inc wallY[3]					; increment the next wall Y to move it one way from the corner
	L1:					
	call Gotoxy						; go to the spot in dl, dh
	call WriteChar					; display the | there
	inc dh							; then increment the y 
	cmp dh, wallY[3]				; and compare it to the next corner to know when to stop	
	jl L1							; if it's less than continue looping

	mov dl, wallX[0]				; move the next corner into dl
	mov dh, wallY[0]				; and dh
	mov eax,"|"						; and move the | back into eax

	L2:		
	call Gotoxy						; go to dh dl
	call WriteChar					; display the | there
	inc dh							; inc dh to move up 
	cmp dh, wallY[3]				; compare it to the corner 
	jl L2							; loop while it's less than the corner
	
	ret
dispWalls ENDP


end main