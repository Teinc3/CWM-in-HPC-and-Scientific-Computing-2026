#include <stdio.h>
#include <stdlib.h>
#include <math.h>
// Also import cuda headers
#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
//rng within cuda
#include <curand.h>


// Initialise the kernel fns
__device__ int getIdx()
{
	return threadIdx.x + blockIdx.x * blockDim.x;
}

__global__ void check(int *output_arr, float *randx, float *randy, int N)
{
  	int idx = getIdx();
	if (idx >= N)
	{
		return;
	}

	// Now set the value into the output array
	float x = randx[idx];
	float y = randy[idx];
  	bool is_in_circle = x * x + y * y <= 1.0f;
	output_arr[idx] = (int)is_in_circle;
}

__global__ void reduce(int *arr, int gap, int N)
{
	// Iter 1 (gap=1): 0+1->0, 2+3->2, 4+5->4
	// Iter 2 (gap=2): 0+2->0, 4+6->4, 8+10->8
	// Iter 3 (gap=4): 0+4->0, 8+12->8, 16+20->16
	int idx = getIdx();
	int closer_idx = 2 * idx * gap;
	int further_idx = (2 * idx + 1) * gap;
	if (further_idx < N)
	{
		arr[closer_idx] += arr[further_idx];
	}
	// Only if further_idx within bounds do we add that to the closer idx
}


int main()
{
    	int N=100000000;
    	int area;

	// 0. Check device
	int deviceid = 0;
	int deviceCount;
	cudaGetDeviceCount(&deviceCount);
	if (deviceid < deviceCount)
	{
		cudaSetDevice(deviceid);
	}
	else
	{
		printf("No Device found, exitting...");
		return 1;
	}

    	// 1. Declare results array on host and on device
	size_t int_arr_size = sizeof(int) * N;
	size_t rand_arr_size = sizeof(float) * N;

	float *randx, *randy;
    	int *rand_res_d;
	cudaMalloc((void**)&rand_res_d, int_arr_size);
	cudaMalloc((void**)&randx, rand_arr_size);
	cudaMalloc((void**)&randy, rand_arr_size);

	// 2. Run generator on cuda to populate array
	// declare, setup, config, generate
        curandGenerator_t gen;
        curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);
        curandSetPseudoRandomGeneratorSeed(gen, 1234ULL);
        curandGenerateUniform(gen, randx, (size_t)N);
        curandGenerateUniform(gen, randy, (size_t)N);

	int T, B;
	T = N >= 1024 ? 1024 : N;
	B = (N + T - 1) / T;
	check<<<B, T>>>(rand_res_d, randx, randy, N);

	// 3. Reduction, with log2(N) steps
	for (int gap = 1; gap < N; gap *= 2)
	{
		// Check number of threads we need
		int C = (N + 2 * gap - 1) / (2 * gap);
		T = C >= 1024 ? 1024 : C;
		B = (C + T - 1)/ T;
		reduce<<<B, T>>>(rand_res_d, gap, N);
	}

	// 4. Retrieve results
	// Copy rand_res_d[0] (i.e. sizeof(int) bytes)
	cudaMemcpy(
		&area, rand_res_d, sizeof(int), cudaMemcpyDeviceToHost
	);
	float pi = (4.0*area/(float)N);
	printf("\nPi:\t%f\n", pi);

	// 5. Free memory
	cudaFree(rand_res_d);
	cudaFree(randx);
	cudaFree(randy);

	return(0);
}
