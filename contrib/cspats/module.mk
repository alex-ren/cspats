
local_lib_name := cspats

local_target := lib$(local_lib_name).a

local_src := $(wildcard $(subdirectory)/SATS/*.sats) \
             $(wildcard $(subdirectory)/DATS/*.dats)

$(eval $(call make-cspats_library, $(subdirectory)/$(local_target), $(local_src)))


