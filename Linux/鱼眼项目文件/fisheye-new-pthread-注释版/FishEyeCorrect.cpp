#include "FishEyeCorrect.h"


CFishEyeCorrect::~CFishEyeCorrect(){}
/*****************************
*将度转为弧度
******************************/
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
/*****************************
*构造函数，初始化piParam
******************************/
CFishEyeCorrect::CFishEyeCorrect():piParam(0.01745329)
{

}
/*****************************
*功能：求出源图中鱼眼所在区域
*输入参数：视频输入图
*输出参数：空
*返回值：鱼眼区域所在的矩形
******************************/
Rect CFishEyeCorrect::GetArea(const Mat &inputImage)
{
	FindCorrectArea(inputImage);
	return correctArea;
}
/*****************************
*功能：求出源图中鱼眼所在区域
*输入参数：视频输入图
*输出参数：空
*返回值：空
******************************/
void CFishEyeCorrect::FindCorrectArea(const Mat &inputImage)
{
	Mat grayImage;
	cvtColor(inputImage,grayImage,CV_BGR2GRAY,1);
	/*二值化*/
	threshold(grayImage,grayImage,100,255,THRESH_BINARY);
	vector<vector<Point > > contours;
	/*找轮廓*/
	findContours(grayImage,contours,CV_RETR_EXTERNAL,CV_CHAIN_APPROX_NONE);
	Rect minAreaTemp;
	int areaSize(0); 
	int areaSizeTemp(0);
	int areaIter(0);
	/*找到最大轮廓,就是鱼眼圆的轮廓*/
	for (int contoursIter = 0;contoursIter != contours.size();++contoursIter)
	{
	/*求轮廓的包围盒子*/
		minAreaTemp=boundingRect(contours[contoursIter]);
		areaSizeTemp=minAreaTemp.width*minAreaTemp.height;
		if (areaSize<areaSizeTemp)
		{
			correctArea=minAreaTemp;
			areaSize=areaSizeTemp;
		}
	}
	
}
/*****************************
*功能：计算所需参数
*输入参数：鱼眼区域的宽高
*输出参数：空
*返回值：空
******************************/
void CFishEyeCorrect::CalculateParam(int width, int height)
{
	r=0.5*(width<height?width:height);
	f= r*2/3.14159265;
	cx=(width-1)/2;  
	cy=(height-1)/2;   
}
/*****************************
*功能：展开图在鱼眼区域坐标
*输入参数：展开图中坐标，展开图的方位角，仰角，视角
*输出参数：鱼眼区域中的对应坐标
*返回值：空
******************************/
void CFishEyeCorrect::Fix(int &u,int &v,double &x,double &y,const double &phi,const double &sita,const double &gama)
{
	/*展开平面与校正图比例，平面与空间坐标关系*/
	double wp,hp,dux,duy,duz,dvx,dvy,dvz,xp,yp,zp,SQRT,sit,c_p,s_p;
	//1
	/*展开图像上的一个像素大小对应透视投影平面上的宽高大小*/
	wp=r*tan(gama/2)/(cx+0.5);     
	hp=r*tan(gama/2)/(cy+0.5);     
	//2
	/*展开图U坐标正方向单位像素对应相机坐标系x,y,z三个轴上的变化量*/
	dux=wp*sin(phi),duy=-wp*cos(phi),duz=0;
	/*展开图V坐标正方向单位像素对应相机坐标系x,y,z三个轴上的变化量*/
	dvx=-hp*cos(sita)*cos(phi),dvy=-hp*cos(sita)*sin(phi);
	dvz=hp*sin(sita);
	//3
	/*展开图中一个坐标在球面坐标系x,y,z的坐标值*/
	xp=r*sin(sita)*cos(phi)+(cx-u)*dux+(v-cy)*dvx;
	yp=r*sin(sita)*sin(phi)+(cx-u)*duy+(v-cy)*dvy;
	zp=r*cos(sita)+(v-h)*dvz;
	//4
	/*求出斜边长度*/
	SQRT=sqrt(xp*xp+yp*yp);
	/*求入射角*/
	sit=atan(SQRT/zp);
	/*求cos值*/
	c_p=xp/SQRT;   
	/*求sin值*/          
	s_p=yp/SQRT;
	//5
	/*对应鱼眼图中坐标*/
	x=cx+f*sit*c_p;
	y=cy+f*sit*s_p;
}
/*****************************
*功能：建立四幅展开图对应的鱼眼图的索引表
*输入参数：鱼眼图
*输出参数：空
*返回值：空
******************************/
void CFishEyeCorrect::FishImgIndex(const Mat& ormImg)
{
	/*为索引表分配空间*/
	ImgIndex =  Mat::zeros(Size(w*2,h*2),CV_32SC2);
	ImgIndex1 = Mat::zeros(Size(w,h),CV_32SC2);
	ImgIndex2 = Mat::zeros(Size(w,h),CV_32SC2);
	ImgIndex3 = Mat::zeros(Size(w,h),CV_32SC2);
	ImgIndex4 = Mat::zeros(Size(w,h),CV_32SC2);
	ImgIndex22 = Mat::zeros(Size(w,h),CV_32SC2);
	/*遍历展开图的每一个像素，求取对应鱼眼图中的坐标*/
	for (int i =0; i < h; ++i)
	{
		int *data1 = ImgIndex1.ptr<int>(i);
		int *data2 = ImgIndex2.ptr<int>(i);
		int *data3 = ImgIndex3.ptr<int>(i);
		int *data4 = ImgIndex4.ptr<int>(i);
		for (int j =0;j < w; ++j)
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
		}
	}
	/*四块小的索引表合成一块大的索引表*/
	Mat roi1 = ImgIndex(Rect(0,0,w,h));
	Mat roi2 = ImgIndex(Rect(w,0,w,h));
	Mat roi3 = ImgIndex(Rect(0,h,w,h));
	Mat roi4 = ImgIndex(Rect(w,h,w,h));

	ImgIndex1.copyTo(roi1);
	ImgIndex2.copyTo(roi2);
	ImgIndex3.copyTo(roi3);
	ImgIndex4.copyTo(roi4);
}
/*****************************
*功能：鱼眼图校正
*输入参数：空
*输出参数：空
*返回值：空
******************************/
void CFishEyeCorrect::ImageCorrect( )
{	
	dstImg =  Mat::zeros(Size(w,h),CV_8UC3); 
	lineWidth = dstImg.step[0];
	eleWidth = dstImg.step[1];
	orgImgLineWidht = orgImg.step[0];
	orgImgEleWidht = orgImg.step[1];
	eleSize = dstImg.elemSize1();
	pthread_t tid1,tid2,tid3,tid4;
    void *tret;
    /*创建校正线程一，求取第一幅展开图*/
	if (pthread_create(&tid1,NULL,pth_fun1,this)!=0) 
	{
       	  	printf("Create thread 1 error!\n");
         	exit(1);
   	  }
	/*创建校正线程二，求取第二幅展开图*/
     if (pthread_create(&tid2,NULL,pth_fun2,this)!=0)
 	{
         printf("Create thread 2 error!\n");
         exit(1);
   	 }
   	 /*创建校正线程三，求取第三幅展开图*/
	if (pthread_create(&tid3,NULL,pth_fun3,this)!=0) 
	{
       	  	printf("Create thread 1 error!\n");
         	exit(1);
   	  }
	/*创建校正线程四，求取第四幅展开图*/
     if (pthread_create(&tid4,NULL,pth_fun4,this)!=0)
 	{
         printf("Create thread 2 error!\n");
         exit(1);
   	 }
   	 /*等待四个校正线程处理完毕*/
	 if (pthread_join(tid1,&tret)!=0)
	{
		 printf("Join thread 1 error!\n");
		 exit(1);
	}
	 if (pthread_join(tid2,&tret)!=0)
	{
		 printf("Join thread 1 error!\n");
		 exit(1);
	}
	 if (pthread_join(tid3,&tret)!=0)
	{
		 printf("Join thread 1 error!\n");
		 exit(1);
	}
	 if (pthread_join(tid4,&tret)!=0)
	{
		 printf("Join thread 1 error!\n");
		 exit(1);
	}
}
/*****************************
*功能：校正线程一
*输入参数：指向当前类对象的指针
*输出参数：空
*返回值：空
******************************/
void *CFishEyeCorrect::pth_fun1(void *pth)
{  
	clock_t str = clock();
	CFishEyeCorrect *pthis = (CFishEyeCorrect *)pth;
	/*鱼眼图中像素搬移到展开图中*/
	for (int i =0;i < pthis->h/2 ; ++i)
	{
		int *data = pthis->ImgIndex.ptr<int>(i*2);
		for (int j = 0; j < (pthis->w)/2;++j)
		{

		  int u = data[j*4];
		  int v = data[j*4 +1];
			if (u < pthis->orgImg.rows-1 && u > -1 && v < pthis->orgImg.cols-1 && v > -1 )
			{
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j )
					= *(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v );
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j + pthis->eleSize) 
					=*(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v + pthis->eleSize);
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j + 2*pthis->eleSize)	                   
					=*(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v + 2*pthis->eleSize);
			}
		}
	}
	pthread_exit(NULL); 
}
/*****************************
*功能：校正线程一
*输入参数：指向当前类对象的指针
*输出参数：空
*返回值：空
******************************/
void *CFishEyeCorrect::pth_fun2(void *pth)
{
	CFishEyeCorrect *pthis = (CFishEyeCorrect *)pth;
	/*鱼眼图中像素搬移到展开图中*/
	for (int i =0;i <( pthis->h)/2; ++i)      
	{
		int *data = pthis->ImgIndex.ptr<int>(i*2);
		for (int j = pthis->w/2+1; j <((pthis->w)-1);++j)
		{
		  int u = data[j*4];
		  int v = data[j*4 +1];
			if (u < pthis->orgImg.rows-1 && u > -1 && v < pthis->orgImg.cols-1 && v > -1 )
			{
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j )
					= *(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v );
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j + pthis->eleSize) 
					=*(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v + pthis->eleSize);
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j + 2*pthis->eleSize)	                   
					=*(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v + 2*pthis->eleSize);
			}
		}
	}
	pthread_exit(NULL); 
}
/*****************************
*功能：校正线程一
*输入参数：指向当前类对象的指针
*输出参数：空
*返回值：空
******************************/
void *CFishEyeCorrect::pth_fun3(void *pth)
{
	CFishEyeCorrect *pthis = (CFishEyeCorrect *)pth;
	/*鱼眼图中像素搬移到展开图中*/
	for (int i = pthis->h/2;i < ((pthis->h)-1); ++i)
	{
		int *data = pthis->ImgIndex.ptr<int>(i*2);
		for (int j = 0; j < (pthis->w)/2;++j)
		{

		  int u = data[j*4];
		  int v = data[j*4 +1];
			if (u < pthis->orgImg.rows-1 && u > -1 && v < pthis->orgImg.cols-1 && v > -1 )
			{
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j )
					= *(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v );
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j + pthis->eleSize) 
					=*(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v + pthis->eleSize);
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j + 2*pthis->eleSize)	                   
					=*(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v + 2*pthis->eleSize);
			}
		}
	}
	pthread_exit(NULL); 
}
/*****************************
*功能：校正线程一
*输入参数：指向当前类对象的指针
*输出参数：空
*返回值：空
******************************/
void *CFishEyeCorrect::pth_fun4(void *pth)
{
	CFishEyeCorrect *pthis = (CFishEyeCorrect *)pth;
	/*鱼眼图中像素搬移到展开图中*/
	for (int i =pthis->h/2;i <(( pthis->h)-1) ; ++i)
	{
		int *data = pthis->ImgIndex.ptr<int>(i*2);
		for (int j = pthis->w/2; j <((pthis->w)-1);++j)
		{

		  int u = data[j*4];
		  int v = data[j*4 +1];
			if (u < pthis->orgImg.rows-1 && u > -1 && v < pthis->orgImg.cols-1 && v > -1 )
			{
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j )
					= *(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v );
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j + pthis->eleSize) 
					=*(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v + pthis->eleSize);
				*(pthis->dstImg.data + pthis->lineWidth*i + pthis->eleWidth*j + 2*pthis->eleSize)	                   
					=*(pthis->orgImg.data + pthis->orgImgLineWidht*u + pthis->orgImgEleWidht*v + 2*pthis->eleSize);
			}
		}
	}
	pthread_exit(NULL);
}