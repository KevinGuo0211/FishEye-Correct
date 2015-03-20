#include "StdAfx.h"
#include "ImgWarp.h"

void ImgWarp::FisheyeImgCorrectInit()
{
	phi=0;
	phi=phi*3.14159265/180;
	sita=30;
	sita=(90-sita)*3.14159265/180;
	gama=60;
	gama=gama*3.14159265/180;
	SQRT = 700;
	sit = 1.0;
}

void ImgWarp::FishCalculate(Mat& orgImg)
{
	w = orgImg.size().width;
	h = orgImg.size().height;
	r=0.5*(w<h?w:h);
	f=r*2/3.14159265;
	cx=0.5*(w-1);
	cy=0.5*(h-1);

}
void ImgWarp::Fix(int &x,int &y,double &u,double &v)
{
	//展开平面与校正图比例，平面与空间坐标关系，
	//double wp,hp,dux,duy,duz,dvx,dvy,dvz,xp,yp,zp,c_p,s_p;
	double wp,hp,dux,duy,duz,dvx,dvy,dvz,yp,zp;

	wp=r*tan(gama/2)/(cx+0.5);
	hp=r*tan(gama/2)/(cy+0.5);
	//3
	dux=wp*sin(phi),duy=-wp*cos(phi),duz=0;
	dvx=-hp*cos(sita)*cos(phi),dvy=-hp*cos(sita)*sin(phi);
	dvz=hp*sin(sita);
	//4
	//xp=r*sin(sita)*cos(phi)+(cx-u)*dux+(v-cy)*dvx;
	//yp=r*sin(sita)*sin(phi)+(cx-u)*duy+(v-cy)*dvy;
	//zp=r*cos(sita)+(v-cy)*dvz;
	yp = (y-cy)/(f*sit)*SQRT;
	zp = SQRT/tan(sit);
	//5
	/*SQRT=sqrt(xp*xp+yp*yp);
	sit=atan(SQRT/zp);
	c_p=xp/SQRT;
	s_p=yp/SQRT;*/
	//6
	/*x=cx+f* sit*c_p;
	y=cy+f*sit*s_p;*/
	u = cx - (yp - r*sin(sita)*sin(phi))/duy - (zp - r*cos(sita))*dvy/(duy*dvz);
	v = (yp - r*sin(sita)*sin(phi) - (cx -u)*duy)/dvy + cy;
}
void ImgWarp::ImageWarp(Mat &orgImg, Mat &dstImg)
{
	FisheyeImgCorrectInit();
	FishCalculate(orgImg);

	dstImg = Mat::zeros(Size(w,h),CV_8UC3);
	for (int i =0; i < h; ++i)
	{
		for (int j =0; j< w;++j)
		{
			double u = 0;
			double v = 0;
			Fix(i,j,u,v);
			int iu = (int)u;
			int iv = (int)v;
			if (iu < dstImg.rows && iu > -1 && iv < dstImg.cols && iv > -1)
			{
				dstImg.at<Vec3b>(i,j) = orgImg.at<Vec3b>(iu,iv);
			}
		}
	}
}


/**********************************************************
*平面到球面变换
**********************************************************/
int ImgWarp::Plane2Sphere(const cv::Mat& src,cv::Mat& dst,uint z)
{
	if (src.empty() ||
		(src.data == dst.data) ||
		z > 10000)
	{
		return -1;
	}

	const uint nWidth = 2 * z * atan(double(src.cols / 2.0 / z));
	const uint nHeight = 2 * z * atan(double(src.rows / 2.0 / z));


	const uint nHalfWidthDst = nWidth / 2;
	const uint nHalfHeightDst = nHeight / 2;
	const uint nHalfWidthSrc = src.cols / 2;
	const uint nHalfHeightSrc = src.rows / 2;

	dst = Mat::zeros(nHeight,nWidth,src.type());

	for (uint v=0; v<nHalfHeightDst; ++v)
	{
		for (uint u=0; u<nHalfWidthDst; ++u)
		{
			uint x = z * tan(double(u*1.1/z));
			uint y = z * tan(v*1.1/z) / cos(u*1.1/z);

			Set4By1(src,dst,Point(x,y),Point(u,v),
				nHalfWidthSrc,nHalfHeightSrc,
				nHalfWidthDst,nHalfHeightDst);

		}
	}
	AdjustWidth(dst);

	return 0;
}

void ImgWarp::Set4By1(const cv::Mat& src,cv::Mat& dst,
	cv::Point srcPt,cv::Point dstPt,
	uint nHalfWidthSrc,uint nHalfHeightSrc,
	uint nHalfWidthDst,uint nHalfHeightDst)
{
	uint u = srcPt.x;
	uint v = srcPt.y;
	uint x = dstPt.x;
	uint y = dstPt.y;
	Point srcPoint[4] = 
		{Point(u+nHalfWidthSrc,v+nHalfHeightSrc),	//右上)
		Point(u+nHalfWidthSrc,nHalfHeightSrc-v),
		Point(nHalfWidthSrc-u,nHalfHeightSrc-v),
		Point(nHalfWidthSrc-u,nHalfHeightSrc+v)};

	Point dstPoint[4] = 
		{Point(x+nHalfWidthDst,y+nHalfHeightDst),	//右上)
		Point(x+nHalfWidthDst,nHalfHeightDst-y),
		Point(nHalfWidthDst-x,nHalfHeightDst-y),
		Point(nHalfWidthDst-x,nHalfHeightDst+y)};

	bool bGray = src.channels()==3 ? false : true;

	for (uint i=0; i<4; ++i)
	{
		if (srcPoint[i].x<src.cols && srcPoint[i].y<src.rows &&
			srcPoint[i].x>=0 && srcPoint[i].y>=0 /*&&
			dstPoint[i].x<dst.cols && dstPoint[i].y<dst.rows &&
			dstPoint[i].x>=0 && dstPoint[i].y>=0*/)
		{
			if (bGray)
			{
				dst.at<uchar>(dstPoint[i]) = src.at<uchar>(srcPoint[i]);
			}
			else
			{
				dst.at<Vec3b>(dstPoint[i]) = src.at<Vec3b>(srcPoint[i]);
			}
		}
	}
}

inline void ImgWarp::AdjustWidth(cv::Mat& src)
{
	if (src.cols*src.channels()%4 != 0)
	{
		uint right = (src.cols+3)/4*4 - src.cols;
		copyMakeBorder(src,src,0,0,0,right,BORDER_REPLICATE);
	}
}