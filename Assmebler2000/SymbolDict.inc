MaxTrieNodeCount equ 1000
; todo trie node too many warning

TrieNode struct
	nodeType byte ?
	nodeChildren dword 128 dup(?)
	nodeVal dword ?
	nodeStr byte 20 dup(?)
	nodeName byte 20 dup(?)
TrieNode ends

TRIE_NULL equ 0
TRIE_VAR equ 1
TRIE_LABEL equ 2
TRIE_DIRECTIVE equ 3
TRIE_INST equ 4
TRIE_REG equ 5
TRIE_EXTERN equ 6

dictPreprocess proto
getTrieItem proto, strAddr: dword
getOrCreateTrieItem proto, strAddr: dword
isReg proto, strAddr: dword

DOTDATA equ 1
DOTTEXT equ 2
DOTBYTE equ 3
DOTINT equ 4
DOTLONG equ 5
DOTASCII equ 6
DOTASCIZ equ 7
DOTSET equ 8
DOTEQU equ 9
DOTALIGN equ 10
DOTIMPORT equ 11
INSADDL equ 12
INSSUBL equ 13
INSMOVL equ 14
INSPUSHL equ 15
INSPOPL equ 16
INSORL equ 17
INSANDL equ 18
INSXORL equ 19
INSNOTL equ 20
INSCMPL equ 21
INSTESTL equ 22
INSLOOP equ 23
INSCALL equ 24
INSRET equ 25
INSJMP equ 26
INSJZ  equ 27
INSINCL equ 28
INSDECL equ 29
INSNEGL equ 30
INSLEAL equ 31