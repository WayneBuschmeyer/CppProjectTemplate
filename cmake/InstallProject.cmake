include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

function(projectTemplateInstallLibrary targetName)
    set(packageInstallDirectory "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")

    install(
        TARGETS ${targetName}
        EXPORT ${PROJECT_NAME}Targets
        FILE_SET HEADERS
            DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        ARCHIVE
            DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        LIBRARY
            DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        RUNTIME
            DESTINATION "${CMAKE_INSTALL_BINDIR}"
    )

    install(
        EXPORT ${PROJECT_NAME}Targets
        FILE "${PROJECT_NAME}Targets.cmake"
        NAMESPACE "${PROJECT_NAME}::"
        DESTINATION "${packageInstallDirectory}"
    )

    configure_package_config_file(
        "${PROJECT_SOURCE_DIR}/cmake/ProjectConfig.cmake.in"
        "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION
            "${packageInstallDirectory}"
    )

    write_basic_package_version_file(
        "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        VERSION "${PROJECT_VERSION}"
        COMPATIBILITY SameMajorVersion
    )

    install(
        FILES
            "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
            "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION
            "${packageInstallDirectory}"
    )
endfunction()
