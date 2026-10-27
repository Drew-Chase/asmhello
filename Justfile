set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile","-Command"]
set shell := ["bash", "-c"]

default:
    just --list

[windows]
build:
    @Write-Host "Generating Objects"
    @cmake -G Ninja -DCMAKE_BUILD_TYPE=Release '-DCMAKE_ASM_MASM_COMPILER=C:/Program Files (x86)/Microsoft Visual Studio/18/BuildTools/VC/Tools/MSVC/14.50.35717/bin/Hostx64/x64/ml64.exe' '-DCMAKE_LINKER=C:/Program Files (x86)/Microsoft Visual Studio/18/BuildTools/VC/Tools/MSVC/14.50.35717/bin/Hostx64/x64/link.exe' -S . -B bin/obj/release
    @Write-Host "Building Binary from Objects"
    @cmake --build bin/obj/release
    @Write-Host "Binary size: $((Get-Item 'bin/obj/release/asmhello.exe').Length) bytes"

[linux]
build:
    @echo "Nothing Yet!"
