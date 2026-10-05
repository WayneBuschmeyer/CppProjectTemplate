function(projectTemplateApplyDeveloperOptions targetName)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        target_compile_options(
            ${targetName}
            PRIVATE
                /permissive-
                /Zc:preprocessor
                /Zc:__cplusplus
                /utf-8
                $<$<CONFIG:Debug>:/sdl>
        )
    endif()
endfunction()
