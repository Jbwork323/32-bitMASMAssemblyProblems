COMMENT !
Joseph Work
9/23/24
CSC 3000 X00
HW Assignment 5
This program plays the game hangman with one of ten randomly selected words
the program first generates a number bewteen 0-9 and assigns the word based on that
the user can then enter a character to try to guess a letter, if they are correct a corresponding position within
a results string will be filled with their correct guess, if they are incorrect they will use one of 6 guesses and the corresponding hangman will be displayed
the game ends when the user gets the word right or uses 6 guesses, the program can be repeated indefinitely

!

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
head BYTE " O", 0							; these will be used to create the hangman
body BYTE "|", 0
lArm BYTE "/", 0
rArm BYTE "\", 0
rLeg BYTE " \" , 0


word1 BYTE "python", 0						; ten six letter words to be guessed by the user, I decided to do animals
word2 BYTE "beetle", 0
word3 BYTE "baboon", 0
word4 BYTE "rabbit", 0
word5 BYTE "badger", 0
word6 BYTE "cougar", 0
word7 BYTE "turtle", 0
word8 BYTE "walrus", 0
word9 BYTE "weasel", 0
word10 BYTE "gorilla", 0

input BYTE ?								; var to hold user input
randNum DWORD 0								; var to hold randomly generated number from 0-9
guessedLetters DWORD 0						; var to count how many letters the user has guessed
introMessage BYTE "Welcome to Animal Hangman, the word is 6 letters you have 6 guesses! ",0		; first message displayed to the user
promptMsg BYTE "Enter the letter you want to guess: ", 0										; message prompting the user for input
winMsg BYTE "You guessed correct! ", 0															; message displayed when user wins the game
loseMsg BYTE "You failed to guess the word!", 0													; message displayed when user loses the game
alreadyMsg BYTE "You already guessed that!", 0													; message displayed when user has already guessed that letter correctly

currentWord BYTE 7 DUP(0)					; var to be populated with randomly selected word

resultArray BYTE 6 DUP('-'), 0				; var to hold the result of the user's guess, starts at ------ and updates each position when the letter is found

manIndex DWORD 0							; index to properly display the hangman
userRight DWORD 0							; bool used to decide whether to update hangman based on if the user found a letter or not
continueMsg BYTE "Enter Y/y to play again, or exit with anything else: ", 0				; prompt for the user if they want to continue or not
wordMsg BYTE "The correct word was: ", 0	; message to be displayed with the correct word at the end of the program

.code
main proc
start:
	mov guessedLetters, 0						; reset these three variables to 0 at the start of the program
	mov manIndex, 0								; this allows the program to repeat indefinitely 
	mov userRight, 0

	mov esi, OFFSET resultArray					; we also need to clear out the results array 
	mov al, '-'									; store - in al
	mov ecx, 6									; set the loop counter to 6
	l1:											; populate the results string with -
		mov [esi], al							; move a - into position
		inc esi									; move to the next
		loop l1									; loop six times

			
	call getRandNum								; generate the random number
    call setWord								; assign the word based on the random number
	mov edx, OFFSET introMessage				; set edx to the intro message
	call WriteString							; and display it

	call hangMan								; start the hangman game

	call crlf
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
hangMan PROC
; plays the hangman game, allowing the user to guess letters until they either get it right or fail
; Uses: esi and edi as array pointers, ecx as loop counter, al and ah to store characters, edx to store strings
; Receives: currentWord set to the word to be guessed
; Returns: resultArray changed to user guesses
;-----------------------------------------------------
	startGame:
	mov userRight, 0							; reset userRight at the start of the procedure		
	
	call crlf									; new line
	mov edx, OFFSET promptMsg					; set edx to the prompt message
	call WriteString							; display the prompt
	call ReadChar								; and read a character from the user
	
	cmp al, 97									; if the character's ASCII Value is below 97 then it is not a lowercase letter
	jge next									; so if it is above that skip this
	add al, 32									; adding 32 to the characters converts uppercase letters to lowercase
	mov input, al								; store the user's input

	next:
	mov esi, OFFSET currentWord					; point esi to the word to be guessed
	mov edi, OFFSET resultArray					; point edi to the array containing the user's correct guesses
	mov ecx, 6									; set the loop counter to 6
	cmpLoop:									; loop to see if the user's guess was correct
		
		cmp [esi], al							; compare the current letter to the users guess
		je correct								; if they are equal jump to correct
		inc esi									; else move to the next letter
		inc edi									; also move to the next position in the results array
		loop cmpLoop

	jmp continue								;once the loop is over jump to continue

	correct:
		cmp al, [edi]							; first make sure the user hasn't guessed this letter before
		je alreadyGuessed						; if they have jump to that label
		mov userRight, 1						; else set the boolean to indicate they guessed right
		add guessedLetters, 1					; and add 1 to the counter of how many letters they have guessed
		mov ah, [esi]							; move the letter into ah
		mov [edi],ah							; and then move it into the results Array
		inc esi									; go to the next index on both array
		inc edi
		loop cmpLoop



continue:
	call crlf 
	mov edx, OFFSET resultArray					; set edx to display the results array	
	call WriteString							; display it

	cmp userRight, 0							; then check if the user correctly guessed or not
		je dispMan								; if they did not display the hangman
	cmp guessedLetters, 6						; else check if they have finished the game
	jl startGame								; if they have not restart the procedure

	call crlf
	mov edx, OFFSET winMsg						; if they have 6 correct letters the word is complete 
	call WriteString							; diplay the win message
	jmp endProcedure							; and end the procedure

alreadyGuessed:	
	mov edx, OFFSET alreadyMsg					; if they have already guessed this letter set edx to display that
	call WriteString							; display the message
	jmp startGame								; and restart the procedure


	dispMan:									; dispMan works iteratively, as manIndex gets higher it displays more of the hangman and then ends the program after it reaches 6
	call crlf
		add manIndex, 1							; start by incrementing manIndex
		mov edx, OFFSET head					; point edx to the head
		call WriteString						; write that to the screen
		call crlf								; new line

		cmp manIndex, 2							; now check if they are at 2 failed guesses
		jl startGame							; if not restart the procedure
		mov edx, OFFSET larm					; if they are display the head and the arm
		call WriteString						

		cmp manIndex, 3							; now check if they are at 3 failed guesses
		jl startGame							; if they are not restart
		mov edx, OFFSET body					; if they are display the head, arm, and body
		call WriteString
		
		cmp manIndex, 4							; now check if they have reached 4 failed guesses
		jl startGame							; if not restart
		mov edx, OFFSET rArm					; if they have display the head, body, and both arms
		call WriteString

		cmp manIndex, 5							; check if they are at 5 failed guesses
		jl startGame							; if not restart
		call crlf
		mov edx, OFFSET larm					; the left arm and left leg are the same, / so I used the same var
		call WriteString						; display the head, body, both arms, and one leg

		cmp manIndex, 6							; finally check if they have reached 6 failed guesses
		jl startGame							; if they have not restart
		mov edx, OFFSEt rLeg					; if they have display the entire hangman
		call WriteString

		call crlf
		mov edx, OFFSET loseMsg					; and tell the user that they lost
		call WriteString

	

endProcedure:									; ends the game
	call crlf									; new line
	mov edx, OFFSET wordMsg						; set edx to "The correct word was: "
	call WriteString							; write it to the screen
	mov edx, OFFSET currentWord					; point edx to the correct word

	call WriteString							; display the correct word

	call crlf
	ret
hangMan ENDP




;-----------------------------------------------------
setWord PROC
; sets the word to be guesses based on the randomly generated numbers
; Uses: esi and edi as array pointers, ecx as loop counter, al to store characters
; Receives: randNum variable set
; Returns: currentWord variable set
;-----------------------------------------------------
	
	cmp randNum, 0						; this works as a switch statement to set esi to the right word based on the randNum
		jg label1						; if randNum is greater than 0 go to the next option
		mov esi, OFFSET word1			; else set esi to the right word
		jmp endProc						; and skip the rest 

	label1:								; repeat until the right word variable is found and set
		cmp randNum, 1					; if randNum > 1
			jg label2					; jmp to label 2
			mov esi, OFFSET word2		; else set the word to word2
			jmp endProc					; and end the procedure
	label2:			
		cmp randNum, 2					; if rand num is greater than 2
			jg label3					; then go to label 3
			mov esi, OFFSET word3		; else set the word to word 3
			jmp endProc					; and end the procedure
	label3:							
		cmp randNum, 3					; else if randNum is greater than 3
			jg label4					; go straight to label 4
			mov esi, OFFSET word4		; else set the word to word 4
			jmp endProc					; and return
	label4:	
		cmp randNum, 4					; if randNum > 4
			jg label5					; go to label 5
			mov esi, OFFSET word5		; else set the word to word 5
			jmp endProc					; and return to main
	label5:
		cmp randNum, 5					; compare randNum to 5
			jg label6					; if it's greater go to label 6
			mov esi, OFFSET word6		; else set the word to word6
			jmp endProc					; and end the procedure
	label6:		
		cmp randNum, 6					; comapre randNum to 6
			jg label7					; if it's greater go to label 7
			mov esi, OFFSET word7		; else set the word to word7
			jmp endProc					; and end the procedure
	label7:
		cmp randNum, 7					; compare randNum to 7
			jg label8					; if it's greater go to label 8
			mov esi, OFFSET word8		; else set the word to word 8
			jmp endProc					; and end the procedure
	label8:								
		cmp randNum, 8					; compare the randNum to 8
			jg label9					; if it's greater skip to label 9
			mov esi, OFFSET word9		; else set the word to word9
			jmp endProc					; and end the procedure
	label9:		
		cmp randNum, 9					; finally if the randNum is 9
			mov esi, OFFSET word10		; set the word to word10

endProc:								; once the word is properly set in esi
	mov edi, OFFSET currentWord			; point edi to the currentWord array
    mov ecx, 6							; set loop counter to 6
copyLoop:
    mov al, [esi]						; copy the next letter
    mov [edi], al						; store it in the currentWord string
    inc esi								; move to the next byte in source
    inc edi								; move to the next byte in destination
	loop copyLoop						; repeat the loop six times


ret

setWORD ENDP

;-----------------------------------------------------
getRandNum PROC
; creates a random number from 0-9
; Uses: eax to store random number
; Receives:none
; Returns: randNum variable set
;-----------------------------------------------------
	call Randomize							; seed the random range
	mov eax, 10								; set the range from 0-9
    call RandomRange						; get the random number
    mov randNum, eax						; set the variable to the number
	ret
getRandNum ENDP

end main