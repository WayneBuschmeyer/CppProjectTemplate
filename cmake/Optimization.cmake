include(CheckIPOSupported)

# Probe IPO/LTO once per configuration and reuse the result for project-owned
# targets. Unsupported IPO does not make an otherwise valid toolchain unusable.
function(projectTemplateConfigureIpo)
    set_property(
        GLOBAL
        PROPERTY PROJECT_TEMPLATE_IPO_SUPPORTED FALSE
    )

    if(NOT PROJECT_TEMPLATE_ENABLE_IPO)
        return()
    endif()

    set(shouldCheckIpo FALSE)

    if(CMAKE_CONFIGURATION_TYPES)
        set(shouldCheckIpo TRUE)
    elseif(
        CMAKE_BUILD_TYPE STREQUAL "Release"
        OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo"
    )
        set(shouldCheckIpo TRUE)
    endif()

    if(NOT shouldCheckIpo)
        return()
    endif()

    check_ipo_supported(
        RESULT ipoSupported
        OUTPUT ipoError
        LANGUAGES CXX
    )

    if(ipoSupported)
        set_property(
            GLOBAL
            PROPERTY PROJECT_TEMPLATE_IPO_SUPPORTED TRUE
        )

        return()
    endif()

    message(
        WARNING
        "IPO/LTO was requested for optimized builds but is unavailable: ${ipoError}"
    )
endfunction()

function(projectTemplateEnableIpo targetName)
    if(NOT PROJECT_TEMPLATE_ENABLE_IPO)
        return()
    endif()

    get_property(
        ipoSupported
        GLOBAL
        PROPERTY PROJECT_TEMPLATE_IPO_SUPPORTED
    )

    if(NOT ipoSupported)
        return()
    endif()

    set_target_properties(
        ${targetName}
        PROPERTIES
            INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE
            INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO TRUE
    )
endfunction()
