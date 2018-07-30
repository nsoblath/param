# CMakeLists.txt for param/source
# Author: N. Oblath
# Created: Jan 1, 2016

# Setup the header and source variables

set( Param_HEADERS
    param.hh
    param_array.hh
    param_base.hh
    param_base_impl.hh
    param_codec.hh
    param_node.hh
    param_value.hh
)

set( Param_SOURCES
    param_array.cc
    param_base.cc
    param_codec.cc
    param_node.cc
    param_value.cc
)

include_directories( BEFORE ${CMAKE_CURRENT_SOURCE_DIR}/utility )
add_subdirectory( utility )

if( Param_BUILD_CODEC_JSON )
    include_directories( BEFORE ${CMAKE_CURRENT_SOURCE_DIR}/codec/json )
    add_subdirectory( codec/json )
endif()

if( Param_BUILD_CODEC_YAML )
    include_directories( BEFORE ${CMAKE_CURRENT_SOURCE_DIR}/codec/yaml )
    add_subdirectory( codec/yaml )
endif()

# Build the library
add_library( Param ${Param_SOURCES} )
target_compile_options( Param INTERFACE ${GLOBAL_COMPILE_OPTIONS} )
target_link_libraries( Param ${FULL_PROJECT_LIBRARIES} ${EXTERNAL_LIBRARIES} )

install( TARGETS Param EXPORT ParamTargets DESTINATION ${LIB_INSTALL_DIR} )
set_property( GLOBAL APPEND PROPERTY Param_LIBRARIES Param )
set_target_properties( Param PROPERTIES INSTALL_NAME_DIR ${LIB_INSTALL_DIR} )

# Install headers
install( FILES ${Param_HEADERS} DESTINATION ${INCLUDE_INSTALL_DIR} )
