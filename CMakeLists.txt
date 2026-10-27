cmake_minimum_required(VERSION 3.20)
project(asmhello C ASM_NASM)

# C is only enabled so CMake links through the platform's normal toolchain
# (link.exe on Windows, gcc -> ld on Linux). We never compile any C.
set(CMAKE_C_STANDARD_LIBRARIES "")

if (WIN32)
    set(CMAKE_ASM_NASM_OBJECT_FORMAT win64)
else ()
    set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
endif ()

add_executable(asmhello main.asm)
set_target_properties(asmhello PROPERTIES LINKER_LANGUAGE C)

# Let main.asm find os/*.inc no matter which build folder NASM runs from
target_include_directories(asmhello PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

if (WIN32)
    # ---------------- Windows (MSVC link.exe) ----------------
    target_link_options(asmhello PRIVATE
            /SUBSYSTEM:CONSOLE      # console app
            /ENTRY:main             # our own entry point, no CRT startup
            /NODEFAULTLIB           # don't pull in the C runtime
    )

    if (CMAKE_BUILD_TYPE STREQUAL "Release")
        target_link_options(asmhello PRIVATE
                /DEBUG:NONE             # no debug directory / .pdb pointer
                /INCREMENTAL:NO         # no padding for incremental relinks
                /DYNAMICBASE:NO         # opt out of ASLR...
                /FIXED                  # ...so no .reloc section is needed
                /ALIGN:16               # section alignment in memory (default 4096)
                /FILEALIGN:16           # section alignment on disk (default 512)
                /MANIFEST:NO            # no embedded manifest / .rsrc section
                /EMITTOOLVERSIONINFO:NO # no Rich header (undocumented)
                /NOVCFEATURE            # no VC feature debug record (undocumented)
                /NOCOFFGRPINFO          # no POGO debug record (undocumented)
        )
    endif ()
else ()
    # ---------------- Linux (gcc as the link driver -> ld) ----------------
    target_link_options(asmhello PRIVATE
            -nostdlib               # no libc, no crt startup files: _start is ours
            -static                 # no dynamic loader / interpreter
            -Wl,--build-id=none     # no .note.gnu.build-id section
    )

    if (CMAKE_BUILD_TYPE STREQUAL "Release")
        target_link_options(asmhello PRIVATE
                -s                  # strip the symbol table
                -Wl,-n              # don't page-align sections (like /FILEALIGN)
        )
    else ()
        # Debug: emit DWARF so gdb can step through the source
        target_compile_options(asmhello PRIVATE -g -F dwarf)
    endif ()
endif ()