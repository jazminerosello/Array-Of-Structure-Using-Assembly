global _start

section .data
    LF equ 10
    NULL equ 0
    SYS_EXIT equ 60
    STDOUT equ 1
    SYS_WRITE equ 1
    STDIN equ 0
    SYS_READ equ 0

    arraysize equ 5 ;size of an array
	patient equ 36 ;size of structure

    case_id equ 0
    case_id_length equ 20
    sex equ 21
    status equ 23
    date equ 25

    counter db 0
	totalPatient equ 180 ;summation of the size of the elements in the array 
	
	tempStat db 0

    ans db 0 ;storage of the choice for menu

	menu db 10, "[1] Add Patient", 10, "[2] Edit Patient", 10, "[3] Print Patients", 10, "[4] Exit", 10, "Enter choice: "
	menuLength equ $-menu

	invalidChoice db 10, ">>>> Invalid choice! <<<<", 10
	invalidChoiceLength equ $-invalidChoice

	fullPrompt db ">>>> Record is already full! <<<<", 10
	fullPromptLength equ $-fullPrompt

	addCase db 10, "Enter caseID: "		;Use this prompt for add and edit
	addCaseLength equ $-addCase

	addSex db "Enter sex (F - Female, M - Male): "
	addSexLength equ $-addSex

	addStatus db "Enter status (0 - deceased, 1 - admitted, 2 - recovered): " ;Use this prompt for add and edit
	addStatusLength equ $-addStatus

	addDate db "Enter date admitted (mm/dd/yyyy): "
	addDateLength equ $-addDate

	printCase db 10, "CaseID: "
	printCaseLength equ $-printCase

	printSex db 10, "Sex: "
	printSexLength equ $-printSex

	printStatus db 10, "Status: "
	printStatusLength equ $-printStatus

	printDate db 10, "Date Admitted: "
	printDateLength equ $-printDate

	cannotEdit db ">>>> Cannot edit records of a deceased patient. <<<<", 10
	cannotEditLength equ $-cannotEdit

	cannotFind db ">>>> Patient not found! <<<<", 10
	cannotFindPrompt equ $-cannotFind

    designForPrinting db "======= List of Patients =======", 10
	designForPrintingLen equ $-designForPrinting

    noPatientsYet db "======= NO PATIENTS YET =======", 10
	noPatientsYetLen equ $-noPatientsYet

	newLine db 10
	newLineLength equ $-newLine

section .bss
    patientRecord resb patient*arraysize
	tempCaseID resb 20

section .text
_start:

    ;menu print
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, menu
    mov rdx, menuLength
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLength
    syscall
	
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, ans ;get the answer of users and store to ans
    mov rdx, 2  ;1 for the digit and 1 for null char
    syscall

    sub byte[ans], 30h ;convert to decimal
	mov bl, byte[ans] ;mov ans to bl register

    cmp bl, 1 ;compare to 1, then go to add label
    je add

    cmp bl, 2 ;compare to 2, then go to edit label
    je edit

    cmp bl, 3 ;compare to 3, then go to printClear label
    je printClear
 
    cmp bl, 4 ;compare to 4, then go to exit_here label
    je exit_here

    jmp printPrompt ;if wala sa apat na nasa itaas ang choice ni user, print invalid prompt


add: ;rbx here is the index*patient
    mov bl, byte[counter] ;mov counter to bl
    cmp bl, totalPatient ;check if bl = totalPatient, if yes, record is already full so print prompt message
    je printFull

    ;else, ask for patients information

     ;printing and getting the input for case ID
	mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, addCase
    mov rdx, addCaseLength
    syscall

    mov rax, 0
	mov rdi, 0
	lea rsi, [patientRecord +rbx + case_id] 
	mov rdx, 20
	syscall

	dec rax
	mov byte[patientRecord+rbx+case_id_length], al

    ;printing and getting the input for sex
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, addSex
    mov rdx, addSexLength
    syscall

    mov rax, 0
	mov rdi, 0
	lea rsi, [patientRecord + rbx + sex]
	mov rdx, 2
	syscall

    ;printing and getting the input for status
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, addStatus
    mov rdx, addStatusLength
    syscall

    mov rax, 0
	mov rdi, 0
	lea rsi, [patientRecord + rbx + status]
	mov rdx, 2
	syscall

    sub byte[patientRecord + rbx + status], 30h

    ;printing and getting the input for date
	mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, addDate
    mov rdx, addDateLength
    syscall

    mov rax, 0
	mov rdi, 0
	lea rsi, [patientRecord + rbx + date]
	mov rdx, 11
	syscall



    add bl, 36 ;add 36 to bl since 36 is the size of one element
    mov byte[counter], bl ;mov the bl to counter
    mov bl, 0 ;clear bl register

    jmp _start ;go to menu again

printFull: ;printing prompt message saying it's already full 
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, fullPrompt
    mov rdx, fullPromptLength
    syscall

    jmp _start ;jump to _start label to ask users again for their choice in the menu


printClear: ;rbx here is the index*patient
    mov rbx, 0 ;clear the rbx register

    mov r8, 0
    mov r8b, byte[counter]
    cmp r8, 0
    je printNoPatients

    ;for design only
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, designForPrinting
    mov rdx, designForPrintingLen
    syscall

    jmp printing ;go to lable printing

printNoPatients:
    ;whenever users chose to print patients when there is still no patients in the record
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, noPatientsYet
    mov rdx, noPatientsYetLen
    syscall

    jmp _start ;go to lable printing


printing:

    ;print the case_id
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, printCase
    mov rdx, printCaseLength
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [patientRecord + rbx + case_id]
    mov dl, byte[patientRecord +rbx+ case_id_length]
    syscall

     ;printing the sex
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, printSex
    mov rdx, printSexLength
    syscall

    mov rax, 1
	mov rdi, 1
	lea rsi, [patientRecord + rbx + sex]
	mov rdx, 1
	syscall

    ;printing the status
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, printStatus
    mov rdx, printStatusLength
    syscall

    add byte[patientRecord + rbx + status], 30h ;since we converted the status in add portion to decimal, 
    ;to be able to print it, we need to convert it back to string

    mov rax, 1
	mov rdi, 1
	lea rsi, [patientRecord + rbx + status]
	mov rdx, 1
	syscall

    ;printing the date
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, printDate
    mov rdx, printDateLength
    syscall

    mov rax, 1
	mov rdi, 1
	lea rsi, [patientRecord + rbx+ date]
	mov rdx, 10
	syscall

	mov rax, 1
	mov rdi, 1
	lea rsi, [newLine]
	mov dl, newLineLength
	syscall

    mov rax, 1
	mov rdi, 1
	lea rsi, [newLine]
	mov dl, newLineLength
	syscall

    ;since we convert the status to string when we print, we need
    ;to turn it back to decimal
    sub byte[patientRecord + rbx + status], 30h


    add rbx, 36 ;add 36 to rbx since 36 is the size of an element
	cmp bl, byte[counter] ;compare if bl = counter to know kung lahat ng element
    ;int the array of structures are already printed
	je _start ;if yes, go to menu again
   
    jmp printing ;else jump to printing 

edit:
    ;ask for the caseID users want to edit the status
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, addCase
    mov rdx, addCaseLength
    syscall

	mov rax, 0
	mov rdi, 0
	mov rsi, tempCaseID ;store their input in tempCaseID
	mov rdx, 20
	syscall

    dec rax ;dec rax, since there are instances that caseID length (20) will not be used
    mov rbx, 0

checkEveryElement:
    mov rsi, 0
    mov rdi, 0
    mov rcx, 0

    lea rsi, [patientRecord + rbx + case_id]
    mov rdi, tempCaseID
    mov cl, byte[patientRecord + rbx + case_id_length]
    cld ;forward move

looping:
    cmpsb ;compare rdi to rsi
    jne next ;if one letter is not equal jump to next to get the index*patient of hte next element
    loop looping ;else check other characters in rsi adn rdi

    cmp byte[patientRecord + rbx + status], 0 ;compare if status is equal to 0
    je printCannot ;if yes, print cannot be edited 

    jmp askNew ;else, ask new status

next:
    add rbx, 36 ;add 36 to rbx since it is the size of an element to the array
    cmp bl, byte[counter] ;compare if bl = counter to know if all patients ay nadaanan na
    je notFound ;if yes, and wala pa rin doon 'yung ka-same ng users input for case_id, meaning case_id input is not fount in the record'

    jmp checkEveryElement ;if hindi pa equal, checkEveryElement uli to compare

askNew:
    ;printing and getting the input for new status of the rbx or index*patient in the array
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, addStatus
    mov rdx, addStatusLength
    syscall

    mov rax, 0
	mov rdi, 0
	lea rsi, [patientRecord + rbx + status]
	mov rdx, 2
	syscall

    sub byte[patientRecord + rbx + status], 30h ;convert to decimal
    jmp _start

printCannot:
    ;prints prompt message that the patient's status is deceased, therefore cannot be edit
	mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, cannotEdit
    mov rdx, cannotEditLength
    syscall

	jmp _start

notFound: ;print that the case_id users input to be edited is not found
	mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, cannotFind
    mov rdx, cannotFindPrompt
    syscall

	jmp _start

printPrompt: ;print prompt message that their choice in menu is invalid
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, invalidChoice
    mov rdx, invalidChoiceLength
    syscall

	jmp _start


exit_here:
	mov rax, 60
	xor rdi, rdi
	syscall