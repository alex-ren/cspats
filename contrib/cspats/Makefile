

.PHONY: all
all:

include module.mk

ROOT := ../../

all: 
	$(MAKE) --directory=$(ROOT) cspats_lib

.PHONY: clean
clean:
	$(MAKE) --directory=$(ROOT) clean







#  ##
#  ##
#  ## A Makefile template for compiling ATS programs
#  ##
#  ##
#  
#  ######
#  
#  
#  ######
#  
#  ATSUSRQ="$(ATSHOME)"
#  ATSLIBQ=$(ATSUSRQ)
#  ifeq ($(ATSUSRQ),"")
#  ATSUSRQ="/usr"
#  endif # end of [ifeq]
#  
#  ######
#  
#  ATSCC=$(ATSUSRQ)/bin/atscc
#  ATSOPT=$(ATSUSRQ)/bin/atsopt
#  
#  CWD=$(shell pwd)
#  
#  
#  #
#  # HX: Please uncomment the one you want, or skip it entirely
#  #
#  ATSCCFLAGS=-IATS ../../ -I ../../
#  # ATSCCFLAGS=-D_ATS_GCATS
#  #
#  # '-flto' enables link-time optimization such as inlining lib functions
#  #
#  #ATSCCFLAGS=-O2 -flto -D_ATS_GCATS
#  
#  ######
#  
#  ######
#  RMF = rm -f
#  
#  
#  SOURCES := \
#    DATS/cspats.dats \
#    SATS/cspats.sats \
#  
#  
#  # convert the file name to .o files
#  # $(call atsobjname,filelist)
#  define atsobjname
#  $(patsubst %.dats,%_dats.o,$(patsubst %.sats,%_sats.o,$1))
#  endef
#  
#  define atsgenname
#  $(patsubst %.dats,%_dats.c,$(patsubst %.sats,%_sats.c,$1))
#  endef
#  
#  OBJECTS := $(call atsobjname,$(SOURCES))
#  
#  .PHONY: all
#  all: $(OBJECTS)
#  
#  $(call atsobjname, DATS/cspats.dats): DATS/cspats.dats SATS/cspats.sats
#  	$(ATSCC) $(ATSCCFLAGS) -c $< -o $@
#  
#  
#  $(call atsobjname, SATS/cspats.sats): SATS/cspats.sats
#  	$(ATSCC) $(ATSCCFLAGS) -c $< -o $@
#  
#  ######
#  
#  ######
#  
#  .PHONY: clean
#  
#  clean::
#  	$(RMF) *~
#  	$(RMF) $(call atsgenname,*.sats *.dats) # remove C file
#  	$(RMF) $(OBJECTS) # remove obj file
#  #	$(RMF) $(call atsgenname,$(SOURCES))
#  
#  
#  ###### end of [Makefile] ######
#  
#  
#  
