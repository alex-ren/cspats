
local_lib_name := logtool

local_target := lib$(local_lib_name).a

local_src := $(wildcard $(subdirectory)/SATS/*.sats) \
             $(wildcard $(subdirectory)/DATS/*.dats)

$(eval $(call make-logtool_library, $(subdirectory)/$(local_target), $(local_src)))


