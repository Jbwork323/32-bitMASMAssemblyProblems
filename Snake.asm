COMMENT !
Joseph Work
11/15/24
CSC 3000 X00
HW Assignment 11
This program plays the snake game, where the player is a snake trying to collect apples
each time they collect an apple the snake gets one segment longer however if they
hit a wall or their own body the game is over, the game stores their high score and
asks if they want to play again upon a loss
!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data

stylizedSnakeMsg1 BYTE " ---  -   -     -     -   -  ----", 0	; string used to display a stylized snake logo
stylizedSnakeMsg2 BYTE "-     --  -    - -    -  -   -   ", 0	; second row of snake logo
stylizedSnakeMsg3 BYTE " ---  - - -   -----   ---    ----", 0	; third row of snake logo
stylizedSnakeMsg4 BYTE "    - -  --  -     -  -  -   -   ", 0	; fourth row of snake logo
stylizedSnakeMsg5 BYTE " ---  -   - -       - -   -  ----", 0	; fifth row of snake logo


wallArr BYTE 52 DUP("-"),0									; this array is used to display both horinzontal walls

welcomeMsg BYTE "Welcome to Snake, your goal is to collect as many apples as you can ", 0dh, 0ah
		   BYTE "without running into a wall or your own tail, move your snake with WASD.", 0dh, 0ah			; message displayed at the start of the game
		   BYTE "Press any key to start the game.", 0

scoreMsg BYTE "Apples Collected: ",0						; displayed with the player score
score BYTE 0												; var to hold player score
highScore BYTE 0											; high score updated when score exceedes high score
continueMsg BYTE "Play again? (Y/y): ",0					; message prompting the player to continue
errMsg BYTE "Invalid input",0								; message displayed when the user enters invalid input
endMsg BYTE "Game Over!",0									; message displayed at the end of the game
highScoreStr BYTE "High Score: ", 0							; String displayed with the high score
snake BYTE "O", 100 DUP("-")								; array of 100 dashes that acts as the body of the snake
xPosition BYTE 55,54,53,52,51, 100 DUP(?)					; array of 100 possible x positions for the snake, starting with the first 5
yPosition BYTE 16,16,16,16,16, 100 DUP(?)					; array of 100 possible y positions for the snake, starting with the first 5
wallX BYTE 34,34,85,85										; the X positions of the corners of the wall
wallY BYTE 5,24,5,24										; the Y positions of the corners of the wall
appleX BYTE ?												; var to store the x position of a generated apples
appleY BYTE ?												; var to hold the Y position of a generated appple
input BYTE "-"												; - denotes the start of the game
lastInput BYTE ?											; var to hold the previous input
speedMsg BYTE "Enter the speed (1-slow, 2-medium, 3-fast): ",0	; message displayed to prompt player to enter speed
speed DWORD 0												; var to hold user entered speed

.code
main PROC
	mov edx, OFFSEt welcomeMsg								; display the welcome message
	call WriteString										; write it to the screen
	call ReadChar											; then wait for user input before continuing
	call clrscr												; get rid of the welcome message
	call setSpeed											; call setSpeed to let the player choose their speed
	call clrscr												; once the speed has been chosen get rid of that message
	call dispWalls											; then display walls
	call dispScore											; put the scoreboard in the top left

	mov esi,0												; set esi to 0
	mov ecx,5												; and the loop counter ecx to 5
dispSnakeLoop:												; loop five times
	call dispSnake											; display the first five snake pieces
	inc esi													; incremen esi after each call
loop dispSnakeLoop											; loop five times

	call Randomize											; seed the random function
	call getApplePosition									; and then generate a random apple position
	call putApple											; put the apple at that position
	call displayTitle
	call playGame											; playGame will play the game until the user loses
	call EndGame											; once playGame returns that means the game is finished
	

	.IF eax == 1											; endGame asks the player if they want to continue
		call resetGame										; and if eax is set to 1 that means they did
	.ELSE													; else
		exit												; end the program
	.ENDIF

main ENDP
;-------------------------------------------------------
displayTitle PROC
; displays a stylized version of the word snake
; Uses: eax, edx to store values
; Receives: none
; Returns: none
;-------------------------------------------------------
    
	mov eax, red							; set eax to red
	call SetTextColor						; then set the text color to that
	mov dl, 42								; move to the middle of the screen
	mov dh, 0								; and start at row 0
	call gotoxy								; go to that position
    mov edx, OFFSET stylizedSnakeMsg1		; point edx to the first part of the message
    call WriteString						; and write that to the screen

    mov eax, magenta						; next set the color to magenta
	call SetTextColor						; set the color to that
    mov dl, 42								; go back to the middle of the screen
    mov dh, 1								; row 1
    call Gotoxy								; go to that position
    mov edx, OFFSET stylizedSnakeMsg2		; point edx to the second part of the message
    call WriteString						; and display that

	 mov eax, yellow						; next set eax to the yellow
	call SetTextColor						; set the color to yelloe
    mov dl, 42								; move to the middle
    mov dh, 2								; and one row down
    call Gotoxy								; go to that position
    mov edx, OFFSET stylizedSnakeMsg3		; point edx to the 3rd message
    call WriteString						; display it

	 mov eax, green							; the next color is green
	call SetTextColor						; set the text to that
    mov dl, 42								; back to the middle
    mov dh, 3								; one row down
    call Gotoxy								; go to that spot
    mov edx, OFFSET stylizedSnakeMsg4		; point edx to the message
    call WriteString						; write the string

	 mov eax, blue							; set eax to blue
	call SetTextColor						; set the text color
    mov dl, 42								; to the middle of the screen
    mov dh, 4								; and one row down
    call Gotoxy								; gto to that position
    mov edx, OFFSET stylizedSnakeMsg5		; point edx to the last message
    call WriteString						; write it
	ret										; return to main
displayTitle ENDP

;-------------------------------------------------------
playGame PROC
; plays the actual snake game until the player hits a wall
; Uses: eax, ebx, edx to store values
; Receives: none
; Returns: none
;-------------------------------------------------------
	gameLoop:							; loop that handles the game
		mov dl,100						; move the cursor out of the way
		mov dh,1						; by setting dl and dh to spots outside the board
		call Gotoxy						; go to that spot

		
		call ReadKey					; read a key from the user, I used WASD for controls 
        jz noKey						; if no key is entered keep going in the same direction

		mov bl, input					; move the char entered into bl
		mov lastInput, bl				; and then store it in lastInput
		mov input,al					; move the entered char into input

		noKey:							; if no key is entered input will still be set from last time
		cmp input,"w"					; if it's w 
		je checkUp						; then check upwards of the snake

		cmp input,"s"					; else if it's s
		je checkBottom					; then check under the snake

		cmp input,"a"					; if it's an a 
		je checkLeft					; then check to the left of the snake
			
		cmp input,"d"					; and finally if it's a d
		je checkRight					; check to the right
		jne gameLoop					; restart if they didn't enter WASD because that means they didn't move
		
		checkBottom:					; each of tehse checks if the user can keep moving	
		cmp lastInput, "w"				; check if the last input was w
		je keepDirection				; because they can't move down right after moving up without hitting their own body
		mov cl, wallY[1]				; mov the bottom wall position into cl
		dec cl							; decrement it to become one unit above the wall
		cmp yPosition[0],cl				; compare the snake position to the wall position
		jl moveDown						; if it's less than they are still alive
		je hitWall						; else they have hit a wall and failed

		checkLeft:						; jumped to if the user moves left
		cmp lastInput, "-"				;first check if it's start of the game, because the snake starts facing right
		je noLeft						; so if they went left right away the snake would hit itself and lose
		cmp lastInput, "d"				; next compare if their last input was d or left
		je keepDirection				; if it was keep that direction
		mov cl, wallX[0]				; else move the position of the left wall into cl
		inc cl							; and increment it 
		cmp xPosition[0],cl				; then check if they are at least one spot away from the wall
		jg moveLeft						; if they are then move left
		je hitWall						; else they must have hit the left wall	

		checkRight:						; next check the right
		cmp lastInput, "a"				; see if they were moving right last
		je keepDirection				; if so keep the direction
		mov cl, wallX[2]				; else move the coord of tyhe right wall into cl
		dec cl							; decrement to become one spot away from that
		cmp xPosition[0],cl				; then see if they are at least one spot away from the wall
		jl moveRight					; if so then move right
		je hitWall						; if not they have hit the right wall and lost	

		checkUp:						; finally check up 
		cmp lastInput, "s"				; check if they were moving up last
		je keepDirection				; if they were they cannot go straight down without hitting themselves
		mov cl, wallY[0]				; next move the top wall coord into cl
		inc cl							; increment it to move one down from the wall
		cmp yPosition,cl				; compare the snake's position to tyhat
		jg moveUp						; if it's greater than the snake can go up
		je hitWall						; if not the snake has hit the wall	
		
		moveUp:							; jumped to when moving the snake up
		mov eax, speed					; move the speed into eax
		add eax, speed					; double the amount of delay because the Y is shorter than X
		call delay						; and delay to set the movement speed
		mov esi, 0						; esi will be used to index the two arrays
		call updateSnake				; update the snake's position on the screen
		mov ah, yPosition[esi]			; ah stores the next y position of the snake
		mov al, xPosition[esi]			; ah stores the next x position of the snake
		dec yPosition[esi]				; decrement the array to move the head up
		call dispSnake					; display the updated snake
		call dispBody					; display the updated body
		call checkSnake					; then check the snake
		jmp checkApple					; go straight to checking if the snake ate an apple
		
		moveDown:						; jumped to when moving down
		mov eax, speed					; move the speed into eax
		add eax, speed					; double the amount of delay because the Y is shorter than X
		call delay						; and delay to set the movement speed
		mov esi, 0						; esi will be used to index the two arrays
		call updateSnake				; update the snake's position on the screen
		mov ah, yPosition[esi]			; ah stores the next y position of the snake
		mov al, xPosition[esi]			; ah stores the next x position of the snake
		inc yPosition[esi]				; increment the array to move the head down
		call dispSnake					; display the updated snake
		call dispBody					; display the updated body
		call checkSnake					; then check the snake
		jmp checkApple					; go straight to checking if the snake ate an apple

		moveLeft:						; jumped to when moving left
		mov eax, speed					; move the speed into eax
		call delay						; then call delay to set the speed
		mov esi, 0						; set esi to 0 to index the arrays
		call updateSnake				; update the snake's position
		mov ah, yPosition[esi]			; ah contains the next y position
		mov al, xPosition[esi]			; al contains the next x
		dec xPosition[esi]				; decrement the x position to move the snake to the left
		call dispSnake					; display the snake
		call dispBody					; and the body
		call checkSnake					; then check the snake
		jmp checkApple					; go straight to checking if the snake ate an apple

		moveRight:						
		mov eax, speed					; move the speed into eax
		call delay						; then call delay to set the speed
		mov esi, 0						; set esi to 0 to index the arrays
		call updateSnake				; update the snake's position
		mov ah, yPosition[esi]			; ah contains the next y position
		mov al, xPosition[esi]			; al contains the next x
		inc xPosition[esi]				; increment the x position to move the snake to the right
		call dispSnake					; display the snake
		call dispBody					; and the body
		call checkSnake					; then check the snake
		
	
		checkApple:						; jumped to after snake has been checked	
		cmp eax, 1						; if checkSnake returns eax as 1 it means a wall has been hit
			je hitWall					; so jump there
		mov esi,0						; set esi to 0 for indexing	
		mov bl,xPosition[0]				; move the snake's x into bl
		cmp bl,appleX					; then compare that to the apple's x
		jne gameloop					; restart if they're not equal
		mov bl,yPosition[0]				; if they are then move the y into bl
		cmp bl,appleY					; compare them
		jne gameloop					; if they're not equal restart

		call gotApple					; else they have gotten an apple	

jmp gameLoop							; loop until game ends


	keepDirection:						; jumped to when changing direction would kill the snake
	mov input, bl						; set the current input as previous input
	jmp noKey				            ; then go back to the start

	noLeft:								; the snake cannot move left at the beginning of the game
	mov	input, "-"						; set the input to - which shows the beginning of the game
	jmp gameLoop						; then restart

	hitWall:							; if they hit a wall they lost 
	ret									; so return to main

playGame ENDP

;-------------------------------------------------------
dispWalls PROC	
; displays the top and bottom walls of the game in a green text color
; Uses: eax to store values, edx as string pointer
; Receives: none
; Returns: none
;-------------------------------------------------------
	push eax						; push eax to preserve it
	mov eax, green + (black*16)		; the walls are green so move that into eax
	call SetTextColor				; set the text color
	pop eax							; then pop eax
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
	push eax						; push eax to preserve it
	mov eax, white +(black*16)		; move white on black into eax
	call SetTextColor				; and reset the text color to that
	pop eax							; pop eax to restore it
	ret
dispWalls ENDP

;-------------------------------------------------------
dispScore PROC		
; displays a scoreboard at the top right of the screen with the current and high scores
; Uses: eax to store values, edx as string pointer
; Receives: none
; Returns: none
;-------------------------------------------------------
	mov dl,2						; score board is displayed at Y 2
	mov dh,1						; and X y
	call Gotoxy						; go to that spot
	mov edx,OFFSET scoreMsg			; point edx to the string that goes with the score
	call WriteString				; display the string
	mov dl, 2						; now set dl back to 2
	mov dh, 2						; but dh to one to move one row down
	call GoToXy						; go to that spot
	mov edx, OFFSET highScoreStr	; now point edx to the message to go with the high score
	call WriteString				; write the string
	movzx eax, highScore			; then mpve the highscore into eax
	call WriteDec					; and display it next to the message
	ret
dispScore ENDP

;-------------------------------------------------------
setSpeed PROC
; allows the player to set the speed of the game from 1-3
; Uses: eax esi to store values, edx to store and point to strings, 
; Receives: none
; Returns: speed variable set
;-------------------------------------------------------
	start:
	mov edx,0					; zero out edx
	mov dl, 35					; the score prompt displays in the middle of the screen so set x to 35	
	mov dh,1					; and y to 1
	call Gotoxy					; go to that position
	mov edx,OFFSET speedMsg		; point edx to the speed prompt
	call WriteString			; display it
	mov esi, 40					; each speed level has a 40ms difference between them
	mov eax,0					; zero out eax
	call readInt				; get the user's input for the speed
	cmp eax,1					; it must be more than 1
	jl invalidInput				; so it's invalid if less than
	cmp eax, 3					; and it must be less than 3
	jg invalidInput				; so it's invalid if greater than
								; the users input will be used to set the speed but 
								; 1 is slowest and 3 is fastest so we fist need to reverse what the entered
	mov ebx, 4					; by first moving 4 into ebx for subtraction
	sub ebx, eax				; subtract the user's input from ebx reversing it 
	mov eax, ebx				; then move the new number into eax

	mul esi						; multiply eax by 40 to set the speed
	mov speed, eax				; store the speed in eax
	ret							; and return

	invalidInput:				; if the user enters invalid input		
	mov dl,35					; go back to the middle of the screen 	
	mov dh,2					; then one spot below the speed message
	call Gotoxy					; go to that spot
	mov edx, OFFSET errMsg		; point edx to the error message		
	call WriteString			; display it
	jmp start					; restart the procedure
	
	ret
setSpeed ENDP

;-------------------------------------------------------
dispSnake PROC	
; displays the head of the snake at the current position
; Uses: eax, edx to store values
; Receives: al, ah set to next position of head
; Returns: updated head position
;-------------------------------------------------------
	push eax						; push eax to preserve it
	mov eax, lightblue +(black*16)	; set eax to lightblue on black
	call SetTextColor				; set the textcolor to that
	pop eax							; then pop eax to restore it
	mov dl,xPosition[esi]			; move the snake's X position into dl
	mov dh,yPosition[esi]			; and the y into dh
	call Gotoxy						; go to that position
	mov dl, al						; move dl into al to save it
	mov al, snake[esi]				; then move that position into the snake array
	call WriteChar					; display the snake's head
	mov al, dl						; move the spot back into dl
	push eax						; push eax again to preserve
	mov eax, white +(black*16)		; set the color back to white on black
	call SetTextColor				; set the text color
	pop eax							; pop eax
	ret								; and return
dispSnake ENDP

;-------------------------------------------------------
updateSnake PROC	
; erases the previous position of the snake each time it moves
; Uses: al, dl, ah to store values
; Receives: al, ah set to new snake positions
; Returns: none
;-------------------------------------------------------
	mov dl, xPosition[esi]			; move the x position into dl
	mov dh,yPosition[esi]			; and the y into dh
	call Gotoxy						; go to that spot
	mov dl, al						; save the value of al in dl
	mov al, " "						; move a blank space into al
	call WriteChar					; write that, deleting the last spot of the snake from the screen
	mov al, dl						; move dl back into al
	ret								; return
updateSnake ENDP

;-------------------------------------------------------
putApple PROC	
; places an apple at a position passed to it by getApple position
; Uses: eax, dl dh to store values
; Receives: appleX and appleY set by getApple position
; Returns: none
;-------------------------------------------------------
	mov eax,red +  (black * 16)		; apples are red so set eax to red on black
	call SetTextColor				;set the color to red
	mov dl,appleX					; the x and Y will have already been generated so move the x into dl
	mov dh,appleY					; and the y into dh
	call Gotoxy						; go to that position
	mov al,"O"						; put a O into al for the apple symbol
	call WriteChar					; display the apple
	mov eax,white + (black * 16)	; then set eax to white on black
	call SetTextColor				; reset the text color
	ret								; and return
putApple ENDP

;-------------------------------------------------------
getApplePosition PROC	
; generates a random position to place an apple while ensuring that the position does not overlap the snake
; Uses: eax and esi to store values, ecx as loop counter 
; Receives: none
; Returns: appleX and appleY set to random integers 
;-------------------------------------------------------
	generateX:						; loop to generate a valid apple X spot
	mov eax,49						; start by setting the range from 0-48
	call RandomRange				; create a number in that range
	add eax, 35						; then add 35 to make the range 35-84(within the game board)
	mov appleX,al					; then store the value in appleX

	generateY:						; generates a valid Y spot
	mov eax,17						; set the range to 0-17
	call RandomRange				; create a number in that range
	add eax, 6						; add six to make the range 6-23 (within the game board)
	mov appleY,al					; store it in the variable

	mov ecx, 5						; set ecx to five because the snake will always have 5 segments
	add cl, score					; add the amount of extra segments to the loop counter
	mov esi, 0						; zero out esi
		
checkX:								; now we have to make sure the apple doesn't spawn on the snake
	movzx eax,  appleX				; move the apple x into eax
	cmp al, xPosition[esi]			; then compare that to snake head's position
	je checkY						; if they're equal then we have to check the y to make sure
	continueloop:					; else continue the looop
	inc esi							; increment to check each segment
loop checkX							; loop ecx # of times
	ret								;  return if the coin is valid

	checkY:							; only check if the X is invalid
	movzx eax, appleY				; move the Y into eax
	cmp al, yPosition[esi]			; compare it against the snake's Y positions
	jne continueloop				; if the Y doesn't equal go back to checking the x's
	jmp generateX					; if the X and Y are the same go back to the start								
getApplePosition ENDP

;-------------------------------------------------------
checkSnake PROC		
; checks if the snake has hit itself or not and lost the game
; Uses: eax, esi to store values, ecx as loop counter
; Receives: xPosition and yPosition array updated by the game
; Returns: ebx as boolean 1 = game over
;-------------------------------------------------------
	mov al, xPosition[0]			; put the snake head's X into al
	mov ah, yPosition[0]			; and the Y into ah
	mov esi,4						; start checking from where the extra segments begin
	mov ecx,1						; set ecx to 1 
	add cl,score					; and add the score to make the loop counter the amount of segments
checkXposition:			
	cmp xPosition[esi], al			; check if the x is the same
	je checkY						; if it is then we need to check Y
	contloop:						; else we can just continue the loop
	inc esi							; inc esi to check the next segment
loop checkXposition					; loop ecx # of times
	
	ret								; if the x's don't match we can return
	checkY:							; if the X matches then we need to check the Y 
	cmp yPosition[esi], ah			; compare the Y position to ah
	je hitSelf						; if they're equal the snake has hit itself
	jmp contloop	

	hitSelf:
		mov ebx, 1					; set ebx to 1 to show the game function that a hit has happened
		ret							; then return
checkSnake ENDP

;-------------------------------------------------------
dispBody PROC	
; displays the body of the snake following the head
; Uses: eax, edx to store values, ecx as loop counter, esi as index
; Receives: x and yPositions set by gameplay
; Returns: none
;-------------------------------------------------------
		push eax						; push eax to preserve it
		mov eax, lightblue + (black*16)	; set eax to lightblue on black
		call SetTextColor				; set the text color
		pop eax							; pop eax to restore it
		mov ecx, 4						; set ecx to 4 for the four default segments
		add cl, score					; then add the amount of extra segments
		
		printbodyloop:	
		inc esi							; inc esi to check the next segment
		call updateSnake				; erase the previous position each time
		mov dl, xPosition[esi]			; move the x position into dl
		mov dh, yPosition[esi]			; and y into dh
		mov yPosition[esi], ah			; then put the new Y position in the array
		mov xPosition[esi], al			; and the new X position in the array
		mov al, dl						; put the prevous x into al
		mov ah,dh						; then put the prev y into ah
		call dispSnake					; display the snake's head
		cmp esi, ecx					; if esi = ecx then the loop is finishes
		jl printbodyloop				; so if not continue
	ret
dispBody ENDP

;-------------------------------------------------------
gotApple PROC
; updates the player's score and adds a snake segment when the player gets an apple
; Uses: eax, ebx, esi to store values
; Receives: x and Yposition set by gameplay 
; Returns: updated arrays and snake position
;-------------------------------------------------------
	inc score					; when the snake gets an apple inc the score
	mov ebx,4					; set ebx to four
	add bl, score				; then add the score to that to get the amount of segments
	mov esi, ebx				; store the amount in esi
	mov ah, yPosition[esi-1]	; put the previous Y into ah
	mov al, xPosition[esi-1]	; and the previous x into al
	mov xPosition[esi], al		; add one segment to the snake
	mov yPosition[esi], ah		; the position of the new tail = where the old tail was

	cmp xPosition[esi-2], al	; check if the previous tail was on the Y axis
	jne checkY					; jump if not on the y Axis

	cmp yPosition[esi-2], ah	; check if the new tail should be above or below the previous one
	jl incY						; if it's less than it should be below
	jg decY						; else it should be above
	incY:						; inc if below
	inc yPosition[esi]			; increment the y pos
	jmp continue				; and continue
	decY:						; dec if above
	dec yPosition[esi]			; decrement the y pos
	jmp continue				; and continue

	checkY:						; if the old tail was on the X
	cmp yPosition[esi-2], ah	; check if it should be to the right or left of the old tail
	jl incx						; if right the increment
	jg decx						; if left then decrement
	incx:						; inc if right
	inc xPosition[esi]			; increment the xpos
	jmp continue				; and continue
	decx:						; dec if left
	dec xPosition[esi]			; decrement the xpos

	continue:				
	call dispSnake				; display the new snakle
	call getApplePosition		; create a new apple
	call putApple				; put the apple in place

	mov dl,20					; move to the position of the score board
	mov dh,1					; set dl to 1
	call Gotoxy					; go to the scoreboard
	mov al,score				; move the score into al
	call WriteDec				; and write it next to the board
	ret
gotApple ENDP

;-------------------------------------------------------
EndGame PROC
; ends the game once the player has a hit a wall or themself, prompting them if they want to restart or not
; Uses: eax t store values, edx as string pointer
; Receives: none
; Returns: eax as boolean, 1 = continue 0 = exit
;-------------------------------------------------------
	mov eax, 1000				; add a little delay to the end by setting eax to 1000
	call delay					; then delaying
	Call ClrScr					; clear the screen

	mov edx, OFFSET endMsg		; point edx to the end message
	call WriteString			; write the string
	call crlf					; new line
	
	mov edx, OFFSET scoreMsg	; point edx to the score message
	call WriteString			; write the string
	movzx eax, score			; move the score into eax
	call WriteDec				; display the score
	call crlf					; new line
	mov al, score				; move the score into al
	mov ah, highScore			; and the high score into ah
	.IF al > ah					; if the new score is better than the high score
		mov highScore, al		; set the new high score
	.ENDIF
	
	mov edx, OFFSET highScoreStr; point edx to the high score message
	call WriteString			; write the string
	movzx eax, highScore		; put the high score into eax
	call WriteDec				; display the high score
	call crlf					; new line


	mov edx, OFFSET continueMsg	; point edx to the continue message
	call WriteString			; display it
	call crlf					; new line

	retry:						
	call ReadChar				; get a character from the user
	.IF al == 'Y' || al == 'y'	; if it's a Y or y then they want to restart
		mov eax, 1				; so set eax to 1 to show main that they wanted to restart
		ret						; return to main
	.ELSE	
		mov eax, 0				; else set eax to 0 to show main they didn't
		ret						; return to main
	.ENDIF
EndGame ENDP

;-------------------------------------------------------
resetGame PROC	
; resets all relevant variables so that the game can run more than once
; Uses: no registers
; Receives: xPosition, yPosition, score, lastInput, input, wallY set by gameplay
; Returns: variables reset to default values
;-------------------------------------------------------
	mov xPosition[0], 45		; we need to reset the snake's default position
	mov xPosition[1], 44		; set the next x
	mov xPosition[2], 43		; set the next x
	mov xPosition[3], 42		; set the next x
	mov xPosition[4], 41		; set the next x
	mov yPosition[0], 15		; set the y
	mov yPosition[1], 15		; set the next y 
	mov yPosition[2], 15		; set the next y
	mov yPosition[3], 15		; set the next y
	mov yPosition[4], 15		; set the final y
	
	mov score,0					; reset the score 0
	mov lastInput, 0			; reset the last input to 0
	mov	input, "-"				; set input to the default value
	dec wallY[3]				; reset the wallY to it's default
	Call ClrScr					; clear the scree
	jmp main					; and restart the program
resetGame ENDP
END main