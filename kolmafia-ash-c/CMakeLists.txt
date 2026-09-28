cmake_minimum_required(VERSION 3.16)
project(kolmafia_ash_c VERSION 0.1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBCURL REQUIRED IMPORTED_TARGET libcurl)
pkg_check_modules(JSONC REQUIRED IMPORTED_TARGET json-c)

add_library(kolmafia_ash STATIC src/kolmafia_ash.c)
target_include_directories(kolmafia_ash PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(kolmafia_ash PUBLIC PkgConfig::LIBCURL PkgConfig::JSONC)
target_compile_options(kolmafia_ash PRIVATE -Wall -Wextra -Wpedantic)

add_executable(kolmafia_ash_example examples/basic.c)
target_link_libraries(kolmafia_ash_example PRIVATE kolmafia_ash)

include(CTest)
if(BUILD_TESTING)
  add_executable(test_unit tests/test_unit.c)
  target_link_libraries(test_unit PRIVATE kolmafia_ash)
  add_test(NAME unit COMMAND test_unit)

  add_executable(test_integration tests/test_integration.c)
  target_link_libraries(test_integration PRIVATE kolmafia_ash)
  add_test(NAME integration COMMAND test_integration)
endif()
