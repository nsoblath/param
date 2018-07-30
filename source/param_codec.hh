/*
 * param_codec.hh
 *
 *  Created on: Aug 10, 2016
 *      Author: N.S. Oblath
 */

#ifndef PARAM_PARAM_CODEC_HH_
#define PARAM_PARAM_CODEC_HH_

#include "param.hh"

#include "factory.hh"

#include <memory>
#include <string>

namespace param
{

#define REGISTER_PARAM_INPUT_CODEC(codec_class, encoding) \
        static registrar< param_input_codec, codec_class > s_param_input_codec##codec_class##_registrar( encoding );

    class PARAM_API param_input_codec
    {
        public:
            param_input_codec();
            virtual ~param_input_codec();

            virtual param_ptr_t read_file( const std::string& a_filename, const param_node& a_options = param_node() ) = 0;
            virtual param_ptr_t read_string( const std::string& a_string, const param_node& a_options = param_node() ) = 0;
    };


    class PARAM_API param_output_codec
    {
        public:
            param_output_codec();
            virtual ~param_output_codec();

            virtual bool write_file( const param& a_param, const std::string& a_filename, const param_node& a_options = param_node() ) = 0;
            virtual bool write_string( const param& a_param, std::string& a_string, const param_node& a_options = param_node() ) = 0;
    };

#define REGISTER_PARAM_OUTPUT_CODEC(codec_class, encoding) \
        static registrar< param_output_codec, codec_class > s_param_output_codec##codec_class##_registrar( encoding );


    class PARAM_API param_translator
    {
        public:
            param_translator();
            ~param_translator();

        public:
            param_ptr_t read_file( const std::string& a_filename, const param_node& a_options = param_node()  );
            param_ptr_t read_string( const std::string& a_string, const param_node& a_options = param_node()  );

        public:
            bool write_file( const param& a_param, const std::string& a_filename, const param_node& a_options = param_node() );
            bool write_string( const param& a_param, std::string& a_string, const param_node& a_options = param_node() );
    };



} /* namespace param */

#endif /* PARAM_PARAM_CODEC_HH_ */
