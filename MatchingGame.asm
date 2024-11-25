COMMENT !
Joseph Work
11/10/24
CSC 3000 X00
HW Assignment 10
This program plays a matching game where two players try to find matches in a 4x5 grid of 20 cards
The program first assigns random locations for all 10 pairs of symbols then displays the grid of 20 cards
the players then enter their names and one is randomly chosen to pick two cards first
if they match the game will prevent players from guessing those cards again
the game goes until all matches have been found
!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

dispCards PROTO posA:DWORD, posB:DWORD, symbol:BYTE, symbol2:BYTE

.data

symbols BYTE '!','!','@','@','#','#','$','$','%','%','^','^','&','&','~','~','?','?','+','+',0	; array holding each pair of symbols
indexes DWORD 20 DUP (21)									; array to hold random indexes the symbols will be displayed at
emptySpace BYTE " ", 0										; string used for formatting
promptMsg BYTE "Pick your first card(1-20): ", 0			; prompt for the user to pick their first card
promptMsg2 BYTE "Pick your second card (1-20): ", 0			; prompt for the user to pick their second card
correctMsg BYTE "The cards match!", 0						; message for when they guess correctly
incorrectMsg BYTE "The cards don't match!", 0				; message for when they get it wrong
secondSpot DWORD 0											; var holds the second user inputted location
p1Name BYTE 20 DUP (0)										; string to hold the first player's name
p2Name BYTE 20 DUP (0)										; str to hold the second player's name
p1Prompt BYTE "Player 1 enter your name: ", 0				; prompt for the first player
p2Prompt BYTE "Player 2 enter your name: ", 0				; prompt for the second player
turnBool DWORD 0											; used to alternate turns
stringX BYTE "X", 0											; used to display when a card has already been found 
turnMsg BYTE " it is your turn. ", 0						; message displayed with player name to tell what turn it is
p1Score DWORD 0												; var to hold player 1's score
p2Score DWORD 0												; var to hold player 2's score
foundSyms BYTE 10 DUP (0)									; array of symbols that have been found
foundSpots DWORD 20 DUP (0)									; array of spots that have been found
iteration DWORD 0											; used to index arrays to hold found symbols and found spots
foundErrMsg BYTE "Those symbols have already been found!", 0; message to be displayed when the user enters a spot that has already been found
firstPick DWORD 0											; var to hold the first number entered by user
winMsg BYTE " you won the matching game!", 0				; var displayed when someone wins
errMsg BYTE "Invalid Input", 0								; error message displayed when the user enters invalid input
continueMsg BYTE "Play again? (Y/y): ", 0

.code
main proc
	startMain:
		
		call Randomize							; seed the randomization
		mov ecx, 20								; set the loop counter to 20
		mov edi, OFFSET indexes					; point edi to the indexes array
		randIndexes:							; now we generaste 20 random indexes to place each symbol at
			mov eax, 20							; set the range for an index from 0-19
			call RandomRange					; create the random number
			push ecx							; push ecx onto the stack
			push edi							; push edi onto the stack
			mov ecx, 20							; set ecx to 20 for the second loop
			mov edi, OFFSET indexes				; and reset edi to the start of the array
			checkDups:							; now we check for any duplicates
				cmp eax, [edi]					; compare eax to the array element
				je dupFound						; if it's a dupe then jump there to create a new one
				add edi, 4						; else move to the next element
				loop checkDups					; loop 20 times
			pop edi								; after checking restore edi
			pop ecx								; and restore ecx

			mov [edi], eax						; next move the index into the array
			add edi, 4							; and move to the next spot in the array
		loop randIndexes
		jmp next								; jump to next to avoid an infinite loop

		dupFound:								; if a dupe is found
			pop edi								; restore edi
			pop ecx								; and ecx
			jmp randIndexes						; then restart to create a new index

		next:

		mov edx, OFFSET p1Prompt				; point edx to the player 1 prompt
		call WriteString						; diplay it

		mov edx, OFFSET p1Name					; set buffer for input
		mov ecx, 20								; max length of name input is 20
		call ReadString							; take p1's name

		mov edx, OFFSET p2Prompt				; point edx to p2's prompt
		call WriteString						; display that
		mov edx, OFFSET p2Name					; set buffer for input
		mov ecx, 20								; max length of name is 20
		call ReadString							; get p2's name

		INVOKE dispCards, 0, 0, 'a', 'a'		; initially display the board of cards, passing useless arguments
		call playGame							; playgame will run until the game is finished

		call crlf
		mov edx, OFFSET continueMsg				; point edx to the continue message
		call WriteString						; write it to the screen
		call ReadChar							; take user input
		.IF al == 'Y' || al == 'y'
			call resetGame
			jmp startMain
		.ELSE
			exit
		.ENDIF
		

main ENDP

;-------------------------------------------------------
resetGame PROC
; resets arrays and variables to allow the program to run more than once
; Uses: indexes foundSpots foundsyms arrays, ecx as loop counter, iteration 
; Receives: variables set by game
; Returns: variables reseet to default values
;-------------------------------------------------------
	pushad							; push register values
	mov iteration, 0				; reset iteration to 0
	mov ecx, 20						; set the loop counter to 20
	L1:
		mov [indexes+ecx*4], 21		; move the number 21 into each spot in indexes
		mov [foundSpots+ecx*4], 0	; and 0 into each spot in foundSpots
		loop l1
	mov ecx, 10						; set the loop counter again
	L2:
		mov [foundSyms], 0			; set every spot in foundsyms to 0
	loop L2
	popad							; pop registers
	call crlf						; new line
	ret								; return to main
resetGame ENDP

;-------------------------------------------------------
dispCards PROC posA:DWORD, posB:DWORD, symbol:BYTE, symbol2:BYTE
; displays a 4x5 grid of cards, placing x's on spots already found and 
; the relevant symbol on player chosen spots
; Uses: ecx as loop counter, eax as iterator, edi as array pointer, ebx to store values
; Receives: posA, posB, symbol, symbol2 from pickCards
; Returns: none
;-------------------------------------------------------
	pushad								; push all registers to preserve them
	mov eax, 0							; eax is used to display 1-20 so initally set it to 0
	mov ecx, 20							; and set the loop counter to 20
	dispLoop:
		inc eax							; increment eax
			mov edi, OFFSET foundSpots	; if a spot has already been found we display an X
			cld							; first clear the direction flag
			push ecx					; then push ecx to preserve it
			mov ecx, LENGTHOF foundSpots; set ecx to the length of foundSpots
			repne scasd					; check each element to see if they = eax
			je dispX					; if they do, jump to display an x
			pop ecx						; else pop ecx to restore the value
		.IF eax == posA			; posA will be the first position chosen by the player, if it's ==eax 
			push eax			; first preserve eax
			mov al, symbol		; then point al to the symbol at that position
			call WriteChar		; write the character to the screen
			pop eax				; pop eax to restore it

		.ELSEIF eax == posB		; now do the same but for posB
			push eax			; push eax
			mov al, symbol2		; set al to the symbol at that location
			call WriteChar		; display it
			pop eax				; and pop eax
		.ELSE					; else
			call WriteDec		; just display the number
		.ENDIF

		next:
		mov edx, OFFSET emptySpace ; an empty space will be displayed between each number
		call WriteString		   ; display the space
		.IF eax < 10			; if eax is less than ten
			call WriteString	; there needs to be 2 spaces for formatting
		.ENDIF
		push eax				; else we need to check if eax%5=0 for formatting
		.IF eax >=5				; if eax is >= 5
			mov ebx, 5			; set ebx to 5 for division
			xor edx, edx		; zero out edx because it will hold the remainder
			div ebx				; divide eax by ebx
		.ENDIF
		
		.IF edx == 0			; if it's zero
			call crlf			; display a new line
		.ENDIF
		pop eax					; restore eax
	loop dispLoop				; loop 20 times
	popad
	ret
	dispX:						; if the spot has already been found it should be an X 
		mov edx, OFFSET stringX	; so point edx to the X string
		call WriteString		; write the string
		pop ecx					; pop ecx to restore the value
		jmp next				; and go back up to do the rest
		
dispCards ENDP

;-------------------------------------------------------
playGame PROC
; keeps track of player scores, alternates turns, and calls playgame function
; Uses: eax ebx to store values, edx as string pointer
; Receives: eax set to 0 or 1 to siginify if a player has won a turn
; Returns: none
;-------------------------------------------------------
	mov p1Score, 0						; set the first player's score to 0
	mov p2Score, 0						; and the second's to 0 as well
	mov eax, 1							; we need to generate who will go first so set the range to 0-1
	call RandomRange					; and create the random number
	mov turnBool, eax					; store the randomly made turn
	gameLoop:
		call crlf						; new line
		.IF turnBool == 0				; if the turnbool is 0
			mov edx, OFFSET p1Name		; display p1's name
		.ELSE							; else it'll be 1
			mov edx, OFFSET p2Name		; so display p2's name
		.ENDIF
		call crlf						; new line
		pickTheCards:
			call WriteString			; write the player's name
			call pickCards				; and call pickCards to have the player select their two choices
		.IF eax == 1 && turnBool == 0	; if eax is set to 1 after pickCards it means the player found a match
			inc p1Score					; so if it was p1's turn then increment their score
		.ELSEIF eax == 1 && turnBool == 1 ; else if eax returned as 1 and it was p2's turn
			inc p2Score					; increment their score
		.ENDIF	
		mov eax, p1Score				; move the first player's score into eax
		mov ebx, p2Score				; and second's into ebx
		add eax, ebx					; add them together to get the total score
		.IF eax >= 10					; if the total score is ten or more
			jmp endGame					; the game is over and we need to determine a winner
		.ENDIF
		.IF turnBool == 1				; if turnBool is 1
			mov turnBool, 0				; change players by setting it to 0
		.ELSE							; else if it's 0
			mov turnBool, 1				; change the turn by setting it to 1	
		.ENDIF
		jmp gameLoop					; restart if no winner has been found
		endGame:
			mov eax, p1Score
			mov ebx, p2Score
			.IF eax > ebx				; check to see if player 1 found more matches
				mov edx, OFFSET p1Name	; if they did point edx to their name
			.ELSE						; else player 2 found more
				mov edx, OFFSET p2Name	; so point edx to their name
			.ENDIF
			call WriteString			; display the winning player's name
			mov edx, OFFSET winMsg		; and then point edx to the winMsg
			call WriteString			; display that
			ret							; and return to main
playGame ENDP

;-------------------------------------------------------
pickCards PROC
; allows the player to pick two cards, displaying the board each time and checking if they match
; Uses: eax ebx to store values, edx as string pointer, esi edi as array pointers
; Receives: none
; Returns: eax set to 0 or 1 to show if a player has found a match
;-------------------------------------------------------
	mov edx, OFFSET turnMsg				; point edx to the turnMsg
	call WriteString					; and display it following the player's name
	
	mov esi, OFFSET indexes				; point esi to the indexes
	mov edi, OFFSET symbols				; and edi to the symbols
	L2:
		mov edx, OFFSET promptMsg		; point edx to the prompt
		call WriteString				; display it
		call readInt					; read an int from the user
		.IF eax < 1 || eax > 20			; the range is from 1-20 so if their input is outside that
			jmp invalidInput			; jump to that label
		.ENDIF
		mov firstPick, eax				; and store that input into firstPick
		sub eax, 1						; subtract 1 from their input for indexing
		
		mov eax, [esi+eax*4]			; move the index from the array at their input into eax
		mov bl, [edi+eax]				; and then move the character assigned to that index into bl

		INVOKE dispCards, firstPick, 0, bl,'a'	; display the board with the first character revealed 

		push edi						; push edi 
		push ecx						; and ecx to preserve them
		mov edi, OFFSET foundSyms		; point edi to the array of already found symbols
		mov al, bl						; and then move the character they selected into al
		mov ecx, LENGTHOF foundSyms		; set the counter to the length of the foundSyms array
		repne scasb						; and make sure that it is not already in the array
			je alreadyFound				; if it has been jump to that label
		pop ecx							; restore ecx
		pop edi							; and edi

		mov edx, OFFSET promptMsg2		; point edx to the secon prompt
		call WriteString				; display it
		call readInt					; read an int from the user
		.IF eax < 1 || eax > 20			; if it's outside the acceptable range
			jmp invalidInput			; jump to invalid input
		.ENDIF
		mov secondSpot, eax					; else store that value in the input variable
		sub eax, 1						; then subtract 1 for indexing
		
		mov eax, [esi+eax*4]			; move the index at that position into eax
		mov bh, [edi+eax]				; and then move the char at that index into bh

		INVOKE dispCards, firstPick, secondSpot, bl, bh	; display the new board with both of their selections highlighted

		cmp bl, bh						; then check if they match
		je matchFound					; if they do jump to that label
		mov edx, OFFSET incorrectMsg	; else point edx to the incorrect message
		call WriteString				; display it
		mov eax, 0						; then set eax to 0 to show that there was no match
		ret								; return to playGame

		matchFound:						; if they found a match
			mov edx, OFFSET correctMsg	; point edx to the found message
			call WriteString			; write the found message
			mov eax, iteration			; and move iteration into eax to store the found symbol
			mov [foundSyms + eax], bl	; store the found symbol in the array so they can't select it again
			
			inc iteration				; increment iteration to move to the next spot in the found array
			mov eax, iteration			; we will store each correct spot they choose, first move iteration back into eax
			mov ebx, firstPick			; then move the first location into ebx
			mov [foundSpots + eax*4], ebx ; and then move that location into the array of found spots
			inc eax						; increment eax to move to the next spot
			mov ebx, secondSpot			; move the second location into ebx
			mov [foundSpots + eax*4], ebx ; and then put that into the array
			mov eax, 1					; set eax to 1 to show the playGame function that they have found a 
			ret							; return to playGame
		alreadyFound:
			mov edx, OFFSET foundErrMsg	; point edx to the message saying that they already found that symbol
			call WriteString			; and write the string
			call crlf					; new line
			jmp L2						; restart the loop
		invalidInput:
			mov edx, OFFSET errMsg		; point edx to the invalid input message
			call WriteString			; display that
			call crlf					; new line
			jmp L2						; restart the loop
pickCards ENDP
end main