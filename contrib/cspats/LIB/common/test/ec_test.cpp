
#include "../headers.h"
#include "../ec.h"
#include "../logf.h"

int main(int argc, char *argv[])
{
    int r = 0;

    INSTANT_TRACE("This is instant trace. in log file");
    INSTANT_TRACE_FMT("This is instant trace.%d. in log file", 111);
    logfmt_enable(false);  // disable
    INSTANT_TRACE_FMT("This is instant trace.%d. not in log file", 333);

    BUFFERED_TRACE("This is buffered trace. in log file");
    logfmt_enable(true);  // disable
    BUFFERED_TRACE_FMT("This is buffered trace.%d. in log file", 222);

    ec_nzero( r = 0 )

    return 0;

EC_CLEANUP_BGN
    return -1;
EC_CLEANUP_END

}


