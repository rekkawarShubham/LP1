#include<iostream>
#include<cstdio>

using namespace std;



__global__ void mini1(int *a,int *b,int n)
{
	int block=256*blockIdx.x;
	int mini=7888888;
	for(int i=block;i<min(256+block,n);i++)
	{
		if(mini>a[i])
		{
			mini=a[i];
		}
	}
	b[blockIdx.x]=mini;
}




int main()
{
	cout<<"Enter the size of array:";
	int n;
	cin>>n;
	int a[n];

	cudaEvent_t start,end,start1,end1;
	cudaEventCreate(&start);
	cudaEventCreate(&end);
	cudaEventCreate(&start1);
	cudaEventCreate(&end1);

	for(int i=0;i<n;i++)
	{
		a[i]=rand()%n;
		cout<<a[i]<<"\t";
	}
	cudaEventCreate(&start1);
	cudaEventCreate(&end1);
	cudaEventRecord(start1);
	int max=0;
	for(int i=0;i<n;i++)
	{
		if(a[i]>max)
		{
			max=a[i];
		}
	}
	cudaEventRecord(end1);
	cudaEventSynchronize(end1);
	float time1=0;
	cudaEventElapsedTime(&time1,start1,end1);
	cout<<"\nSequential Processing:";
	cout<<"\nMax="<<max;
	cout<<"\nSequential time="<<time1;

	int *ad,*bd;
	int size=n*sizeof(int);
	
	cudaMalloc(&ad,size);
	cudaMemcpy(ad,a,size,cudaMemcpyHostToDevice);
	int grids=ceil(n*1.0f/256.0f);
	cudaMalloc(&bd,grids*sizeof(int));
	dim3 grid(grids,1);
	dim3 block(1,1);

	cudaEventRecord(start);

	while(n>1)

	{

		mini1<<<grids,block>>>(ad,bd,n);
		n=ceil(n*1.0f/256.0f);
		cudaMemcpy(ad,bd,n*sizeof(int),cudaMemcpyDeviceToDevice);


	}
	
	cudaEventRecord(end);
	cudaEventSynchronize(end);

	float time=0;
	cudaEventElapsedTime(&time,start,end);
	
	int ans[2];

	cudaMemcpy(ans,ad,4,cudaMemcpyDeviceToHost);
	
	cout<<"\nParallel Processing:\nMin="<<ans[0]<<endl;
	cout<<"Parallel time=";
	cout<<time<<endl;
} 
