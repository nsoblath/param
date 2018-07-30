# CMakeLists.txt for Param/source/codec/yaml
# Author: N. Oblath
# Created: Jan 1, 2016

set( dir ${CMAKE_CURRENT_SOURCE_DIR} )

set( Param_HEADERS ${Param_HEADERS}
    ${dir}/param_yaml.hh
    PARENT_SCOPE )

set( Param_SOURCES ${Param_SOURCES}
    ${dir}/param_yaml.cc
    PARENT_SCOPE )
