#include<math.h>
#include<time.h>
#include<stdexcept>
#include<iostream>

using namespace std;



__global__ void kernel_sum( int* A,  int* B, int* C, int NUMBERofELEMENTS);

void sum( int* A,  int* B, int* C, int n_el);

int main()
{

	int NUMBER_OF_ELEMENTS;
	cout<<"\nEnter number of elements:";
	cin>>NUMBER_OF_ELEMENTS;
	int SIZE  = NUMBER_OF_ELEMENTS*sizeof(int);

	int* hostA = (int*)malloc(SIZE);
	int* hostB = (int*)malloc(SIZE);
	int* hostC = (int*)malloc(SIZE);
	int* ans = (int*)malloc(SIZE);
	int* deviceA,*deviceB,*deviceC;
	cudaEvent_t start,end,start1,end1;

	cudaEventCreate(&start1);
	cudaEventCreate(&end1);
	srand(time(0));
	int i;
	for(i=0;i<NUMBER_OF_ELEMENTS;i++)
	{
		hostA[i] = rand()%NUMBER_OF_ELEMENTS;
		hostB[i] = rand()%NUMBER_OF_ELEMENTS;
	}

	cudaEventRecord(start1);
	for(i=0;i<NUMBER_OF_ELEMENTS;i++)
	{
		ans[i]=hostA[i]+hostB[i];
	}
	cudaEventRecord(end1);
	cudaEventSynchronize(end1);
	float t1=0;
	cudaEventElapsedTime(&t1,start1,end1);


	cudaEventCreate(&start);
	cudaEventCreate(&end);
	cudaMalloc(&deviceA,SIZE);
	cudaMalloc(&deviceB,SIZE);
	cudaMalloc(&deviceC,SIZE);

	cudaMemcpy(deviceA,hostA,SIZE,cudaMemcpyHostToDevice);
	cudaMemcpy(deviceB,hostB,SIZE,cudaMemcpyHostToDevice);

	cudaEventRecord(start);

	sum(deviceA,deviceB,deviceC,NUMBER_OF_ELEMENTS);

	cudaEventRecord(end);
	cudaEventSynchronize(end);
	float t=0;
	cudaEventElapsedTime(&t,start,end);
    cudaMemcpy(hostC,deviceC,SIZE,cudaMemcpyDeviceToHost);


	cudaFree(deviceA);
	cudaFree(deviceB);
	cudaFree(deviceC);

	double error = 0;
	for(i = 0;i<NUMBER_OF_ELEMENTS;i++)
	{
		double diff = double((hostA[i]+hostB[i])-hostC[i]);
		error+=diff;
		cout<<"\nExpected value="<<ans[i];
		cout<<"\tActual value="<<hostC[i];
	}

	error = sqrt(error);
	cout<<"\nError  = "<<error<<endl;
	cout<<"\nSequential time="<<t1;
	cout<<"\nParallel time="<<t<<endl;	
	delete[] hostA;
    delete[] hostB;
    delete[] hostC;
    return cudaDeviceSynchronize();
}


void sum( int* A,  int* B, int* C, int n_el)
{
	int threadsPerblock,blocksperGrid;

	if(n_el<512)
	{
		threadsPerblock = n_el;
		blocksperGrid = 1;
	}
	else
	{
		threadsPerblock = 512;
		blocksperGrid = ceil(double(n_el)/double(threadsPerblock));
	}

	//now invoke kernel method
	kernel_sum<<<blocksperGrid,threadsPerblock>>>(A,B,C,n_el);
}


__global__ void kernel_sum( int* A,  int* B, int* C, int NUMBERofELEMENTS)
{
	//calculate unique thread index

	int index = blockDim.x * blockIdx.x + threadIdx.x;

	if(index<NUMBERofELEMENTS)
	C[index] = A[index] + B[index];
}
