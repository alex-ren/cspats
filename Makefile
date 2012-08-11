##
##
## A Makefile template for compiling ATS programs
##
##

######


#==================================

ATSUSRQ="$(ATSHOME)"
ATSLIBQ=$(ATSUSRQ)
ifeq ($(ATSUSRQ),"")
ATSUSRQ="/usr"
endif # end of [ifeq]

######

ATSCC=$(ATSUSRQ)/bin/atscc
ATSOPT=$(ATSUSRQ)/bin/atsopt

#==================================

CWD=$(shell pwd)

define atscname
$(patsubst %.dats,%_dats.c,$(patsubst %.sats,%_sats.c,$1))
endef

#==================================

CC=gcc
CPP=g++

######

# $(call source-to-object, source-file-list)
source-to-object = $(subst .c,.o,$(filter %.c,$1)) \
                   $(subst .cpp,.o,$(filter %.cpp,$1)) \
                   $(subst .sats,_sats.o,$(filter %.sats,$1)) \
                   $(subst .dats,_dats.o,$(filter %.dats,$1))


# $(subdirectory)
subdirectory = $(patsubst %/module.mk,%,    \
                 $(word                     \
                   $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))

# ------------------------------------------------------
# $(call make-library, library-name, source-file-list)
define make-library
  libraries += $1
  sources   += $2

  $1: $(call source-to-object,$2)
	$(AR) $(ARFLAGS) $$@ $$^
endef

# ------------------------------------------------------
# $(call make-ec_library, library-name, source-file-list)
define make-ec_library
  ec_lib += $1
  sources   += $2

  $1: $(call source-to-object,$2)
	$(AR) $(ARFLAGS) $$@ $$^
endef

# ------------------------------------------------------
# $(call make-cspcpp_library, library-name, source-file-list)
define make-cspcpp_library
  cspcpp_lib += $1
  sources   += $2

  $1: $(call source-to-object,$2) $(ec_lib)
	$(AR) $(ARFLAGS) $$@ $$^
endef

# ------------------------------------------------------
# $(call generated-source, source-file-list)
generated-ats-source = $(call atscname,$(filter %.sats,$1)) \
                   $(call atscname,$(filter %.dats,$1))

# Collect information from each module in these four variables.
# Initialize them here as simple variables

modules   := contrib/cspats contrib/cspats/LIB contrib/cspats/LIB/common test
programs  :=
ec_lib    :=
cspcpp_lib:=
libraries :=
sources   :=

# file extension for dependency files
depgcc := depgcc
depsats := depsats
depdats := depdats

objects      = $(call source-to-object,$(sources))
dependencies = $(subst .o,.$(depgcc),$(objects)) \
               $(subst .sats,.$(depsats),$(filter %.sats,$(sources))) \
               $(subst .dats,.$(depdats),$(filter %.dats,$(sources)))


include_dirs := contrib/cspats/LIB contrib/cspats/LIB/common
# CPPFLAGS  += $(addprefix -I ,$(include_dirs))
# vpath %.h $(include_dirs)

ATSCCFLAGS=-I $(CWD)


MV  := mv -f
RM  := rm -f
SED := sed

all:
# todo include $(addsuffix /module.mk,$(modules))
# todo add more xx.mk here
include contrib/cspats/LIB/common/module.mk
include contrib/cspats/LIB/module.mk

# must after the include
libraries += $(ec_lib) $(cspcpp_lib)

.PHONY: all
all: $(programs)

.PHONY: libraries
libraries: $(libraries)

.PHONY: ec_lib
ec_lib: $(ec_lib)

.PHONY: cspcpp_lib
cspcpp_lib: $(cspcpp_lib)

.PHONY: clean
clean:
	$(RM) $(objects) $(programs) $(libraries) $(dependencies)  \
            $(call generated-ats-source, $(sources))

ifneq "$(MAKECMDGOALS)" "clean"
  include $(dependencies)
endif


# %_sats.c: %.sats
$(call atscname,%.sats): %.sats
	$(ATSOPT) --output $@ $(ATSCCFLAGS) --static $<

$(call atscname,%.dats): %.dats
	$(ATSOPT) --output $@ $(ATSCCFLAGS) --dynamic $<

CPP_DEP = $(subst .cpp,.$(depgcc),$(filter %.cpp,$(sources)))
C_DEP   = $(subst .c,.$(depgcc),$(filter %.c,$(sources)))


# xxx.depgcc: xxx.cpp
$(CPP_DEP): %.$(depgcc): %.cpp
	$(CPP) $(CFLAGS) $(CPPFLAGS) -M $< | \
	$(SED) 's,\($(notdir $*)\.o\)[ :]*,$(dir $@)\1 $@: ,g' > $@.tmp
	$(MV) $@.tmp $@

# xxx.depgcc: xxx.c
$(C_DEP): %.$(depgcc): %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -M $< | \
	$(SED) 's,\($(notdir $*)\.o\)[ :]*,$(dir $@)\1 $@: ,g' > $@.tmp
	$(MV) $@.tmp $@


##########################################################
#    
#    
#    #LIBPARCOMB=$(ATSHOME)/contrib/parcomb/atsctrb_parcomb.o
#    LIBCSP := \
#    contrib/cspats/LIB/cspats_lib.o \
#    contrib/cspats/LIB/cspats.o \
#    contrib/cspats/LIB/common/ec.o \
#    contrib/cspats/LIB/common/logf.o \
#    contrib/cspats/LIB/common/syserr.o \
#    
#    ######
#    
#    #
#    # HX: Please uncomment the one you want, or skip it entirely
#    #
#    # ATSCCFLAGS=-D_ATS_GCATS
#    #
#    # '-flto' enables link-time optimization such as inlining lib functions
#    #
#    #ATSCCFLAGS=-O2 -flto -D_ATS_GCATS
#    
#    ######
#    
#    ######
#    RMF = rm -f
#    
#    # convert the file name to .o files
#    # $(call atsobjname,filelist)
#    define atsobjname
#    $(patsubst %.dats,%_dats.o,$(patsubst %.sats,%_sats.o,$1))
#    endef
#    
#    define atsdepname
#    $(patsubst %.dats,%_dats.d,$(patsubst %.sats,%_sats.d,$1))
#    endef
#    
#    define atshtmlname
#    $(patsubst %.dats,%_dats.html,$(patsubst %.sats,%_sats.html,$1))
#    endef
#    
#    SOURCES := \
#      test.dats \
#      contrib/cspats/SATS/cspats.sats \
#      contrib/cspats/DATS/cspats.dats \
#    
#    OBJECTS := $(call atsobjname,$(SOURCES))
#    
#    target := tester
#    
#    .PHONY: all
#    all: $(target)
#    
#    tester: $(OBJECTS)
#    	$(ATSCC) -o $@ $^ $(LIBCSP) -pthread -lstdc++
#    
#    
#    # #################
#    $(call atsobjname,%.sats): %.sats
#    	$(ATSCC) $(ATSCCFLAGS) -c $< -o $@
#    # || touch $@
#    
#    $(call atsobjname,%.dats): %.dats
#    	$(ATSCC) $(ATSCCFLAGS) -c $< -o $@
#    
#    #                  # #################
#    #                  # Generate dependency files
#    #                  # SOURCESsta := $(filter %.sats, $(SOURCES))
#    #                  # SOURCESdyn := $(filter %.dats, $(SOURCES))
#    #                  
#    #                  ifneq "$(findstring clean,$(MAKECMDGOALS))" "clean"
#    #                    ifneq "$(MAKECMDGOALS)" "html"
#    #                      -include $(call atsdepname,$(SOURCES))
#    #                    endif
#    #                  endif
#    
#    $(call atsdepname,%.sats): %.sats
#    	$(ATSOPT) -o $@.$$$$ -dep1 -s $<;    \
#    	sed 's/\(.*\)\.o[ :]*/\1.o $@ : /g' < $@.$$$$ > $@;    \
#    	rm -f $@.$$$$
#    
#    $(call atsdepname,%.dats): %.dats
#    	$(ATSOPT) -o $@.$$$$ -dep1 -d $<;    \
#    	sed 's/\(.*\)\.o[ :]*/\1.o $@ : /g' < $@.$$$$ > $@;    \
#    	rm -f $@.$$$$
#    ######
#    # Generate html files for ATS source code
#    source_sats := $(wildcard *.sats)
#    source_dats := $(wildcard *.dats)
#    
#    html_file_sats := $(call atshtmlname,$(source_sats))
#    html_file_dats := $(call atshtmlname,$(source_dats))
#    
#    .PHONY: html
#    
#    html: $(html_file_sats) $(html_file_dats)
#    
#    $(html_file_sats): $(call atshtmlname,%.sats): %.sats
#    	$(ATSOPT) --posmark_html -s $< > $@
#    
#    $(html_file_dats): $(call atshtmlname,%.dats): %.dats
#    	$(ATSOPT) --posmark_html -d $< > $@
#    
#    ######
#    
#    .PHONY: clean distclean
#    
#    clean::
#    	$(RMF) *~
#    	$(RMF) $(call atsobjname,*.sats *.dats)
#    	$(RMF) $(call atsdepname,*.sats *.dats)
#    	$(RMF) *_?ats.c
#    	$(RMF) $(target)
#    
#    distclean: clean
#    	$(RMF) $(call atshtmlname,*.sats *.dats)
#    
#    ###### end of [Makefile] ######
#    
#    
#    
