default: VSFS

VSFS: VSFS.o
	g++ -Wall -Werror -std=c++11 VSFS.o -O -o VSFS 

VSFS.o: VSFS.cpp
	g++ -c VSFS.cpp

clean: 
	rm *.o VSFS

