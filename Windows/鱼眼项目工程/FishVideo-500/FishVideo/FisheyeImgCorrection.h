
//Fisheye Image correction

#include "cv.h"
#include <math.h>
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

using namespace cv;

class FisheyeImgCorrect
{
public:
	int w;
	int h;
	double cx;
	double cy;
	double f;
	double r;
	double phi0;
	double sita0;
	double gama0;
	double phi1;
	double sita1;
	double gama1;
	double phi2;
	double sita2;
	double gama2;
	Mat ImgIndex1;
	Mat ImgIndex2;
	Mat ImgIndex3;
	int Flag;
	void FisheyeImgCorrectInit();
	void FishCalculate(Mat& fishImage);
	void FishImgIndex(Mat &orgImg);
	void Fix(int &u,int &v,double &x,double &y,double phi0,double sita0,double gama0);
	void ImageCorrect(Mat& fishImage,Mat& dstImg1,Mat& dstImg2,Mat& dstImg3);
};