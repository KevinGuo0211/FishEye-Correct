//利用扫描线逼近算法标定鱼眼图像的中心和半径，及标准圆变换
//标准圆变换部分，坐标原点设置的不好，没有找到在OPENCV中如何将图像坐标原点设置在图像中心
#include "StdAfx.h"
#include "ScanningMethod.h"
#include"cv.h"
#include"cxcore.h"
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"



//将椭圆变换为标准圆
void ScanningMethod::Standard_circle(Mat& img,Mat& imgOut)
{
//	CMyTrace myTrace("");
//	myTrace.theFunctionName = new string("Standard_circle(Mat& img,Mat& imgOut),STRAT");
//	myTrace.WriteToLog("ok");
	float u =1.0*img.size().width /2;
	float v = 1.0*img.size().height/ 2;
	float beta  = 1.0 * img.size().width / img.size().height;
	//Mat imgOut;
	if( img.size().width < img.size().height )

		imgOut = Mat::zeros( cvSize( min( img.size().width, img.size().height ), min( img.size().width, img.size().height)), CV_8UC3);
	else
		imgOut = Mat::zeros( cvSize( max( img.size().width, img.size().height ), max( img.size().width, img.size().height)), CV_8UC3);
	
	float a[] = { 1.0, 0, 0,
				0, beta, 0,
				0, 0, 1.0 };
				

	Mat M( 3,3,CV_32FC1,a);
	//cvSetData(K,a,K->step);


	//cvWarpPerspective( img,imgOut, K, CV_INTER_LINEAR + CV_WARP_FILL_OUTLIERS, cvScalarAll( 255 ));

	 warpPerspective(img, imgOut,  M,imgOut.size() , INTER_LINEAR, BORDER_CONSTANT,Scalar());
	//cvReleaseMat(&K);
//	 myTrace.WriteToLog("Standard_circle(Mat& img,Mat& imgOut),END");
	//return imgOut;

}


//最小外接矩形
void ScanningMethod::FindDeviceArea(const Mat inputImage)
{
	Mat grayImage;
	cvtColor(inputImage,grayImage,CV_BGR2GRAY,0);
	long hist[256]={0};
	//计算直方图
	//imwrite("C:\\Users\\Administrator\\Desktop\\2.jpg",grayImage);
	AccumulatedHistogram(grayImage,hist,false);
	int firstTh(0);
	//找二值化阈值
	TroughBinaryzation(hist,firstTh);
		//Canny(grayImage,grayImage,30,100);
	threshold(grayImage,grayImage,firstTh,255,THRESH_BINARY);
	//imshow("a",grayImage);
	vector<vector<Point>> contours;
	//找轮廓
	findContours(grayImage,contours,CV_RETR_EXTERNAL,CV_CHAIN_APPROX_NONE);
	//find the device's area;
	
	Rect minAreaTemp;
	int areaSize(0); 
	int areaSizeTemp(0);
	int areaIter(0);
	//找到最大轮廓
	//vector<vector<Point>> theContour;
	for (int contoursIter = 0;contoursIter != contours.size();++contoursIter)
	{
		minAreaTemp=boundingRect(contours[contoursIter]);
		areaSizeTemp=minAreaTemp.width*minAreaTemp.height;
		if (areaSize<areaSizeTemp)
		{
			minArea=minAreaTemp;
			areaSize=areaSizeTemp;
			areaIter=contoursIter;
		}
	}
	//theContour.push_back(contours[areaIter]);
	//make mask
	//填充轮廓
	//outputMask=Mat::zeros(inputImage.size(),CV_8UC1);
	//drawContours(outputMask,contours,areaIter,Scalar(255,0,0),CV_FILLED);
	//output center-point
	//找到中心点和水平方向上任意一点
	//Point2f center((float)(minArea.x+minArea.width/2),(float)(minArea.y+minArea.height/2));
	//centerPoint=center;
	//line(outputMask,center,Point2f(minArea.x,minArea.y+minArea.height/2),Scalar(0,0,0),2);

   // outputMask = Mat::zeros(minArea.width,minArea.height,CV_8UC3);
	/*outputMask =inputImage(minArea);*/
	//imshow("aa",outputMask);
	//tmpImg.copyTo(outputMask);
	
}

//accumulate the histogram of image,if flag=ture,accumulate the accumulatedHistogram
void ScanningMethod::AccumulatedHistogram(Mat inputImage,long *histogramArray,bool flag)
{
	uchar* data;
	for (int row=0;row!=inputImage.rows;++row)
	{
		data = inputImage.ptr<uchar>(row);
		for (int col=0;col!=inputImage.cols;++col)
		{
			histogramArray[(int)data[col]]++;
		}
	}
	if (flag==true)
	{
		for (int i=0;i!=255;++i)
		{
			histogramArray[i+1]+=histogramArray[i];
		}
	}
}


//find the threshold of binaryzation
void ScanningMethod::TroughBinaryzation(long *inputVec,int &Th)
{
	int maxLoc(0);
	long maxVal(0);

	for (int i=15;i!=80;++i)
	{
		if (maxVal<(inputVec[i]))
		{
			maxVal=inputVec[i];
			maxLoc=i;
		}
	}
   // int value = maxLoc;
	//long maxvalue = maxVal;
	for (int i=maxLoc;i!=256;++i)
	{
		if (inputVec[i]<maxVal/2)
		{
			for (int j=i;j!=256;++j)
			{
				if ((inputVec[j]-inputVec[j-1])>=10)  //10
				{
					Th=j;
					break;
				}
			}
			break;
		}
	}
}