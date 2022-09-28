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
                      OPTIONS
                        libusb:shared=False
                        libpng:shared=False
                      GENERATORS cmake_find_package)


conan_cmake_autodetect(settings ARCH x86_64)
if (APPLE)
  list(APPEND settings "os.version=${CMAKE_OSX_DEPLOYMENT_TARGET}")
endif()

if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
  set(conan_compiler "gcc")
elseif (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  set(conan_compiler "msvc")
elseif (CMAKE_C_COMPILER_ID STREQUAL "Clang")
  set(conan_compiler "clang")
elseif (CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
  set(conan_compiler "apple-clang")
endif()

string(REGEX MATCH "^([0-9]+)\\.?.*$" COMPILER_VERSION_MAJOR ${CMAKE_C_COMPILER_VERSION})
set(COMPILER_VERSION_MAJOR ${CMAKE_MATCH_1})

if (CMAKE_CROSSCOMPILING)
  conan_cmake_install(PATH_OR_REFERENCE .
                      BUILD missing
                      REMOTE conancenter
                      SETTINGS_BUILD
                        ${settings}
                      SETTINGS_HOST
                        os=${CMAKE_SYSTEM_NAME}
                        compiler=${conan_compiler}
                        compiler.version=${COMPILER_VERSION_MAJOR}
                      ENV_HOST
                        CONAN_CMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH}
                        CHOST=${TOOLCHAIN_PREFIX}
                        CC=${CMAKE_C_COMPILER}
                        CXX=${CMAKE_CXX_COMPILER}
                        RC=${CMAKE_RC_COMPILER}
                      )
else()
  conan_cmake_install(PATH_OR_REFERENCE .
                      BUILD missing
                      REMOTE conancenter
                      SETTINGS
                        ${settings}
                        os=${CMAKE_SYSTEM_NAME}
                        compiler=${conan_compiler}
                        compiler.version=${COMPILER_VERSION_MAJOR}
                      ENV
                        CONAN_CMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH}
                        CHOST=${TOOLCHAIN_PREFIX}
                        CC=${CMAKE_C_COMPILER}
                        CXX=${CMAKE_CXX_COMPILER}
                        RC=${CMAKE_RC_COMPILER}
                      )
endif()
