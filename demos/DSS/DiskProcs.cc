/*
 * DiskProcs.cc
 * 
 * External action procedures linked to Channel dio and Atomic dint 
 */

#include "Lit.h"
#include "Action.h"

using namespace ucsp;	// for I/O


/*
 * Replaces dio?block:  start I/O on given block #
 */
void dio_chanInput( ActionType t, ActionRef* a, Var* v, Lit* block )
{
    cerr << "*** dio_chanInput: Starting I/O on block # " << *block << endl;
}


/*
 * Replaces dint:  disk interrupt 
 */
void dint_atomic( ActionType t, ActionRef* a, Var* v, Lit* l )
{
    cerr << "*** dint_atomic: Receiving disk interrupt" << endl;
}
