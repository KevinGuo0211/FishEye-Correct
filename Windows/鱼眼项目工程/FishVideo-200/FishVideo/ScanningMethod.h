//利用扫描线逼近算法标定鱼眼图像的中心和半径


#include"cv.h"
#include"cxcore.h"


using namespace cv;
using namespace std;

 class ScanningMethod
 {
 public:
	 Rect minArea;
	 void Standard_circle(Mat& img,Mat&imgout);
	 void FindDeviceArea(const Mat inputImage);
	 void AccumulatedHistogram(Mat inputImage,long *histogramArray,bool flag);
	 void TroughBinaryzation(long *inputVec,int &Th);
 };
