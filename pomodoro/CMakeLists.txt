cmake_minimum_required(VERSION 3.16)

project(pomodoro VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets Sql)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(apppomodoro
    main.cpp
)

qt_add_qml_module(apppomodoro
    URI pomodoro
    SOURCES
        pomodorotimer.h
        pomodorotimer.cpp
        pomodorostorage.h
        pomodorostorage.cpp
    QML_FILES
        Main.qml
        pomodoro/SettingsWindow.qml
        pomodoro/DbViewerWindow.qml
    RESOURCES
        assets/focus.gif
        assets/break.gif
        assets/start.gif
        assets/pause.gif
        SOURCES pomodorotimer.h
        SOURCES pomodorotimer.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(apppomodoro PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apppomodoro
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(apppomodoro
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Widgets
    PRIVATE Qt6::Sql
)

install(TARGETS apppomodoro
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
