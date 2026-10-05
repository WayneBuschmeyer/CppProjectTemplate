function(projectTemplateEnableCompilerCache)
    if(NOT PROJECT_TEMPLATE_ENABLE_COMPILER_CACHE)
        return()
    endif()

    find_program(
        compilerCacheExecutable
        NAMES sccache ccache
    )

    if(NOT compilerCacheExecutable)
        message(
            FATAL_ERROR
            "Compiler caching was requested, but neither sccache nor ccache was found."
        )
    endif()

    set(
        CMAKE_C_COMPILER_LAUNCHER
        "${compilerCacheExecutable}"
        PARENT_SCOPE
    )

    set(
        CMAKE_CXX_COMPILER_LAUNCHER
        "${compilerCacheExecutable}"
        PARENT_SCOPE
    )
endfunction()
