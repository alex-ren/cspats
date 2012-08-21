
local_lib_name := cspcpp

local_target := lib$(local_lib_name).a

local_src := $(wildcard $(subdirectory)/*.cpp)

$(eval $(call make-cspcpp_library, $(subdirectory)/$(local_target), $(local_src)))


test_dir := test

# local_src_test := $(wildcard $(subdirectory)/$(test_dir)/*.cpp)
local_src_test01 := $(wildcard $(subdirectory)/$(test_dir)/cspcpp_test.cpp)
local_src_test02 := $(wildcard $(subdirectory)/$(test_dir)/cspcpp_test02.cpp)
$(eval $(call make-cspcpp_test, $(subdirectory)/$(test_dir)/cspcpp_test, $(local_src_test01)))
$(eval $(call make-cspcpp_test, $(subdirectory)/$(test_dir)/cspcpp_test02, $(local_src_test02)))


