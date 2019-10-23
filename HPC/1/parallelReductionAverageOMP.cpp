#include<iostream>
#include<omp.h>
using namespace std;
int main(){

    int arr[5] = {1,2,3,4,5},i;
    float avg = 0;
    #pragma omp parallel
    {
        int id = omp_get_thread_num();
        #pragma omp for
        for(i=0;i<5;i++){
        avg += arr[i];
        cout<<"For i= "<<i<<" thread "<<id<<" is executing"<<endl;
        }
    }
    avg /= 5;
    cout<<"Output: "<<avg<<endl;
}
