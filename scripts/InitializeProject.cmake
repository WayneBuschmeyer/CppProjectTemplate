cmake_minimum_required(VERSION 4.3)

if(NOT DEFINED PROJECT_NAME OR PROJECT_NAME STREQUAL "")
    message(FATAL_ERROR "PROJECT_NAME is required.")
endif()

if(NOT PROJECT_NAME MATCHES "^[A-Z][A-Za-z0-9]*$")
    message(
        FATAL_ERROR
        "PROJECT_NAME must use PascalCase and contain only letters and numbers."
    )
endif()

if(NOT DEFINED PROJECT_DESCRIPTION OR PROJECT_DESCRIPTION STREQUAL "")
    message(FATAL_ERROR "PROJECT_DESCRIPTION is required.")
endif()

get_filename_component(repositoryRoot "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

set(starterHeader "${repositoryRoot}/include/ProjectName/ProjectName.h")

if(NOT EXISTS "${starterHeader}")
    message(
        FATAL_ERROR
        "This template no longer appears to be in its uninitialized state. "
        "Initialization is intentionally one-shot."
    )
endif()

# This workflow validates the template generator itself. Generated projects keep
# their normal build/test and CodeQL workflows but should not inherit template-
# maintenance CI.
file(
    REMOVE
    "${repositoryRoot}/.github/workflows/TemplateValidation.yml"
)

# Convert PascalCase to UPPER_SNAKE_CASE for option names and include guards.
string(
    REGEX REPLACE
    "([a-z0-9])([A-Z])"
    "\\1_\\2"
    projectPrefix
    "${PROJECT_NAME}"
)

string(
    REGEX REPLACE
    "([A-Z]+)([A-Z][a-z])"
    "\\1_\\2"
    projectPrefix
    "${projectPrefix}"
)

string(TOUPPER "${projectPrefix}" projectPrefix)

# Derive a lowerCamelCase prefix for private CMake helper functions.
string(TOLOWER "${projectPrefix}" projectFunctionWords)
string(REPLACE "_" ";" projectFunctionWords "${projectFunctionWords}")
list(POP_FRONT projectFunctionWords projectFunctionPrefix)

foreach(projectFunctionWord IN LISTS projectFunctionWords)
    string(SUBSTRING "${projectFunctionWord}" 0 1 wordFirstCharacter)
    string(TOUPPER "${wordFirstCharacter}" wordFirstCharacter)
    string(SUBSTRING "${projectFunctionWord}" 1 -1 wordRemainder)
    string(
        APPEND
        projectFunctionPrefix
        "${wordFirstCharacter}${wordRemainder}"
    )
endforeach()

# Build a CMake bracket argument whose closing delimiter does not occur in the
# user-provided description. This preserves quotes, semicolons, backslashes, and
# even text containing shorter CMake bracket delimiters without escaping it.
set(descriptionEquals "")

while(TRUE)
    set(descriptionClose "]${descriptionEquals}]")
    string(FIND "${PROJECT_DESCRIPTION}" "${descriptionClose}" descriptionClosePosition)

    if(descriptionClosePosition EQUAL -1)
        break()
    endif()

    string(APPEND descriptionEquals "=")
endwhile()

set(
    projectDescriptionArgument
    "[${descriptionEquals}[${PROJECT_DESCRIPTION}]${descriptionEquals}]"
)

message(STATUS "Project name: ${PROJECT_NAME}")
message(STATUS "Option prefix: ${projectPrefix}")
message(STATUS "CMake helper prefix: ${projectFunctionPrefix}")

file(
    GLOB_RECURSE candidateFiles
    RELATIVE "${repositoryRoot}"
    "${repositoryRoot}/*.cmake"
    "${repositoryRoot}/*.cpp"
    "${repositoryRoot}/*.cxx"
    "${repositoryRoot}/*.h"
    "${repositoryRoot}/*.hpp"
    "${repositoryRoot}/*.in"
    "${repositoryRoot}/*.json"
    "${repositoryRoot}/*.md"
    "${repositoryRoot}/*.ps1"
    "${repositoryRoot}/*.txt"
    "${repositoryRoot}/*.vsconfig"
    "${repositoryRoot}/*.yml"
    "${repositoryRoot}/*.yaml"
    "${repositoryRoot}/.clang-format"
    "${repositoryRoot}/.clang-tidy"
    "${repositoryRoot}/.editorconfig"
    "${repositoryRoot}/.gitattributes"
    "${repositoryRoot}/.gitignore"
)

foreach(relativePath IN LISTS candidateFiles)
    if(
        relativePath MATCHES "^\\.git/"
        OR relativePath MATCHES "^\\.vs/"
        OR relativePath MATCHES "^out/"
        OR relativePath MATCHES "^build/"
        OR relativePath STREQUAL "scripts/InitializeProject.cmake"
        OR relativePath STREQUAL "scripts/InitializeProject.ps1"
        OR relativePath STREQUAL "scripts/InitializeProject.cmd"
    )
        continue()
    endif()

    set(filePath "${repositoryRoot}/${relativePath}")
    file(READ "${filePath}" content)
    string(REPLACE "PROJECT_TEMPLATE" "${projectPrefix}" content "${content}")
    string(REPLACE "projectTemplate" "${projectFunctionPrefix}" content "${content}")
    string(REPLACE "ProjectName" "${PROJECT_NAME}" content "${content}")

    # Insert user prose last so placeholder-looking words in the description
    # remain exactly as supplied. Replace the complete starter bracket argument
    # so the generated delimiter is guaranteed not to collide with the prose.
    string(
        REPLACE
        "[=[Project description]=]"
        "${projectDescriptionArgument}"
        content
        "${content}"
    )

    file(WRITE "${filePath}" "${content}")
endforeach()

set(oldIncludeDirectory "${repositoryRoot}/include/ProjectName")
set(newIncludeDirectory "${repositoryRoot}/include/${PROJECT_NAME}")
file(RENAME "${oldIncludeDirectory}" "${newIncludeDirectory}")

set(oldHeaderPath "${newIncludeDirectory}/ProjectName.h")
set(newHeaderPath "${newIncludeDirectory}/${PROJECT_NAME}.h")
file(RENAME "${oldHeaderPath}" "${newHeaderPath}")

set(oldSourcePath "${repositoryRoot}/src/ProjectName.cpp")
set(newSourcePath "${repositoryRoot}/src/${PROJECT_NAME}.cpp")
file(RENAME "${oldSourcePath}" "${newSourcePath}")

message(STATUS "Initialization complete.")
message(STATUS "Review the changes, then build with a normal preset.")
