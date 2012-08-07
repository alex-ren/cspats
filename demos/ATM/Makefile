# Makefile for ATM demo as of V4.2
# Target-specific variable syntax works with GNU make.
#
# NOTE: pth-config must be in path
# You may need to set LD_LIBRARY_PATH to find libpth.so

# CSP++ installation (parent of bin, include, lib)
#
CSP = ../../v4.2

# MySQL installation
#
# NOTE: You may need to set LD_LIBRARY_PATH to location of mysqlclient.so, e.g.,
# /opt/sfw/mysql/lib/mysql
#
SQL = /opt/sfw/mysql

# Compile flags (compiling is via implicit rule)
#
#	-fno_exceptions 	CSP++ does not use exceptions; this reduces object size
#
CPPFLAGS = -I$(CSP)/include/cspxx -I$(SQL)/include/mysql
CXX = /opt/sfw/gcc-3/bin/g++
CXXFLAGS = -Wall -fno-exceptions -g -O2 `pth-config --cflags`
CCC = $(CXX)
CCFLAGS = $(CXXFLAGS)

# Linker flags
#
#	-lcspxx 	CSP++ runtime framework
#	-lpth		Pth threads
#	-lsocket	Sockets library (Solaris needs with Pth)
#	-lresolv	Resolver library
#	-lnsl		Network services library
#
LDFLAGS = `pth-config --ldflags` -L$(CSP)/lib -lcspxx \
	-lpth -lresolv -lnsl -L$(SQL)/lib/mysql -lmysqlclient
LDFLAGS += -lsocket	# Solaris-specific lib

# Rule: how to run translator
#
%cc: %csp
	$(CSP)/bin/cspt -s $<


all: atm bank


atm: atm.o atmprocs.o
	$(CCC) -o $@ atm.o atmprocs.o $(LDFLAGS)

atm.o: atm.cc
atm.o: CPPFLAGS += \
	-Dmachcash_p=machcash_chanInput		-Dinsertcard_p=insertcard_atomic \
	-Dreadcard_p=readcard_chanInput 	-Dreadpin_p=readpin_chanInput \
	-Dchoose_p=choose_chanInput		-Dgetacct_p=getacct_chanInput \
	-Dgetamnt_p=getamnt_chanInput		-Dgetfrom_p=getfrom_chanInput \
	-Dgetto_p=getto_chanInput		-Dbanksend_p=banksend_chanOutput \
	-Dbankstatus_p=bankstatus_chanInput	-Dcommit_p=commit_atomic \
	-Drollback_p=rollback_atomic		-Dagain_p=again_chanInput \
	-Dstartenv_p=startenv_atomic		-Dinsertenv_p=insertenv_atomic \
	-DexceedsMch_p=exceedsMch_atomic	-Ddispense_p=dispense_chanOutput \
	-Dreadnewpin_p=readnewpin_chanInput	-Dsameacct_p=sameacct_atomic \
	-Ddisplay_p=display_chanOutput		-Dcancel_p=cancel_atomic

atm.cc: atm.csp


bank: bank.o
	$(CCC) -o $@ bank.o $(LDFLAGS)
	
bank.o: bank.cc


clean:
	-rm core* *.o atm atm.cc bank
