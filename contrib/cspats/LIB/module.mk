
local_lib_name := cspcpp

local_target := lib$(local_lib_name).a

local_src := $(wildcard $(subdirectory)/*.cpp)

$(eval $(call make-cspcpp_library, $(subdirectory)/$(local_target), $(local_src)))


