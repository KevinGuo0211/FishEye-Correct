// yingjiema.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/gpu/gpu.hpp"
#include <iostream>
//#include <nvcuvid.h>
//#include <cuviddec.h>

using namespace cv;
using namespace std;
using namespace gpu;
int _tmain(int argc, _TCHAR* argv[])
{
	 
	while(1){
		int num_devices = getCudaEnabledDeviceCount();
		if (num_devices <=0)
		{

			cout<<"There is no device."<<endl;
			return -1;
		}
		int enable_device_id = -1;
		for (int i=0;i<num_devices;i++)
		{
			DeviceInfo dev_info(-1);
			if (dev_info.isCompatible())
			{
				enable_device_id = i;
			}
		}

		if (enable_device_id <0)
		{
			cout<<"GPU module isn't built for GPU"<<endl;
			return -1;
		}
		setDevice(enable_device_id);
		Mat src_image = imread("1.png");
		Mat dst_image ;
		GpuMat d_src_img(src_image);
		GpuMat d_dst_img;
		gpu::cvtColor(d_src_img,d_dst_img,CV_BGR2GRAY);
		d_dst_img.download(dst_image);
		imshow("test",dst_image);
		waitKey(10);
		}
	   return 0;
}