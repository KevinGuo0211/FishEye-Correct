#include "opencv/cv.h"
#include <opencv2/core/core.hpp>        // Basic OpenCV structures 
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include<iostream>
using namespace cv;
using namespace std;
/*鱼眼图校正类*/
class CFishEyeCorrect
{
public:
	/*展开图宽高*/
	int w;
	int h;
	/*鱼眼区域的宽高的一半*/
	double cx;
	double cy;
	/*f表示焦距，此处用的等距投影模型*/
	double f;
	/*半径*/
	double r;
	/*四个视角的方位角、仰角、视角参数*/
	/*方位角*/
	double phi0;    
	/*仰角*/      
	double sita0;
	/*视角*/
	double gama0;
	double phi1;
	double sita1;
	double gama1;
	double phi2;
	double sita2;
	double gama2;
	double phi3;
	double sita3;
	double gama3;
	/*四幅展开图索引合成的大索引矩阵*/
	Mat ImgIndex;
	/*四幅展开图索引*/
	Mat ImgIndex1;
	Mat ImgIndex2;
	Mat ImgIndex3;
	Mat ImgIndex4;
	int ***dex;
	/*鱼眼区域矩阵*/
	Mat orgImg;
	/*四幅展开图合并为一幅大图，第一到第四，从上往下，从左往右*/
	Mat dstImg;
	CFishEyeCorrect();
	~CFishEyeCorrect();
	/*保存鱼眼区域的矩形变量*/
	Rect correctArea;
	/*从txt中读取相关参数，赋给CFishEyeCorrect类中的相关变量*/
	void ParamFix();
	/*计算所需参数*/
	void CalculateParam(int width, int height);
	/*求出展开图坐标对应的鱼眼图中的坐标*/
	void Fix(int &u,int &v,double &x,double &y,const double &phi,const double &sita,const double &gama);
	/*建立四幅展开图对应鱼眼图中坐标索引，并合成一幅大的索引图*/
	void FishImgIndex(const Mat& ormImg);
	/*图像校正函数*/
	void ImageCorrect( );
	/*获取原图中的鱼眼区域*/
	Rect GetArea(const Mat &inputImage);


private:
	/*获取鱼眼区域矩阵，保存在correctArea*/
	void FindCorrectArea(const Mat &inputImage);
	/*一度等于多少弧度，π/180*/
	const double piParam;
};
