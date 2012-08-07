
#include "headers.h"
#include "ec.h"
#include "logf.h"

int main(int argc, char *argv[])
{
    int r = 0;

    INSTANT_TRACE("This is instant trace.");

    logfmt_enable(false);  // disable
    BUFFERED_TRACE("This is buffered trace.");

    ec_nzero( r = 0 )

    return 0;

EC_CLEANUP_BGN
    return -1;
EC_CLEANUP_END

}


