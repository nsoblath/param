# CMakeLists.txt for param/source/utility
# Author: N. Oblath
# Created: Jan 1, 2016

set( dir ${CMAKE_CURRENT_SOURCE_DIR} )

set( Param_HEADERS ${Param_HEADERS}
    ${dir}/debug_msg.hh
    ${dir}/destroyer.hh
    ${dir}/error.hh
    ${dir}/factory.hh
    ${dir}/param_api.hh
    ${dir}/singleton.hh
    PARENT_SCOPE )
