
local_lib_name := ec

local_target := lib$(local_lib_name).a

local_src := $(wildcard $(subdirectory)/*.c)

$(eval $(call make-ec_library, $(subdirectory)/$(local_target), $(local_src)))


