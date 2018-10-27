param([string]$FileNameNoExt);
if ($FileNameNoExt -eq "") {
    Write-Host "No file name given!";
    exit;
}

Remove-Item -Path "$FileNameNoExt.obj" -ErrorAction SilentlyContinue;
Remove-Item -Path "$FileNameNoExt.exe" -ErrorAction SilentlyContinue;
G:\masm32\bin\ml.exe /c /Zd /coff "$FileNameNoExt.asm";
G:\masm32\bin\link.exe /SUBSYSTEM:CONSOLE "$FileNameNoExt.obj";