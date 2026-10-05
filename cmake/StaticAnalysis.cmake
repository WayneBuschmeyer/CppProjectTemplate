function(projectTemplateEnableStaticAnalysis targetName)
    if(PROJECT_TEMPLATE_ENABLE_CLANG_TIDY)
        find_program(
            clangTidyExecutable
            NAMES
                clang-tidy-22
                clang-tidy
        )

        if(NOT clangTidyExecutable)
            message(
                FATAL_ERROR
                "Clang-Tidy was requested, but clang-tidy was not found."
            )
        endif()

        set_property(
            TARGET ${targetName}
            PROPERTY CXX_CLANG_TIDY
                "${clangTidyExecutable};--config-file=${PROJECT_SOURCE_DIR}/.clang-tidy"
        )
    endif()

    if(PROJECT_TEMPLATE_ENABLE_MSVC_ANALYZE)
        if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(
                FATAL_ERROR
                "MSVC native analysis was requested with a non-MSVC compiler."
            )
        endif()

        target_compile_options(
            ${targetName}
            PRIVATE
                /analyze
                /analyze:external-
        )
    endif()
endfunction()
