CC = gcc
CPP = g++


MODULES = cspats_lib.o cspats.o


.PHONY: all
all: $(MODULES)

cspats_lib.o: cspats_lib.cpp cspats_lib.h
	$(CPP) -o $@ -c $<

cspats.o: cspats.cpp cspats.h cspats_lib.h
	$(CPP) -o $@ -c $<

test: $(MODULES) test.c
	$(CC) -o $@ test.c cspats_lib.o cspats.o \
common/ec.o common/logf.o common/syserr.o \
-pthread -lstdc++

.PHONY: clean
clean:
	rm -rf *.o
	rm -rf test


