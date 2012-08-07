# Makefile for DSS demo as of V4.2
#
# NOTE: pth-config must be in path
# You may need to set LD_LIBRARY_PATH to find libpth.so

# CSP++ installation (parent of bin, include, lib)
#
CSP = $(HOME)/programs/install
# CSP = /home/grad2/aren/programs/install

# Compile flags (compiling is via implicit rule)
#
#	-fno_exceptions 	CSP++ does not use exceptions; this reduces object size
#
CPPFLAGS = -I$(CSP)/include/cspxx -I$(MYINC)
CXX = g++ #/opt/sfw/gcc-3/bin/g++
CXXFLAGS = -Wall -fno-exceptions -g -O2 `pth-config --cflags`
CCC = $(CXX)
CCFLAGS = $(CXXFLAGS)

# Linker flags
#
#	-lcspxx 	CSP++ runtime framework
#	-lpth		Pth threads
#	-lsocket	Solaris (needed with Pth)
#
LDFLAGS = `pth-config --ldflags` -L$(CSP)/lib -lcspxx -lpth # -lsocket

# Rule: how to run translator
#
%cc: %csp
	$(CSP)/bin/cspt -s $<


all: DSS DSSsim


DSS: DSS.o DiskProcs.o
	$(CCC) -o $@ DSS.o DiskProcs.o $(LDFLAGS)

DSS.o: DSS.cc
DSS.o := CPPFLAGS += -Ddio_p=dio_chanInput -Ddint_p=dint_atomic

DSS.cc: DSS.csp

DiskProcs.o: DiskProcs.cc



DSSsim: DSSsim.o
	$(CCC) -o $@ DSSsim.o $(LDFLAGS)

DSSsim.o: DSSsim.cc

DSSsim.cc: DSSsim.csp


clean:
	-rm -f core* *.o DSS DSS.cc DSSsim DSSsim.cc
