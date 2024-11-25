COMMENT !
Joseph Work
9/5/24
CSC 3000 X00
Advanced Computer Architecture
HW Assignment 2
Program that first prompts the user to enter a number between 5 and 100 for an array length
it then generates an array of that length full of random 2 digit numbers and displays it
The program then asks the user to enter  a K value less than 100, then calcuates all the
multiples of K in the array and displays those, and then the largest of the multipoles in the array
The program then generates an array of 100 random locations on the screen and 100 random colors
It then displays the max K multiple in a random location with a random text color 100 times before 
asking the user if they want to continue or not
!


INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
userK DWORD ?															; the K value to be entered by the user
arrLength DWORD ?														; the array length value to be entered by the user
randomArray DWORD 100 DUP(0)											; the array of random values to be generated
multArray DWORD 100 DUP(0)												; the array that will hold the multiples of K in it
promptMsg BYTE "Enter an array length from 5-100:  ", 0					; first prompt for user input		
promptMsg2 BYTE "Enter a positive integer less than 100:  ", 0			; first prompt for user input
multMsg BYTE "The multples of K in the array: ", 0						; message to be displayed with multArray
multMsg2 BYTE "The largest multiple of K in the array: ", 0				; the message to be displayed with largestMult
waitingMsg BYTE "Press any key to coninue...", 0						; the message to be displayed before the random text and colors
index DWORD 0															; index is used to index the results array when calculating K values
largestMult WORD 0														; var used to hold the largest multiple of K from multArray
locations   DWORD   100 DUP(0)											; Array to store 100 unique random locations
maxX WORD 0																; holds the max X amount from GetMaxXY
maxY WORD 0																; holds the max Y amount from GetMaxXY
colors      DWORD    100 DUP(0)											; Array to store 100 random colors
bgColor     DWORD    7													; used to check generated colors vs the background color 
defColor = 0 + (lightGray *16)											; defColor is the background color (lightGray)
continueMsg BYTE "Enter Y/y to continue, or exit with anything else: ", 0	; prompt for the user if they want to continue or not


arrMsg BYTE "Your random array: ", 0									; message to be displayed with the first generated array
errMsg BYTE "Invalid Input", 0											; error message that displays when users enter invalid input
comma BYTE ", ", 0														; comma used for clean display


.code
main PROC

initProc:											; jumped to if the user wishes to continue
	call takeInput									; call takeinput Procedure
	mov edi, OFFSET randomArray						; set edi to point to the random array
	mov ecx, arrLength								; set ecx loop counter to array length
	call randArray									; call randArray procedure
	call takeInput2									; get user input for the second time to get K value

	mov esi, OFFSET randomArray						; set esi to point to the initial array
	mov ecx, arrLength								; set ecx to the length of the array
	mov ebx, userK									; set ebx to point to the user's input for K
	mov edi, OFFSET multArray						; set edi to point to the results array
	call multiplesK									; call the procedure to find multiples and max multiple
	call crlf										; new line
	mov edx, OFFSET waitingMsg						; set edx to display message waiting for user input
	call WriteString								; write it to the screen

	call ReadChar									; wait for any user input before continuing
	call Clrscr										; clear the screen
		
	mov ecx, 100									; set ecx as loop counter
	call generateLocations							; generate the 100 random locations
	call generatecolors								; generate the 100 color values
	call displaymaxmultiple							; display the maxMult 100 times

continueProc:										; after everything else is done this executes
		call crlf									; new line
		mov edx, OFFSET continueMsg					; prompt the user if they want to continue
		call WriteString							; write it to the screen
		call ReadChar								; take user input
		cmp al, 'Y'									; if it's Y then restart from the beginning
		je initProc									; jump to initProc
		cmp al, 'y'									; it's not case senstive so lowercase y also works
		je initProc									; also jump to initProc
		exit										; if they enter anything other than those, end the program

exit
main ENDP

;-----------------------------------------------------
DisplayMaxMultiple PROC
; displays the max multiple at 100 locations in different colors
; Uses: edx to store values, eax to store values, edi and esi as array pointers, ecx as loop counter
; Receives: nothing
; Returns: locations and colors array populated, defColor
;-----------------------------------------------------
    mov ecx, 100					; Number of instances
    xor esi, esi					; Clear esi
	mov esi, OFFSET locations		; set esi to point to locations array 
	mov edi, OFFSET colors			; set edi to point to colors array
	
DisplayLoop:
	
    mov dx, [esi]					; Get location
    call GotoXY						; Move cursor to the locations

	mov edx, [edi]					; move the color into edx for calcuations
	add edx, defColor				; add defColor to edx [edi] + (LightGray * 16)
	mov eax, edx					; move the new value of random text and lightGray background into eax

    call SetTextColor				; Set random text color

    mov ax, largestMult				; Load the max multiple
    call WriteDec					; Display the max multiple at random location in random color

	mov eax, 1000					; set eax to 1000 for 1 second
    call Delay						; Wait 1 second

    add esi, 4						; go to next locations array value
	add edi, 4						; go to next color array value
    loop DisplayLoop				; Repeat for all 100 locations

    ret
DisplayMaxMultiple ENDP

;-----------------------------------------------------
GenerateColors PROC
; generates an array of 100 random colors ensuring they dont match the background color
; Uses: eax to store values, esi as array pointer, ecx as loop counter
; Receives: bgColor
; Returns: array of 100 color values 
;-----------------------------------------------------
    
    mov ecx, 100					; set loop counter to 100
    xor esi, esi					; Clear esi
	mov esi, OFFSET colors			; point esi to the color array

GenColorLoop:
	mov eax, 15						; set eax to 15 to generate a value with an upper range of 15

    call RandomRange				; Generate random color value
    cmp eax, bgColor				; Compare with background color
    je GenColorLoop					; If match, generate another color
	
	mov [esi], eax					; if not the background color put it in the array
	add esi, 4						; go to next array value
    loop GenColorLoop				; Repeat until 100 colors are stored

    ret
GenerateColors ENDP

;-----------------------------------------------------
generateLocations PROC
; generates 100 unique random locations 
; Uses: ecx as loop counter, esi as array pointer, ebx eax and edx to store values
; Receives: none
; Returns: array of 100 location values
;-----------------------------------------------------
    
    call Randomize						; seed the randomizer
    call GetMaxXY						; get the max dimensions of the console
    mov maxX, ax						; Store the maximum X dimension
	
    mov maxY, dx						; Store the maximum Y dimension

    mov ecx, 100						; Set loop counter for 100 locations
    mov esi, OFFSET locations			; Point ESI to the locations array

genLocLoop:
    
    movzx eax, maxX						; set eax to the maxX value
    dec eax								; Set max range to maxX-1
    call RandomRange					; get random number in that range
    mov ebx, eax						; Store random X in EBX

    
    movzx eax, maxY						; move maxY into eax
    dec eax								; Set max range to maxY-1
    call RandomRange					; get the random number in that range
    mov edx, eax						; Store random Y in EDX

    ; Combine X and Y into one DWORD (Y in high-order, X in low-order)
    shl edx, 6							; Shift Y to high-order 16 bits
    or ebx, edx							; Combine X and Y into a single DWORD in EBX

	mov edi, OFFSET locations			; point edi to the beginning of the array
	mov eax, 100						; set eax to 100 to use as loop counter
	checkDups:							; ensure location hasn't been used before
		cmp ebx, [edi]					; compare ebx to the current array value
		je genLocLoop					; if it already exists make another one
		add edi, 4						; if not go to next array index
		dec eax							; decrement array counter
		cmp eax, 0						; once eax = 0	
			jnz checkDups				; end the loop



    
    mov [esi], ebx						; store the location in the array
    add esi, 4							; Move to the next position in the array

    loop genLocLoop						; Repeat until 100 locations are stored

    ret
	generateLocations endp

;-----------------------------------------------------
multiplesK PROC
; finds the multiples of user entered K value in randomly generateed array 
; Uses: edx to store values, ax to store values, edi and esi as array pointers, bx to store values, ecx as loop counter
; Receives: edi and esi as array pointers, ecx as loop counter, ebx as user entered K
; Returns: new array of multiples of K and the max multiple set
;-----------------------------------------------------
	mov index, 0					; set index = 0
	mov edx, OFFSET multMsg			; point edx to the initial message
	call WriteString				; write it to the screen
	

L1:
        mov ax, [esi]				; Load the current array element
        cdq							; Sign extend EAX into EDX:EAX
        div bx						; AX / BX -> quotient in AX, remainder in DX

        cmp dx, 0					; Check if remainder is 0 (meaning it's a multiple)
        jne NotAMultiple			; If not zero, skip

		mov ax, [esi]				; set ax = to the next array value
        mov [edi], ax				; Store the multiple in the result array
		mov ax, [edi]				; set it back to ensure that we're printing the right number
		call WriteDec				; display it
		mov edx, OFFSET comma		; set edx to a comma
		call WriteString			; and display that
        add edi, 2					; Move to the next position in result array
		inc index					; increment index
        

    NotAMultiple:
        add esi, 2					; Move to the next element in the array
        loop L1						; loop arrayLength number of times

	mov ax, [edi-2]					; move the last element of the array into ax

	cmp ax, 0						; and check if it's 0, meaning that no values were put into the mult array
	jnz getBiggest					; if it's not zero skip this and go straight to the next loop
	call WriteDec					; print 0 to the screen to show that there were no multiples
	mov largestMult, 0				; set the largestMult to 0 if the array was not populated
	jmp returnToMain				; skip the loop
	
	getBiggest:						
		mov ecx, index				; set loop counter = index
		mov edi, OFFSET multArray	; set edi to point to the beginning of the array
		
			
		L2:							; this loop finds the largest multiple in the array
			mov ax, [edi]			; set ax = to the first element
			mov bx, largestMult		; and set bx = largest mult
			cmp ax, bx				; compare ax and bx 
			jg greater				; if ax is greater then replace largestMult with it
			jle continue			; else continue


			greater:
			mov largestMult, ax		; set the new largest mult

			continue:		
				add edi, 2			; go to the next array element
				loop L2				

		returnToMain:
			call crlf					; new line
			mov edx, OFFSET multMsg2	; set edx to display the new message
			call WriteString			; write it to the screen
			mov ax, largestMult			; set ax back to the largest mult
			
			call WriteDec				; and display it
			ret
multiplesK ENDP

;-----------------------------------------------------
takeInput PROC
; Used to take user input then validate that it is greater than 5 but less than 100 
; Uses: edx to store values, eax to store input
; Receives: Nothing
; Returns: arrayLength variable populated with user input
;-----------------------------------------------------
	call crlf											; new line
	L1:
		mov edx, OFFSET promptMsg						; set EDX to display prompt message
		call WriteString								; write it to the screen

		call ReadInt									; take user input for even number between 10 and 40
		

		ValidNum:							
			cmp eax, 5									; compare eax to 5
			jl InvalidNum								; if it is less than 5 go to invalid num

			cmp eax, 100									; compare eax to 100
			jg InvalidNum									; if it is greater or equal to 100 then it is invalid

			mov arrLength,eax								; finally if eax is valid set the input variable = to it
			ret

		InvalidNum:			
			mov edx, OFFSET errMsg						; set edx to display error message
			call WriteString							; write it to the screen
			call Crlf									; new line
			jmp L1										; restart the loop

takeInput ENDP



;-----------------------------------------------------
takeInput2 PROC
; Used to take user input for the K variable which must be a positive int less than 100 
; Uses: edx to store values, eax to store input
; Receives: Nothing
; Returns: userK variable populated by userInput
;-----------------------------------------------------
	call crlf											; new line
	L1:
		mov edx, OFFSET promptMsg2						; set EDX to display prompt message
		call WriteString								; write it to the screen

		call ReadInt									; take user input for even number between 10 and 40
		

		ValidNum:							
			cmp eax, 0								
			jle InvalidNum								; if it is less than 10 go to invalid num

			cmp eax, 100									; compare eax to 40
			jge InvalidNum								; if it is greater than 40 go to invalid num

			mov userK,eax								; finally if eax is valid set the input variable = to it
			ret

		InvalidNum:			
			mov edx, OFFSET errMsg						; set edx to display error message
			call WriteString							; write it to the screen
			call Crlf									; new line
			jmp L1										; restart the loop

takeInput2 ENDP



;-----------------------------------------------------
randArray PROC
; generates an array of N random numbers from 10-99
; Uses: edi as array pointer, ax to store values, edx to store values, ecx as loop counter
; Receives: edi as array pointer, ecx as loop counter (N)
; Returns: array filled with random numbers
;-----------------------------------------------------
		mov edx, OFFSET arrMsg
		call WriteString

		call Randomize						; seed the randomizer to ensure random numbers
		L1:									; begin loop
		
		mov eax, 89							; set range of rand nums 0-89
	
		call RandomRange					; generate random number
		add eax, 10							; add ten to the random number because we're only doing 2 digits
		mov [edi], eax						; move the random number into the array
		mov eax, [edi]						; move it back into ax
		call WriteDec						; display random number
			
		mov edx, OFFSET comma				; set edx to display comma
		call writestring					; write it to the console
		add edi, 2							; move to the next array value
	loop l1

	ret

randArray ENDP
END main