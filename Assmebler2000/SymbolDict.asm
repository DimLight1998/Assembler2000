include common.inc
include SymbolDict.inc

.data?
	trieNodes TrieNode MaxTrieNodeCount dup(<>)
	trieAllocator dword ?
.data
	dot_data byte ".data", 0
	dot_text byte ".text", 0
	dot_byte byte ".byte", 0
	dot_int byte ".int", 0
	dot_long byte ".long", 0
	dot_ascii byte ".ascii", 0
	dot_asciz byte ".asciz", 0
	dot_set byte ".set", 0
	dot_equ byte ".equ", 0
	; dot_align byte ".align", 0
	dot_import byte ".import", 0
	ins_addl byte "addl", 0
	ins_subl byte "subl", 0
	ins_movl byte "movl", 0
	ins_pushl byte "pushl", 0
	ins_popl byte "popl", 0
	ins_orl byte "orl", 0
	ins_andl byte "andl", 0
	ins_xorl byte "xorl", 0
	ins_notl byte "notl", 0
	ins_cmpl byte "cmpl", 0
	ins_testl byte "testl", 0
	ins_loop byte "loop", 0
	ins_call byte "call", 0
	ins_ret byte "ret", 0
	ins_jmp byte "jmp", 0
	ins_jz byte "jz", 0
	ins_incl byte "incl", 0
	ins_decl byte "decl", 0
	ins_negl byte "negl", 0
	ins_leal byte "leal", 0
	reg_eax byte "eax", 0
	reg_ecx byte "ecx", 0
	reg_edx byte "edx", 0
	reg_ebx byte "ebx", 0
	reg_esp byte "esp", 0
	reg_ebp byte "ebp", 0
	reg_esi byte "esi", 0
	reg_edi byte "edi", 0
.code

initNode proc uses eax edi ecx, nodeAddr: ptr TrieNode
	mov al, 0
	mov edi, nodeAddr
	mov ecx, type TrieNode
	cld
	rep stosb
	ret
initNode endp

dictPreprocess proc
	mov trieAllocator, offset trieNodes
	;invoke initNode, trieAllocator
	add trieAllocator, type TrieNode ; prevbug: type dword
	assume eax: ptr TrieNode

	; add regs
	addSymbol reg_eax, TRIE_REG, 0
	addSymbol reg_ecx, TRIE_REG, 1
	addSymbol reg_edx, TRIE_REG, 2
	addSymbol reg_ebx, TRIE_REG, 3
	addSymbol reg_esp, TRIE_REG, 4
	addSymbol reg_ebp, TRIE_REG, 5
	addSymbol reg_esi, TRIE_REG, 6
	addSymbol reg_edi, TRIE_REG, 7

	; add directives
	addSymbol dot_data, TRIE_DIRECTIVE, DOTDATA
	addSymbol dot_text, TRIE_DIRECTIVE, DOTTEXT
	addSymbol dot_byte, TRIE_DIRECTIVE, DOTBYTE
	addSymbol dot_int, TRIE_DIRECTIVE, DOTINT
	addSymbol dot_long, TRIE_DIRECTIVE, DOTLONG
	addSymbol dot_ascii, TRIE_DIRECTIVE, DOTASCII
	addSymbol dot_asciz, TRIE_DIRECTIVE, DOTASCIZ
	addSymbol dot_set, TRIE_DIRECTIVE, DOTSET
	addSymbol dot_equ, TRIE_DIRECTIVE, DOTEQU
	addSymbol dot_import, TRIE_DIRECTIVE, DOTIMPORT

	; add instructions
	addSymbol ins_addl , TRIE_INST, INSADDL 
	addSymbol ins_subl , TRIE_INST, INSSUBL 
	addSymbol ins_movl , TRIE_INST, INSMOVL 
	addSymbol ins_pushl, TRIE_INST, INSPUSHL
	addSymbol ins_popl , TRIE_INST, INSPOPL 
	addSymbol ins_orl  , TRIE_INST, INSORL 
	addSymbol ins_andl , TRIE_INST, INSANDL 
	addSymbol ins_xorl , TRIE_INST, INSXORL 
	addSymbol ins_notl , TRIE_INST, INSNOTL 
	addSymbol ins_cmpl , TRIE_INST, INSCMPL 
	addSymbol ins_testl, TRIE_INST, INSTESTL
	addSymbol ins_loop , TRIE_INST, INSLOOP 
	addSymbol ins_call , TRIE_INST, INSCALL 
	addSymbol ins_ret  , TRIE_INST, INSRET 
	addSymbol ins_jmp  , TRIE_INST, INSJMP 
	addSymbol ins_jz   , TRIE_INST, INSJZ  
	addSymbol ins_incl , TRIE_INST, INSINCL 
	addSymbol ins_decl , TRIE_INST, INSDECL 
	addSymbol ins_negl , TRIE_INST, INSNEGL 
	addSymbol ins_leal , TRIE_INST, INSLEAL 

	assume eax: nothing
	ret
dictPreprocess endp

getTrieItem proc uses esi edx ebx, strAddr: dword
	mov edx, offset trieNodes
	assume edx: ptr TrieNode
	mov esi, strAddr
	assume esi: ptr byte
	.while 1
		movsx eax, [esi]
		.if !eax
			.break
		.endif
		lea ebx, [edx].nodeChildren
		.if ! dword ptr [ebx + eax * type dword]
			mov eax, 0 ; do not find
			ret
		.endif
		mov edx, [ebx + eax * type dword]
		inc esi
	.endw
	mov eax, edx
	assume esi: nothing
	assume edx: nothing
	ret
getTrieItem endp

getOrCreateTrieItem proc uses esi edx ebx ecx, strAddr: dword
	mov edx, offset trieNodes
	assume edx: ptr TrieNode
	mov esi, strAddr
	assume esi: ptr byte
	.while 1
		movsx eax, [esi]
		.if !eax
			.break
		.endif
		lea ebx, [edx].nodeChildren
		.if ! dword ptr [ebx + eax * type dword]
			;invoke initNode, trieAllocator
			mov ecx, trieAllocator
			mov [ebx + eax * type dword], ecx
			add trieAllocator, type TrieNode ; prevbug: type dword
		.endif
		mov edx, [ebx + eax * type dword]
		inc esi
	.endw
	mov eax, edx
	assume esi: nothing
	assume edx: nothing
	ret
getOrCreateTrieItem endp

isReg proc uses ebx, strAddr: dword
	invoke getTrieItem, strAddr
	.if eax == 0
		mov eax, 0
		ret
	.endif
	mov bl, (TrieNode ptr [eax]).nodeType
	.if bl == TRIE_REG
		mov eax, 1
	.else
		mov eax, 0
	.endif
	ret
isReg endp

end