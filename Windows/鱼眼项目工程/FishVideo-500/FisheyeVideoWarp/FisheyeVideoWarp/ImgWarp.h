
#include "cv.h"
#include <math.h>
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

using namespace cv;
typedef unsigned int uint;

class ImgWarp
{
public:
	int w;
	int h;
	double cx;
	double cy;
	double f;
	double r;
	double phi;
	double sita;
	double gama;
	double SQRT;
	double sit;
	uint theta;
	void Fix(int &x,int &y,double &u,double &v);
	void FisheyeImgCorrectInit();
	void FishCalculate(Mat& orgImg);
	void ImageWarp(Mat &orgImg, Mat &dstImg);
	int Plane2Sphere(const Mat& src,Mat& dst,uint z);
	void Set4By1(const cv::Mat& src,cv::Mat& dst,
		cv::Point srcPt,cv::Point dstPt,
		uint nHalfWidthSrc,uint nHalfHeightSrc,
		uint nHalfWidthDst,uint nHalfHeightDst);
	inline void AdjustWidth(cv::Mat& src);

};