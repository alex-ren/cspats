##
##
## A Makefile template for compiling ATS programs
##
##

######


######

ATSUSRQ="$(ATSHOME)"
ATSLIBQ=$(ATSUSRQ)
ifeq ($(ATSUSRQ),"")
ATSUSRQ="/usr"
endif # end of [ifeq]

######

ATSCC=$(ATSUSRQ)/bin/atscc
ATSOPT=$(ATSUSRQ)/bin/atsopt

CWD=$(shell pwd)

#LIBPARCOMB=$(ATSHOME)/contrib/parcomb/atsctrb_parcomb.o
LIBCSP := \
contrib/cspats/LIB/cspats_lib.o \
contrib/cspats/LIB/cspats.o \
contrib/cspats/LIB/common/ec.o \
contrib/cspats/LIB/common/logf.o \
contrib/cspats/LIB/common/syserr.o \

######

#
# HX: Please uncomment the one you want, or skip it entirely
#
ATSCCFLAGS=-I $(CWD)
# ATSCCFLAGS=-D_ATS_GCATS
#
# '-flto' enables link-time optimization such as inlining lib functions
#
#ATSCCFLAGS=-O2 -flto -D_ATS_GCATS

######

######
RMF = rm -f

# convert the file name to .o files
# $(call atsobjname,filelist)
define atsobjname
$(patsubst %.dats,%_dats.o,$(patsubst %.sats,%_sats.o,$1))
endef

define atsdepname
$(patsubst %.dats,%_dats.d,$(patsubst %.sats,%_sats.d,$1))
endef

define atshtmlname
$(patsubst %.dats,%_dats.html,$(patsubst %.sats,%_sats.html,$1))
endef

SOURCES := \
  test.dats \
  contrib/cspats/SATS/cspats.sats \
  contrib/cspats/DATS/cspats.dats \

OBJECTS := $(call atsobjname,$(SOURCES))

target := tester

.PHONY: all
all: $(target)

tester: $(OBJECTS)
	$(ATSCC) -o $@ $^ $(LIBCSP) -pthread -lstdc++


# #################
$(call atsobjname,%.sats): %.sats
	$(ATSCC) $(ATSCCFLAGS) -c $< -o $@
# || touch $@

$(call atsobjname,%.dats): %.dats
	$(ATSCC) $(ATSCCFLAGS) -c $< -o $@

#                  # #################
#                  # Generate dependency files
#                  # SOURCESsta := $(filter %.sats, $(SOURCES))
#                  # SOURCESdyn := $(filter %.dats, $(SOURCES))
#                  
#                  ifneq "$(findstring clean,$(MAKECMDGOALS))" "clean"
#                    ifneq "$(MAKECMDGOALS)" "html"
#                      -include $(call atsdepname,$(SOURCES))
#                    endif
#                  endif

$(call atsdepname,%.sats): %.sats
	$(ATSOPT) -o $@.$$$$ -dep1 -s $<;    \
	sed 's/\(.*\)\.o[ :]*/\1.o $@ : /g' < $@.$$$$ > $@;    \
	rm -f $@.$$$$

$(call atsdepname,%.dats): %.dats
	$(ATSOPT) -o $@.$$$$ -dep1 -d $<;    \
	sed 's/\(.*\)\.o[ :]*/\1.o $@ : /g' < $@.$$$$ > $@;    \
	rm -f $@.$$$$
######
# Generate html files for ATS source code
source_sats := $(wildcard *.sats)
source_dats := $(wildcard *.dats)

html_file_sats := $(call atshtmlname,$(source_sats))
html_file_dats := $(call atshtmlname,$(source_dats))

.PHONY: html

html: $(html_file_sats) $(html_file_dats)

$(html_file_sats): $(call atshtmlname,%.sats): %.sats
	$(ATSOPT) --posmark_html -s $< > $@

$(html_file_dats): $(call atshtmlname,%.dats): %.dats
	$(ATSOPT) --posmark_html -d $< > $@

######

.PHONY: clean distclean

clean::
	$(RMF) *~
	$(RMF) $(call atsobjname,*.sats *.dats)
	$(RMF) $(call atsdepname,*.sats *.dats)
	$(RMF) *_?ats.c
	$(RMF) $(target)

distclean: clean
	$(RMF) $(call atshtmlname,*.sats *.dats)

###### end of [Makefile] ######



