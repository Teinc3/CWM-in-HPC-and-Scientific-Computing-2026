INC := -I${CUDA_HOME}/include
LIB := -L${CUDA_HOME}/lib64 -lcudart -lcuda -lcurand

CC = gcc
GCC = g++
NVCC = ${CUDA_HOME}/bin/nvcc

NVCCFLAGS = -O3 -arch=sm_70 --ptxas-options=-v -Xcompiler -Wextra -lineinfo
CFLAGS_OMP = -O3 -mavx -std=c99 -Wall -Wextra -pedantic -fopenmp

INCS =

EXCFILE_CUDA = mc_pi_cuda
EXCFILE_OMP = mc_pi

default: all
all: clean omp cuda

omp: Makefile
	$(CC) $(INCS) $(CFLAGS_OMP) -o mc_pi mc_pi.c

cuda: Makefile
	$(NVCC) -o mc_pi_cuda mc_pi_cuda.cu $(LIB) $(NVCCFLAGS)

clean:
	rm -f *.o $(ANALYZE)
