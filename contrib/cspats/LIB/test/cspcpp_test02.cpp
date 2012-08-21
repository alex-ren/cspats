
#include "cspats.h"

#include "cspats_lib.h"

#include <stdio.h>

int main(int argc, char *argv[])
{
    one2one_chan_ptr p_ch = NULL;
    barrier2_ptr     p_bar= NULL;
    int ret = -1;

    alt_ptr p_alt_ch = NULL;
    alt_ptr p_alt_bar = NULL;

    p_ch = one2one_chan_create();
    p_alt_ch = one2one_chan_in_2_alt(p_ch);

    p_bar = barrier2_create();
    p_alt_bar = barrier2_2_alt(p_bar);

    ret = alternative_2(p_alt_ch, p_alt_bar);

    printf("==================================\n");

}


