list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})

if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
  message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
  file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/0.18.1/conan.cmake"
                "${CMAKE_BINARY_DIR}/conan.cmake"
                TLS_VERIFY ON)
endif()

include(${CMAKE_BINARY_DIR}/conan.cmake)
conan_cmake_configure(REQUIRES 
                        libusb/1.0.26
                        libpng/1.6.37
                      GENERATORS cmake_find_package)
conan_cmake_autodetect(settings ARCH x86_64)
if (APPLE)
  list(APPEND settings "os.version=${CMAKE_OSX_DEPLOYMENT_TARGET}")
endif()
conan_cmake_install(PATH_OR_REFERENCE .
                    BUILD missing
                    REMOTE conancenter
                    SETTINGS ${settings})
