/*
 * debug_msg.hh
 *
 *  Created on: July 29, 2018
 *      Author: nsoblath
 */

#ifndef PARAM_UTILITY_DEBUG_MSG_HH_
#define PARAM_UTILITY_DEBUG_MSG_HH_

#include <iostream>

#ifdef NDEBUG
#define COUT_DEBUG( msg )
#else
#define COUT_DEBUG( msg ) std::cout << msg << std::endl;
#endif

#define COUT_MSG( msg ) std::cout << msg << std::endl;

#define CERR_WARNING( msg ) std::cerr << "WARNING: " << msg << std::endl;

#define CERR_ERROR( msg ) std::cerr << "ERROR: " << msg << std::endl;

#endif /* PARAM_UTILITY_DEBUG_MSG_HH_ */
