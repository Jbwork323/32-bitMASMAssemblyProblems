COMMENT !
Joseph Work
9/17/24
CSC 3000 X00
HW Assignment 4
Program to play a number guessing game, it will generate a randomn number between 1-50 and then ask the user to guess it
they have ten guesses and it will display messages saying whether they were too low, too high, or correct
the program can be repeated indefintiely by the user

!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
prompt1 BYTE "Guess the random number between 1 and 50: ", 0				; initial prompt to get user input
triesMsg BYTE "Tries left: ", 0												; message to be displayed with the number of tries
overMsg BYTE "Your guess was too high!", 0									; message displayed when guess is too high	
underMsg BYTE "Your guess was too low!", 0									; message for when the guess is too low
correctMsg BYTE "You guessed correct!", 0									; message for when the guess is correct
doneMsg BYTE "You're out of tries!", 0										; message for when the user has used all ten tries
randNumMsg BYTE "The number was : ", 0										; message to be displayed with the number when the user fails to guess it
continueMsg BYTE "Press Y/y to continue or exit with anything else: ", 0	; message promping the user to continue
errMsg BYTE "Invalid Input", 0												; invalid input error message


randNum DWORD 0																; DWORD to hold the generated number
userGuess DWORD 0															; DWORD to hold the user's guess
numTries DWORD 0															; DWORD to hold the remaining number of tries

.code
main proc
	begin:					
		mov eax, 10						; set eax to ten for number of tries
		mov numTries, eax				; set the number of tries
		call getRandNum					; get a random number from 1 - 50
		call guessNum					; then call the procedure to actually run the game
		mov edx, OFFSET continueMsg		; set edx to display the continue prompt
		call WriteString				; display it
		call ReadChar					; read a character from the user
		cmp al, 'Y'						; if its Y
		je begin						; restart the program
		cmp al, 'y'						; or if it's y 
		je begin						; restart the program

	exit								; else end the program

main endp

;-----------------------------------------------------
guessNum PROC
; procedure to allow the user ten attemps to guess the random number and display the results of their guess
; Uses: edx as string pointer, eax to store values
; Receives: numTries var set to ten, randNum var set to random number between 1-50
; Returns: none
;-----------------------------------------------------
	call crlf							; begin with new line
	start:	
		cmp numTries, 0					; check if the user has run out of tries
		jle noTries						; if they have jump to noTries to end the procedure
		mov edx, OFFSET triesMsg		; point edx to "Number of tries:"
		call WriteString				; display it
		mov eax, numTries				; and display the remaining number of tries
		call WriteDec					
		call crlf						; new line
		mov edx, OFFSET prompt1			; point edx to initial prompt
		call WriteString				; display it
		call ReadInt					; take user input
		jo invalid						; ReadInt will set overflow flag on invalid input, so jump there if it is set
		mov userGuess, eax				; else set the guess variable to the user's guess
		jmp next						; and skip the invalid function

	invalid:							; if the user didn't enter an integer
		mov edx, OFFSET errMsg			; point edx to the error message
		call WriteString				; display it
		mov eax, numTries				; mov the remaining num of tries into eax
		dec eax							; subtract 1
		mov numTries, eax				; set the variable back
		call crlf						; new line
		jmp start						; and restart the procedure

		next:
			mov eax, userGuess			; set eax to the user's guess
			cmp eax, randNum			; compare it to the random num
			jg tooHigh					; if it's greater than go to tooHigh
			jl tooLow					; else if it's lesser go to toLow
			je correct					; finally if it's right go to correct

		tooHigh:
			mov edx, OFFSET overMsg		; set edx to tell the user their guess was too high
			call WriteString			; display it
			mov eax, numTries			; mov the number of tries into eax
			dec eax						; subtract 1
			mov numTries, eax			; move it back into the variable
			call crlf					; new line
			jmp start					; restart procedure

		tooLow:
			mov edx, OFFSET underMsg	; set edx to tell the user their guess was too high
			call WriteString			; display it
			mov eax, numTries			; mov the number of tries into eax
			dec eax						; subtract 1
			mov numTries, eax			; move it back into the variable
			call crlf					; new line
			jmp start					; restart procedure

		correct:
			mov edx, OFFSET correctMsg  ; set edx to tell the user they guessed correct
			call WriteString			; display that
			call crlf					; new line
			ret							; return to main where the user can restart if they want

		noTries:
			mov edx, OFFSET doneMsg		; display that the user has no tries left
			call WriteString			; write the message to the screen
			call crlf					; new line
			mov edx, OFFSET randNumMsg  ; set edx to display a message with the randNum
			call WriteString			; write it to the screen
			mov eax, randNum			; mov the randNum into eax
			call WriteDec				; and display to the user what the number was
			call crlf					; new line
			ret							; return to main where the user can restart if they want

guessNum ENDP


;-----------------------------------------------------
getRandNum PROC
; procedure to generate random number between 1-50 and store it in a variable
; Uses: eax to store values
; Receives: none
; Returns: randNum variable set to random number
;-----------------------------------------------------

	call Randomize						; seed the randomrange function
	mov eax, 50							; set eax to the range 0-49
	call RandomRange					; get the random num
	add eax, 1							; add one to it to make the range 1-50
	mov randNum, eax					; set the variable to the random number
	ret									; return to main

getRandNum ENDP


end main