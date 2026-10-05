include("${CMAKE_CURRENT_LIST_DIR}/Architecture.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/CompilerCache.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/CompilerWarnings.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Coverage.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/DeveloperOptions.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Hardening.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Optimization.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Sanitizers.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/StaticAnalysis.cmake")

function(projectTemplateDefineOptions)
    option(
        PROJECT_TEMPLATE_BUILD_APP
        "Build the starter application"
        ${PROJECT_IS_TOP_LEVEL}
    )

    option(
        PROJECT_TEMPLATE_REQUIRE_64_BIT
        "Reject accidental 32-bit configurations"
        ON
    )

    option(
        PROJECT_TEMPLATE_ENABLE_DEVELOPER_OPTIONS
        "Enable strict project-development compiler options"
        ${PROJECT_IS_TOP_LEVEL}
    )

    option(
        PROJECT_TEMPLATE_WARNINGS_AS_ERRORS
        "Treat warnings from project-owned targets as errors"
        ON
    )

    option(
        PROJECT_TEMPLATE_ENABLE_HARDENING
        "Enable low-cost platform hardening for project-owned targets"
        ${PROJECT_IS_TOP_LEVEL}
    )

    option(
        PROJECT_TEMPLATE_ENABLE_IPO
        "Enable IPO/LTO for optimized project-owned targets when supported"
        ${PROJECT_IS_TOP_LEVEL}
    )

    option(
        PROJECT_TEMPLATE_ENABLE_INSTALL
        "Enable install and CMake package export rules"
        ${PROJECT_IS_TOP_LEVEL}
    )

    option(
        PROJECT_TEMPLATE_ENABLE_COMPILER_CACHE
        "Use sccache or ccache"
        OFF
    )

    option(
        PROJECT_TEMPLATE_ENABLE_CLANG_TIDY
        "Run Clang-Tidy as part of compilation"
        OFF
    )

    option(
        PROJECT_TEMPLATE_ENABLE_MSVC_ANALYZE
        "Run MSVC native static analysis"
        OFF
    )

    option(
        PROJECT_TEMPLATE_ENABLE_ASAN
        "Enable AddressSanitizer"
        OFF
    )

    option(
        PROJECT_TEMPLATE_ENABLE_UBSAN
        "Enable UndefinedBehaviorSanitizer where supported"
        OFF
    )

    option(
        PROJECT_TEMPLATE_ENABLE_COVERAGE
        "Enable compiler coverage instrumentation"
        OFF
    )
endfunction()

function(projectTemplateConfigureTarget targetName)
    set_target_properties(
        ${targetName}
        PROPERTIES
            CXX_EXTENSIONS OFF
    )

    if(PROJECT_TEMPLATE_ENABLE_DEVELOPER_OPTIONS)
        projectTemplateSetCompilerWarnings(${targetName})
        projectTemplateApplyDeveloperOptions(${targetName})
    endif()

    if(PROJECT_TEMPLATE_ENABLE_HARDENING)
        projectTemplateEnableHardening(${targetName})
    endif()

    projectTemplateEnableSanitizers(${targetName})
    projectTemplateEnableCoverage(${targetName})
    projectTemplateEnableIpo(${targetName})
    projectTemplateEnableStaticAnalysis(${targetName})
endfunction()
