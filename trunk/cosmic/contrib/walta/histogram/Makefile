CC = g++
#  if you are not on neutrino, comment out the -march=athlon-tbird
# CFLAGS = -O3 -march=athlon-tbird
CFLAGS = -O3 -I../include

program:
	$(CC) $(CFLAGS) rik__histogram.cc -c

clean::
	rm *.exe *.o
