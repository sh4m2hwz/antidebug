macro mmov32 dst,src
{
    push dword 0x80000000
    push eax
    push dword src
    movbe eax,[esp]
    add esp,4
    push eax
    push dword 0x00010203
    vpbroadcastd xmm3,[esp+3*4]
 ;   xorpd xmm2,xmm2
    movd xmm2,[esp]
    pshufb xmm2,xmm2
    push dword [esp]
    or dword [esp],0x80808003
    and dword [esp],0x80808003
    xor eax,eax
    push ebx
    and ebx,0
    or bl,4
    or al,bl
    jmp lp
    
;shuf1:

    not byte [esp+8]
    pinsrb xmm4,[esp+8],0x00 
    jmp $+176

;shuf2:

    shufps xmm4,xmm4,11100010b
    jmp $+167

;shuf3:

    shufps xmm4,xmm4,11001001b
    jmp $+158

;shuf4:    

    shufps xmm4,xmm4,00111001b
    jmp $+149

            
;lp:
    movd xmm5,[esp+4]
    orps xmm4,xmm5
    dec byte [esp+4]
    
    push ebx
    
    mutation_cmpzc32 ebx,eax
    jz $-50
    dec bl
    
    mutation_cmpzc32 ebx,eax
    jz $-90
    dec bl
    
    mutation_cmpzc32 ebx,eax
    jz $-130
    dec bl
    
    mutation_cmpzc32 ebx,eax
    jz $-182

;continue:

    pop ebx
    dec al
    test al,al
    jnz $-149
    pop ebx    

    pshufb xmm2,xmm4
    and dword [esp],0x80000000
    vpbroadcastd xmm3,[esp]
    xorpd xmm5,xmm5
    movd xmm5,[esp]
    shufps xmm5,xmm5,00111001b
    xorps xmm3,xmm5    
    vpgatherdd xmm1,[esp+xmm2*4],xmm3
    movd xmm0,[esp]
    add esp,12
    pop eax
    pextrd [esp],xmm1,2
    movd xmm2,[esp]
    pextrd [esp],xmm1,1
    movd xmm3,[esp]
    pshufb xmm2,xmm3
    movd [esp],xmm2
    pop dword dst
}

macro mcmp8 dst,src
{cmp byte dst,src}
macro mmovzx32_8 dst,src
{
    push bx
    or bl,src
    and bl,src
    xor bh,bh
    shld bx,bx,8
    push bx
    push word 0
    vpbroadcastw xmm1,[esp]
    or dword [esp-2],0x80000000
    and dword [esp-2],0x80000000
    vpbroadcastd xmm1,[esp-2]
    or dword [esp-2],0xffffffff
    movd xmm3,[esp-2]
    shufps xmm3,xmm3,01010100b    
    andps xmm1,xmm3 
    vmaskmovps xmm0,xmm1,[esp+2]
    xorps xmm3,xmm3
    pblendw xmm0,xmm3,11111110b
    or dword [esp-2],0x00000001
    and dword [esp-2],0x00000001
    movd xmm3,[esp-2]
    pshufb xmm0,xmm3
    movd [esp],xmm0
    mov bx,[esp+4]
    mov dst,[esp]  
}
macro mmov8 dst,src
{   
      push ebx
	pushad
	movzx eax,byte src
	bswap eax
	lzcnt ebx,eax
	or eax,ebx
	push eax
	movups [esp-16],xmm5
	movups [esp-38],xmm3
	movd xmm5,[esp]
	and dword [esp-42],0
	vpbroadcastd xmm3,[esp-42]
	push dword 0x00010203
	movd xmm3,[esp]
	pshufb xmm5,xmm3
	movd [esp],xmm5
	and al,byte [esp]
	or al,byte [esp]
      add esp,4
	movups xmm3,[esp-38]
	movups xmm5,[esp-16]
      or byte [esp+20],al
	and byte [esp+20],al
      pop eax
	popad
      mov byte dst,bl
      pop ebx
}
macro mxor32 dst,src
{

    push dword src
    push dword dst

    pinsrd xmm0,[esp],3
    pinsrd xmm1,[esp+4],3
    
    or byte [esp-1],0xff
    vpbroadcastb xmm2,[esp-1] ; ~ab + ~ba
    
    movdqu xmm4,xmm0
    movdqu xmm3,xmm1
    
    xorps xmm4,xmm2
    andps xmm4,xmm1
    
    xorps xmm1,xmm2
    andps xmm1,xmm0
    
    orps xmm1,xmm4
    pextrd dword dst,xmm1,3
    add esp,8 

}

macro mand32 dst,src
{

    push dword src
    push dword dst

    pinsrd xmm0,[esp],3
    pinsrd xmm1,[esp+4],3
    
    or byte [esp-1],0xff
    vpbroadcastb xmm2,[esp-1]
    xorps xmm0,xmm2 ; ~a ~(~a|~b)
    xorps xmm1,xmm2 ; ~b
    orps xmm1,xmm0 ; a | b
    add esp,8
    xorps xmm1,xmm2 ; ~r
    pextrd dword dst,xmm1,3

}

macro mnot32 operandr_m
{

    push dword operandr_m
    or byte [esp-1],0xff
    vpbroadcastb xmm0,[esp-1]
    pinsrd xmm1,[esp],2
    xorpd xmm0,xmm1
    pextrd dword operandr_m,xmm0,3
    add esp,4

}

macro madd32 dst,src
{

;    push dword src
;    push dword dst

;    pinsrd xmm0,[esp],3
;    pinsrd xmm0,[esp+4],2
    
;    vpbroadcastd xmm1,[esp+4]
    
;    phaddd xmm0,xmm1
;    pextrd [esp],xmm0,1
    
;    pop dword dst

    push dword src
    push dword dst

    push ebx
    
;decrypt_instr1:    
    
    or ebx,1
    push eax
    xor eax,eax
    and ebx,1
    push edx
    or edx,2
    and edx,2
    push ecx
    or ecx,3
    and ecx,3
    
    pinsrd xmm1,eax,0
    pinsrd xmm1,ebx,1
    pinsrd xmm1,edx,2
    pinsrd xmm1,ecx,3
    
    push 0x80000000
    vpbroadcastd xmm2,[esp]
    add esp,4
    push 0x80030201
    push 0x00060504
    xchg ch,cl
    pinsrb xmm2,ecx,3
    pinsrb xmm2,ecx,7
    movq xmm3,[esp]
    add esp,8
    shufps xmm2,xmm2,00011110b
    movupd xmm6,xmm2
    vpgatherdd xmm0,[addr1+xmm1*4],xmm2
    or al,0x22
    push 0x00010203
    push 0x04050607
    movq xmm5,[esp]
    add esp,8
    
    pshufb xmm0,xmm5 
    
    psrlq xmm0,8
    pshufb xmm0,xmm3
    psllq xmm0,8  
    pinsrb xmm0,eax,0x00      
    movdqu xmm2,xmm6
    pshufb xmm0,xmm5
    movq [addr1],xmm0
    
     
    
;decrypt_instr2:

    and byte [addr2+6],0x0f
    
    vpgatherdd xmm0,[addr2+xmm1*4],xmm2    
    pshufb xmm0,xmm5
    psrlq xmm0,8
    inc bl
    push 0x02000106
    and al,0x58
    push 0x05040380
    movq xmm3,[esp]
    add  esp,8
    pshufb xmm0,xmm3
    pinsrb xmm0,ebx,0
    pshufb xmm0,xmm5
    movq [addr2],xmm0
     
;decrypt_instr3:

    or byte [addr3+4],0xc4
    movdqu xmm2,xmm6
    and byte [addr3+4],0xc4
    vpgatherdd xmm0,[addr3+xmm1*4],xmm2
    
    push 0x02010006          
    push 0x05040380
    movq xmm3,[esp] 
    add esp,8   
    
    pshufb xmm0,xmm5
    psrlq xmm0,8
    pshufb xmm0,xmm3
    pinsrb xmm0,ebx,0
    pshufb xmm0,xmm5
    movq [addr3],xmm0
    
;decrypt_instr4:

    movd xmm0,[addr4]
    psllq xmm0,8
    pinsrb xmm0,[addr4+4],0
    pshufb xmm0,xmm5
    push 0x80808001
    psrlq xmm0,24
    push 0x04000302    
    movq xmm3,[esp]
    add esp,8
    pshufb xmm0,xmm3
    pshufb xmm0,xmm5
    psrlq xmm0,24
    movd [addr4],xmm0
    psrlq xmm0,32
    pextrb [addr4+4],xmm0,0
    
;decrypt_instr5:

    ror byte [addr5],4
    movq xmm0,[addr5]
    xor al,al
    pshufb xmm0,xmm5
    psrlq xmm0,8
    push 0x80020605
    push 0x04030100
    movq xmm3,[esp]
    add esp,8
    pop ecx
    pshufb xmm0,xmm3
    psllq xmm0,8
    pop edx
    pinsrb xmm0,[addr5+7],0
    pshufb xmm0,xmm5
    pop ebx
    movq [addr5],xmm0        
    pop eax
addr1: db 0x04, 0x24, 0x03, 0x66, 0x0F, 0x3A, 0x22 ; pinsrd xmm0,DWORD PTR [esp],0x3 
addr2: db 0x22, 0x44, 0x24, 0x04, 0x66, 0x3A, 0xFF,0x02 ; pinsrd xmm0,DWORD PTR [esp+0x4],0x2
addr3: db 0x58, 0x4C, 0x24, 0x04, 0x44, 0xE2, 0x79 ; vpbroadcastd xmm1,DWORD PTR [esp+0x4]
addr4: db 0x02, 0xC1, 0x66, 0x38, 0x0F ; phaddd xmm0,xmm1 
addr5: db 0xF0, 0x3A, 0x16, 0x04, 0x66, 0x24, 0x01 ; pextrd DWORD PTR [esp],xmm0,0x1 

    pop dword dst
    add esp,4
;encrypted_instr5:    

    ror byte [addr5+1],4
    push edx    
    movq xmm0,[addr5]
    push eax
    pshufb xmm0,xmm5
    push ebx
    psrlq xmm0,8
    push ecx
    push 0x80050403
    push 0x02060100
    movq xmm3,[esp]
    add esp,8
    pshufb xmm0,xmm3
    psllq xmm0,8
    pinsrb xmm0,[addr5+7],0
    pshufb xmm0,xmm5
    movq [addr5],xmm0    
 
;encrypted_instr4:

    movq xmm0,[addr4]
    push 0x80808001
    pshufb xmm0,xmm5
    push 0x00040203
    psrlq xmm0,24
    movq xmm3,[esp]
    add esp,8
    pshufb xmm0,xmm3
    psllq xmm0,24
    pinsrb xmm0,[addr4+5],2
    pinsrb xmm0,[addr4+6],1
    pinsrb xmm0,[addr4+7],0
    pshufb xmm0,xmm5
    movq [addr4],xmm0

;encrypted_instr3:

    movq xmm0,[addr3]
    pshufb xmm0,xmm5
    psrlq xmm0,8
    
    push 0x80030201
    push 0x00060504
    movq xmm3,[esp]
    add esp,7
    
    pshufb xmm0,xmm3
    mov byte [esp],0x44
    pinsrb xmm0,[esp],2
    psllq xmm0,8
    pinsrb xmm0,[addr3+7],0
    pshufb xmm0,xmm5
    movq [addr3],xmm0
    inc esp

;encrypted_instr2:
    
    movdqu xmm2,xmm6
    and eax,0
    pinsrd xmm1,eax,0
    inc eax
    pinsrd xmm1,eax,1
    vpgatherdd xmm0,[addr2+xmm1*4],xmm6
    pshufb xmm0,xmm5
    dec esp
    pextrb [esp],xmm0,0
    push 0x80030201
    push 0x00060405
    movq xmm3,[esp]
    add esp,8
    pinsrb xmm7,[esp],0
    psrlq xmm0,8
    pshufb xmm0,xmm3
    or al,0xff
    pinsrb xmm0,eax,0
    psllq xmm0,8
    pextrb [esp],xmm7,0
    xorpd xmm7,xmm7
    pinsrb xmm0,[esp],0
    pshufb xmm0,xmm5
    movq [addr2],xmm0
    inc esp
    
;encrypted_instr1:

    movq xmm0,[addr1]
    pshufb xmm0,xmm5
    psrlq xmm0,8
    push 0x80020100
    push 0x06050403
    movq xmm3,[esp]
    add esp,8
    pshufb xmm0,xmm3
    pop ecx
    psllq xmm0,8
    pop ebx
    pinsrb xmm0,[addr1+7],0
    pop eax
    pshufb xmm0,xmm5
    movq [addr1],xmm0
    pop edx            
    
  
;04 24 03 ror 66 0f 3a 22 ; pinsrd xmm0,DWORD PTR [esp],0x3
;22 44 24 04 ror 66 (3a ror (ff and 0x0f)) ; pinsrd xmm0,DWORD PTR [esp+0x4],0x2
;58 4c 24 04 ror ((c4 <- 44)  e2 79) ; vpbroadcastd xmm1,DWORD PTR [esp+0x4]
;( 02 c1 66 (38 0f rol 8) rol 16) ; phaddd xmm0,xmm1
;(f0 ror 4) 3a 16 04 66 24 01 pshufb 02060504030100 ; pextrd DWORD PTR [esp],xmm0,0x1    
        
;
}


macro mjz addr
{

   jz addr 

}
macro mjmp addr
{jmp addr}
macro mlodsb
{
    push ecx
    movzx ecx,byte [esi]
    pinsrb xmm0,ecx,0
    pop ecx
    shufps xmm0,xmm0,00110110b
    pextrb eax,xmm0,12
    
}
macro mlodsd
{
    pinsrd xmm4,[esi],1
    shufps xmm4,xmm4,11000110b
    pblendw xmm4,xmm5,01001101b
    pextrd eax,xmm4,2
}
macro mpush32 operandr_m 
{
    dec esp
    add ecx,5
    dec esp
    xor edx,ecx
    dec esp
    xor edx,ecx
    sub ecx,5
    dec esp
    or dword [esp],dword operandr_m
    and dword [esp],dword operandr_m
}
macro mjnz addr 
{jnz addr}
macro mand8 dst,src
{and byte dst,src}
macro mcall addr 
{
    call addr
}
macro mor32 dst,src
{or dword dst,dword src}
macro mret
{retn}
macro mlea dst,src
{
    mpush32 src
    shld dst,src,31
    ror dword [esp],1
    add esp,4
    shld dst,src,1

}
macro mshl32 dst,src
{shl dword dst,src}
macro mcld
{cld}
macro restore_context_vm rmem
{

    mov ebx,rmem
    fxrstor [ebx]
    popfd
    popad
    
    
}

macro save_context_vm rmem ; register operand
{
    push ebx
    mov ebx,rmem
    and ebx,0xffffff00
    fxsave [ebx]
    pop ebx
    pushad
    pushfd
    finit
    vzeroall
    
}

macro mutation_cmpzc32 dst,src ; src reg or mem dst src or reg
{

    push edi

    push dword src

    xorpd xmm0,xmm0
    xorpd xmm1,xmm1
    movd xmm0,[esp]
    movd xmm1,dst
    
    psubd xmm1,xmm0
    
    movd edi,xmm1
    add esp,8
    or edi,0
    
    
}