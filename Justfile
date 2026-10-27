set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]
set shell := ["bash", "-cu"]

# ---- Settings (override with env vars, e.g. BUILD_TYPE=Debug just build) ----

target     := "asmhello"
build_type := env_var_or_default("BUILD_TYPE", "Release")
build_dir  := "bin/obj/" + lowercase(build_type)
exe        := if os_family() == "windows" { target + ".exe" } else { target }

# NASM: full path on Windows (not always on PATH), plain name elsewhere
nasm := env_var_or_default("NASM", if os_family() == "windows" {
    "C:/Users/drew.chase/AppData/Local/bin/NASM/nasm.exe"
} else {
    "nasm"
})

# MSVC tools folder (Windows only), so CMake uses link.exe instead of a MinGW ld
msvc_bin := env_var_or_default("MSVC_BIN", "C:/Program Files (x86)/Microsoft Visual Studio/18/BuildTools/VC/Tools/MSVC/14.50.35717/bin/Hostx64/x64")

platform_flags := if os_family() == "windows" { "'-DCMAKE_LINKER=" + msvc_bin + "/link.exe'" } else { "" }

# ---- Recipes ----

[private]
@default:
    just --list

# Generate the CMake build files
configure:
    @echo "Configuring {{build_type}} build in {{build_dir}}"
    @cmake -G Ninja -DCMAKE_BUILD_TYPE={{build_type}} '-DCMAKE_ASM_NASM_COMPILER={{nasm}}' {{platform_flags}} -S . -B {{build_dir}}

# Build the binary and print its size
build: configure && size
    @echo "Building {{exe}}"
    @cmake --build {{build_dir}}

# Build, then run the binary and show its exit code
run: build && _run

# Delete all build output
clean:
    @cmake -E rm -rf bin

[windows]
[doc('Print the size of the built binary')]
size:
    @echo "Binary size: $((Get-Item '{{build_dir}}/{{exe}}').Length) bytes"

[unix]
[doc('Print the size of the built binary')]
size:
    @echo "Binary size: $(wc -c < '{{build_dir}}/{{exe}}') bytes"

[windows]
_run:
    @& '{{build_dir}}/{{exe}}'; echo "Exit code: $LASTEXITCODE"

[unix]
_run:
    @'{{build_dir}}/{{exe}}' && echo "Exit code: 0" || echo "Exit code: $?"
