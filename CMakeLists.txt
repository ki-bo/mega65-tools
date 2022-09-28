cmake_minimum_required(VERSION 3.16)
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.9" CACHE STRING "Deployment Target for macOS" FORCE)
set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "OSX Build Architectures" FORCE)

project(mega65-tools LANGUAGES C)

include(cmake/conan_setup.cmake)

find_package(libusb)
find_package(PNG)

add_executable(m65
    src/tools/m65.c
    src/tools/m65common.c
    src/tools/logging.c
    src/tools/version.c
    src/tools/screen_shot.c
    src/tools/fpgajtag/fpgajtag.c
    src/tools/fpgajtag/util.c
    src/tools/fpgajtag/usbserial.c
    src/tools/fpgajtag/process.c
)

target_include_directories(m65 PRIVATE include)
target_link_libraries(m65 libusb::libusb PNG::PNG)

if (MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall)
endif()
