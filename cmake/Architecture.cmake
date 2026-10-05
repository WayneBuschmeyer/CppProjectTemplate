# The template defaults to 64-bit builds without assuming x86-64 specifically.
# ARM64 and other 64-bit targets remain valid.
function(projectTemplateVerifyArchitecture)
    if(NOT PROJECT_TEMPLATE_REQUIRE_64_BIT)
        return()
    endif()

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        return()
    endif()

    message(
        FATAL_ERROR
        "This project requires a 64-bit target, but CMake configured a 32-bit "
        "toolchain."
    )
endfunction()
