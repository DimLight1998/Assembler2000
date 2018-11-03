Remove-Item -Path "*.obj" -ErrorAction SilentlyContinue;
Remove-Item -Path "*.exe" -ErrorAction SilentlyContinue;
Remove-Item -Path "*.out" -ErrorAction SilentlyContinue;
G:\masm32\bin\ml.exe /c /Zd /coff "Test.asm" "EncoderUtils.asm" "Testing.asm";
G:\masm32\bin\link.exe /SUBSYSTEM:CONSOLE "Test.obj" "EncoderUtils.obj" "Testing.obj";

# run
./Test.exe;
Format-Hex .\EC043F61423846589CCD3FB4A9ED58AD.out;