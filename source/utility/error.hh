/*
 * error.hh
 *
 *  Created on: Nov 7, 2011
 *      Author: nsoblath
 */

#ifndef PARAM_EXCEPTION_HH_
#define PARAM_EXCEPTION_HH_

#include "param_api.hh"

#include <exception>
#include <sstream>
#include <string>

namespace param
{

    class PARAM_API error : public ::std::exception
    {
        public:
            error() : std::exception(), f_error() {};
            error( const error& orig ) : std::exception(), f_error( orig.f_error ) {};
            ~error() throw () {};

            template< class x_streamable >
            error& operator<<( x_streamable a_fragment );
            error& operator<<( const std::string& a_fragment );
            error& operator<<( const char* a_fragment );

            virtual const char* what() const throw();

        private:
            std::string f_error;
    };

    template< class x_streamable >
    error& error::operator<<( x_streamable a_fragment )
    {
        std::stringstream stream;
        stream << a_fragment;
        stream >> f_error;
        return *this;
    }

    inline error& error::operator<<( const std::string& a_fragment )
    {
        f_error += a_fragment;
        return *this;
    }

    inline error& error::operator<<( const char* a_fragment )
    {
        f_error += std::string( a_fragment );
        return *this;
    }

    inline const char* error::what() const throw ()
    {
        return f_error.c_str();
    }

}

#endif /* PARAM_EXCEPTION_HH_ */
