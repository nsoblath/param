#define SCARAB_API_EXPORTS

#include "parsable.hh"

#include "logger.hh"

#include <sstream>


namespace scarab
{
    LOGGER( dlog, "parsable" );

    parsable::parsable() :
            param_node()
    {}

    parsable::parsable( const std::string& a_addr_with_value ) :
            param_node()
    {
        size_t t_val_pos = a_addr_with_value.find_first_of( f_value_separator );
        if( t_val_pos != std::string::npos )
        {
            add_next( *this, a_addr_with_value.substr( 0, t_val_pos ), a_addr_with_value.substr( t_val_pos + 1 ) );
        }
        else
        {
            add_next( *this, a_addr_with_value, "" );
        }
    }

    parsable::parsable( const std::string& a_addr, const std::string& a_value ) :
            param_node()
    {
        add_next( *this, a_addr, a_value );
    }

    parsable::parsable( const parsable& a_orig ) :
            param_node( a_orig )
    {}

    parsable::~parsable()
    {
    }

    void parsable::add_next( param_node& a_parent, const std::string& a_addr, const std::string& a_value )
    {
        size_t t_div_pos = a_addr.find( f_node_separator );
        if( t_div_pos == a_addr.npos )
        {
            // we've found the value; now check if it's a number or a string
            if( a_value.empty() )
            {
                a_parent.add( a_addr, std::move(param()) );
                LDEBUG( dlog, "Parsed value as NULL" << *this );
            }
            // if "true" or "false", then bool
            else if( a_value == "true" )
            {
                a_parent.add( a_addr, std::move(param_value( true )) );
                LDEBUG( dlog, "Parsed value (" << a_value << ") as bool(true)" << *this );
            }
            else if( a_value == "false" )
            {
                a_parent.add( a_addr, std::move(param_value( false )) );
                LDEBUG( dlog, "Parsed value (" << a_value << ") as bool(false):" << *this );
            }
            else
            {
                // To test if the string is numeric:
                //   1. if it has 2 decimal points, it's not numeric (IP addresses, for example, would pass the second test)
                //   2. double is the most general form of number, so if it fails that conversion, it's not numeric.
                double t_double;
                std::stringstream t_conv_double( a_value );
                if( a_value.find( '.' ) == a_value.rfind( '.' ) &&
                        a_value.find( '-' ) == a_value.rfind( '-' ) &&
                        ! (t_conv_double >> t_double).fail() )
                {
                    // now we know the value is numeric
                    if( a_value.find( '.' ) != std::string::npos ||
                        a_value.find( 'e' ) != std::string::npos ||
                        a_value.find( 'E' ) != std::string::npos )
                    {
                        // value is a floating-point number, since it has a decimal point
                        a_parent.add( a_addr, std::move(param_value( t_double )) );
                        LDEBUG( dlog, "Parsed value (" << a_value << ") as double(" << t_double << "):" << *this );
                    }
                    else if( a_value[ 0 ] == '-' )
                    {
                        // value is a signed integer if it's negative
                        a_parent.add( a_addr, std::move(param_value( (int64_t)t_double )) );
                        LDEBUG( dlog, "Parsed value (" << a_value << ") as int(" << (int64_t)t_double << "):" << *this );
                    }
                    else
                    {
                        // value is assumed to be unsigned if it's positive
                        a_parent.add( a_addr, std::move(param_value( (uint64_t)t_double )) );
                        LDEBUG( dlog, "Parsed value (" << a_value << ") as uint(" << (uint64_t)t_double << ");" << *this );
                    }
                }
                else
                {
                    // value is not numeric; treat as a string
                    a_parent.add( a_addr, std::move(param_value( a_value )) );
                    LDEBUG( dlog, "Parsed value (" << a_value << ") as a string:" << *this );
                }
            }
            return;
        }
        param_node t_new_node;
        a_parent.add( a_addr.substr( 0, t_div_pos ), std::move(t_new_node) );
        add_next( t_new_node, a_addr.substr( t_div_pos + 1 ), a_value );
        return;
    }

}
