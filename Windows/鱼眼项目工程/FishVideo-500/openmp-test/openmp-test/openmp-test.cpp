// openmp-test.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <iostream>
#include <time.h>
#include <omp.h>
void test()
{
	int a = 0;
	 for (int i=0;i<100000000;i++)
		 a++;
 }


int _tmain(int argc, _TCHAR* argv[])
{
   clock_t t1 = clock();
   #pragma omp parallel for
   for (int i=0;i<8;i++)
	   test();
    clock_t t2 = clock();
	std::cout<<"time: "<<t2-t1<<std::endl;
	system("pause");
	return 0;
}

