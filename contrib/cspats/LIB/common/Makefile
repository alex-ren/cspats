
CC = gcc
CPP = g++


MODULES = logf.o ec.o syserr.o test.o

.PHONY: test
test: test.exe
	./test.exe

logf.o: logf.c logf.h
	$(CC) -o $@ -c $<

ec.o: ec.c ec.h
	$(CC) -o $@ -c $<

syserr.o: syserr.c syserr.h
	$(CC) -o $@ -c $<

test.o: test.cpp ec.h
	$(CPP) -o $@ -c $<

test.exe: $(MODULES)
	$(CPP) -o $@ $(MODULES)

.PHONY: clean cleanall


clean:
	rm -rf *.o
	rm -rf test.exe

cleanall: clean
	rm -rf *.log




