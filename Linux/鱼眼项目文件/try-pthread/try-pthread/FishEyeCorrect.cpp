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

	phi3 = phi3 * piParam;
	sita3 = (90-sita3)*piParam;
	gama3 = gama3 * piParam;
}

CFishEyeCorrect::CFishEyeCorrect():piParam(0.01745329)
{
	phi0 = 0.87262757;
	sita0 = 0.61086524;
	gama0 = 1.91986218;

	phi1 = -1.4835279;
	sita1 = -0.08726645;
	gama1 = 1.745532925;

	phi2 = 5.23598775;
	sita2 = 0.6981317;
	gama2 = 1.65806279;

	phi3 = 5.23598775;
	sita3 = 0.6981317;
	gama3 = 1.65806279;
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
	w = 480;
	h = 360;
	r=0.5*(width<height?width:height);
	//0.6366197730950255438113531364418 = 2/3.14159265
	f=r*0.63661977;
	//(w-1)*0.5
	cx=(width-1)>>1;
	//(h-1)*0.5
	cy=(height-1)>>1;
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
	//ImgIndex = Mat::zeros(Size(w*2,h*2),CV_32SC2);
	//ImgIndex1 = Mat::zeros(Size(w,h),CV_32SC2);
	//ImgIndex2 = Mat::zeros(Size(w,h),CV_32SC2);
//	ImgIndex3 = Mat::zeros(Size(w,h),CV_32SC2);
	//ImgIndex4 = Mat::zeros(Size(w,h),CV_32SC2);
		
	int **Index=(int **)malloc(w*8*sizof(int*));
	//#pragma omp parallel for
	for (int i =0; i < h; ++i)
	{
		
		//int *data1 = ImgIndex1.ptr<int>(i);
		//int *data2 = ImgIndex2.ptr<int>(i);
		//int *data3 = ImgIndex3.ptr<int>(i);
		//int *data4 = ImgIndex4.ptr<int>(i);
		//#pragma omp parallel for
		for (int j =0;j < w; ++j)
		{
			Index[j] = (int *)malloc(sizeof(int)*8);
			double x1 = 0 ;
			double y1 = 0;
			double x2 = 0 ;
			double y2 = 0;
			double x3 = 0 ;
			double y3 = 0;
			double x4 = 0 ;
			double y4 = 0;

			Fix(i,j, x1,y1,phi0,sita0,gama0);
			Fix(i,j, x2,y2,phi1,sita1,gama1);
			Fix(i,j, x3,y3,phi2,sita2,gama2);
			Fix(i,j, x4,y4,phi3,sita3,gama3);

			data1[j*2] = (int)x1;
			data1[j*2+1] = (int)y1;

			data2[j*2] = (int)x2;
			data2[j*2+1] = (int)y2;

			data3[j*2] = (int)x3;
			data3[j*2+1] = (int)y3;

			data4[j*2] = (int)x4;
			data4[j*2+1] = (int)y4;
			Index[j][0] = x1;
			Index[j][1] = y1;
			Index[j][2] = x2;
			Index[j][3] = y2;
			Index[j][4] = x3;
			Index[j][5] = y3;
			Index[j][6] = x4;
			Index[j][7] = y4;
			
		}
	}
/*	Mat roi1 = ImgIndex(Rect(0,0,w,h));
	Mat roi2 = ImgIndex(Rect(w,0,w,h));
	Mat roi3 = ImgIndex(Rect(0,h,w,h));
	Mat roi4 = ImgIndex(Rect(w,h,w,h));
	ImgIndex1.copyTo(roi1);
	ImgIndex2.copyTo(roi2);
	ImgIndex3.copyTo(roi3);
	ImgIndex4.copyTo(roi4);*/
}


/*
void CFishEyeCorrect::ImageCorrect(const Mat& orgImg,Mat& dstImg1,Mat& dstImg2,Mat& dstImg3)
{
	
	dstImg1 =  Mat::zeros(Size(w/3,h/3),CV_8UC3); 
	dstImg2 =  Mat::zeros(Size(w/3,h/3),CV_8UC3);
	dstImg3 =  Mat::zeros(Size(w/3,h/3),CV_8UC3);

	int lineWidth1 = dstImg1.step[0];
	int eleWidth1 = dstImg1.step[1];
	int lineWidth2 = dstImg2.step[0];
	int eleWidth2 = dstImg1.step[1];
	int lineWidth3 = dstImg3.step[0];
	int eleWidth3 = dstImg3.step[1];
	int eleSize = dstImg1.elemSize1();

	int orgImgLineWidht = orgImg.step[0];
	int orgImgEleWidht = orgImg.step[1];

	//int in
	
	//#pragma omp parallel for
	for (int i =0;i < dstImg1.rows ; ++i)
	{
		int *data1 = ImgIndex1.ptr<int>(i);
		int *data2 = ImgIndex2.ptr<int>(i);
		int *data3 = ImgIndex3.ptr<int>(i);
		for (int j = 0; j < dstImg1.cols;++j)
		{
		int u1 = data1[j*2];
		//int u1 = *(ImgIndex1.data + ImgIndex1.step[0]*i*3 + ImgIndex1.step[1]*j*3);//+ sizeof(int)*j*8);
		int v1 = data1[j*2 +1];
		//int v1 = *(ImgIndex1.data + ImgIndex1.step[0]*i*3 +  ImgIndex1.step[1]*j*3 + sizeof(int));
		int u2 = data2[j*2];
		//int u2 = *(ImgIndex2.data + ImgIndex2.step[0]*i*3 + ImgIndex2.step[1]*j*3);
		int v2 = data2[j*2 +1];
		//int v2 = *(ImgIndex2.data + ImgIndex2.step[0]*i*3 + ImgIndex2.step[1]*j*3 + sizeof(int));
		int u3 = data3[j*2];
		//int u3 = *(ImgIndex3.data + ImgIndex3.step[0]*i*3 + ImgIndex3.step[1]*j*3);
		int v3 = data3[j*2 +1];
		//int v3 = *(ImgIndex3.data + ImgIndex3.step[0]*i*3 + ImgIndex3.step[1]*j*3 + sizeof(int));

			if (u1 < orgImg.rows-1 && u1 > -1 && v1 < orgImg.cols-1 && v1 > -1 )
			{
				*(dstImg1.data + lineWidth1*i + eleWidth1*j )
					= *(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 );
				*(dstImg1.data + lineWidth1*i + eleWidth1*j + eleSize) 
					=*(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 + eleSize);
				*(dstImg1.data + lineWidth1*i + eleWidth1*j + 2*eleSize)	                   
					=*(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 + 2*eleSize);
			}
			if (u2 < orgImg.rows-1 && u2 > -1 && v2 < orgImg.cols-1 && v2 > -1 )
			{
				*(dstImg2.data + lineWidth2*i + eleWidth2*j )
					= *(orgImg.data + orgImgLineWidht*u2 + orgImgEleWidht*v2 );
				*(dstImg2.data + lineWidth2*i + eleWidth2*j + eleSize) 
					=*(orgImg.data + orgImgLineWidht*u2 + orgImgEleWidht*v2 + eleSize);
				*(dstImg2.data + lineWidth2*i + eleWidth2*j + 2*eleSize)	                   
					=*(orgImg.data + orgImgLineWidht*u2 + orgImgEleWidht*v2 + 2*eleSize);
			}
			if (u3 < orgImg.rows-1 && u3 > -1 && v3 < orgImg.cols-1 && v3 > -1 )
			{
				*(dstImg3.data + lineWidth3*i + eleWidth3*j )
					= *(orgImg.data + orgImgLineWidht*u3 + orgImgEleWidht*v3 );
				*(dstImg3.data + lineWidth3*i + eleWidth3*j + eleSize) 
					=*(orgImg.data + orgImgLineWidht*u3 + orgImgEleWidht*v3 + eleSize);
				*(dstImg3.data + lineWidth3*i + eleWidth3*j + 2*eleSize)	                   
					=*(orgImg.data + orgImgLineWidht*u3 + orgImgEleWidht*v3 + 2*eleSize);
			}
		}
	}
}

*/
void CFishEyeCorrect::ImageCorrect(const Mat& orgImg,Mat& dstImg,int **Index )
{
	
	dstImg =  Mat::zeros(Size(w*2,h*2),CV_8UC3); 
	//#pragma omp parallel for
	int lineWidth = dstImg.step[0];
	int eleWidth = dstImg.step[1];
	int orgImgLineWidht = orgImg.step[0];
	int orgImgEleWidht = orgImg.step[1];
	int eleSize = dstImg.elemSize1();
	for (int i =0;i < h; ++i)
	{
		//int *data = ImgIndex.ptr<int>(i);
		for (int j = 0; j < w;++j)
		{
			int u1 = Index[j][0];
			int v1 = Index[j][1];
			int u2 = Index[j][2];
			int v2 = Index[j][3];
			int u3 = Index[j][4];
			int v3 = Index[j][5];
			int u4 = Index[j][6];
			int v4 = Index[j][7];
		  //int u = data[j*2];
		 // int v = data[j*2 +1];
			/*if (u < orgImg.rows-1 && u > -1 && v < orgImg.cols-1 && v > -1 )
			{
				*(dstImg.data + lineWidth*i + eleWidth*j )
					= *(orgImg.data + orgImgLineWidht*u + orgImgEleWidht*v );
				*(dstImg.data + lineWidth*i + eleWidth*j + eleSize) 
					=*(orgImg.data + orgImgLineWidht*u + orgImgEleWidht*v + eleSize);
				*(dstImg.data + lineWidth*i + eleWidth*j + 2*eleSize)	                   
					=*(orgImg.data + orgImgLineWidht*u + orgImgEleWidht*v + 2*eleSize);
			}*/
			if (u1 < orgImg.rows-1 && u1 > -1 && v1 < orgImg.cols-1 && v1 > -1 )
				{
					*(dstImg.data + lineWidth*i + eleWidth*j )
					= *(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 );
				*(dstImg.data + lineWidth*i + eleWidth*j + eleSize) 
					=*(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 + eleSize);
				*(dstImg.data + lineWidth*i + eleWidth*j + 2*eleSize)	                   
					=*(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 + 2*eleSize);		
					}
				if (u2 < orgImg.rows-1 && u2 > -1 && v2 < orgImg.cols-1 && v2 > -1 )
				{
					*(dstImg.data + lineWidth*i + eleWidth*j )
					= *(orgImg.data + orgImgLineWidht*u2 + orgImgEleWidht*v2 );
				*(dstImg.data + lineWidth*i + eleWidth*j + eleSize) 
					=*(orgImg.data + orgImgLineWidht*u2 + orgImgEleWidht*v2 + eleSize);
				*(dstImg.data + lineWidth*i + eleWidth*j + 2*eleSize)	                   
					=*(orgImg.data + orgImgLineWidht*u2 + orgImgEleWidht*v2 + 2*eleSize);		
					}
					if (u3 < orgImg.rows-1 && u3 > -1 && v3 < orgImg.cols-1 && v3 > -1 )
				{
					*(dstImg.data + lineWidth*i + eleWidth*j )
					= *(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 );
				*(dstImg.data + lineWidth*i + eleWidth*j + eleSize) 
					=*(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 + eleSize);
				*(dstImg.data + lineWidth*i + eleWidth*j + 2*eleSize)	                   
					=*(orgImg.data + orgImgLineWidht*u1 + orgImgEleWidht*v1 + 2*eleSize);		
					}
					if (u4 < orgImg.rows-1 && u4 > -1 && v4 < orgImg.cols-1 && v4 > -1 )
				{
					*(dstImg.data + lineWidth*i + eleWidth*j )
					= *(orgImg.data + orgImgLineWidht*u4 + orgImgEleWidht*v4 );
				*(dstImg.data + lineWidth*i + eleWidth*j + eleSize) 
					=*(orgImg.data + orgImgLineWidht*u4 + orgImgEleWidht*v4 + eleSize);
				*(dstImg.data + lineWidth*i + eleWidth*j + 2*eleSize)	                   
					=*(orgImg.data + orgImgLineWidht*u4 + orgImgEleWidht*v4 + 2*eleSize);		
					}
		}  
	}
	

}


