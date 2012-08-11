

.PHONY: all
all:

include module.mk

ROOT := ../../../../

test := test


all: 
	$(MAKE) --directory=$(ROOT) ec_lib
	g++ test.cpp -L./ -l$(local_lib_name) -o $(test)
	./$(test)

.PHONY: clean
clean:
	$(MAKE) --directory=$(ROOT) clean
	rm -f $(test)
	rm -f *temp.log



#  CC = gcc
#  CPP = g++
#  
#  
#  MODULES = logf.o ec.o syserr.o test.o
#  
#  .PHONY: test
#  test: test.exe
#  	./test.exe
#  
#  logf.o: logf.c logf.h
#  	$(CC) -o $@ -c $<
#  
#  ec.o: ec.c ec.h
#  	$(CC) -o $@ -c $<
#  
#  syserr.o: syserr.c syserr.h
#  	$(CC) -o $@ -c $<
#  
#  test.o: test.cpp ec.h
#  	$(CPP) -o $@ -c $<
#  
#  test.exe: $(MODULES)
#  	$(CPP) -o $@ $(MODULES)
#  
#  .PHONY: clean cleanall
#  
#  
#  clean:
#  	rm -rf *.o
#  	rm -rf test.exe
#  
#  cleanall: clean
#  	rm -rf *.log
#  



