#include<math.h>
#include<time.h>
#include<stdexcept>
#include<iostream>
#include<cstdlib> //for abs(x)
#include<stdio.h>

using namespace std;



__global__ void kernel_multiplication( int* A,  int* B, int* C,int N,int M);


int main()
{
	int NUMBER_OF_ELEMENTS;
	int VECTOR_SIZE;
	cout<<"Enter the vector size:";
	cin>>VECTOR_SIZE;
	NUMBER_OF_ELEMENTS=VECTOR_SIZE;
	int SIZE  = NUMBER_OF_ELEMENTS*sizeof(int);


	cudaEvent_t start,end,start1,end1;

	int* hostA = (int*)malloc(VECTOR_SIZE*sizeof(int));
	int* hostB = (int*)malloc(SIZE*VECTOR_SIZE*sizeof(int));
	int* hostC = (int*)malloc(VECTOR_SIZE*sizeof(int));

	int* deviceA,*deviceB,*deviceC;

	srand(time(0));
	int i,j;

	cout<<"\nVector:\n";
	for(i=0;i<VECTOR_SIZE;i++)
	{
		hostA[i] = rand()%VECTOR_SIZE;	
		cout<<hostA[i]<<"\t";
	}

	//initialize matrix by random elements
	for(i=0;i<NUMBER_OF_ELEMENTS;i++)
	{
		for(j=0;j<VECTOR_SIZE;j++)
		{
			hostB[i*VECTOR_SIZE+j] = rand()%VECTOR_SIZE;
		}
	}

	cout<<"\nMatrix=\n";
	for(i=0;i<NUMBER_OF_ELEMENTS;i++)
	{
		for(j=0;j<VECTOR_SIZE;j++)
		{
			cout<<hostB[i*VECTOR_SIZE+j]<<"\t";
		}
		cout<<"\n";
	}

	cudaMalloc(&deviceA,VECTOR_SIZE*sizeof(int));
	cudaMalloc(&deviceB,NUMBER_OF_ELEMENTS*VECTOR_SIZE*sizeof(int));
	cudaMalloc(&deviceC,VECTOR_SIZE*sizeof(int));

	cudaEventCreate(&start);
	cudaEventCreate(&end);
	cudaEventCreate(&start1);
	cudaEventCreate(&end1);

	cudaEventRecord(start);
	cudaMemcpy(deviceA,hostA,VECTOR_SIZE*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(deviceB,hostB,SIZE*VECTOR_SIZE,cudaMemcpyHostToDevice);
	kernel_multiplication<<<NUMBER_OF_ELEMENTS,1>>>(deviceA,deviceB,deviceC,NUMBER_OF_ELEMENTS,VECTOR_SIZE);
	cudaDeviceSynchronize();
    cudaMemcpy(hostC,deviceC,VECTOR_SIZE*sizeof(int),cudaMemcpyDeviceToHost);
    cudaEventRecord(end);
    cudaEventSynchronize(end);
	float t=0;
	cudaEventElapsedTime(&t,start,end);


	cudaFree(deviceA);
	cudaFree(deviceB);
	cudaFree(deviceC);

	double error = 0;

    int* answer = (int*) malloc(VECTOR_SIZE*sizeof(int));

    cudaEventRecord(start1);
	for(int i=0;i<NUMBER_OF_ELEMENTS;i++)
	{
		int sum = 0;
		for(int j=0;j<VECTOR_SIZE;j++)
		{
			sum += hostA[j]*hostB[j*VECTOR_SIZE+i];
		}
		answer[i] = sum;
	}

	for(int k=0;k<VECTOR_SIZE;k++)
	{
		cout<<k<<")"<< "Expected value = "<<answer[k]<<" Actual value = "<<hostC[k]<<"\n";
		error += double(abs(answer[k]-hostC[k]));
	}

	error=sqrt(error);
	cout<<"error = "<<error<<"\n";
	cudaEventRecord(end1);
    cudaEventSynchronize(end1);
	float t1=0;
	cudaEventElapsedTime(&t1,start1,end1);

	cout<<"\nSequential time="<<t1;
	cout<<"\nParallel time="<<t<<endl;

	delete[] hostA;
    delete[] hostB;
    delete[] hostC;
    return cudaDeviceSynchronize();

}

__global__ void kernel_multiplication( int* A,  int* B, int* C, int N,int M)
{
	int index =  threadIdx.x + blockIdx.x * blockDim.x;
	int sum = 0;
	if(index<N)
	{
		for(int i=0;i<M;i++)
		sum+=A[i]*B[(i*M)+index];
		C[index] = sum;
	}
}