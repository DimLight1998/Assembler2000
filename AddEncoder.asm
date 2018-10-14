.386
.model flat, stdcall
option casemap:none


AddMemReg proc uses eax ebx ecx edx esi edi,
    memBase: ptr byte, memScale: dword, memIndex: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte


    ret
AddMemReg endp


AddRegReg proc uses eax ebx ecx edx esi edi,
    memBase: ptr byte, memScale: dword, memIndex: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    
    ret
AddRegReg endp


AddRegMem proc uses eax ebx ecx edx esi edi,
    memBase: ptr byte, memScale: dword, memIndex: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    
    ret
AddRegMem endp


AddRegImm proc uses eax ebx ecx edx esi edi,
    memBase: ptr byte, memScale: dword, memIndex: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    
    ret
AddRegImm endp


AddMemImm proc uses eax ebx ecx edx esi edi,
    memBase: ptr byte, memScale: dword, memIndex: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    
    ret
AddMemImm endp