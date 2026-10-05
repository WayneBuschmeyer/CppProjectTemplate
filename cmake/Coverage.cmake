function(projectTemplateEnableCoverage targetName)
    if(NOT PROJECT_TEMPLATE_ENABLE_COVERAGE)
        return()
    endif()

    get_target_property(targetType ${targetName} TYPE)

    if(
        CMAKE_CXX_COMPILER_ID MATCHES "Clang"
        AND NOT CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"
    )
        target_compile_options(
            ${targetName}
            PRIVATE
                -fprofile-instr-generate
                -fcoverage-mapping
        )

        if(targetType MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
            target_link_options(
                ${targetName}
                PRIVATE
                    -fprofile-instr-generate
            )
        endif()
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_compile_options(
            ${targetName}
            PRIVATE
                --coverage
        )

        if(targetType MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
            target_link_options(
                ${targetName}
                PRIVATE
                    --coverage
            )
        endif()
    else()
        message(
            FATAL_ERROR
            "Coverage instrumentation is not configured for this compiler frontend."
        )
    endif()
endfunction()
