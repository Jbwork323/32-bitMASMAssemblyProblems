COMMENT !
Joseph Work
10/18/24
CSC 3000 X00
Advanced Computer Architecture
HW Assignment 7
This program will generate two arrays woth 50 numbers -50 to 50, then calculate the differences beteween matching values in the array
the user is then prompted to enter a difference value, the program will find all difference values that are less than or equal to
the user inputted value and display those pairs of numbers on a checkerboard in a random color
the color will change each second until the user presses a key, the program will restart if the key was a Y or y
else it will end
!
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data

arr1 SDWORD 50 DUP(?)							; will hold 50 random numbers from -50 to 50
arr2 SDWORD 50 DUP(?)							; will hold 50 random numbers from -50 to 50
differences DWORD 50 DUP(?)						; will hold the differences between the numbers in arr1 and arr2
indexOfMatches DWORD 50 DUP(0)					; will hold the indexes of matching differences
locations BYTE 100 DUP(0)						; will hold valid locations to place matching pairs
array1Msg BYTE "Array X: ", 0					; displayed wth arr1
array2Msg BYTE "Array Y: ", 0					; displayed with arr2
comma BYTE ", ", 0								; comma used to display between arr values
colorSpace  BYTE "---", 0						; used to set up the checkerboard
counter DWORD 0									; used to track indexes of matching vars
inArrLength DWORD 0								; used to know the length of indexOfmatches
numMatches DWORD 0								; the actual number of matches found

textColor DWORD 0								; will hold a randomly generated text color
bgColor DWORD 0									; will hold a randomly generated background color
loopBool DWORD 0								; used to alternate between colors for checkerboard
promptMsg BYTE "Enter a difference value: ", 0	; used to prompt the user for input
difference DWORD 0								; stores the user inputted difference value
errMsg BYTE "Invalid input", 0					; message displayed when user enters invalid input
continueMsg BYTE "Enter a Y/y to restart or any other key to stop: ", 0		; displayed at the end to prompt the user to continue or not
amountMsg BYTE "There were ", 0					; used to say how many matches there were 
amountMsg2 BYTE " matching differences.", 0		; displayed after amount Msg1
userInput BYTE "-"								; used to read a Y or y to restart program or not
	
positionsX BYTE 1, 4, 7, 10, 13, 16, 19, 22			 ; X-coordinates for Row 1
                 BYTE 1, 4, 7, 10, 13, 16, 19, 22    ; X-coordinates for Row 2
                 BYTE 1, 4, 7, 10, 13, 16, 19, 22    ; X-coordinates for Row 3
                 BYTE 1, 4, 7, 10, 13, 16, 19, 22    ; X-coordinates for Row 4
                 BYTE 1, 4, 7, 10, 13, 16, 19, 22    ; X-coordinates for Row 5
                 BYTE 1, 4, 7, 10, 13, 16, 19, 22    ; X-coordinates for Row 6
                 BYTE 1, 4, 7, 10, 13, 16, 19, 22    ; X-coordinates for Row 7
                 BYTE 1, 4, 7, 10, 13, 16, 19, 22    ; X-coordinates for Row 8


positionsY BYTE 1, 1, 1, 1, 1, 1, 1, 1				; Y-coordinates for Row 1
                 BYTE 3, 3, 3, 3, 3, 3, 3, 3		; Y-coordinates for Row 2
                 BYTE 5, 5, 5, 5, 5, 5, 5, 5		; Y-coordinates for Row 3
                 BYTE 7, 7, 7, 7, 7, 7, 7, 7		; Y-coordinates for Row 4
                 BYTE 9, 9, 9, 9, 9, 9, 9, 9		; Y-coordinates for Row 5
                 BYTE 11, 11, 11, 11, 11, 11, 11, 11 ; Y-coordinates for Row 6
                 BYTE 13, 13, 13, 13, 13, 13, 13, 13 ; Y-coordinates for Row 7
                 BYTE 15, 15, 15, 15, 15, 15, 15, 15 ; Y-coordinates for Row 8

.code
main proc
	start:
	call Randomize					; seed the random function for all future procedures
	call drawBoard					; then draw the chessboard
	mov eax, white					; put the color white into eax
	call setTextColor				; and set the text color
	call crlf						; new line
	mov edi, OFFSET arr1			; point edi to array 1
	call popArray					; now populate the array with 50 random values
	mov edi, OFFSET arr2			; point edi to array 2
	call popArray					; and now populate that one
	
	mov edi, OFFSET arr1			; point edi back to array 1
	mov edx, OFFSET array1Msg		; and then edx to array 1 message
	call WriteString				; display the message
	call dispArray					; then display the array
	call crlf						; new line
	
	mov edi, OFFSET arr2			; point edi to array 2
	mov edx, OFFSET array2Msg		; and edx to array 2 message
	call WriteString				; display the message
	call dispArray					; and then the array
	call calcDiffs					; now fill the differences array with the abs differcnes between arr1 and arr2
	call takeInput					; get user input for their difference value
	call findMatches				; and find now the indexes of differences that are <= user input
	call getLocations				; now that we found the indexes we need to create an array of valid locations to display them
	mov edx, OFFSET amountMsg		; next we display how many matches were found
	call WriteString				; displau the first amount message
	mov eax, inArrLength			; inArrLength has the number of matches in it
	call WriteDec					; display that in between msg1 and 2
	mov edx, OFFSET amountMsg2		; now point edx to msg2
	call WriteString				; and then display that
	call crlf						; new line
	mov edx, OFFSET continueMsg		; now we'll display the continue message because the dispMatches function messes with the cursor
	call WriteString				; display the continue message at the bottom of the console
	call dispMatches				; and now the checkerboard will display the matching values and switch colors every second
									; until the user presses a key
	call clrscr						; once they do clear the screen
	call resetVars					; reset all variables
	cmp userInput, 'y'				; and see if they entered a y
		je start					; if they did restart
	cmp userInput, 'Y'				; else if they entered a Y
		je start					; also restart
	exit							; if they entered anything else end the program

main endp

;-----------------------------------------------------
resetVars PROC
; resets all relevant variables to allow the program to run more than once
; Uses: ecx as loop counter, eax to store variables, edi esi as array pointers
; Receives: counter inArrLangth loopBool numMatches indexOfMatches locations set with results of game
; Returns: all above variables reset to default values
;-----------------------------------------------------
	mov counter, 0						; reset the counter
	mov inArrLength, 0					; reset the index array length
	mov loopBool, 0						; reset the loop bool
	mov numMatches, 0					; reset the number of matches
	mov ecx, 50							; set ecx to 50 to iterate that many times
	mov edi, OFFSET indexOfMatches		; point edi to indexOfMatches
	mov esi, OFFSET locations			; and esi to locations
	L1:
	mov eax, 0							; first set eax to 0
	mov [edi], eax						; then the value in indexOfmatches to 0
	mov [esi], eax						; then the value in locations to 0
	inc esi								; and then increment esi
	mov [esi], eax						; then set the next spot in esi also to 0 because locations is twice as long as indexOfMatches
	add edi, 4							; move to the next spot in indexes
	inc esi								; and the next in locations
	loop l1
	ret
resetVars ENDP

;-----------------------------------------------------
getLocations PROC
; creates an array of locations within the checkerboard to display numbers
; Uses: edi esi edx as array pointers, ecx as loop counter, ah al to store values
; Receives: positionsX and Y arrays, inArrLength
; Returns: new array of valid locations
;-----------------------------------------------------

	mov esi, OFFSET positionsX			; point esi to the x array
	mov edi, OFFSET positionsY			; and edi to the y array
	mov edx, OFFSET locations			; and edx to the locations array
	mov ecx, inArrLength				; set ecx to the amount of matches found
	l1:									; now we populate the locations array with 
										; enough locations to fill the checkerboard
		mov al, [esi]					; put the x location into al
		mov ah, [edi]					; and the y into ah
		mov [edx], al					; now move x into the first spot in locations
		inc edx							; go to the next spot in locations
		mov [edx], ah					; and put the y in there
		inc esi							; move to the next x
		inc edi							; and the next y
		inc edx							; and the next spot in locations
	loop l1								; loop inArrLength number of times
	ret
getLocations ENDP

;-----------------------------------------------------
dispMatches PROC
; displays matching numbers on the checkerboard in the arrays where the difference between the two is >= to the user input
; Uses: edi esi as array pointers, ecx as loop counter, eax edx to store values
; Receives: indexes array populated, arr1 and arr2 filled with random numbers
; Returns: none
;-----------------------------------------------------
	start:
	mov eax, 16							; first we need to generate two random colors so set eax to 16
	call RandomRange					; and get a random number 0-15
	mov textColor, eax					; set textcolor to that numbbr
	mov eax, 16							; now we create a second color so reset eax
	call RandomRange					; call randomRange again
	mov bgColor, eax					; and set the backrgound color to that
		
	mov ebx, bgColor					; set ebx to the background color
	mov eax, textColor					; and eax to the text color
	cmp ebx, eax						; compare them to make sure they're not the same
		je start						; if they are then restart
	shl ebx, 4							; now we need to combine them so shift ebx lext by 4
	or eax, ebx							; then or the two of them to combine them
	call SetTextColor					; and now we can set the text color
	mov edi, OFFSET locations			; point edi to locations

	mov esi, OFFSET indexOfMatches		; and esi to the indexes array
	mov ecx, inArrLength				; set ecx to the length of the indexes array
	L1:									; the way I stored the locations in the array means
			mov dl, [edi]				; that x is in the first position so set dl to that	
			inc edi						; then increment edi to go to the y position which is second
			mov dh, [edi]				; now set dh to the y location
			call gotoxy					; call gotoxy to go to that console location
			;mov eax, green				; for the initial display I decided to do green on black
			;call setTextColor			; now set the text color to that
			mov edx, [esi]				; put the index into edx
			mov eax, [arr1+edx*4]		; now put the first number from arr1 at that index into eax 
			call WriteInt				; write the first num to the screen
			dec edi						; now we need to go to the position under the one we were at
			mov dl, [edi]				; set edi back to the x position and move it into dl
			inc edi						; then inc again to get back to the y
			mov dh, [edi]				; put the y into dh
			add dh, 1					; and add 1 to dh to move one row down
			call gotoxy					; go to the position on screen
			mov edx, [esi]				; now set edx to the index location again
			mov eax, [arr2+edx*4]		; move the second number from arr2 at index into eax
			call WriteInt				; and write that under the first number
			add esi, 4					; go to the next index
			inc edi						; and the next pair of locations

			loop L1						; loop l1 for each index
			mov eax, 1000				; set eax to 1000 for a 1 second delay
			call Delay					; then call the delay
			call ReadKey				; Readkey will wait for user input without stopping the program so call that
			jz start					; if the zero flag is set then there was no input so restart
endProc:	
	mov userInput, al					; else store the key inputted in the variable
	ret									; and then return to main
dispMatches ENDP

;-----------------------------------------------------
findMatches PROC
; finds the index of differences that are <= to the user inputted differece
; Uses: edi esi as array pointers, ecx as loop counter, eax to store values
; Receives: array of differences 
; Returns: array of indexes of matching elements
;-----------------------------------------------------
 mov counter, 0					; counter is used to store the index of any diff matches found
 
 mov edi, OFFSET differences	; point edi to the differences array
 mov esi, OFFSET indexOfMatches	; and esi to the one that will hold the indexes they were found at
 mov ecx, 50					; there are 50 differences so set the loop counter to that
 L1:
	mov eax, difference			; put the user entered difference into eax
	cmp eax, [edi]				; and compare it to the one in the array
		jge foundMatch			; if the user one is greater or equal it's a match and will be included
	continue:	
		add edi, 4				; go to the next element in edi
		inc counter				; and increment the index counter
		loop L1
	jmp endProc					; end the procedure when the loop ends
foundMatch:
	mov eax, counter			; put the index into eax
	inc inArrLength
	mov [esi], eax				; and then into the indexOfMatches array
	add esi, 4					; go to the next position in indexOfMatches
	jmp continue				; and then go back to continue
 
 endProc:						; used to end the proc 
	ret
findMatches ENDP

;-----------------------------------------------------
calcDiffs PROC
; calculates the difference between matching elements of two randomly generated arrays
; Uses: ecx as loop counter, esi edi edx as array pointers, eax ebx to store values
; Receives: two randomly generated arrays
; Returns: array of differences between matching elements
;-----------------------------------------------------
	mov ecx, 50					; set the loop counter to 50
	mov esi, OFFSET arr1		; point esi to the first randomly generated array
	mov edi, OFFSET arr2		; edi to the second array
	mov edx, OFFSET differences ; and edx to the array that will the hold the differences between 1 and 2
	L1:
		mov eax, [esi]			; put the number from arr1 into eax
		mov ebx, [edi]			; and the number from arr2 into ebx
		sub eax, ebx			; subtract them to get the difference
		test eax, eax			; however for this purpose there can't be a negative difference
		js absValue				; so if it is negative we need to get the absolute value of it
		
		next:	
		mov [edx],eax			; once we are sure the difference is positive store it in the array
		add esi, 4				; and move to the next spot in arr1
		add edi, 4				; same in arr2
		add edx, 4				; and same in differences array
	loop L1
	jmp endProc					; once the loop is done end the procedure 

	absValue:					; this will only run if the difference is negative
		neg eax					; so to get the abs value we can just negate the negative
		jmp next				; and jump back to next
	endProc:
	ret

calcDiffs ENDP

;-----------------------------------------------------
takeInput PROC
; takes user input for difference between 1 and 50
; Uses: edx as string pointer, eax to store input
; Receives: none
; Returns: variable populated by user input
;-----------------------------------------------------
	start:
		call crlf							; new line
		mov edx, OFFSEt promptMsg			; point edx to a prompt message
		call WriteString					; write it to the screeen
		call ReadInt						; and then get an integer from the user
		cmp eax, 0							; compare it to 0 first because it can't be negative
		jle invalidInput					; so if it is then it's invalid
		cmp eax, 50							; it also can't be over 50
		jg invalidInput						; so if it is then it's invalid
		mov difference, eax					; finally if it's valid store the input
		ret									; and return
	invalidInput:
		mov edx, OFFSET errMsg				; point edx to an error message
		call WriteString					; display it
		jmp start							; and restart

	ret
takeInput ENDP

;-----------------------------------------------------
drawBoard PROC
; draws a 8x8 grey and white checkerboard to the console
; Uses: esi edi as array pointers, ecx as loop counter, eax to store values, edx to store values
; Receives: none
; Returns: none
;-----------------------------------------------------
	mov esi, OFFSET positionsX					; point esi to an array of 64 X positions 
	mov edi, OFFSET positionsY					; point edi to an array of 64 Y positions
	mov ecx, 64									; set the loop counter to 64
	mov loopBool, 0								; loopBool is used to alternate between white and grey squares
	mov eax, white + (white*16)					; initially set the color to white text on white background
			call SetTextColor					; set that text color
	dispLoop:
		mov dl,[esi]							; put the x position into dl
		mov dh, [edi]							; and the y into dh, they will form a 3x2 rectangle
		call gotoXY								; go to that position
		cmp ecx, 64								; but first compare ecx to 64 if it's not 64 then we need to check ecx%8
		cmovne eax, ecx							; to make a good checkerboard that doesn't have the same colors in each column
		mov edx, 0								; clear out the edx register
		mov ebx, 8								; set ebx to 8
		div ebx									; and divide eax(64)/ebx(8)
		cmp edx, 0								; if edx contains 0
		je continueLabel						; then skip setting the color

		cmp loopBool, 1							; else check loopBool, if it's 0 it's grey, 1 is white
			je whiteColor						; so if it's 1 go to the white label
		mov eax, gray + (gray*16)				; else set eax to grey text on a grey background
		call setTextColor						; and set that text color
		inc loopBool							; increment loopBool to alternate
		jmp continueLabel						; and skip WhiteColor
		whiteColor:
			mov eax, white + (white*16)			; if loop bool is 1 then the color needs to be white so set eax
			call SetTextColor					; then set the color to white on white
			dec loopBool						; and decrement loopBool to switch next time

		continueLabel:
			mov edx, OFFSET colorSpace			; point edx to '---' which is used to fill in space
			call WriteString					; and display that in either grey on grey or white on white
			mov dl,[esi]						; my spaces are 3x2 so we need to display it in the space directly under
			mov dh, [edi]						; put the x and y value back in dl and dh
			add dh, 1							; but add 1 to the y value to go one row down
			call gotoxy							; go to that position
			mov edx, OFFSET colorSpace			; point edx to '---' again
			call WriteString					; and display it in the color again making a solid 3x2 space
			inc edi								; increment the X array
			inc esi								; and the Y array
			loop dispLoop						; and loop 64 times to make an 8x8 board
			
	ret

drawBoard ENDP

;-----------------------------------------------------
dispArray PROC
; displays a 50 element array as a comma seperated list
; Uses: eax to store values, edx as string pointer, edi as array pointer, ecx as loop counter
; Receives: edi pointing to array
; Returns: none
;-----------------------------------------------------
	mov ecx, 50								; set loop counter to 50
	dispLoop:		
		mov eax, [edi]						; put the array value into eax
		call WriteInt						; write it to the screen
		mov edx, OFFSET comma				; followed by a comma
		call WriteString					; write the comma
		add edi, 4							; and go to the next array element
		loop dispLoop						; loop 50 times
	ret

dispArray ENDP

;-----------------------------------------------------
popArray PROC
; populates an array with 50 random values from -50 to 50
; Uses: ecx as loop pointer, eax to store values, edi as array pointer
; Receives: edi pointing to array
; Returns: array populated with 50 random values
;-----------------------------------------------------
	 
	mov ecx, 50
	L1:										; begin loop	
		mov eax, 101						; set range of rand nums to 0-100
		call RandomRange					; generate random number
		sub eax, 50							; subtract 50 to make the range -50-50
		mov [edi], eax						; move the random number into the array		
		add edi, 4							; move to the next array value
	loop l1
	ret
popArray ENDP

end main