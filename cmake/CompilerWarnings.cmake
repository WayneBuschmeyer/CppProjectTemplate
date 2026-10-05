# Warning syntax is selected by compiler identity and frontend style. clang-cl
# is Clang, but it accepts MSVC-style driver options.
function(projectTemplateSetCompilerWarnings targetName)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        target_compile_options(
            ${targetName}
            PRIVATE
                /W4
        )
    elseif(
        CMAKE_CXX_COMPILER_ID MATCHES "Clang"
        AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"
    )
        target_compile_options(
            ${targetName}
            PRIVATE
                /W4
                -Wshadow
                -Wconversion
                -Wsign-conversion
        )
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(
            ${targetName}
            PRIVATE
                -Wall
                -Wextra
                -Wpedantic
                -Wshadow
                -Wconversion
                -Wsign-conversion
                -Wnon-virtual-dtor
                -Wold-style-cast
                -Woverloaded-virtual
                -Wformat=2
        )
    else()
        message(
            WARNING
            "No curated warning policy exists for ${CMAKE_CXX_COMPILER_ID}."
        )
    endif()

    if(NOT PROJECT_TEMPLATE_WARNINGS_AS_ERRORS)
        return()
    endif()

    set_property(
        TARGET ${targetName}
        PROPERTY COMPILE_WARNING_AS_ERROR ON
    )

    get_target_property(targetType ${targetName} TYPE)

    if(targetType MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
        set_property(
            TARGET ${targetName}
            PROPERTY LINK_WARNING_AS_ERROR ON
        )
    endif()
endfunction()
