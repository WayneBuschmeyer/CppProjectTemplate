cmake_minimum_required(VERSION 4.3)

get_filename_component(repositoryRoot "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(presetsPath "${repositoryRoot}/CMakePresets.json")

file(READ "${presetsPath}" presetsJson)

string(JSON schemaVersion GET "${presetsJson}" version)

if(NOT schemaVersion EQUAL 9)
    message(
        FATAL_ERROR
        "CMakePresets.json must use schema version 9 for Visual Studio 2026 "
        "compatibility. Found schema ${schemaVersion}."
    )
endif()

string(JSON minimumMajor GET "${presetsJson}" cmakeMinimumRequired major)
string(JSON minimumMinor GET "${presetsJson}" cmakeMinimumRequired minor)
string(JSON minimumPatch GET "${presetsJson}" cmakeMinimumRequired patch)

if(
    NOT minimumMajor EQUAL 4
    OR NOT minimumMinor EQUAL 3
    OR NOT minimumPatch EQUAL 0
)
    message(
        FATAL_ERROR
        "CMakePresets.json must keep the project baseline at CMake 4.3.0. "
        "Found ${minimumMajor}.${minimumMinor}.${minimumPatch}."
    )
endif()

# Schema 9 is an intentional Visual Studio compatibility ceiling. Reject a few
# easy-to-reintroduce fields that require newer schemas before they reach CI.
string(FIND "${presetsJson}" "\"$comment\"" commentPosition)

if(NOT commentPosition EQUAL -1)
    message(
        FATAL_ERROR
        "Preset schema 9 does not support $comment. Keep preset rationale in "
        "normal project documentation instead."
    )
endif()

string(
    FIND
    "${presetsJson}"
    "\"installAbsoluteDestination\""
    installAbsoluteDestinationPosition
)

if(NOT installAbsoluteDestinationPosition EQUAL -1)
    message(
        FATAL_ERROR
        "installAbsoluteDestination requires a newer preset schema than 9."
    )
endif()

string(FIND "${presetsJson}" "\"cmakeExecutable\"" cmakeExecutablePosition)

if(NOT cmakeExecutablePosition EQUAL -1)
    message(
        FATAL_ERROR
        "Shared presets must not set cmakeExecutable. Visual Studio should "
        "select its supported CMake executable."
    )
endif()

message(
    STATUS
    "Preset contract valid: schema ${schemaVersion}, CMake "
    "${minimumMajor}.${minimumMinor}.${minimumPatch}, no cmakeExecutable override."
)
