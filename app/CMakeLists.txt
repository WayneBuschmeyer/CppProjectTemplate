add_executable(
    ${PROJECT_NAME}App
    Main.cpp
)

target_link_libraries(
    ${PROJECT_NAME}App
    PRIVATE
        ${PROJECT_NAME}::${PROJECT_NAME}
)

projectTemplateConfigureTarget(${PROJECT_NAME}App)
