
#include<bits/stdc++.h>
#include<omp.h>
using namespace std;


int* serial_bubble_sort(int arr[], int n)
{
	bool fl = true;
	for( int i = 0; i < n; i++ )
	 {
		for( int j = 0; j < n-i-1; j +=1 )
		{
			if( arr[ j ] > arr[ j+1 ] )
			{
				swap( arr[ j ], arr[ j+1 ] );
				fl=false;
			}
		}
		if(fl) break;
	}
	return arr;
}


int* parallel_bubble_sort(int arr[], int n)
{
	bool fl = true;
	for( int i = 0; i < n; i++ )
	 {
	 	//cout<<"Iter : "<<i<<endl;
		int first = i % 2;
		#pragma omp parallel for shared(arr,first)
		for( int j = first; j < n-1; j += 2 )
		{
			if( arr[ j ] > arr[ j+1 ] )
			{
				swap( arr[ j ], arr[ j+1 ] );
				fl=false;
			}
		}
		if(fl) break;
	}
	return arr;
}

void merge(int a[], int l, int m, int r)
{
	int temp[m-l+1], temp2[r-m];
	for(int i=0; i<(m-l+1); i++)
		temp[i]=a[l+i];
	for(int i=0; i<(r-m); i++)
		temp2[i]=a[m+1+i];
	int i=0, j=0, k=l;
	while(i<(m-l+1) && j<(r-m))
	{
		if(temp[i]<temp2[j])
			a[k++]=temp[i++];
		else
			a[k++]=temp2[j++];
	}
	
	while(i<(m-l+1))
		a[k++]=temp[i++];
	while(j<(r-m))
		a[k++]=temp2[j++];

}
void serial_merge_sort(int a[], int l, int r)
{
	if(l<r)
	{
		int m=(l+r)/2;
		serial_merge_sort(a,l,m);
		serial_merge_sort(a,m+1,r);
		merge(a,l,m,r);
	}
}

void parallel_merge_sort(int a[], int l, int r)
{
	if(l<r)
	{
		int m=(l+r)/2;
		#pragma omp parallel sections num_threads(2)
		{
			#pragma omp section
			{
				parallel_merge_sort(a,l,m);
			}
			#pragma omp section
			{
				parallel_merge_sort(a,m+1,r);
			}
		}
		merge(a,l,m,r); 
	}
}


int main()
{
	int n;
	n = rand()%1000;
	int arr[n];
	int temp[n];
	
	cout<<"N : "<<n<<endl;;
	
	
	#pragma omp parallel for shared(arr,n)
	for(int i=0;i<n;i++){
		arr[i] = rand()%1000;
	}
	
	
	double start,end;
	//Parallel Bubble Sort
	#pragma omp parallel for shared(temp,arr,n)
	for(int i=0;i<n;i++){
		temp[i] = arr[i];
	}
	
	cout<<"Array init parallel bubble"<<endl;
	
	start = omp_get_wtime();
	int* result = parallel_bubble_sort(temp,n);
	end = omp_get_wtime();
	
	
	for(int i=0;i<10;i++){
		cout<<temp[i]<<" ";
	}
	cout<<endl;
	
	cout<<"Time parallel bubble sort : "<< end-start <<endl;
	
	//Parallel Merge Sort
	
	int* temp_arr = new int[n];
	
	#pragma omp parallel for shared(temp,arr,n)
	for(int i=0;i<n;i++){
		temp[i] = arr[i];
	}
	
	cout<<"Array init parallel merge"<<endl;
	
	start = omp_get_wtime();
	parallel_merge_sort(temp, 0, n-1);
	end = omp_get_wtime();
	
	for(int i=0;i<10;i++){
		cout<<temp[i]<<" ";
	}
	cout<<endl;
	
	cout<<"Time parallel Merge sort  : "<< end-start <<endl;
	
	//Serial Merge Sort
	
	temp_arr = new int[n];
	
	#pragma omp parallel for shared(temp,arr,n)
	for(int i=0;i<n;i++){
		temp[i] = arr[i];
	}
	
	cout<<"Array init serial merge"<<endl;
	
	start = omp_get_wtime();
	serial_merge_sort(temp, 0, n-1);
	end = omp_get_wtime();
	
	for(int i=0;i<10;i++){
		cout<<temp[i]<<" ";
	}
	cout<<endl;
	
	cout<<"Time serial Merge sort    : "<< end-start <<endl;
	
	return 0;
}

