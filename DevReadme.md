# 开发专用文档

## 计划实现的指令

- [ ] ADD
- [ ] SUB
- [ ] MOV
- [ ] PUSH
- [ ] POP
- [ ] OR
- [ ] AND
- [ ] XOR
- [ ] NOT
- [ ] CMP
- [ ] TEST
- [ ] LOOP
- [ ] CALL
- [ ] RET
- [ ] JMP
- [ ] JZ
- [ ] INC
- [ ] DEC
- [ ] NEG
- [ ] LEA

## 编码指令开发流程

1. 将同一个指令的编码函数放到 `<operationName>Encoder.asm` 文件下，例如 `AddEncoder.asm`。
2. 使用 `masm.json` 中的代码片段作为函数的原型，将所有函数统一起来。
3. 函数的命名方式常见 `AddEncoder.json`。