#include "FishEyeCorrect.h"

CFishEyeCorrect::~CFishEyeCorrect(){}

void CFishEyeCorrect::ParamFix()
{
	phi0 = phi0 * piParam;
	sita0 = (90 - sita0) * piParam;
	gama0 = gama0 * piParam;

	phi1 = phi1 * piParam;
	sita1 = (90 - sita1) * piParam;
	gama1 = gama1 * piParam;

	phi2 = phi2 * piParam;
	sita2 = (90-sita2)*piParam;
	gama2 = gama2 * piParam;
}

CFishEyeCorrect::CFishEyeCorrect():piParam(0.01745329)
{
	phi0 = 2.44346095;
	sita0 = 0.6981316;
	gama0 = 1.65806255;

	phi1 = -1.48352965;
	sita1 = -0.08726645;
	gama1 = 1.65806255;

	phi2 = 4.7123883;
	sita2 = 0.78539805;
	gama2 = 1.48352965;

}

Rect CFishEyeCorrect::GetArea(const Mat &inputImage)
{
	FindCorrectArea(inputImage);
	return correctArea;
}

void CFishEyeCorrect::FindCorrectArea(const Mat &inputImage)
{
	Mat grayImage;
	cvtColor(inputImage,grayImage,CV_BGR2GRAY,1);
	//二值化
	threshold(grayImage,grayImage,40,255,THRESH_BINARY);
	vector<vector<Point > > contours;
	//找轮廓
	findContours(grayImage,contours,CV_RETR_EXTERNAL,CV_CHAIN_APPROX_NONE);
	//find the device's area;
	Rect minAreaTemp;
	int areaSize(0); 
	int areaSizeTemp(0);
	int areaIter(0);
	//找到最大轮廓
	for (int contoursIter = 0;contoursIter != contours.size();++contoursIter)
	{
		minAreaTemp=boundingRect(contours[contoursIter]);
		areaSizeTemp=minAreaTemp.width*minAreaTemp.height;
		if (areaSize<areaSizeTemp)
		{
			correctArea=minAreaTemp;
			areaSize=areaSizeTemp;
		}
	}
	
}




void CFishEyeCorrect::CalculateParam(int width, int height)
{
	w = width;
	h = height;
	r=0.5*(w<h?w:h);
	//0.6366197730950255438113531364418 = 2/3.14159265
	f=r*0.63661977;
	//(w-1)*0.5
	cx=(w-1)>>1;
	//(h-1)*0.5
	cy=(h-1)>>1;
}



void CFishEyeCorrect::Fix(int &u,int &v,double &x,double &y,const double &phi,const double &sita,const double &gama)
{
	//展开平面与校正图比例，平面与空间坐标关系，
	double wp,hp,dux,duy,duz,dvx,dvy,dvz,xp,yp,zp,SQRT,sit,c_p,s_p;
	//CvPoint2D32f xy;
	//1已知phi0 sita0 gama0
	//phi0=-3.14159265*0/2,sita0=-3.14159265*0/4,gama0=3.14159265*1/4,f=r*2/3.14159265;
	//2
	wp=r*tan(gama/2)/(cx+0.5);
	hp=r*tan(gama/2)/(cy+0.5);
	//3
	dux=wp*sin(phi),duy=-wp*cos(phi),duz=0;
	dvx=-hp*cos(sita)*cos(phi),dvy=-hp*cos(sita)*sin(phi);
	dvz=hp*sin(sita);
	//4
	xp=r*sin(sita)*cos(phi)+(cx-u)*dux+(v-cy)*dvx;
	yp=r*sin(sita)*sin(phi)+(cx-u)*duy+(v-cy)*dvy;
	zp=r*cos(sita)+(v-cy)*dvz;
	//5
	SQRT=sqrt(xp*xp+yp*yp);
	sit=atan(SQRT/zp);
	c_p=xp/SQRT;
	s_p=yp/SQRT;
	//6
	x=cx+f*sit*c_p;
	y=cy+f*sit*s_p;
	//return xy;
}



void CFishEyeCorrect::FishImgIndex(const Mat& ormImg)
{
	ImgIndex1 = Mat::zeros(Size(w,h),CV_32SC2);
	ImgIndex2 = Mat::zeros(Size(w,h),CV_32SC2);
	ImgIndex3 = Mat::zeros(Size(w,h),CV_32SC2);
	for (int i =0; i < h; ++i)
	{
		int *data1 = ImgIndex1.ptr<int>(i);
		int *data2 = ImgIndex2.ptr<int>(i);
		int *data3 = ImgIndex3.ptr<int>(i);
		for (int j =0;j < w; ++j)
		{
			double x1 = 0 ;
			double y1 = 0;
			double x2 = 0 ;
			double y2 = 0;
			double x3 = 0 ;
			double y3 = 0;

			Fix(i,j, x1,y1,phi0,sita0,gama0);
			Fix(i,j, x2,y2,phi1,sita1,gama1);
			Fix(i,j, x3,y3,phi2,sita2,gama2);

			data1[j*2] = (int)x1;
			data1[j*2+1] = (int)y1;

			data2[j*2] = (int)x2;
			data2[j*2+1] = (int)y2;

			data3[j*2] = (int)x3;
			data3[j*2+1] = (int)y3;

		}
	}
}



void CFishEyeCorrect::ImageCorrect(const Mat& orgImg,Mat& dstImg1,Mat& dstImg2,Mat& dstImg3)
{
	
	dstImg1 =  Mat::zeros(Size(w/2,h/2),CV_8UC3); 
	dstImg2 =  Mat::zeros(Size(w/2,h/2),CV_8UC3);
	dstImg3 =  Mat::zeros(Size(w/2,h/2),CV_8UC3);
	

	for (int i =0;i < dstImg1.rows -1; ++i)
	{
		int *data1 = ImgIndex1.ptr<int>(i*2);
		int *data2 = ImgIndex2.ptr<int>(i*2);
		int *data3 = ImgIndex3.ptr<int>(i*2);
		for (int j = 0; j < dstImg1.cols-1;++j)
		{

		int u1 = data1[j*4];
		int v1 = data1[j*4 +1];
		int u2 = data2[j*4];
		int v2 = data2[j*4 +1];
		int u3 = data3[j*4];
		int v3 = data3[j*4 +1];
			if (u1 < orgImg.rows-1 && u1 > -1 && v1 < orgImg.cols-1 && v1 > -1 )
			{
				*(dstImg1.data + dstImg1.step[0]*i + dstImg1.step[1]*j )
					= *(orgImg.data + orgImg.step[0]*u1 + orgImg.step[1]*v1 );
				*(dstImg1.data + dstImg1.step[0]*i + dstImg1.step[1]*j + dstImg1.elemSize1()) 
					=*(orgImg.data + orgImg.step[0]*u1 + orgImg.step[1]*v1 + orgImg.elemSize1());
				*(dstImg1.data + dstImg1.step[0]*i + dstImg1.step[1]*j + dstImg1.elemSize1() * 2)	                   
					=*(orgImg.data + orgImg.step[0]*u1 + orgImg.step[1]*v1 + orgImg.elemSize1() * 2);
			}
			if (u2 < orgImg.rows-1 && u2 > -1 && v2 < orgImg.cols-1 && v2 > -1 )
			{
				*(dstImg2.data + dstImg2.step[0]*i + dstImg2.step[1]*j )
					= *(orgImg.data + orgImg.step[0]*u2 + orgImg.step[1]*v2 );
				*(dstImg2.data + dstImg2.step[0]*i + dstImg2.step[1]*j + dstImg2.elemSize1()) 
					=*(orgImg.data + orgImg.step[0]*u2 + orgImg.step[1]*v2 + orgImg.elemSize1());
				*(dstImg2.data + dstImg2.step[0]*i + dstImg2.step[1]*j + dstImg2.elemSize1() * 2)	                   
					=*(orgImg.data + orgImg.step[0]*u2 + orgImg.step[1]*v2 + orgImg.elemSize1() * 2);
			}
			if (u3 < orgImg.rows-1 && u3 > -1 && v3 < orgImg.cols-1 && v3 > -1 )
			{
				*(dstImg3.data + dstImg3.step[0]*i + dstImg3.step[1]*j )
					= *(orgImg.data + orgImg.step[0]*u3 + orgImg.step[1]*v3 );
				*(dstImg3.data + dstImg3.step[0]*i + dstImg3.step[1]*j + dstImg3.elemSize1()) 
					=*(orgImg.data + orgImg.step[0]*u3 + orgImg.step[1]*v3 + orgImg.elemSize1());
				*(dstImg3.data + dstImg3.step[0]*i + dstImg3.step[1]*j + dstImg3.elemSize1() * 2)	                   
					=*(orgImg.data + orgImg.step[0]*u3 + orgImg.step[1]*v3 + orgImg.elemSize1() * 2);
			}
		}
	}
}
