format PE

use32

include 'C:\fasm\include\win32a.inc'

section '.bss' writable readable

    mem rd 20000000

section '.text' data readable executable writeable

entry _start

macro mutation_mov1 src,dst,counter,d,e
{

	push ecx
	mov ecx,counter 

	and counter,0

	and d,0
	inc d

	and e,0
	not e
	btr e,0
.lp:
	bt src,counter
	jnc .no1

	or dst,d
	jmp short .end_lp

.no1:
	
	and dst,e

.end_lp:
      shl d,1
	inc counter
	rol e,1

	loop .lp

	pop ecx

}

macro mutation_mov1_dup2 src,dst,counter,d,e
{

	push ecx
	mov ecx,counter 

	and counter,0

	and d,0
	inc d

	and e,0
	not e
	btr e,0
.lopp:
	bt src,counter
	jnc .no1_

	or dst,d
	jmp short .end_lopp

.no1_:
	
	and dst,e

.end_lopp:
      shl d,1
	inc counter
	rol e,1

	loop .lopp

	pop ecx

}


macro mutation_mov2_32 src,dst,tmp1_mem_size8,tmp2_mem_size8
{

	movq tmp2_mem_size8,xmm1
	shufps xmm1,xmm1,01001110b
	movq tmp2_mem_size8,xmm1
	push dword src
	movd xmm1,[esp]
      add esp,4
	movd dst,xmm1
	push dword tmp1_mem_size8
	push dword tmp2_mem_size8
	movdqu xmm1,[esp]
	pop dword tmp2_mem_size8
	pop dword tmp1_mem_size8

}

macro mutation_mov3_16 src,dst,tmp1_mem_size8,tmp2_mem_size8,temp_size16
{
     	pushad
      or dx,word src
      and dx,word src
	ror dx,8
      mov [esp-2],dx
	movq qword tmp1_mem_size8,xmm2
      shufps xmm2,xmm2,01001110b
	movupd temp_size16,xmm3
      movq qword tmp1_mem_size8,xmm2
	vpbroadcastw xmm2,[esp-2]
	and ecx,1
	bts cx,0
	movd xmm3,ecx
	pshufb xmm2,xmm3
	vpbroadcastq xmm3,qword tmp2_mem_size8
	shufps xmm3,xmm3,01001111b
      movq xmm3,qword tmp2_mem_size8
      movd dword [esp+4],xmm2
      popad
      mov dst,si 
	
}

macro mutation_mov4_8 src,dst
{
      push ebx
	pushad
	movzx eax,src
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
      mov dst,bl
      pop ebx
}

macro mutation_cmpzc32 src,dst ; src reg or mem dst src or reg
{

    push edi

    movd xmm0,src
    movd xmm1,dst
    
    psubd xmm1,xmm0
    
    movd edi,xmm1
    or edi,0
    pop edi
    
}

macro mutation_add32 src,dst ; src and dst is reg operands
{

    movbe [esp-8],src
    bswap dst
    movd xmm0,[esp-8]
    push dst
    movd xmm1,[esp]
    or dword [esp-16],0x00010203
    and dword [esp-16],0x00010203
    movd xmm2,[esp-16] 
    pshufb xmm1,xmm2
    shufps xmm1,xmm1,11100001b
    pshufb xmm0,xmm2
    shufps xmm0,xmm0,11100001b
    paddd xmm0,xmm1
    shufps xmm0,xmm0,11100001b
    movd dst,xmm0

}

macro mutation_sub32 src,dst ; src and dst is reg operands
{

    movbe [esp-8],src
    bswap dst
    movd xmm0,[esp-8]
    push dst
    movd xmm1,[esp]
    or dword [esp-16],0x00010203
    and dword [esp-16],0x00010203
    movd xmm2,[esp-16] 
    pshufb xmm1,xmm2
    shufps xmm1,xmm1,11100001b
    pshufb xmm0,xmm2
    shufps xmm0,xmm0,11100001b
    psubd xmm0,xmm1
    shufps xmm0,xmm0,11100001b
    movd dst,xmm0

}

macro mutation_mul32 src,dst ; src and dst is reg operands
{

    movbe [esp-8],src
    bswap dst
    cvtsi2ss xmm0,[esp-8]
    push dst
    cvtsi2ss xmm1,[esp]
    or dword [esp-16],0x00010203
    and dword [esp-16],0x00010203
    movd xmm2,[esp-16] 
    pshufb xmm1,xmm2
    shufps xmm1,xmm1,11100001b
    pshufb xmm0,xmm2
    shufps xmm0,xmm0,11100001b
    mulps xmm0,xmm1
    shufps xmm0,xmm0,11100001b
    cvtss2si dst,xmm0

}

macro mutation_div32 src,dst ; src and dst is reg operands
{

    movbe [esp-8],src
    bswap dst
    cvtsi2ss xmm0,[esp-8]
    push dst
    cvtsi2ss xmm1,[esp]
    or dword [esp-16],0x00010203
    and dword [esp-16],0x00010203
    movd xmm2,[esp-16] 
    pshufb xmm1,xmm2
    shufps xmm1,xmm1,11100001b
    pshufb xmm0,xmm2
    shufps xmm0,xmm0,11100001b
    divps xmm0,xmm1
    shufps xmm0,xmm0,11100001b
    cvtss2si dst,xmm0

}

macro save_context_vm rmem ; register operand
{
    mov ebx,esp
    mov [rmem-65535],esp
    lea esp,[rmem-65535]
    add esp,4
    add esp,64
    pushad
    pushfd
    cld 
    mov esi,[rmem-65535]
    sub esi,255
    mov ecx,255+255
    mov edi,esp
    rep movsb
    shl edi,4 
    FXSAVE [edi]
    mov esp,ebx
}

macro restore_context_vm rmem
{

    mov esi,[rmem-65535]
    mov ebx,esi
    mov edi,esp
    mov ecx,255+255
    add esi,0x68
    rep movsb
    
    xchg ebx,esp
    add esp,68
    
    FXSTOR [edi]
    
    popfd
    popad

}

macro mutation_mov_imm32_append src,dst
{

    push src
.link:    vpbroadcastb xmm0,[esp]
    movups xmm1,xmm0
    vpbroadcastb xmm0,[esp+1]
    movups xmm2,xmm0
    vpbroadcastb xmm0,[esp+2]
    movups xmm3,xmm0
    vpbroadcastb xmm0,[esp+3]
    or dword [esp],0x80808001
    and dword [esp],0x80808001
    movd xmm4,[esp]
    pshufb xmm1,xmm4
    or dword [esp],0x80800080
    and dword [esp],0x80800080
    movd xmm4,[esp]    
    pshufb xmm2,xmm4
    or dword [esp],0x80008080
    and dword [esp],0x80008080
    pshufb xmm3,xmm4 
    or dword [esp],0x00808080
    and dword [esp],0x00808080
    pshufb xmm0,xmm4
    orps xmm1,xmm2
    orps xmm1,xmm3
    orps xmm1,xmm0
    movd dst,xmm1
    add esp,4

}

macro mutation_mov_imm32 src,dst ; dst is reg src imm32
{

    push src ; 0x0503d005
    vpbroadcastb xmm0,[esp]
    movups xmm1,xmm0
    vpbroadcastb xmm0,[esp+1]
    movups xmm2,xmm0
    vpbroadcastb xmm0,[esp+2]
    movups xmm3,xmm0
    vpbroadcastb xmm0,[esp+3]
    or dword [esp],0x80808001
    and dword [esp],0x80808001
    movd xmm4,[esp]
    pshufb xmm1,xmm4
    or dword [esp],0x80801080
    and dword [esp],0x80801080
    movd xmm4,[esp]    
    pshufb xmm2,xmm4
    or dword [esp],0x80108080
    and dword [esp],0x80108080
    movd xmm4,[esp] 
    pshufb xmm3,xmm4 
    or dword [esp],0x01808080
    and dword [esp],0x01808080
    movd xmm4,[esp]     
    pshufb xmm0,xmm4
    orps xmm1,xmm2
    orps xmm1,xmm3
    orps xmm1,xmm0
    movd dst,xmm1
    add esp,4

}  

macro obfuscation_call_ebx1 
{
vzeroall
push dword [$+127+3+4+5+3]
vpbroadcastb xmm0,[esp]
push dword 0xffffffff
vpbroadcastb xmm1,[esp]
xorps xmm1,xmm0
pblendw xmm1,xmm2,11111110b
mov dword [esp-100],0x40
movd xmm5,[esp-100]
addps xmm1,xmm5
and dword [esp],0x80010280
movd xmm2,[esp]
movd xmm0,[$+69+7+2+3]
pshufb xmm0,xmm2
or dword [esp],0x80808000
and dword [esp],0x80808000
ror dword [esp],8
movd xmm2,[esp]
pshufb xmm1,xmm2
orps xmm0,xmm1
mov dword [esp],0x00010203
movd xmm1,[esp]
add esp,12
pshufb xmm0,xmm1
movd [$+8+7+2],xmm0
mov word [$+11],0xe430 ; inc esp; inc esp
db 0x40,0xd3,0x01,0x46
}


macro obfuscation_call_ebx2
{
vzeroall
push dword [$+127+3+4+5+3]
vpbroadcastb xmm0,[esp]
push dword 0xffffffff
vpbroadcastb xmm1,[esp]
xorps xmm1,xmm0
pblendw xmm1,xmm2,11111110b
mov dword [esp-100],0x40
movd xmm5,[esp-100]
addps xmm1,xmm5
and dword [esp],0x80010280
movd xmm2,[esp]
movd xmm0,[$+69+7+2+3]
pshufb xmm0,xmm2
or dword [esp],0x80808000
and dword [esp],0x80808000
ror dword [esp],8
movd xmm2,[esp]
pshufb xmm1,xmm2
orps xmm0,xmm1
mov dword [esp],0x00010203
movd xmm1,[esp]
add esp,12
pshufb xmm0,xmm1
movd [$+8+7+2],xmm0
mov word [$+11],0x4646 ; inc esp; inc esp
db 0x40,0xd3,0x01,0x46
}

macro mutation_movzx_reg32_reg8 src,dst
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

macro mutation_movsx_reg32_reg8 src,dst
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
    or dword [esp],0xffffff00
    or dword [esp-2],0x00000001
    and dword [esp-2],0x00000001
    movd xmm3,[esp-2]
    pshufb xmm0,xmm3
    movd [esp],xmm0
    mov bx,[esp+4]
    bt dword [esp],7
    jnc short .continue
    or dword [esp],0xffffff00
.continue:    
    mov dst,[esp] 

}

macro append_ret link
{

    mutation_mov_imm32 link,ebx
    mutation_mov_imm32 0x000040c3,ecx
    mutation_mov2_32 ecx,[ebx],[esp+24],[esp+44]

}

macro mutation_mov4_8 src,dst
{
      push ebx
	pushad
	movzx eax,src
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
      mov dst,bl
      pop ebx
}

macro randomize 
{
    rdtsc
    xor eax,edx
    mutation_mov_imm32 1103515245,edx
    mutation_mul32 eax,edx
    mutation_mov_imm32 12345,esi
    mutation_add32 esi,edx
    mutation_mov_imm32 65536,eax
    mutation_div32 eax,edx
    mov esi,0x10000000
    mov eax,edx
    xor edx,edx
    div esi
 ; random number   
;randseed = randseed * 1103515245 + 12345
;randseed = (randseed / 65536) mod 0x100000000
;rndnum = randseed and 0xFFFFFFFF

}
_start:

load_peb_addr:
    mutation_mov_imm32_append 0x3024300c,eax
    or ebx,0x20
    and ebx,0x20
    mutation_mov1 eax,edx,ebx,ebp,esi
load_peb_value:   
    mutation_mov_imm32_append 0x45008b64,[esp]
    mutation_movzx_reg32_reg8 [esp],edx
load_EnabelDebug_addr:    
    mutation_mov_imm32_append 0x02044545,[esp+24] ; 
load_EnabelDebug_value:
    mutation_mov_imm32_append 0x18b60f46,[esp]
    
    append_ret load_peb_addr.link    
    mutation_mov2_32 ebx,[esp],[esp+8],[esp+16]     

    append_ret load_peb_value.link    
    mutation_mov2_32 ebx,[esp+4],[esp+16],[esp+24]    
    
    append_ret load_EnabelDebug_addr.link
    mutation_mov2_32 ebx,[esp+8 ],[esp+24],[esp+32]
    
    append_ret load_EnabelDebug_value.link
    mutation_mov2_32 ebx,[esp+16],[esp+24],[esp+32]
    
    mutation_mov_imm32 -4,ecx
    
call_obfuscat:
 
    mutation_mov2_32 [esp],ebx,[esp+24],[esp+24]      
    mutation_add32 ecx,ebx
    obfuscation_call_ebx1

    mutation_mov2_32 [esp+4],ebx,[esp+28],[esp+24]     
    mutation_add32 ecx,ebx
    obfuscation_call_ebx2

    mutation_mov2_32 [esp+8],ebx,[esp+82],[esp+26]
    mutation_add32 ecx,ebx
    obfuscation_call_ebx2

    mutation_mov2_32 [esp+16],ebx,[esp+28],[esp+26]
    mutation_add32 ecx,ebx
    obfuscation_call_ebx2

    mutation_mov_imm32 1,edx
    mutation_cmpzc32 edx,ebx
    jz exit_error

_load_peb_addr:
    mutation_mov_imm32_append 0x30b0c031,eax
    or ebx,0x20
    and ebx,0x20
    mutation_mov1 eax,edx,ebx,ebp,esi
_load_peb_value:   
    mutation_mov_imm32_append 0x90008b64,[esp]
    mutation_movzx_reg32_reg8 [esp],edx
load_processheap_value_addr:    
    mutation_mov_imm32_append 0x4518408b,[esp+24]
load_flags_value:
    mutation_mov_imm32_append 0x4540488b,[esp]
load_fastflags_value:
    mutation_mov_imm32_append 0x4544408b,[esp]    
append_ret_s:            
    append_ret _load_peb_addr.link    
    mutation_mov2_32 ebx,[esp],[esp+8],[esp+16]     

    append_ret _load_peb_value.link    
    mutation_mov2_32 ebx,[esp+4],[esp+16],[esp+24]    
    
    append_ret load_processheap_value_addr.link
    mutation_mov2_32 ebx,[esp+8],[esp+24],[esp+32]
    
    append_ret load_flags_value.link
    mutation_mov2_32 ebx,[esp+16],[esp+46],[esp+46]
    
    append_ret load_fastflags_value.link
    mutation_mov2_32 ebx,[esp+24],[esp+46],[esp+46]
    
    mutation_mov_imm32 -4,edx
    
_call_obfuscat:
 
    mutation_mov2_32 [esp],ebx,[esp+36],[esp+48]      
    mutation_add32 edx,ebx
    obfuscation_call_ebx1

    mutation_mov2_32 [esp+4],ebx,[esp+28],[esp+36]     
    mutation_add32 edx,ebx
    obfuscation_call_ebx2

    mutation_mov2_32 [esp+8],ebx,[esp+82],[esp+29]
    mutation_add32 edx,ebx
    obfuscation_call_ebx2

    mutation_mov2_32 [esp+16],ebx,[esp+28],[esp+29]
    mutation_add32 edx,ebx
    obfuscation_call_ebx2

    mutation_mov2_32 [esp+24],ebx,[esp+28],[esp+36]
    mutation_add32 edx,ebx
    obfuscation_call_ebx2

    and edx,0
    or ebx,edx
    and ebx,edx
    dec bl
    dec ebx
    neg bl
    
    mutation_cmpzc32 edx,eax
    jnz decrypt
    
    mutation_cmpzc32 ebx,ecx
    jnz decrypt
    


exit_error:

    and ecx,0x01
    or al,0x01 
    mutation_mov4_8 al,cl
.lp:
    randomize ; return value in edx
    or edx,0x20
    and edx,0x20
    mutation_mov1_dup2 edx,dword [edi+ecx*4],edx,esi,ebx
    
    mutation_mov_imm32 0x01,esi
    mutation_add32 esi,ecx
        
    jmp .lp        

continue:

        

;.chk1:
;    mov eax,[fs:0x30]
;    cmp byte [eax+0x02],0x01 ; BeingDebugger
;    jnz .chk2
;    jmp near .exit_error
;.chk2:
;    mov eax,[fs:0x30]    
;    cmp byte [eax+0x68],0x70 ; NtGlobalFlag
;    jnz .chk3
;    jmp near .exit_error
;.chk3:
;    mov eax, [fs:0x30]
;    mov eax, [eax+0x18]
;    mov ecx, [eax+0x40] ; Flags
;    mov eax, [eax+0x44] ; ForceFlags
;    test eax,eax
 ;   jnz .decrypt ; return (Flags == 2 && ForceFlags == 0) ? false : true;
;    cmp ecx,0x02
;    jnz .continue
;    jmp near .exit_error

;.exit_error:            
;    or ecx,0xffffffff
;    mov edi,esp
;    mov al,0x44
;    rep stosb
    
decrypt:
    invoke ExitProcess,0
    
section '.idata' import data readable executable

    library kernel32,'kernel32.dll'
    
    import kernel32,ExitProcess,'ExitProcess'
    
section '.reloc' fixups data readable discardable     