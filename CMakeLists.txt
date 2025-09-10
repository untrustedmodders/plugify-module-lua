cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

if(POLICY CMP0092)
    cmake_policy(SET CMP0092 NEW) # Don't add -W3 warning level by default.
endif()


file(READ "${CMAKE_CURRENT_SOURCE_DIR}/version.txt" VERSION_FILE_CONTENTS)
string(STRIP "${VERSION_FILE_CONTENTS}" VERSION_FILE_CONTENTS)
set(LUALM_VERSION "${VERSION_FILE_CONTENTS}" CACHE STRING "Set version name")
set(LUALM_PACKAGE "lua_module" CACHE STRING "Set package name")
string(REPLACE "v" "" LUALM_VERSION "${LUALM_VERSION}")
string(REGEX REPLACE "[.+-]" ";" LUALM_VERSION_LIST ${LUALM_VERSION})
list(GET LUALM_VERSION_LIST 0 LUALM_VERSION_MAJOR)
list(GET LUALM_VERSION_LIST 1 LUALM_VERSION_MINOR)
list(GET LUALM_VERSION_LIST 2 LUALM_VERSION_PATCH)

project(plugify-module-lua
        VERSION "${LUALM_VERSION_MAJOR}.${LUALM_VERSION_MINOR}.${LUALM_VERSION_PATCH}"
        DESCRIPTION "Lua Language Module"
        HOMEPAGE_URL "https://github.com/untrustedmodders/plugify-module-lua"
        LANGUAGES CXX
)
		
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(NOT CMAKE_BUILD_TYPE MATCHES "Debug|Devel|MinSizeRel|RelWithDebInfo|Release")
    message(STATUS "CMAKE_BUILD_TYPE not set, defaulting to Debug.")
    set(CMAKE_BUILD_TYPE Debug)
endif()

set(BUILD_SHARED_LIBS ON CACHE INTERNAL "")

#
# Plugify
#
set(PLUGIFY_BUILD_SHARED_LIB ON CACHE INTERNAL "")
set(PLUGIFY_BUILD_TESTS OFF CACHE INTERNAL "")
if(LINUX)
	set(PLUGIFY_USE_STATIC_STDLIB ON CACHE INTERNAL "")
	set(PLUGIFY_USE_ABI0 OFF CACHE INTERNAL "")
endif()
add_subdirectory(external/plugify)

#
# Lua
#
set(LUA_ENABLE_SHARED OFF CACHE INTERNAL "")
add_subdirectory(external/lua)

#
# Lua Language Module for Plugify
#
file(GLOB_RECURSE LUALM_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "src/*.cpp")

add_library(${PROJECT_NAME} SHARED ${LUALM_SOURCES})

set(LUALM_LINK_LIBRARIES plugify::plugify lua_static)

if(NOT COMPILER_SUPPORTS_FORMAT)
    set(LUALM_LINK_LIBRARIES ${LUALM_LINK_LIBRARIES} fmt::fmt-header-only)
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE
        LUALM_PLATFORM_WINDOWS=$<BOOL:${WIN32}>
        LUALM_PLATFORM_APPLE=$<BOOL:${APPLE}>
        LUALM_PLATFORM_LINUX=$<BOOL:${LINUX}>
        LUALM_IS_DEBUG=$<STREQUAL:${CMAKE_BUILD_TYPE},Debug>
)

target_link_libraries(${PROJECT_NAME} PRIVATE ${LUALM_LINK_LIBRARIES})

include(GenerateExportHeader)
generate_export_header(${PROJECT_NAME} EXPORT_MACRO_NAME LUALM_EXPORT EXPORT_FILE_NAME ${CMAKE_BINARY_DIR}/exports/module_export.h)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/exports)

if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /W4 /WX)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -Wextra -Wconversion -Werror -Wshadow -Wpedantic)
endif()

if(APPLE)
    target_link_options(${PROJECT_NAME} PRIVATE "-Wl,-exported_symbols_list,${CMAKE_CURRENT_SOURCE_DIR}/sym/exported_symbols.lds")
elseif(UNIX)
    target_link_options(${PROJECT_NAME} PRIVATE "-Wl,--version-script,${CMAKE_CURRENT_SOURCE_DIR}/sym/version_script.lds")
endif()

configure_file(
    ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}.pmodule.in
    ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pmodule
)

set(LUALM_GITHUB_ACTIONS "0" CACHE STRING "Build with github actions")

if(LUALM_GITHUB_ACTIONS)
    execute_process(COMMAND cmake -E create_symlink
            "${CMAKE_CURRENT_SOURCE_DIR}/lib"
            "${CMAKE_CURRENT_BINARY_DIR}/lib"
    )
endif()