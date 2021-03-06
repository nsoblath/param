/*
 * destroyer.hh
 *
 *  Created on: Nov 7, 2011
 *      Author: nsoblath
 */

#ifndef PARAM_DESTROYER_HH_
#define PARAM_DESTROYER_HH_

namespace param
{

    template< class XDoomed >
    class destroyer
    {
        public:
            destroyer( XDoomed* = 0 );
            ~destroyer();

            void set_doomed( XDoomed* );

        private:
            // Prevent users from making copies of a destroyer to avoid double deletion:
            destroyer( const destroyer< XDoomed >& );
            void operator=( const destroyer< XDoomed >& );

        private:
            XDoomed* f_doomed;
    };

    template< class XDoomed >
    destroyer< XDoomed >::destroyer( XDoomed* d )
    {
        f_doomed = d;
    }

    template< class XDoomed >
    destroyer< XDoomed >::~destroyer()
    {
        delete f_doomed;
    }

    template< class XDoomed >
    void destroyer< XDoomed >::set_doomed( XDoomed* d )
    {
        f_doomed = d;
    }

} /* namespace param */
#endif /* PARAM_DESTROYER_HH_ */
