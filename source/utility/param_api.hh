/*
 * param_api.hh
 *
 *  Created on: Jan 1, 2016
 *      Author: nsoblath
 */

#ifndef PARAM_API_HH_
#define PARAM_API_HH_


namespace param
{
    // API export macros for windows
#ifdef _WIN32
#  ifdef PARAM_API_EXPORTS
#    define PARAM_API __declspec(dllexport)
#    define PARAM_EXPIMP_TEMPLATE
#  else
#    define PARAM_API __declspec(dllimport)
#    define PARAM_EXPIMP_TEMPLATE extern
#  endif
#else
#  define PARAM_API
#endif

}

#endif /* PARAM_API_HH_ */
