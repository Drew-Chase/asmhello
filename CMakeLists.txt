cmake_minimum_required(VERSION 3.20)
project(asmhello C ASM_NASM)

set(CMAKE_ASM_NASM_OBJECT_FORMAT win64)
set(CMAKE_C_STANDARD_LIBRARIES "")
add_executable(asmhello main.asm)
set_target_properties(asmhello PROPERTIES LINKER_LANGUAGE C)

if (CMAKE_BUILD_TYPE STREQUAL "Release")
    target_link_options(asmhello PRIVATE
            /SUBSYSTEM:CONSOLE
            /ENTRY:main
            /NODEFAULTLIB
            /DEBUG:NONE         # no debug .pdf file pointer
            /INCREMENTAL:NO     # no padding for incremental relinks
            /DYNAMICBASE:NO     # opt out of ASLR...
            /FIXED              # removes the .reloc section
            /MERGE:.rdata=.text # imports + readonly data is moved into the code section
            /MERGE:.data=.text # imports + readonly data is moved into the code section
            /ALIGN:16           # aligns the memory to 16 bytes instead of 512 default
            /FILEALIGN:16       # aligns the file to 16 bytes instead of 512 bytes
            /MANIFEST:NO        # Removes the manifest file.
            /EMITTOOLVERSIONINFO:NO
            /NOVCFEATURE
            /NOCOFFGRPINFO
    )
else ()
    target_link_options(asmhello PRIVATE
            /SUBSYSTEM:CONSOLE
            /ENTRY:main
            /NODEFAULTLIB
    )
endif ()