cmake_minimum_required(VERSION 3.20)
project(kolmafia_ash_cpp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBCURL REQUIRED IMPORTED_TARGET libcurl)

add_library(kolmafia_ash
    src/client.cpp
    src/boost_json.cpp
)
add_library(kolmafia::ash ALIAS kolmafia_ash)

target_include_directories(kolmafia_ash
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(kolmafia_ash PUBLIC PkgConfig::LIBCURL)

target_compile_features(kolmafia_ash PUBLIC cxx_std_20)

if (MSVC)
  target_compile_options(kolmafia_ash PRIVATE /W4 /permissive-)
else()
  target_compile_options(kolmafia_ash PRIVATE -Wall -Wextra -Wpedantic -Wconversion)
endif()

option(KOLMAFIA_ASH_BUILD_EXAMPLES "Build examples" ON)
option(KOLMAFIA_ASH_BUILD_TESTS "Build smoke tests" ON)

if(KOLMAFIA_ASH_BUILD_EXAMPLES)
  add_executable(kolmafia_ash_example examples/read_only.cpp)
  target_link_libraries(kolmafia_ash_example PRIVATE kolmafia::ash)
endif()

if(KOLMAFIA_ASH_BUILD_TESTS)
  enable_testing()
  add_executable(kolmafia_ash_smoke tests/smoke.cpp)
  target_link_libraries(kolmafia_ash_smoke PRIVATE kolmafia::ash)
  add_test(NAME kolmafia_ash_smoke COMMAND kolmafia_ash_smoke)
endif()
