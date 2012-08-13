

local_prog_name := test

local_target := $(local_prog_name)

# local_src := $(wildcard $(subdirectory)/SATS/*.sats) \
#              $(wildcard $(subdirectory)/DATS/*.dats)
local_src := $(subdirectory)/DSS.dats

$(eval $(call make-cspprogram, $(subdirectory)/$(local_target), $(local_src)))

