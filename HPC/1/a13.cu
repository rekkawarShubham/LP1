#include<iostream>
#include<cstdio>
using namespace std;
__global__ void sum(int *a,int *b,int n)
{
	int block=256*blockIdx.x;
	int sum=0;
	for(int i=block;i<min(block+256,n);i++)
	{
		sum=sum+a[i];
	}
	b[blockIdx.x]=sum;
}
int main()
{
	cout<<"Enter the no of elements:";
	int n;
	cin>>n;
	int a[n];

	for(int i=0;i<n;i++)
	{
		a[i]=rand()%n;
		cout<<a[i]<<"\t";
	}

	cudaEvent_t start1,end1;
	cudaEventCreate(&start1);
	cudaEventCreate(&end1);
	cudaEventRecord(start1);
	int sum1=0;
	for(int i=0;i<n;i++)
	{
		sum1+=a[i];
	}
	float mean1=0.0f;
	mean1=sum1/(n*1.0f);
	cudaEventRecord(end1);
	cudaEventSynchronize(end1);
	float time1=0;
	cudaEventElapsedTime(&time1,start1,end1);
	cout<<"\nSequential Processing:";
	cout<<"\nSum="<<sum1;
	cout<<"\nMean="<<mean1;
	cout<<"\nSequential time="<<time1;

	int *ad,*bd;
	int size=n*sizeof(int);
	cudaMalloc(&ad,size);
	cudaMemcpy(ad,a,size,cudaMemcpyHostToDevice);

	int grids=ceil(n*1.0f/256.0f);
	cudaMalloc(&bd,grids*sizeof(int));
	dim3 grid(grids,1);
	dim3 block(1,1);
	int p=n;
	cudaEvent_t start,end;
	cudaEventCreate(&start);
	cudaEventCreate(&end);
	cudaEventRecord(start);
	while(n>1)
	{
		sum<<<grid,block>>>(ad,bd,n);
		n=ceil(n*1.0f/256.0f);
		cudaMemcpy(ad,bd,n*sizeof(int),cudaMemcpyDeviceToDevice);
	}
	cudaEventRecord(end);
	cudaEventSynchronize(end);
	float time=0;
	cudaEventElapsedTime(&time,start,end);
	int add[2];
	n=p;
	cudaMemcpy(add,ad,4,cudaMemcpyDeviceToHost);
	cout<<"\nSum="<<add[0]<<endl;
	float mean=0.0f;
	mean=add[0]/(n*1.0f);
	cout<<"Mean="<<mean<<endl;
	cout<<"Parallel time="<<time<<endl;
}
