cmake_minimum_required(VERSION 4.3)

project(
    ProjectName
    VERSION 0.1.0
    DESCRIPTION [=[Project description]=]
    LANGUAGES CXX
)

# The starter uses ordinary headers. Module dependency scanning should become an
# explicit project decision rather than background work performed by every build.
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/ProjectOptions.cmake")

projectTemplateDefineOptions()
projectTemplateVerifyArchitecture()
projectTemplateEnableCompilerCache()
projectTemplateConfigureIpo()

set(projectHeaders
    include/ProjectName/ProjectName.h
)

set(projectSources
    src/ProjectName.cpp
)

add_library(${PROJECT_NAME} STATIC)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        ${projectSources}
    PUBLIC
        FILE_SET HEADERS
        BASE_DIRS
            "${CMAKE_CURRENT_SOURCE_DIR}/include"
        FILES
            ${projectHeaders}
)

# C++23 is part of the public interface contract. CMake is responsible for
# selecting the toolchain-specific language-mode flag.
target_compile_features(
    ${PROJECT_NAME}
    PUBLIC
        cxx_std_23
)

projectTemplateConfigureTarget(${PROJECT_NAME})

# CMake can compile every public header as its own translation unit. Keeping
# this in the normal developer build catches headers that accidentally depend on
# include order.
if(PROJECT_IS_TOP_LEVEL AND CMAKE_VERIFY_INTERFACE_HEADER_SETS)
    add_custom_target(
        ${PROJECT_NAME}VerifyHeaders
        ALL
    )

    add_dependencies(
        ${PROJECT_NAME}VerifyHeaders
        ${PROJECT_NAME}_verify_interface_header_sets
    )
endif()

if(PROJECT_TEMPLATE_BUILD_APP)
    add_subdirectory(app)
endif()

# Tests are a top-level development concern. Projects that consume this library
# with add_subdirectory() should not inherit its test suite.
if(PROJECT_IS_TOP_LEVEL)
    include(CTest)

    if(BUILD_TESTING)
        add_subdirectory(tests)
    endif()
endif()

if(PROJECT_TEMPLATE_ENABLE_INSTALL)
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/InstallProject.cmake")
    projectTemplateInstallLibrary(${PROJECT_NAME})
endif()
