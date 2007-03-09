GCC = gcc
FLAGS = -O1
LIBS = /usr/lib/libgsl.a /usr/lib/libm.a


program: poisson.c
	${GCC} ${FLAGS} poisson.c ${LIBS} -o poisson.exe


clean::
	rm *.exe *.o
