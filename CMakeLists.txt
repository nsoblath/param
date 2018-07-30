# Main CMakeLists.txt file for the param library
# Author: N.S. Oblath
# Created: July 29, 2018


# Minimum CMake version 3.1 required for the variable CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT
cmake_minimum_required (VERSION 3.7)

# Set policies
cmake_policy( SET CMP0011 NEW )
cmake_policy( SET CMP0012 NEW ) # how if-statements work
cmake_policy( SET CMP0042 NEW ) # rpath on mac os x
cmake_policy( SET CMP0048 NEW ) # version in project()

# Define the project
project( Param VERSION 0.0.0 )

# Project options
option( Param_ENABLE_TESTING "Turn on or off the building of test programs" OFF )

option( Param_BUILD_CODEC_JSON "Flag to enable building the JSON codec" TRUE )

option( Param_BUILD_CODEC_YAML "Flag to enable building the YAML codec" TRUE )

# Default install prefix
if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
    set( CMAKE_INSTALL_PREFIX ${PROJECT_BINARY_DIR} CACHE PATH "Install prefix" FORCE )
endif()

# Require C++11
set( CMAKE_CXX_STANDARD 11 )

# Boost for Boost Variant
find_package( Boost 1.31.0 REQUIRED )
include_directories( ${Boost_INCLUDE_DIRS} )

# Install directories
set( INCLUDE_INSTALL_SUBDIR "include/${PROJECT_NAME}" CACHE PATH "Install subdirectory for headers" )
if( ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
    set( LIB_INSTALL_SUBDIR "bin" CACHE PATH "Install subdirectory for libraries" )
else()
    set( LIB_INSTALL_SUBDIR "lib" CACHE PATH "Install subdirectory for libraries" )
endif()
set( BIN_INSTALL_SUBDIR "bin" CACHE PATH "Install subdirectory for binaries" )

set( INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${INCLUDE_INSTALL_SUBDIR}" )
set( LIB_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_SUBDIR}" )
set( BIN_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${BIN_INSTALL_SUBDIR}" )

# Build shared libraries
set( BUILD_SHARED_LIBS ON )

# turn on RPATH for Mac OSX
set( CMAKE_MACOSX_RPATH ON )

# add the library install directory to the rpath
SET(CMAKE_INSTALL_RPATH "${LIB_INSTALL_DIR}" )

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
set( CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE )

set( LIB_POSTFIX )
set( INC_PREFIX )

# in windows, disable the min and max macros
if( WIN32 )
    add_definitions( -DNOMINMAX )
endif( WIN32 )

# Handle the JSON codec option
if( Param_BUILD_CODEC_JSON )
    # RapidJSON
    option( RAPIDJSON_BUILD_DOC "Build rapidjson documentation." OFF )
    option( RAPIDJSON_BUILD_EXAMPLES "Build rapidjson examples." OFF )
    option( RAPIDJSON_BUILD_TESTS "Build rapidjson perftests and unittests." OFF )
    option( RAPIDJSON_BUILD_THIRDPARTY_GTEST "Use gtest installation in `thirdparty/gtest` by default if available" OFF )
    option( RAPIDJSON_BUILD_CXX11 "Build rapidjson with C++11 (gcc/clang)" ON )
    option( RAPIDJSON_BUILD_ASAN "Build rapidjson with address sanitizer (gcc/clang)" OFF )
    option( RAPIDJSON_BUILD_UBSAN "Build rapidjson with undefined behavior sanitizer (gcc/clang)" OFF )
    set( RAPIDJSON_FILE_BUFFER_SIZE 65536 CACHE STRING "Buffer size for reading and writing files using RapidJSON (in Bytes)" )
    
    add_definitions( -DRAPIDJSON_FILE_BUFFER_SIZE=${RAPIDJSON_FILE_BUFFER_SIZE} )
    add_definitions( -DUSE_CODEC_JSON )
    
    add_subdirectory( source/codec/json/rapidjson )
    include_directories( BEFORE ${CMAKE_CURRENT_SOURCE_DIR}/source/codec/json/rapidjson/include/ )
else()
    remove_definitions( -DUSE_CODEC_JSON )
endif()

# Handle the YAML codec option
if( Param_BUILD_CODEC_YAML )
    # Yaml-cpp
    option( YAML_CPP_BUILD_TOOLS "yaml-cpp option setting" OFF )
    option( YAML_CPP_BUILD_CONTRIB "yaml-cpp option setting" OFF )
    option( BUILD_SHARED_LIBS "yaml-cpp option setting" ON )
    add_subdirectory( source/codec/yaml/yaml-cpp )
    # I'm hard-coding the include directory and library because I ran into an error when I tried to include ${CMAKE_CURRENT_BINARY_DIR}/param/codec/yaml/yaml-cpp/yaml-cpp-config.cmake )
    include_directories( BEFORE ${CMAKE_CURRENT_SOURCE_DIR}/source/codec/yaml/yaml-cpp/include )
    list( APPEND EXTERNAL_LIBRARIES yaml-cpp )
endif()

# Build some stuff
include_directories( BEFORE ${PROJECT_SOURCE_DIR}/source )
add_subdirectory( source )

if( Param_ENABLE_TESTING )
    # to be used for test setup
endif()
