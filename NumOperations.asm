COMMENT !
Joseph Work
8/31/24
CSC 3000 X00
HW Assignment 1
Program that first prompts the user to enter an even number between 8 and 50, however it onluy accepts even numbers greater
than 9 and less than 40, the user then has the option to use four functions. The first generates the first N fibonacci values
N being the number the user entered before, and saves that in an array.
The second randomly generates an array of N size and then swaps each element with the one after it, so i and i+1 swap then i+2 and i+3, etc.
The third randomly generates an array of N size then adds together the gaps between all of the numbers and displays that
the fourth randomly generates an array of N size and then shifts all elements to the right by a user defined amount
after doing any of these functions the user can restart the program by entering a Y or y

!


INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
														; each array has a max length of 40 because that is the 
														; max the user is allowed to enter
fibArray DWORD 40 dup(?)								; array used to store N fibonacci values
sumArray DWORD 40 dup(?)								; array to store N random numbers to be summed
exchArray DWORD 40 dup(?)								; array to store N random numbers 
newExchArray DWORD 40 dup(?)							; array to store the numbers from exchArray after they have been exchanged
shifterArray DWORD 40 dup(?)							; array to store N random numbers to be shifted						
tempArray DWORD 5 dup(?)								; array to store temporary values from shifterArray

MenuPrompt   BYTE "Make a selection:",0dh,0ah
			 BYTE "a: Fibonacci",0dh,0ah				; menu to prompt the user for which operation they want to do 
             BYTE "b: Exchange Elements"     ,0dh,0ah   ; choice for AND operation
             BYTE "c: Sum Gaps"      ,0dh,0ah           ; choice for OR operation
             BYTE "d: Shift Elements"       ,0          ; choice to NOT operation

input DWORD ?											; input store the user's initial input and acts as the array's lengths 
promptMsg BYTE "Enter an even number between 8-50: ", 0 ; first prompt for user input
promptMsg2 BYTE "Enter your selection(a,b,c,d): ", 0    ; second prompt for user input
errMsg BYTE "Invalid Input", 0							; error message that displays when users enter invalid input
fibDisplayMsg BYTE "Fibonacci sequence to position ", 0 ; message that displays for the fibonacci proc
sumGapMsg BYTE "For the array ", 0						; message for the sum gap proc
sumGapMsg2 BYTE " the sum of the gaps is ", 0			; second sum gap message
comma BYTE ", ",0										; comma used in between array elements when displaying
exchMessage BYTE "Randomly generated array: ", 0		; message to display random array
exchMessage2 BYTE "New exchanged Array: ", 0			; message to be displayed with the exchanged array
continueMsg BYTE "Enter Y/y to continue, or exit with anything else: ", 0	; prompt for the user if they want to continue or not
shiftPrompt BYTE "Enter the amount of spaces to shift the array: ", 0		; prompt for the shifting amount
shiftMsg BYTE "The new shifted array: ", 0				; message to be displayed with the new shifted array
shiftValue DWORD ?										; var to store the user entered shift value
sumOfGaps WORD 0										; var to store the sum of all the gaps in sumGaps
	
     
.code
main PROC
	initProc:											; initProc will be used to continue the program later
		call takeInput									; first take user input for an even num from 10-40
		call menuProc
								
	continueProc:										; after everything else is done this executes
		call crlf										; new line
		mov edx, OFFSET continueMsg						; prompt the user if they want to continue
		call WriteString								; write it to the screen
		call ReadChar									; take user input
		cmp al, 'Y'										; if it's Y then restart from the beginning
		je initProc										; jump to initProc
		cmp al, 'y'										; it's not case senstive so lowercase y also works
		je initProc										; also jump to initProc
		exit											; if they enter anything other than those, end the program

main ENDP

;-----------------------------------------------------
shiftElements PROC
; generates a random array of n values, then asks the user to enter a shift amount which the array is then shifted by
; unfortately this doesn't really work, I couldn't get the last value to wrap and it barely works when printed
; Uses: edi as array pointer, esi as array pointer, ecx as loop counter, eax to store values, ax and bx to store values
; al to store values, ebx to store values
; Receives: Nothing
; Returns: shifted array of N elements filled with random numbers
;-----------------------------------------------------
mov edi, OFFSET shifterArray						; set edi to point to the array to be filled with random numbers
mov ecx, input										; set the loop counter to input
mov esi, OFFSET tempArray							; set esi to point to the temporary array

call crlf											; new line
mov edx, OFFSET exchMessage							; message to go with random array
call WriteString									; write it to the console

call randArray										; generate the random array
mov eax, [edi-2]									; after randArray esi is set to the first following 0 after the 
													; random numbers so set esi to the last random number
mov [esi+2],eax										; move that last number into eax to be used at the front of the shifted array


L1:
call crlf
mov edx, OFFSET shiftPrompt							; prompt the user for the shifting amount
call WriteString									; write the prompt to the console
		
call ReadInt										; take user's input for shift amount

cmp al, 0											; check if they entered 0 or lower which are invalid shift amounts															
jle badInput										; if they did display an error message and restart the loop
jmp next

badinput:											; if the user enter a number <=0 or other bad input this runs
mov edx, OFFSET errMsg								; set edx to display the error message
call WriteString									; write it to the screen
call crlf											; new line
jmp L1												; restart l1


next:
mov shiftValue, eax									; move the shift value into eax if valid
mov edi, OFFSET shifterArray						; set edi to point to the beginning of the array
mov esi, OFFSET tempArray							; do the same with esi to the temp array
mov ecx, shiftValue									; set the loop counter to the shift amount
mov ebx, 0											; ebx acts as a counter for how many times it has looped

mov edx, OFFSET shiftmsg							; display message to go with shifted array
call WriteString									; display it to the screen


L2:
	inc ebx											; first increment ebx
	cmp ebx,input									; then see if it matches input, if it does then we have reached the end
	je wrap											; of the random numbers and need to wrap around

	mov ax, [edi]									; set ax to the next value in edi
	mov bx, [esi]									; set bx to hold the value contained in esi
	mov [edi], bx									; bx will contain the previous value so set the current esi index to that
	mov [esi], ax									; set esi to contain the next valkue

	mov ax, [edi]									; set ax to the next array element
	call WriteDec									; write the next element to the screen
	mov edx, OFFSET comma							; set edx to display a comma in between each element
	call WriteString								; write the comma

	
	add edi, 2										; go t0 the next element in edi
	jmp cont										; if not wrapping, jump to cont to continue the loop
	
	wrap:											; this only runs if we need to wrap
		mov eax, [esi+2]							; esi+2 contains the last value in shiftedArray so set eax to that
		mov edi, OFFSET shifterArray				; reset the edi pointer since we now are at the end of the valuable numbers
		mov[edi], eax								; set the first element in edi to the one in esi+2

	cont:											; if not wrapping
		loop L2										; just continue the loop
			
													; the point of this next section is that if the user 
													; enters a shift amount < the array length, it will still output the entire array

	mov eax, input									; first start by settting eax to the length of the array					
	cmp ebx, eax									; ebx has counted how many times the previous loop iterated
		jg greater									; if it is greater than eax then it means the entire previous array will have been displayed
		jle lesser									; else we need to print the rest of it
	greater:			
		jmp endProc									; if it's greater, just end the procedure

	lesser:	
		sub eax, ebx								; if it's lesser, first find the difference so we know how many elements to print
		mov ebx, eax								; the set ebx to the difference
		jmp printLoop								; then jump to the print loop function
	
	printLoop: 
	cmp ebx, 0										; first ensure that the remainder of the subtraction wasn't 0
		jz endProc									; if it is just end the procedure
		add edi, 2									; else go to the next array element since the last has already been printed
		mov ax, [edi]								; set ax = to it
		call WriteDec								; and print ax

		mov edx, OFFSET comma						; set edx to the comma
		call Writestring							; and display that
		dec ebx										; decrement ebx
	
	jmp printLoop									; and restart the loop until ebx=0

endProc:											; used to end the procedure when needed
ret

shiftElements ENDP





;-----------------------------------------------------
menuProc PROC
; Displays the menu prompt and takes user input to run the various other functions of the program 
; Uses: edx to store values, al to store input
; Receives: Nothing
; Returns: nothing
;-----------------------------------------------------
	L1:
		call crlf							; start with a new line
		mov edx, OFFSET MenuPrompt			; set edx to display the menu
		call WriteString					; write it to the screen
		call crlf							; new line
		mov edx, OFFSET promptMsg2			; set edx to the next prompt
		call WriteString					; display it

		call ReadChar						; take the user's input
		cmp al, 'a'							; if it is a then go to the fibonacci procedure
		je fibonacci						; jump to the fib proc
		cmp al, 'A'							; it's not case sensitive so also do it for A
		je fibonacci						

		cmp al, 'b'							; else if it's b
		je exchangeElements					; go to exchange elements procedure
		cmp al, 'B'							; uppercase B also waorks
		je exchangeElements					; so also go to exchangeElements

		cmp al, 'c'							; else if it's c 
		je sumGaps							; then go to sumgaps procedure
		cmp al, 'C'							; uppercase C also works
		je sumGaps							; so still jump to the procedure

		cmp al, 'd'							; finally if it's d 
		je shiftElements					; then go to shiftElements
		cmp al, 'D'							; uppercase D work as well
		je shiftElements					; also go to the procedure

		jne L1								; if the user didn't enter a valid input restart the loop

		ret									; once the selected function is over, go back to main

menuProc ENDP


;-----------------------------------------------------
takeInput PROC
; Used to take user input then validate that it is even, not less than 10, and not more than 40 
; Uses: edx to store values, eax to store input
; Receives: Nothing
; Returns: Input variable populated by user Input
;-----------------------------------------------------
	call crlf											; new line
	L1:
		mov edx, OFFSET promptMsg						; set EDX to display prompt message
		call WriteString								; write it to the screen

		call ReadInt									; take user input for even number between 10 and 40
		test eax,1										; test if it is even
			jz ValidNum									; if it is even, go to valid num
			jnz InvalidNum								; if not go to invalid num

		ValidNum:							
			cmp eax, 10									; compare eax to 10
			jl InvalidNum								; if it is less than 10 go to invalid num

			cmp eax, 40									; compare eax to 40
			jg InvalidNum								; if it is greater than 40 go to invalid num

			mov input,eax								; finally if eax is valid set the input variable = to it
			ret

		InvalidNum:			
			mov edx, OFFSET errMsg						; set edx to display error message
			call WriteString							; write it to the screen
			call Crlf									; new line
			jmp L1										; restart the loop

takeInput ENDP

;-----------------------------------------------------
fibonacci PROC
; generates N numbers in the fibonoaccia sequence, N is the number initially entered by the user 
; Uses: edx to store values, eax to store values, ecx as loop counter, edi as array pointer, esi as array counter, ebx to store values
; Receives: edi as pointer to fibArray
; Returns: array filled with fibonacci numbers
;-----------------------------------------------------

mov edi, OFFSET fibArray			; set edi as a pointer to fibArray

call crlf							; new line
mov edx, OFFSET fibDisplayMsg		; set edx to display fibonacci message	
call WriteString					; write it to the screen
mov eax, input						; set eax = user input 
call WriteDec						; write eax to the screen
call crlf							; new line

sub eax, 2							; I prepopulate the first two values of the sequence so subtract 2


mov ecx, eax						; set the loop counter to user input -2

mov eax, 0							; first fib value is 0
mov [edi], eax						; set first array value as 0
call WriteDec
call crlf

mov eax, 1							; second fib value is 1
mov [edi+1], eax					; so set second array value to 1
call WriteDec
call crlf

mov eax, 0							; fib(n)					
mov edx, 1							; fib(n-1)
mov ebx, 0							; fib(n-2)
mov esi, 2							; esi is used to increment array position so set it to 2

L1:
	mov eax,ebx						; move fib(n-2)
	add eax, edx					; add edx ((fib(n-1)) to eax(fib(n-1)) to get fib(n)
	mov [edi], eax				; move fib(n) into array
	
	mov ebx, edx					; move fib(n-1) into ebx
	mov edx, eax					; move fib(n) into edx

	mov eax, [edi]				; move the array value into eax
	call writedec					; display each fib value
	call crlf						; new line
	
	add edi, 2						; go to the next element
	loop L1							; loop L1 ecx number of times

	ret								; return

fibonacci ENDP

;-----------------------------------------------------
sumGaps PROC
; generates an array of N size with randomly generated numbers from 0-50 then 
; caculates and displays the sum of the gaps
; Uses: edi as array pointer, esi, ecx as loop counter, edx to point to values, ax to store values
; Receives: none
; Returns: array filled with random numbers, sum of gaps between random numbers
;-----------------------------------------------------

	call crlf								; new line
	mov edi, OFFSET sumArray				; set edi as a pointer to the array
	call Randomize							; seed the random number generator

	mov ecx, input							; set loop counter = input
	mov edx, OFFSET sumGapMsg				; set edx to display sumGap message
	call writestring						; display it

	call randArray							; create random array
		
		mov edx, OFFSET sumGapMsg2			; set edx to display the second message
		call WriteString					; write it to the console
		

			
		mov edi, OFFSET sumArray			; reset edi to the beginning of the array
		mov eax, input						; set eax = user input
		sub eax, 1							; subtract 1 from eax to prevent buffer overflow
		mov ecx, eax						; set the loop counter = input-1

		l2:
			mov ax, [edi]					; move array value into ax
			cmp ax, [edi+2]					; compare ax with the next array value to see which is bigger
			jge greaterThan					; if ax >= jump to greater than
			jl lessThan						; else if it's less than go to LessThan


			greaterThan:
				sub ax, [edi+2]				; subtract ax from the next number
				add sumOfGaps, ax			; add the difference to the sum
				jmp iteration				; go to the next iteration

			lessThan:
				mov bx,[edi+2]				; if ax is less than edi+1 store that value in bx
				sub bx, ax					; then substract ax from bx
				add sumOfGaps, bx			; store the difference in sum of gaps
				jmp iteration				; and continue the loop

			iteration:			
				add edi, 2					; go to the next value in the array
				loop l2			
		
		
		mov ax, sumOfGaps					; move the sum into ax to be displayed
		call WriteDec						; write it to the screen

	ret
sumGaps ENDP



;-----------------------------------------------------
exchangeElements PROC
; randomly generates an array of N elements then swaps them in a new array
; i and i+1 swap i+2 and i+3 swap, etc. 
; Uses: edi as array pointer, esi as exchanged array pointer, eax to store values, ecx as loop counter, edx, ax and bx to store values
; Receives: Nothing
; Returns: array filled with random numbers, second array swapped with first
;-----------------------------------------------------
	mov edi, OFFSET exchArray
	call Randomize							; seed the random number generator
	mov ecx, input							; set loop counter = input
	mov edx, OFFSET exchMessage
	call WriteString

	call randArray							; generate random array

	xor edx, edx							; zero out edx for division
	mov ebx, 2								; set ebx to 2 to divide eax/2
	mov eax, input							; set eax = input
	div ebx									; divide eax by ebx (input/2)

	mov ecx, eax							; set loop counter to input/2
	mov edi, OFFSET exchArray				; set edi to the randomly generated array
	mov esi, OFFSET newExchArray			; set esi to the new array
	call crlf								; new line

	mov edx, OFFSET exchMessage2			; set edx to "New Exchanged Array"
	call Writestring						; Display it before the array

	L2:
	mov ax, [edi]							; set ax to the first element
	mov bx, [edi +2]						; set bx to the second element to be swapped with the first
	
	mov [esi],bx							; set new array first element to the original's second
	mov [esi +2],ax							; and set the second to the first, swapping them

	add edi, 4								; move to the next pair of numbers
	add esi, 4								; move to the space to be occupied by the next two

	loop l2

	mov ecx, input							; reset ecx to input for loop counter
	mov esi, OFFSET newExchArray			; reset esi to start of new array

	l3:										; this loop just prints the new array
	mov ax, [esi]							; set ax to the next array element
	call WriteDec							; display it
	mov edx, OFFSET comma					; point edx to a comma
									
	Call Writestring						; write the comma in between array elements
	add esi, 2								; move to the next array element

	loop l3
	ret										; return to main

exchangeElements ENDP


;-----------------------------------------------------
randArray PROC
; generates an array of N random numbers from 0-50
; Uses: edi as array pointer, ax to store values, edx to store values, ecx as loop counter
; Receives: edi as array pointer, ecx as loop counter (N)
; Returns: array filled with random numbers
;-----------------------------------------------------
		call Randomize						; seed the randomizer to ensure random numbers
		L1:									; begin loop
		
		mov eax, 50							; set range of rand nums 0-50
	
		call RandomRange					; generate random number
		mov [edi], ax						; move the random number into the array
		mov ax, [edi]						; move it back into ax
		call WriteDec						; display random number
			
		mov edx, OFFSET comma				; set edx to display comma
		call writestring					; write it to the console
		add edi, 2							; move to the next array value
	loop l1

	ret

randArray ENDP

END main