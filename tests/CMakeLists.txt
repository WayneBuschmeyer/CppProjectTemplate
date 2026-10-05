include(FetchContent)

# Use a versioned release archive with a cryptographic content hash. This is
# reproducible, avoids requiring Git during configuration, and fails closed if
# the downloaded bytes do not match the reviewed dependency.
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.18.0.tar.gz
    URL_HASH SHA256=6e3191c1455468b3fc35a417fb565c1c5071aee1b7e7f85e30cf48a98d37d8b5
    SYSTEM
    EXCLUDE_FROM_ALL
)

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(googletest)

# Static libraries linked into a sanitizer-enabled executable need compatible
# instrumentation. Apply sanitizer policy only; do not impose project warnings
# or style rules on third-party code.
if(PROJECT_TEMPLATE_ENABLE_ASAN OR PROJECT_TEMPLATE_ENABLE_UBSAN)
    projectTemplateEnableSanitizers(gtest)
    projectTemplateEnableSanitizers(gtest_main)
endif()

add_executable(
    ${PROJECT_NAME}Tests
    ConstexprTests.cpp
    ProjectTests.cpp
)

target_link_libraries(
    ${PROJECT_NAME}Tests
    PRIVATE
        ${PROJECT_NAME}::${PROJECT_NAME}
        GTest::gtest_main
)

projectTemplateConfigureTarget(${PROJECT_NAME}Tests)

# Unit tests intentionally compare known expected values with results under
# test, which makes C6326 noisy under MSVC native analysis.
if(
    PROJECT_TEMPLATE_ENABLE_MSVC_ANALYZE
    AND CMAKE_CXX_COMPILER_ID STREQUAL "MSVC"
)
    target_compile_options(
        ${PROJECT_NAME}Tests
        PRIVATE
            /wd6326
    )
endif()

include(GoogleTest)

gtest_discover_tests(
    ${PROJECT_NAME}Tests
    TEST_PREFIX "${PROJECT_NAME}."
    DISCOVERY_MODE PRE_TEST
)
