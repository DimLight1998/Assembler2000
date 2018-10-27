# 开发专用文档

## 计划实现的指令

- [x] ADD
- [x] SUB
- [x] MOV
- [x] PUSH
- [x] POP
- [x] OR
- [x] AND
- [x] XOR
- [x] NOT
- [x] CMP
- [x] TEST
- ~~LOOP~~
- [x] CALL
- [x] RETN
- [ ] JMP
- [ ] JZ
- [x] INC
- [x] DEC
- [x] NEG
- [x] LEA

## 编码指令开发流程

1. 将同一个指令的编码函数放到 `<operationName>Encoder.asm` 文件下，例如 `AddEncoder.asm`。
2. 使用 `masm.json` 中的代码片段作为函数的原型，将所有函数统一起来。
3. 函数的命名方式参见 `AddEncoder.asm`。

## 对于寄存器的编号

在每个编码函数中有两个参数 `sourceReg` 和 `destinationReg`。它们表示的是具体是哪个寄存器。

编号方式：

- `EAX`：0
- `ECX`：1
- `EDX`：2
- `EBX`：3
- `ESP`：4
- `EBP`：5
- `ESI`：6
- `EDI`：7
- N/A：4294967295

## 语法限制

- `push` 指令对寄存器只支持 eax/ebx/ecx/edx/esi/edi/esp/ebp。
- `pop` 指令对寄存器只支持 eax/ebx/ecx/edx/esi/edi/esp/ebp。