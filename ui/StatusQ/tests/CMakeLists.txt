cmake_minimum_required(VERSION 3.5)

project(TestStatusQ LANGUAGES CXX)

enable_testing()

set(CMAKE_AUTOMOC ON)

find_package(QT NAMES Qt6 Qt5 COMPONENTS QuickTest Qml Quick REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS QuickTest Qml Quick REQUIRED)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

# no need to copy around qml test files for shadow builds - just set the respective define
add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_executable(${PROJECT_NAME} main.cpp)

add_test(NAME ${PROJECT_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME} -input "${CMAKE_CURRENT_SOURCE_DIR}")
add_custom_target("Run_${PROJECT_NAME}" COMMAND ${CMAKE_CTEST_COMMAND} --test-dir "${CMAKE_CURRENT_BINARY_DIR}")
add_dependencies("Run_${PROJECT_NAME}" ${PROJECT_NAME})

# TODO: move this to a test helpers library
target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

add_subdirectory(src)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt${QT_VERSION_MAJOR}::QuickTest
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::Quick
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
        STATUSQ_MODULE_PATH="${STATUSQ_MODULE_PATH}"
        STATUSQ_MODULE_IMPORT_PATH="${STATUSQ_MODULE_IMPORT_PATH}"
        )
