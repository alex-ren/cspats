
local_lib_name := cspcpp

local_target := lib$(local_lib_name).a

local_src := $(wildcard $(subdirectory)/*.cpp)

$(eval $(call make-cspcpp_library, $(subdirectory)/$(local_target), $(local_src)))


test_dir := test
local_test01_target := cspcpp_test
local_test01_src := $(wildcard $(subdirectory)/$(test_dir)/*.cpp)
$(eval $(call make-cspcpp_test, $(subdirectory)/$(test_dir)/$(local_test01_target), $(local_test01_src)))


