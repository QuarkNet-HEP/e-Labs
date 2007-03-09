CC = g++
#  if you are not on neutrino, comment out the -march=athlon-tbird
# CFLAGS = -O3 -march=athlon-tbird
CFLAGS = -O1 -I./include


.SUFFIXES : .exe

.cc.exe:
	$(CC) $(CFLAGS) $< -o $*.exe

program: ${OBJS} ${LIBS}

