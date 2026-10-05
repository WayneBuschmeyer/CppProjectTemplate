# AddressSanitizer requires a runtime DLL on Windows. Stage that runtime beside
# project executables so tests and applications do not depend on an IDE-specific
# PATH configuration when they start.
function(projectTemplateStageMsvcAsanRuntime targetName)
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        return()
    endif()

    get_target_property(targetType ${targetName} TYPE)

    if(NOT targetType STREQUAL "EXECUTABLE")
        return()
    endif()

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(asanArchitecture "x86_64")
    else()
        set(asanArchitecture "i386")
    endif()

    get_filename_component(
        compilerDirectory
        "${CMAKE_CXX_COMPILER}"
        DIRECTORY
    )

    set(
        asanRuntime
        "${compilerDirectory}/clang_rt.asan_dynamic-${asanArchitecture}.dll"
    )

    if(NOT EXISTS "${asanRuntime}")
        message(
            FATAL_ERROR
            "MSVC AddressSanitizer runtime was not found at "
            "${asanRuntime}. Install the C++ AddressSanitizer component "
            "with Visual Studio Installer."
        )
    endif()

    add_custom_command(
        TARGET ${targetName}
        POST_BUILD
        COMMAND
            "${CMAKE_COMMAND}"
            -E
            copy_if_different
            "${asanRuntime}"
            "$<TARGET_FILE_DIR:${targetName}>"
        COMMENT
            "Staging the MSVC AddressSanitizer runtime for ${targetName}"
        VERBATIM
    )
endfunction()

function(projectTemplateEnableSanitizers targetName)
    get_target_property(targetType ${targetName} TYPE)

    set(isMsvcFrontend FALSE)

    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        set(isMsvcFrontend TRUE)
    endif()

    if(PROJECT_TEMPLATE_ENABLE_ASAN)
        if(isMsvcFrontend)
            target_compile_options(
                ${targetName}
                PRIVATE
                    /fsanitize=address
            )

            if(targetType MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
                target_link_options(
                    ${targetName}
                    PRIVATE
                        /INCREMENTAL:NO
                )
            endif()

            projectTemplateStageMsvcAsanRuntime(${targetName})
        elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
            target_compile_options(
                ${targetName}
                PRIVATE
                    -fsanitize=address
                    -fno-omit-frame-pointer
            )

            if(targetType MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
                target_link_options(
                    ${targetName}
                    PRIVATE
                        -fsanitize=address
                )
            endif()
        else()
            message(
                FATAL_ERROR
                "AddressSanitizer is not configured for ${CMAKE_CXX_COMPILER_ID}."
            )
        endif()
    endif()

    if(PROJECT_TEMPLATE_ENABLE_UBSAN)
        if(isMsvcFrontend)
            message(
                FATAL_ERROR
                "UndefinedBehaviorSanitizer is not configured for an MSVC-style frontend."
            )
        elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
            target_compile_options(
                ${targetName}
                PRIVATE
                    -fsanitize=undefined
                    -fno-omit-frame-pointer
            )

            if(targetType MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
                target_link_options(
                    ${targetName}
                    PRIVATE
                        -fsanitize=undefined
                )
            endif()
        else()
            message(
                FATAL_ERROR
                "UndefinedBehaviorSanitizer is not configured for ${CMAKE_CXX_COMPILER_ID}."
            )
        endif()
    endif()
endfunction()
