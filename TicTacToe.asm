
COMMENT !
Joseph Work
9/30/24
CSC 3000 X00
HW Assignment 6
This program allows two people to play tic tac toe with each other, it first prompts them to enter their name
then generates either a 0 or 1 deciding on whether player 1 or 2 gets to go first
the game will then play prompting each player to enter a number 1-9 for their turn
and assign the chosen spot on an array with their symbol, either X or 0
Once a player has achieved three in a row or the game was a tie the program prompts them to play again

!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data


player1NamePrompt BYTE "Player 1 enter your name: ", 0							; prompt for the first player's name
player2NamePrompt BYTE "Player 2 enter your name: ", 0							; prompt for the second player's name			
playerDisplay BYTE ", your symbol is a ", 0										; used to make the statement "Name your symbol is x"
player1Name BYTE 20 DUP (0)														; var used to hold player entered name
player2Name BYTE 20 DUP (0)														; var to hold player 2 entered name
player1Logo BYTE "X", 0															; player1's symbol on the board
player2Logo BYTE "O", 0															; player2's symbol on the board


playerTurnPrompt BYTE " it is your turn! Enter your selection(1-9): ", 0	    ; used to make "Name it is your turn!"
errMsg BYTE "Invalid Choice!", 0												; error message when user enteres invalid inpue
boardMsg BYTE "The current board: ", 0											; message to be displayed with the board
boardArray BYTE '-','-','-','-','-','-','-','-','-', 0							; the array that acts like the tac tac toe game board
winMsg BYTE " you win!", 0														; message to display "Name you win!"
continueMsg BYTE "Enter Y/y to play again, or exit with anything else: ", 0		; prompt for the user if they want to continue or not
tieMsg BYTE "The game was a tie!", 0											; message to tell the user that the game was a tie
loopIteration DWORD 0															; used to count loop iterations in dispBoard
turnCount DWORD 0																; used to count the number of turns in playGame
turnBool DWORD 0																; used to alternate between the two players
input DWORD 0																	; used to hold user entered position on board
currentSymbol BYTE "-", 0														; used to hold either X or O based on the turn
winBool DWORD 0																	; used to determine whether a player as won or not

.code
main proc
	start:
		call crlf									; new line
		call getNames								; first get the two player names 
		call Randomize								; seed the random function
		mov eax, 2									; set the range of the number from 0-1
		call RandomRange							; and create either a 0 or 1
		mov turnBool, eax							; this is used to randomize who goes first, 0 for X 1 for O
		call playGame								; play the game

		call crlf									; new line
		call resetGame
		mov edx, OFFSET continueMsg					; prompt the user if they want to continue
			call WriteString						; write it to the screen
			call ReadChar							; take user input
			cmp al, 'Y'								; if it's Y then restart from the beginning
			je start								; jump to initProc
			cmp al, 'y'								; it's not case senstive so lowercase y also works
			je start								; jump back to the start 
		exit

main endp

;-----------------------------------------------------
resetGame PROC
; resets all relevant variables to allow the game to run more than once
; Uses: esi as array pointer, ecx as loop counter
; Receives: turnCount, turnBool, winBool, boardArray set
; Returns: turnCount, turnBool, winBool, boardArray cleared of values
;-----------------------------------------------------
mov turnCount, 0								; reset the turn count
mov turnBool, 0									; reset the turn bool
mov winBool, 0									; reset the win bool
mov esi, OFFSET boardArray						; we need to clear out the array to allow the program to run more than once 
	mov al, '-'									; store - in al
	mov ecx, 9									; set the loop counter to 9
	l1:											; populate the results string with -
		mov [esi], al							; move a - into position
		inc esi									; move to the next
		loop l1									; loop six times
	ret
resetGame ENDP


;-----------------------------------------------------
playGame PROC
; plays the tic tac toe game until a win happens or a tie is reached
; Uses: edi and eax to store values, edi as array pointer, ah to store characters
; Receives: both player names set to user input, turnBool set to 1 or 0
; Returns: none
;-----------------------------------------------------
	begin:									; used to jump back to at the start of the procedure
	inc turnCount							; turn count is used to check for ties, it increments at the start of each round
	cmp turnCount, 10						; the game should only have 9 rounds so if a win has not happened by then we know it was a tie
	je tieGame								; so if turncount is 10 then jump to tie game

	call dispBoard							; display the board at the start of each run
	mov edi, OFFSET boardArray				; point edi to the board array
	mov eax, turnBool						; turn bool is used to alternate between the player turns
	cmp eax, 0								; if turn bool is 0 it's player1's turn
		jnz player2							; so if it is not 0 then go to player2 label

		player1:
			mov edx, OFFSET player1Name		; point edx to player1's name
			call WriteString				; display it
			
			mov ah, player1Logo				; set ah to X
			mov currentSymbol, ah			; and set that to the current symbol
			
			jmp selection					; go straight to the next part of the procedure

		player2:
			mov edx, OFFSET player2Name		; point edx to player2's name
			call WriteString				; display the name
			
			mov ah, player2Logo				; set ah to player 2's symbol or O
			mov currentSymbol, ah			; set that to the current symbol
			
								

		selection:
			mov edx, OFFSET playerTurnPrompt; prepended by the player's name, ask the player for input
			call writeString				; display the prompt
			call ReadInt					; read an int from the user
			cmp eax, 9						; The user must enter a number 1-9 to put a piece on the board
			jg invalidInput					; if it's greater than 9 then go to invalidInput
			cmp eax, 1						; next compare it to 1
			jl invalidInput					; if it's less than 1 then it's also invalid
			dec eax							; take 1 off eax to use it as an array index
			mov input, eax					; store the user's input
		
			add edi, input					; move to the selected position on the board
			mov ah, '-'						; move '-' into ah because an empty space will have a dash in it
			cmp [edi], ah					; compare the array value at index to '-'
			jne invalidInput				; if it's not a - then somebody has already used that spot so it's invalid

			mov ah, currentSymbol			; move the current player's symbol into ah
			mov [edi], ah					; and set the array value to the player's symbol
		
			add turnBool, 1					; add 1 to turnbool
			cmp turnBool, 2					; if turnBool exceeds 1 then we need to reset to 0 to switch players
			jge alternate					; so if it is jump to alternate

			jmp checkWins					; if it isn't then turnBool was 0 and is now 1 and we have already altnerated

			alternate:
				sub turnBool, 2				; subtract 2 from turnbool to reset it to 0
				
			checkWins:						; label used to check for wins at the end of each round
				call checkWinStatus			; call the procedure, it will return 0 for no wins and 1 for a win found
				cmp winBool, 0				; if winbool is set to 0 there was no win
				jz begin					; so if it is zero then jump to begin
				call dispBoard				; display the game board to show the win
				mov ah, currentSymbol		; mov the current symbol into ah to check which player won
				cmp ah, 'X'					; if it's X 
					je player1Win			; then go to player1Win
					jmp player2Win			; else go to player2Win


			player1Win:				
				mov edx, OFFSET player1Name	; set edx to display player 1's name
				call WriteString			; display it
				mov edx, OFFSET winMsg      ; point edx to the win message
				call WriteString			; write the string saying that player 1 won the game
				jmp endProc					; and end the procedure

			player2Win:
				mov edx, OFFSET player2Name	; point edx to player 2's name
				call WriteString			; display it
				mov edx, OFFSET winMsg		; point edx to the win message
				call WriteString			; display a message saying that player 2 won
				jmp endProc					; and end the procedure

			tieGame: 
				mov edx, OFFSET tieMsg		; if the game is a tie display the tie message
				call WriteString			; write it to the screen
				jmp endProc					; and end the procedure
				
		
		invalidInput:
			mov edx, OFFSET errMsg			; set edx to display an error message
			call WriteString				; display the error message
			call crlf						; new line
			dec turnCount
			jmp begin						; restart from the beginning

			
			endProc:						; used to end the procedure
				ret
		
playGame ENDP

;-----------------------------------------------------
checkWinStatus PROC
; checks the game board for three in a row either horizontally, vertically, or diagonally
; Uses: esi as array pointer, ecx as index, al to store chars
; Receives: boardArray changed with game results
; Returns: winBool set to 1 or 0 based on if a win happened
;-----------------------------------------------------
	mov esi, OFFSET boardArray		; point esi to the start of the board array

    
    mov ecx, 0						; first check the rows for a win, row counter (0, 3, 6)
checkRows:
    mov al, [esi + ecx]				; load the first element of the row
    cmp al, '-'						; ignore any empty spaces
    je checkColumns				    ; if it finds a '-' then skip right to column checks

    
    cmp al, [esi + ecx + 1]			; if there is not a dash compare with the second element
    jne nextRow					    ; if they're not equal go to the next row	
    cmp al, [esi + ecx + 2]			; compare with the third element
    jne nextRow					    ; if they're not equal go to the next row

									; if all three elements match then there is a win 
	jmp winner						; if all three match jump to winner

nextRow:
    add ecx, 3						; move to the next row by adding 3 to ecx
    cmp ecx, 9						; once ecx reaches 9 we have checked all rows
    jl checkRows					; so if it's less than 9 restart

    
    mov ecx, 0					    ; next we check the columns so reset ecx
checkColumns:
    mov al, [esi + ecx]				; load the first element of the column
    cmp al, '-'						; ignore any empty spaces
    je checkDiagonals				; if it is an empty space then skip to diagonals

		
    cmp al, [esi + ecx + 3]			; else compare it to the second element	
    jne nextColumn					; if it's not equal go to the next column
    cmp al, [esi + ecx + 6]			; next compare with the third element
    jne nextColumn					; if not equal go to the next column

    
    jmp winner						; if all three match jump to winner

nextColumn:
    inc ecx						    ; move to the next column
    cmp ecx, 3                      ; if all columns are checked move to diagonals
    jl checkColumns			        ; else check the rest of the columns

    
checkDiagonals:
							        ; first check the main diagonal
    mov al, [esi]				    ; load the first elenment into al
    cmp al, '-'					    ; check if it is empty
    je checkAntiDiagonal		    ; if it is go straight to checking the other diagonal
    cmp al, [esi + 4]			    ; else compare with the next element
    jne checkAntiDiagonal		    ; if it's empty check the other diagonal
    cmp al, [esi + 8]               ; compare with the last element
    jne checkAntiDiagonal	        ; if it's empty check the other diagonal

    
    jmp winner					    ; if all three match jump to winner

checkAntiDiagonal:
								    ; next check the opposite diagonal
    mov al, [esi + 2]               ; load the first element
    cmp al, '-'                     ; check if the first position is empty
    je noWinner						; if it is then go to no winner label
    cmp al, [esi + 4]               ; else compare the next element
    jne noWinner				    ; if it's empty there is no winner either
    cmp al, [esi + 6]			    ; finally compare the last element
    jne noWinner				    ; if it's empty there is no winner

								    ; if all three match there has been a winner
winner:
    mov winBool, 1                  ; Set EAX to 1 indicating a win
    ret

noWinner:
    mov winBool, 0                  ; set the boolean to 0 to signify no win
    ret							    ; and return

checkWinStatus ENDP

;-----------------------------------------------------
getNames PROC
; prompts the user/users to enter two names to be used for tic tac toe
; Uses: edx to store values, ecx as buffer size
; Receives: none
; Returns: player1Name and player2Name set to user input
;-----------------------------------------------------
	mov edx, OFFSET player1NamePrompt					; set edx to prompt player 1 for their name
	call WriteString									; display the message

	mov edx, OFFSET player1Name							; point edx to the variable to contain the first players name
	mov ecx, 20											; set the maximum number of characters to read to 20
	call ReadString										; get the user's name

	call WriteString									; display the entered name
	mov edx, OFFSET playerDisplay						; point edx to "your symbol is"
	call WriteString									; write the message
	

	mov edx, OFFSET player1Logo							; display player's 1's symbol which is X
	call WriteString									; write the symbol making the message "Name your symbol is X"
	call crlf											; new line

	mov edx, OFFSET player2NamePrompt					; point edx to player 2's name prompt
	call WriteString									; write the prompt to the screen

	mov edx, OFFSET player2Name							; point edx to the second name variable
	mov ecx, 20											; set the maximum number of characters to take
	call ReadString										; read the player's name

	call WriteString									; write the name back
	mov edx, OFFSET playerDisplay						; point edx to "your symbol is"
	call WriteString									; display the message
	

	mov edx, OFFSET player2Logo							; point edx to the player2Logo which is O
	call WriteString									; display the logo making the message "Name your symbol is O"

	ret

getNames ENDP

;-----------------------------------------------------
dispBoard PROC
; displays the game board three at a time with new lines in between
; Uses: edx to store values, ecx as loop counter, edi as array pointer, al to store and display chars
; Receives: boardArray changed with game results
; Returns: none
;-----------------------------------------------------
call crlf
mov loopIteration, 0
mov edx, OFFSET boardMsg							; point edx to "The current board: "
call WriteString									; write the message
call crlf
mov edi, OFFSET boardArray							; point edi to the boardArray
mov ecx, 9											; set the loop counter to 9 because the board has 9 elements
L1:
	inc loopIteration								; loop iteration is used to know when to do a new line
	mov al, [edi]									; move the character from the array into al
	call WriteChar									; display it
	mov eax, loopIteration							; store the loop iteration in eax
	mov ebx, 3										; put 3 in ebx for division
	cdq												; sign extend eax for division
	div ebx											; divide loop counter(eax) by 3 (ebx)

	cmp edx, 0										; edx stores the remainder, if it's 0 then we need to do a new line
	jne noNewLine									; so it's not zero skip this
	call crlf										; if it is zero display a new line

	noNewLine:										; this label is used to skip displaying the new line
		inc edi										; move to the next array element
		loop l1										; loop 9 times

	 ret
dispBoard ENDP

end main