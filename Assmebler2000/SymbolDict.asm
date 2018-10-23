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
	invoke initNode, trieAllocator
	add trieAllocator, type dword
	assume eax: ptr TrieNode
	invoke getOrCreateTrieItem, addr dot_data
	mov [eax].nodeType, TRIE_DIRECTIVE
	mov [eax].nodeVal, DOTDATA

	; add regs
	invoke getOrCreateTrieItem, addr reg_eax
	mov [eax].nodeType, TRIE_REG
	mov [eax].nodeVal, 0
	invoke getOrCreateTrieItem, addr reg_ecx
	mov [eax].nodeType, TRIE_REG
	mov [eax].nodeVal, 1
	invoke getOrCreateTrieItem, addr reg_edx
	mov [eax].nodeType, TRIE_REG
	mov [eax].nodeVal, 2
	invoke getOrCreateTrieItem, addr reg_ebx
	mov [eax].nodeType, TRIE_REG
	mov [eax].nodeVal, 3
	invoke getOrCreateTrieItem, addr reg_esp
	mov [eax].nodeType, TRIE_REG
	mov [eax].nodeVal, 4
	invoke getOrCreateTrieItem, addr reg_ebp
	mov [eax].nodeType, TRIE_REG
	mov [eax].nodeVal, 5
	invoke getOrCreateTrieItem, addr reg_esi
	mov [eax].nodeType, TRIE_REG
	mov [eax].nodeVal, 6
	invoke getOrCreateTrieItem, addr reg_edi
	mov [eax].nodeType, TRIE_REG
	mov [eax].nodeVal, 7

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
			invoke initNode, trieAllocator
			mov ecx, trieAllocator
			mov [ebx + eax * type dword], ecx
			add trieAllocator, type dword
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