# PackageBuilder.cmake
# Author: Noah Oblath
# Parts of this script are based on work done by Sebastian Voecking and Marco Haag in the Kasper package
# Convenient macros and default variable settings for the Nymph-based build.
#
# Requires: CMake v3.0 or better (rpath treatment and version variables)

# CMake policies
cmake_policy( SET CMP0011 NEW )
cmake_policy( SET CMP0012 NEW ) # how if-statements work
cmake_policy( SET CMP0042 NEW ) # rpath on mac os x
cmake_policy( SET CMP0048 NEW ) # version in project()

# check if this is a stand-alone build
set( PBUILDER_STANDALONE FALSE CACHE INTERNAL "Flag for whether or not this is a stand-alone build" )
set( PBUILDER_CHILD_NAME_EXTENSION "${PROJECT_NAME}" CACHE INTERNAL "Submodule library name modifier" )
if( ${CMAKE_SOURCE_DIR} STREQUAL ${PROJECT_SOURCE_DIR} )
    set( PBUILDER_STANDALONE TRUE )
else( ${CMAKE_SOURCE_DIR} STREQUAL ${PROJECT_SOURCE_DIR} )
endif( ${CMAKE_SOURCE_DIR} STREQUAL ${PROJECT_SOURCE_DIR} )

# preprocessor defintion for debug build
if ("${CMAKE_BUILD_TYPE}" STREQUAL "DEBUG")
    add_definitions(-D${PROJECT_NAME}_DEBUG)
else ("${CMAKE_BUILD_TYPE}" STREQUAL "DEBUG")
    remove_definitions(-D${PROJECT_NAME}_DEBUG)    
endif ("${CMAKE_BUILD_TYPE}" STREQUAL "DEBUG")

# Setup the default install prefix
# This gets set to the binary directory upon first configuring.
# If the user changes the prefix, but leaves the flag OFF, then it will remain as the user specified.
# If the user wants to reset the prefix to the default (i.e. the binary directory), then the flag should be set ON.
if (NOT DEFINED SET_INSTALL_PREFIX_TO_DEFAULT)
    set (SET_INSTALL_PREFIX_TO_DEFAULT ON)
endif (NOT DEFINED SET_INSTALL_PREFIX_TO_DEFAULT)
if (SET_INSTALL_PREFIX_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX ${PROJECT_BINARY_DIR} CACHE PATH "Install prefix" FORCE)
    set (SET_INSTALL_PREFIX_TO_DEFAULT OFF CACHE BOOL "Reset default install path when when configuring" FORCE)
endif (SET_INSTALL_PREFIX_TO_DEFAULT)

# install subdirectories
set (INCLUDE_INSTALL_SUBDIR "include/${PROJECT_NAME}" CACHE PATH "Install subdirectory for headers")
if( ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
    set (LIB_INSTALL_SUBDIR "bin" CACHE PATH "Install subdirectory for libraries")
else( ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
    set (LIB_INSTALL_SUBDIR "lib" CACHE PATH "Install subdirectory for libraries")
endif( ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
set (BIN_INSTALL_SUBDIR "bin" CACHE PATH "Install subdirectory for binaries")
set (CONFIG_INSTALL_SUBDIR "config" CACHE PATH "Install subdirectory for config files")

set (INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${INCLUDE_INSTALL_SUBDIR}")
set (LIB_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_SUBDIR}")
set (BIN_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${BIN_INSTALL_SUBDIR}")
set (CONFIG_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${CONFIG_INSTALL_SUBDIR}")

# flag for building test programs
set (${PROJECT_NAME}_ENABLE_TESTING OFF CACHE BOOL "Turn on or off the building of test programs")

# flag for building executables (other than test programs)
# this is particularly useful if a project is used multiple times and installed in a general location, where executables would overwrite each other.
set (${PROJECT_NAME}_ENABLE_EXECUTABLES ON CACHE BOOL "Turn on or off the building of executables (other than test programs)")

# build shared libraries
set (BUILD_SHARED_LIBS ON)

# global property to hold the names of nymph library targets
set_property (GLOBAL PROPERTY ${PROJECT_NAME}_LIBRARIES)

# turn on RPATH for Mac OSX
set (CMAKE_MACOSX_RPATH ON)

# add the library install directory to the rpath
SET(CMAKE_INSTALL_RPATH "${LIB_INSTALL_DIR}")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

set (LIB_POSTFIX)
set (INC_PREFIX)

##########
# MACROS #
##########

# This should be called immediately after setting the project name
macro (pbuilder_prepare_project)
    # define the variables to describe the package (will go in the [ProjectName]Config.hh file)
    set (${PROJECT_NAME}_PACKAGE_NAME "${PROJECT_NAME}")
    set (${PROJECT_NAME}_PACKAGE_STRING "${PROJECT_NAME} ${${PROJECT_NAME}_VERSION}")
    
    # Configuration header file
    if (EXISTS ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.hh.in)
        configure_file (
            ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.hh.in
            ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.hh
        )
        # Add the binary tree to the search path for include files so that the config file is found during the build
        include_directories (${PROJECT_BINARY_DIR})
    endif (EXISTS ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.hh.in)
endmacro ()

macro (pbuilder_add_submodule SM_NAME SM_LOCATION)
    if (NOT DEFINED PARENT_LIB_NAME_SUFFIX)
        set (PARENT_LIB_NAME_SUFFIX "_${PROJECT_NAME}" CACHE INTERNAL "Library name suffix for submodules")
    else (NOT DEFINED PARENT_LIB_NAME_SUFFIX)
        set (PARENT_LIB_NAME_SUFFIX "_${PROJECT_NAME}_${PARENT_LIB_NAME_SUFFIX}")
    endif (NOT DEFINED PARENT_LIB_NAME_SUFFIX)
    message( STATUS "PARENT_LIB_NAME_SUFFIX being set for SM ${SM_NAME}: ${PARENT_LIB_NAME_SUFFIX}")
    
    add_subdirectory( ${SM_LOCATION} )
    message( STATUS "SM ${SM_NAME} variables for parent:")
    message( STATUS "${SM_NAME}_LIBRARIES: ${${SM_NAME}_LIBRARIES}")
    message( STATUS "${SM_NAME}_LIBRARY_DIR: ${${SM_NAME}_LIBRARY_DIR}")
    message( STATUS "${SM_NAME}_INCLUDE_DIR: ${${SM_NAME}_INCLUDE_DIR}")
    message( STATUS "${SM_NAME}_DEP_INCLUDE_DIRS: ${${SM_NAME}_DEP_INCLUDE_DIRS}")
    
    unset (PARENT_LIB_NAME_SUFFIX CACHE)
endmacro ()

macro (pbuilder_add_ext_libraries)
    list (APPEND EXTERNAL_LIBRARIES ${ARGN})
endmacro ()

macro (pbuilder_add_submodule_libraries)
    list (APPEND EXTERNAL_LIBRARIES ${ARGN})
    list (APPEND SUBMODULE_LIBRARIES ${ARGN})
endmacro ()

macro (pbuilder_library LIB_BASENAME SOURCES PROJECT_LIBRARIES)
    message (STATUS "Building library ${LIB_BASENAME}; PARENT_LIB_NAME_SUFFIX is ${PARENT_LIB_NAME_SUFFIX}")
    set (FULL_LIB_NAME "${LIB_BASENAME}${PARENT_LIB_NAME_SUFFIX}")
    message( STATUS "lib basename: ${LIB_BASENAME}")
    message( STATUS "full lib name: ${FULL_LIB_NAME}")

    set (FULL_PROJECT_LIBRARIES)
    foreach (project_lib ${${PROJECT_LIBRARIES}})
        list (APPEND FULL_PROJECT_LIBRARIES "${project_lib}${PARENT_LIB_NAME_SUFFIX}")
    endforeach (project_lib)
    message( STATUS "project libraries (lib): ${FULL_PROJECT_LIBRARIES}" )

    add_library( ${FULL_LIB_NAME} ${${SOURCES}} )
    target_link_libraries( ${FULL_LIB_NAME} ${FULL_PROJECT_LIBRARIES} ${EXTERNAL_LIBRARIES} )
    pbuilder_install_libraries (${FULL_LIB_NAME})
endmacro ()

macro (pbuilder_install_libraries)
    message( STATUS "installing libs: ${ARGN}" )
    install (TARGETS ${ARGN} EXPORT ${PROJECT_NAME}Targets DESTINATION ${LIB_INSTALL_DIR})
    #list (APPEND ${PROJECT_NAME}_LIBRARIES ${ARGN})
    set_property (GLOBAL APPEND PROPERTY ${PROJECT_NAME}_LIBRARIES ${ARGN})
    set_target_properties (${ARGN} PROPERTIES INSTALL_NAME_DIR ${LIB_INSTALL_DIR})
endmacro ()

macro (pbuilder_executables PROGRAMS PROJECT_LIBRARIES )
    set (FULL_PROJECT_LIBRARIES)
    foreach (project_lib ${${PROJECT_LIBRARIES}})
        list (APPEND FULL_PROJECT_LIBRARIES "${project_lib}${PARENT_LIB_NAME_SUFFIX}")
    endforeach (project_lib)
    message( STATUS "project libraries (exe): ${FULL_PROJECT_LIBRARIES}" )

    foreach (program ${${PROGRAMS}})
        add_executable (${program} ${CMAKE_CURRENT_SOURCE_DIR}/${program}.cc)
        target_link_libraries (${program} ${FULL_PROJECT_LIBRARIES} ${EXTERNAL_LIBRARIES})
        pbuilder_install_executables (${program})
    endforeach (program)
endmacro ()

macro (pbuilder_install_executables)
    install(TARGETS ${ARGN} EXPORT ${PROJECT_NAME}Targets DESTINATION ${BIN_INSTALL_DIR})
endmacro ()

macro (pbuilder_install_headers)
    install(FILES ${ARGN} DESTINATION ${INCLUDE_INSTALL_DIR})
endmacro ()

macro (pbuilder_install_header_dirs FILE_PATTERN)
    install(DIRECTORY ${ARGN} DESTINATION ${INCLUDE_INSTALL_DIR} FILES_MATCHING PATTERN "${FILE_PATTERN}")
endmacro ()

macro (pbuilder_install_config)
    install(FILES ${ARGN} DESTINATION ${CONFIG_INSTALL_DIR})
endmacro ()

macro (pbuilder_install_files DEST_DIR)
    install(FILES ${ARGN} DESTINATION ${DEST_DIR})
endmacro ()

# This should be called AFTER all subdirectories with libraries have been called, and all include directories added.
macro (pbuilder_install_config_files)
    # Configuration header file
    if (EXISTS ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.hh)
        # Install location for the configuration header
        pbuilder_install_headers (${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.hh)
    endif (EXISTS ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.hh)

    # CMake configuration file
    get_property(${PROJECT_NAME}_LIBRARIES GLOBAL PROPERTY ${PROJECT_NAME}_LIBRARIES)
    if (EXISTS ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake.in)
        # the awkwardness of the following four lines is because for some reason cmake wouldn't just go from .cmake.tmp to .cmake when I tested it.
        configure_file(${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake.in ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}Config.cmake.tmp @ONLY)
        configure_file(${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}Config.cmake.tmp ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}Config.cmake.ppp @ONLY)
        file (REMOVE ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}Config.cmake.tmp)
        file (RENAME ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}Config.cmake.ppp ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}Config.cmake)
    endif (EXISTS ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake.in)
endmacro ()

macro (pbuilder_variables_for_parent)
    if (NOT ${PBUILDER_STANDALONE})
        get_property (LIBRARIES GLOBAL PROPERTY ${PROJECT_NAME}_LIBRARIES)
        set (${PROJECT_NAME}_LIBRARIES ${LIBRARIES} ${SUBMODULE_LIBRARIES} PARENT_SCOPE)
        set (${PROJECT_NAME}_LIBRARY_DIR ${LIB_INSTALL_DIR} PARENT_SCOPE)
        set (${PROJECT_NAME}_INCLUDE_DIR ${INCLUDE_INSTALL_DIR} PARENT_SCOPE)
        get_property (DEP_INCLUDE_DIRS DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
        set (${PROJECT_NAME}_DEP_INCLUDE_DIRS ${DEP_INCLUDE_DIRS} PARENT_SCOPE)
    endif (NOT ${PBUILDER_STANDALONE})
endmacro ()
