/*
 * param_codec.cc
 *
 *  Created on: Aug 10, 2016
 *      Author: obla999
 */

#define PARAM_API_EXPORTS

#include "param_codec.hh"

#include "factory.hh"

namespace param
{

    param_input_codec::param_input_codec()
    {
    }

    param_input_codec::~param_input_codec()
    {
    }


    param_output_codec::param_output_codec()
    {
    }

    param_output_codec::~param_output_codec()
    {
    }


    param_translator::param_translator()
    {
    }

    param_translator::~param_translator()
    {
    }

    param_ptr_t param_translator::read_file( const std::string& a_filename, const param_node& a_options  )
    {
        std::string t_encoding = a_options.get_value( "encoding", "" );
        if( t_encoding.empty() )
        {
            // no encoding provided; get the file extension by finding the text after the last '.' in the filename
            size_t t_dot_pos = a_filename.find_last_of( '.' );
            if( t_dot_pos == a_filename.npos )
            {
                throw error() << "Encoding was not provided, and could not identify file extension to determine an encoding";
            }
            t_encoding = a_filename.substr( t_dot_pos+1 );
        }

        param_input_codec* t_codec = factory< param_input_codec >::get_instance()->create( t_encoding );
        if( t_codec == nullptr )
        {
            throw error() << "Unable to find codec for encoding <" << t_encoding << ">";
        }

        return t_codec->read_file( a_filename, a_options );
    }

    param_ptr_t param_translator::read_string( const std::string& a_string, const param_node& a_options  )
    {
        std::string t_encoding = a_options.get_value( "encoding", "" );
        if( t_encoding.empty() )
        {
            throw error() << "Encoding-type option must be provided";
        }

        param_input_codec* t_codec = factory< param_input_codec >::get_instance()->create( t_encoding );
        if( t_codec == nullptr )
        {
            throw error() << "Unable to find input codec for encoding <" << t_encoding << ">";
        }

        return t_codec->read_string( a_string, a_options );
    }

    bool param_translator::write_file( const param& a_param, const std::string& a_filename, const param_node& a_options  )
    {
        std::string t_encoding = a_options.get_value( "encoding", "" );
        if( t_encoding.empty() )
        {
            // no encoding provided; get the file extension by finding the text after the last '.' in the filename
            size_t t_dot_pos = a_filename.find_last_of( '.' );
            if( t_dot_pos == a_filename.npos )
            {
                throw error() << "Encoding was not provided, and could not identify file extension to determine an encoding";
            }
            t_encoding = a_filename.substr( t_dot_pos+1 );
        }

        param_output_codec* t_codec = factory< param_output_codec >::get_instance()->create( t_encoding );
        if( t_codec == nullptr )
        {
            throw error() << "Unable to find output codec for encoding <" << t_encoding << ">";
        }

        return t_codec->write_file( a_param, a_filename, a_options );
    }

    bool param_translator::write_string( const param& a_param, std::string& a_string, const param_node& a_options  )
    {
        std::string t_encoding = a_options.get_value( "encoding", "" );
        if( t_encoding.empty() )
        {
            throw error() << "Encoding-type option must be provided";
        }

        param_output_codec* t_codec = factory< param_output_codec >::get_instance()->create( t_encoding );
        if( t_codec == nullptr )
        {
            throw error() << "Unable to find output codec for encoding <" << t_encoding << ">";
        }

        return t_codec->write_string( a_param, a_string, a_options );
    }


} /* namespace param */
