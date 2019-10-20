#include<iostream>
#include<time.h>
#include<cstdlib>
#include<stdlib.h>

using namespace std;
__global__ void matrixMultiplication(int* A,int* B,int* C,int N);


void mm(int* A,int* B,int* C,int N);

int main()
{
	cudaEvent_t start,end,start1,end1;
	cudaEventCreate(&start);
	cudaEventCreate(&end);
	cudaEventCreate(&start1);
	cudaEventCreate(&end1);

	int ROWS = 1<<2;
	int COLS = 1<<2;

	cout<<"\nEnter number of rows:";
	cin>>ROWS;

	cout<<"\nEnter number of cols:";
	cin>>COLS;

	int* hostA = (int*)malloc(sizeof(int)*ROWS*COLS);
	int* hostB = (int*)malloc(sizeof(int)*ROWS*COLS);
	int* hostC = (int*)malloc(sizeof(int)*ROWS*COLS);
	srand(time(0));
	int i,j;
	for(i=0;i<ROWS;i++)
	{
		for(j=0;j<COLS;j++)
		{
			hostB[i*COLS+j] = rand()%30;
			hostA[i*COLS+j] = rand()%20;
		}
	}
	cout<<"\nMatrix A:\n";
	for(i=0;i<ROWS;i++)
	{
		for(j=0;j<COLS;j++)
		{
			//cout<<hostA[i*COLS+j]<<"\t";
		}
		//cout<<"\n";
	}

	cout<<"\nMatrix B:\n";
	for(i=0;i<ROWS;i++)
	{
		for(j=0;j<COLS;j++)
		{
			//cout<<hostB[i*COLS+j]<<"\t";
		}
		//cout<<"\n";
	}


	int* deviceA,*deviceB,*deviceC;
	cudaMalloc(&deviceA,sizeof(int)*ROWS*COLS);
	cudaMalloc(&deviceB,sizeof(int)*ROWS*COLS);
	cudaMalloc(&deviceC,sizeof(int)*ROWS*COLS);
	cudaMemcpy(deviceA,hostA,sizeof(int)*ROWS*COLS,cudaMemcpyHostToDevice);
	cudaMemcpy(deviceB,hostB,sizeof(int)*ROWS*COLS,cudaMemcpyHostToDevice);

	cudaEventRecord(start);

	mm(deviceA,deviceB,deviceC,ROWS);

	cudaEventRecord(end);
	cudaEventSynchronize(end);
	float t=0;
	cudaEventElapsedTime(&t,start,end);

	cudaError_t e=cudaGetLastError();                                 
 	if(e!=cudaSuccess) 
 	{                                              
   		printf("Cuda failure %s: ",cudaGetErrorString(e));           
   	}     
	cudaDeviceSynchronize();
    cudaMemcpy(hostC,deviceC,ROWS*COLS*sizeof(int),cudaMemcpyDeviceToHost);
	cudaFree(deviceA);
	cudaFree(deviceB);
	cudaFree(deviceC);

	cudaEventRecord(start1);
	int N = ROWS;
	int* actual = (int*)malloc(sizeof(int)*ROWS*COLS);
	int sum;
	for (int row=0; row<ROWS; row++)
	{
        for (int col=0; col<COLS; col++)
        {
            sum=0;
            for (int n=0; n<N; n++)
            {
                sum += hostA[row*N+n]*hostB[n*N+col];
            }
            actual[row*N+col] = sum;
        }
    }
    cudaEventRecord(end1);
	cudaEventSynchronize(end1);
	float t1=0;
	cudaEventElapsedTime(&t1,start1,end1);

    double error = 0;
    for(int k=0;k<ROWS*COLS;k++)
	{
		cout<<k<<")"<< "Expected value = "<<actual[k]<<"\tActual value = "<<hostC[k]<<"\n";
		error += double(abs(actual[k]-hostC[k]));
	}
	error=sqrt(error);
	cout<<"error = "<<error<<"\n";
	delete[] hostA;
    delete[] hostB;
    delete[] hostC;
    cout<<"\nSequential time="<<t1;
    cout<<"\nParallel time="<<t<<endl;
}

__global__ void matrixMultiplication(int* A,int* B,int* C,int N)
{
	int ROW = blockIdx.y*blockDim.y+threadIdx.y;
	int COL = blockIdx.x*blockDim.x+threadIdx.x;
	int sum =0 ;
	if(ROW<N && COL<N)
	{
		for(int i=0;i<N;i++)
		{
			sum+=A[ROW*N+i]*B[i*N+COL];
		}
		__syncthreads();    
		C[ROW*N+COL]=sum;
	}
	
}


void mm(int* A,int* B,int* C,int N)
{
	dim3 threadsPerblock(N,N);
	dim3 blocksPerGrid(1,1);
	if(N*N>512)
	{
		threadsPerblock.x = 512;
		threadsPerblock.y=512;
		blocksPerGrid.x = ceil(double(N)/double(threadsPerblock.x));
		blocksPerGrid.y = ceil(double(N)/double(threadsPerblock.y));
	}
	matrixMultiplication<<<blocksPerGrid,threadsPerblock>>>(A,B,C,N);
}