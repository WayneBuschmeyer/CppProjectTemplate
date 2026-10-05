cmake_minimum_required(VERSION 4.3)

project(
    ProjectNameConsumer
    LANGUAGES CXX
)

set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

find_package(
    ProjectName 0.1.0
    CONFIG
    REQUIRED
)

add_executable(
    ProjectNameConsumer
    Main.cpp
)

target_link_libraries(
    ProjectNameConsumer
    PRIVATE
        ProjectName::ProjectName
)

set_target_properties(
    ProjectNameConsumer
    PROPERTIES
        CXX_EXTENSIONS OFF
)
