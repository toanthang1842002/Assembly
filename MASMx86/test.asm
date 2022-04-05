.386
.model flat
.data
fwrite db "WriteConsole",0
fgstdh db "GetStdHandle", 0
fexit db "ExitProcess", 0
fread db "ReadConsole",0
.data?
bkernel dd 1 dup(?)         ; Use for base kernel address
vaxedtbl dd 1 dup (?)       ; VA of exported table
rvaxeddir dd 1 dup (?)      ; RVA of exported directory 
fawrite dd 1 dup (?)        ; Use for address function of WriteConsole
faread dd 1 dup (?)         ; Use for address function of ReadConsole
fagstdh dd 1 dup (?)        ; Use for address function of GetStdHandle
faexit dd 1 dup (?)         ; Use for address function of ExitProcess
written dd 1 dup (?)        ; Number of char written (WriteConsole)
read dd 1 dup (?)           ; Number of char read (ReadConsole)
slen dd 1 dup (?)           ; Len of string
std_in_handle dd 1 dup (?)  ; Input handle value
std_out_handle dd 1 dup (?) ; Output handle value
string db 32 dup (?)
.code
_main proc
    call GetBaseAddr        ; Get base address
    call GetExportedTable   ; Get exported table address

    push offset fawrite     ;
    push offset fwrite      ; Find address of WriteConsole()
    call FindAddr           ;

    push offset faread     ;
    push offset fread      ; Find address of ReadConsole()
    call FindAddr  

    push offset fagstdh     ;
    push offset fgstdh      ; Find address of GetStdHandle()
    call FindAddr           ;

    push offset faexit      ;
    push offset fexit       ; Find address of ExitProcess()
    call FindAddr           ;

    mov eax,fagstdh         ; Get STD_OUTPUT_HANDLE
    push -11                ; save to handle var
    call eax                ;
    mov std_out_handle, eax ;

    mov eax,fagstdh         ; Get STD_INPUT_HANDLE
    push -10                ; save to handle var
    call eax                ;
    mov std_in_handle, eax  ;


    mov eax, faread         ; ReadConsole(STD_OUTPUT_HANDLE, *string, 32, *read, NULL)
    push 0                  ;
    push offset read        ;
    push 32                 ;
    push offset string      ;
    push std_in_handle      ;
    call eax                ;

    push offset string      ; Calculate string len 
    push offset slen        ;
    call StrLen             ;

    mov eax, fawrite        ; WriteConsole( Handle, *msg, len(msg), *num_written, NULL)
    push 0                  ;
    push offset written     ;
    push slen               ;
    push offset string      ;
    push std_out_handle     ;
    call eax                ;

    mov eax, faexit         ; ExitProcess(0)
    push 0                  ;
    call eax                ;
    
_main endp

GetBaseAddr proc
    push ebp
    mov ebp, esp
    push eax
    xor eax, eax
    assume fs:nothing
    mov eax, fs:[eax + 30h]     ; EAX = PEB
    mov eax, [eax + 0ch]        ; EAX = PEB->Ldr
    mov esi, [eax + 14h]        ; ESI = PEB->Ldr.InMemoryOrderModuleList
    lodsd                       ; EAX = 2nd Module (ntdll.dll)
    xchg eax, esi               ; Next module
    lodsd                       ; EAX = 3rd Module (Kernel32.dll)
    mov eax, [eax + 10h]        ; Base Address
    assume fs:error
    mov bkernel, eax
    leave
    ret
GetBaseAddr endp

GetExportedTable proc
    push ebp
    mov ebp, esp
    mov ebx, [eax + 3ch]        ; RVA of PE signature (e_lfanew) | EAX point to e_magic
    add ebx, eax                ; VA of PE signature
    mov ebx, [ebx + 78h]        ; RVA of the exported directory
    add ebx, eax                ; VA of the exported directory
    mov rvaxeddir, ebx
    mov esi, [ebx + 20h]        ; RVA of the exported table
    add esi, eax                ; VA of the exported table
    mov vaxedtbl, esi
    leave
    ret
GetExportedTable endp

FindAddr proc
    push ebp
    mov ebp, esp
    push ebx
    xor ecx, ecx
    xor ebx, ebx
    ;push bkernel
    mov esi, vaxedtbl
    l1:
    pop eax
    inc ecx
    lodsd                           ; Load RVA to EAX, ESI = *nextRVA
    add eax, bkernel                ; VA of function name
    push eax                        ; save eax value (Current function address name)
    mov edx, [ebp + 8]              ; Load string address to compare
    cmploop:                        ;
    mov bl, [eax]                   ; Use ebx to hold compare value
    mov bh, [edx]                   ;
    inc eax                         ; Next value to compare
    inc edx                         ;
    cmp bh, 0                       ; Check if compare done or not
    je endcmp                       ; If done jump to end
    cmp bh, bl                      ; Compare value
    je cmploop                      ; If Yes, check next value
    jmp l1                          ; Else, check next element
    endcmp:                         ;
    pop eax                         ; Restore current func address name
    mov ebx, rvaxeddir              ; Move RVA exported directory to ebx (calculate real function address)
    mov esi, [ebx + 24h]            ; ESI = RVA of function ordinal table
    add esi, bkernel                ; ESI = VA of function ordinal table
    mov cx, [esi + ecx *2]          ; get function biased_ordinal
    dec ecx                         ; get function ordinal ()
    mov esi, [ebx + 1ch]            ; RVA of address function = exported addr table
    add esi, bkernel                ; VA of exported addr table
    mov edi, [esi + ecx *4]         ; RVA of function
    add edi, bkernel                ; VA of funtion
    mov ebx, [ebp+12]               ; 
    mov [ebx], edi                  ; save value
    pop ebx                         ;
    leave                           ;
    ret 8                           ; Return then pop args from stack
FindAddr endp

StrLen proc
    push ebp
    mov ebp, esp
    push eax
    push ebx
    xor eax, eax            ; counter
    mov edi, [ebp + 12]     ; load string 
    next:
    mov bl, [edi + eax]     ; first char
    cmp bl, 0               ; check string end or not
    je stop                     
    inc eax                 ; if not increase counter
    jmp next                ; 
    stop:                   ; else save counter value to slen (string len)
    mov ebx, [ebp + 8]
    mov [ebx], eax
    pop ebx
    pop eax
    leave
    ret 8
StrLen endp

end _main