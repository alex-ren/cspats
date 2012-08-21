#include "cspats_lib.h"

#include <stdio.h>

int main(int argc, char *argv[])
{

    One2OneChannel *pch = One2OneChannel::create();
    Barrier2 *pba = Barrier2::create();

    Altable * arr[2] = {};
    arr[0] = pch;
    arr[1] = pba;

    Alternative *palt = Alternative::create(arr, 2);

    printf("==== main ==== 000001\n");
    palt->select();
    printf("==== main ==== 000002\n");

    return 0;
}

