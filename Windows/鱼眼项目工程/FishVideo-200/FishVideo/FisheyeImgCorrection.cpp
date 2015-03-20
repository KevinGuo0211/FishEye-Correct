//Fisheye Image correction
#include "StdAfx.h"
#include "FisheyeImgCorrection.h"


void FisheyeImgCorrect::FisheyeImgCorrectInit()
{
	phi0=0;
	phi0=phi0*3.14159265/180;
	sita0=50;
	sita0=(90-sita0)*3.14159265/180;
	gama0=95;
	gama0=gama0*3.14159265/180;

	phi1=180; 
	phi1=phi1*3.14159265/180;
	sita1=55; 
	sita1=(90-sita1)*3.14159265/180;
	gama1=100;
	gama1=gama1*3.14159265/180;

	phi2=270;
	phi2=phi2*3.14159265/180;
	sita2=45;
	sita2=(90-sita2)*3.14159265/180;
	gama2=85; 
	gama2=gama2*3.14159265/180;

	phi3=270;
	phi3=phi3*3.14159265/180;
	sita3=45;
	sita3=(90-sita3)*3.14159265/180;
	gama3=85; 
	gama3=gama3*3.14159265/180;

}

void FisheyeImgCorrect::FishCalculate(Mat& orgImg)
{
	//w = orgImg.size().width;
	//h = orgImg.size().height;
	//w=480;
	//h= 360;
	int orgw =orgImg.size().width;
	int orgh=orgImg.size().height;
	r=0.5*(orgw<orgh?orgw:orgh);
	f=r*2/3.14159265;
	cx=0.5*(orgw-1);
	cy=0.5*(orgh-1);
	
}
void FisheyeImgCorrect::Fix(int &u,int &v,double &x,double &y,double phi,double sita,double gama)
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
	//double r1 = sit*tan((u*cos(phi)+v*cos(gama)*sin(phi))/(-u*sin(phi)+v*cos(gama)*cos(phi)));
	x=cx+f*sit*c_p;
	y=cy+f*sit*s_p;
	//double K =150.0;
	//double l = K*atan((sqrt(((-u*sin(phi)+v*cos(gama))*((-u*sin(phi)+v*cos(gama))))+(((u*cos(phi)+v*cos(gama)*sin(phi))*((u*cos(phi)+v*cos(gama)*sin(phi)))))))/v*sin(phi));
	//x = cx +l*cos(r1);
	//y = cy +l*sin(r1);
	//return xy;
}

void FisheyeImgCorrect::FishImgIndex(const Mat& orgImg)
{
	/*为索引表分配空间*/
	double wScanl = (double)orgImg.cols/(double)w;
	double hScanl = (double)orgImg.rows/(double)h;
	int Scanl =int( ceil((wScanl+hScanl)/2));

	ImgIndex =  Mat::zeros(Size(w,h),CV_32SC2);
	ImgIndex1 = Mat::zeros(Size(w/2,h/2),CV_32SC2);
	ImgIndex2 = Mat::zeros(Size(w/2,h/2),CV_32SC2);
	ImgIndex3 = Mat::zeros(Size(w/2,h/2),CV_32SC2);
	ImgIndex4 = Mat::zeros(Size(w/2,h/2),CV_32SC2);

	/*遍历展开图的每一个像素，求取对应鱼眼图中的坐标*/
	for (int i =0; i <h/2; ++i)
	{
		int *data1 = ImgIndex1.ptr<int>(i);
		int *data2 = ImgIndex2.ptr<int>(i);
		int *data3 = ImgIndex3.ptr<int>(i);
		int *data4 = ImgIndex4.ptr<int>(i);
		for (int j =0;j < w/2; ++j)
		{
			double x1 = 0 ;
			double y1 = 0;
			double x2 = 0 ;
			double y2 = 0;
			double x3 = 0 ;
			double y3 = 0;
			double x4 = 0 ;
			double y4 = 0;
			/*求取展开图中坐标对应鱼眼图坐标*/
			int u = i*Scanl*2;
			int v = j*Scanl*2;
			Fix(u,v, x1,y1,phi0,sita0,gama0);
			Fix(u,v, x2,y2,phi1,sita1,gama1);
			Fix(u,v, x3,y3,phi2,sita2,gama2);
			Fix(u,v, x4,y4,phi3,sita3,gama3);

			data1[j*2] = (int)x1;
			data1[j*2+1] = (int)y1;

			data2[j*2] = (int)x2;
			data2[j*2+1] = (int)y2;

			data3[j*2] = (int)x3;
			data3[j*2+1] = (int)y3;

			data4[j*2] = (int)x4;
			data4[j*2+1] = (int)y4;
		}
	}
	/*四块小的索引表合成一块大的索引表*/
	Mat roi1 = ImgIndex(Rect(0,0,w/2,h/2));
	Mat roi2 = ImgIndex(Rect(w/2,0,h/2,w/2));
	Mat roi3 = ImgIndex(Rect(0,h/2,w/2,h/2));
	Mat roi4 = ImgIndex(Rect(w/2,h/2,w/2,h/2));

	ImgIndex1.copyTo(roi1);
	ImgIndex2.copyTo(roi2);
	ImgIndex3.copyTo(roi3);
	ImgIndex4.copyTo(roi4);

}


//void FisheyeImgCorrect::FishImgIndex(Mat& ormImg)
//{
//	//ImgIndex = Mat::zeros(Size(w,h),CV_32S);
//	ImgIndex1 = Mat::zeros(Size(w,h),CV_32SC2);
//	ImgIndex2 = Mat::zeros(Size(w,h),CV_32SC2);
//	ImgIndex3 = Mat::zeros(Size(w,h),CV_32SC2);
//// 	 #pragma omp parallel for
//	for (int i =0; i < h; ++i)
//	{
//		int *data1 = ImgIndex1.ptr<int>(i);
//		int *data2 = ImgIndex2.ptr<int>(i);
//		int *data3 = ImgIndex3.ptr<int>(i);
//		for (int j =0;j < w; ++j)
//		{
//			double x1 = 0 ;
//			double y1 = 0;
//			double x2 = 0 ;
//			double y2 = 0;
//			double x3 = 0 ;
//			double y3 = 0;
//
//			Fix(i,j, x1,y1,phi0,sita0,gama0);
//			Fix(i,j, x2,y2,phi1,sita1,gama1);
//			Fix(i,j, x3,y3,phi2,sita2,gama2);
//
//			//Point2f uv1;
//			//uv1.x = int(x1);
//			//uv1.y = int(y1); 
//
//			//Point2f uv2;
//			//uv2.x = int(x2);
//			//uv2.y = int(y2);
//
//			//Point2f uv3;
//			//uv3.x = int(x3);
//			//uv3.y = int(y3);
//
//			data1[j*2] = (int)x1;
//			data1[j*2+1] = (int)y1;
//
//			data2[j*2] = (int)x2;
//			data2[j*2+1] = (int)y2;
//
//			data3[j*2] = (int)x3;        
//			data3[j*2+1] = (int)y3;
// 
//			//ImgIndex1.at<Point2f>(i,j) = uv1;
//			//ImgIndex2.at<Point2f>(i,j) = uv2;
//			//ImgIndex3.at<Point2f>(i,j) = uv3;
//		}
//	}
//}
void FisheyeImgCorrect::ImageCorrect(Mat& orgImg,Mat& dstImg1,Mat& dstImg2,Mat& dstImg3)
{

	//FishCalculate(orgImg);
	
	dstImg1 =  Mat::zeros(Size(w,h),CV_8UC3); 
	dstImg2 =  Mat::zeros(Size(w,h),CV_8UC3);
	dstImg3 =  Mat::zeros(Size(w,h),CV_8UC3);
	
	//#pragma omp parallel for
	for (int i =0;i < dstImg1.rows; ++i)
	{
		int *data1 = ImgIndex1.ptr<int>(i);
		int *data2 = ImgIndex2.ptr<int>(i);
		int *data3 = ImgIndex3.ptr<int>(i);
		//#pragma omp parallel forz
		for (int j = 0; j < dstImg1.cols;++j)
		{	
			int u1 = data1[j*2];
			int v1 = data1[j*2 +1]; 
			int u2 = data2[j*2];
			int v2 = data2[j*2 +1];
			int u3 = data3[j*2];
			int v3 = data3[j*2 +1];

			if (u1 < orgImg.rows-1 && u1 > -1 && v1 < orgImg.cols-1 && v1 > -1 )
			{
				//dstImg1.at<Vec3b>(i,j) = orgImg.at<Vec3b>(u1,v1);
				*(dstImg1.data + dstImg1.step[0]*i + dstImg1.step[1]*j )
					= *(orgImg.data + orgImg.step[0]*u1 + orgImg.step[1]*v1 );
				*(dstImg1.data + dstImg1.step[0]*i + dstImg1.step[1]*j + dstImg1.elemSize1()) 
					=*(orgImg.data + orgImg.step[0]*u1 + orgImg.step[1]*v1 + orgImg.elemSize1());
				*(dstImg1.data + dstImg1.step[0]*i + dstImg1.step[1]*j + dstImg1.elemSize1() * 2)	                   
					=*(orgImg.data + orgImg.step[0]*u1 + orgImg.step[1]*v1 + orgImg.elemSize1() * 2);

			}
			if (u2 < orgImg.rows-1 && u2 > -1 && v2 < orgImg.cols-1 && v2 > -1 )
			{
				//dstImg2.at<Vec3b>(i,j) = orgImg.at<Vec3b>(u2, v2);

				*(dstImg2.data + dstImg2.step[0]*i + dstImg2.step[1]*j )
					= *(orgImg.data + orgImg.step[0]*u2 + orgImg.step[1]*v2 );
				*(dstImg2.data + dstImg2.step[0]*i + dstImg2.step[1]*j + dstImg2.elemSize1()) 
					=*(orgImg.data + orgImg.step[0]*u2 + orgImg.step[1]*v2 + orgImg.elemSize1());
				*(dstImg2.data + dstImg2.step[0]*i + dstImg2.step[1]*j + dstImg2.elemSize1() * 2)	                   
					=*(orgImg.data + orgImg.step[0]*u2 + orgImg.step[1]*v2 + orgImg.elemSize1() * 2);
			}
			if (u3 < orgImg.rows-1 && u3 > -1 && v3 < orgImg.cols-1 && v3 > -1 )
			{
				//dstImg3.at<Vec3b>(i,j) = orgImg.at<Vec3b>(u3,v3);
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

void FisheyeImgCorrect::ImageCorrect( )
{
//	clock_t t1 = clock();
dstImg =  Mat::zeros(Size(w,h),CV_8UC3); 

for (int i =0;i < h ; ++i)
{
	int *data = ImgIndex.ptr<int>(i);
	for (int j = 0; j < w;++j)
	{

		int u = data[j*2];
		int v = data[j*2 +1];
		if (u < orgImg.rows-1 && u > -1 && v < orgImg.cols-1 && v > -1 )
		{
			dstImg.at<Vec3b>(i,j)  = orgImg.at<Vec3b>(u,v);

		}
	}
}
//clock_t t2 = clock();
//cout<<(t2-t1)/1000.0<<endl;
}
