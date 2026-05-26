.SUFFIXES: 
.SUFFIXES: .f90 .c

PROG =	barley

SRCS =	barley.c

OBJS =	barley.o

LIBS =	-lm

CC = icx
CFLAGS = -O0
LDFLAGS = 

all: $(PROG)

$(PROG): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	rm -f $(PROG) $(OBJS) *.mod

.SUFFIXES: $(SUFFIXES) .f90

.f90.o:
	$(F90) $(F90FLAGS) -c $<

