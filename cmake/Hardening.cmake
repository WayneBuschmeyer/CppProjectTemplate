function(projectTemplateEnableHardening targetName)
    get_target_property(targetType ${targetName} TYPE)

    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        target_compile_options(
            ${targetName}
            PRIVATE
                /guard:cf
        )

        if(targetType MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
            target_link_options(
                ${targetName}
                PRIVATE
                    /guard:cf
            )
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(
            ${targetName}
            PRIVATE
                -fstack-protector-strong
        )
    endif()
endfunction()
