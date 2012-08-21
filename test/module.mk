


local_target_DSS := DSS
local_target_test01 := test01
local_target_test02 := test02

# local_src := $(wildcard $(subdirectory)/SATS/*.sats) \
#              $(wildcard $(subdirectory)/DATS/*.dats)
local_src_DSS := $(subdirectory)/DSS.dats
local_src_test01 := $(subdirectory)/test01.dats
local_src_test02 := $(subdirectory)/test02.c

$(eval $(call make-cspprogram, $(subdirectory)/$(local_target_DSS), $(local_src_DSS)))
$(eval $(call make-cspprogram, $(subdirectory)/$(local_target_test01), $(local_src_test01)))
#$(eval $(call make-cspcpp_test, $(subdirectory)/$(local_target_test02), $(local_src_test02)))

