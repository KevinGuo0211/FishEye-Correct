#include <iostream> 						// for standard I/O
#include <string>   						// for strings
#include <iomanip>  						// for controlling float print precision
#include <sstream>                          // string to number conversion
#include <pthread.h>
#include <fstream>

#include "FishEyeCorrect.h"
#include  "opencv2/core/core.hpp"           // Basic OpenCV structures (cv::Mat, Scalar)
#include  "opencv2/imgproc/imgproc.hpp"     // Gaussian Blur
#include  "opencv2/highgui/highgui.hpp"     // OpenCV window I/O

using namespace std;
using namespace cv;

int frameNumber = 0;
/*线程1  进行四个块的校正*/
void  *thrd_func1(void *argv);                  
/*线程2   进行视频解码*/
void  *thrd_func2(void *argv);	
/*提取一个字符串中的数字(从txt中提取数字参数)*/		        
void str2num(string& str,vector<int>& rint);    
/*字符串中提取数字*/
int substr2num(string& str);					
CFishEyeCorrect fishCorrect;
/*保存视频帧的变量*/
Mat frame;	
VideoCapture cap;

int main(int argc, char *argv[])
{
    if(argc <2)
    {
   	return -1;
    }
    cap.open(argv[1]);
    /*获取视频帧数*/
    frameNumber = cap.get(CV_CAP_PROP_FRAME_COUNT);    
    if(!cap.isOpened())
     {
        cout<<"can't open the video!"<<endl;
        return 0;
     }
    int flag = 0;
    /*字符串缓冲数组*/
    char  buf[100];										
    ifstream in("test.txt");
    int totalnum = 0;
    while (in.getline(buf,100))
        {
	   string str = buf;
	   vector<int>   myint;
	   /*提取一行字符串中的数字*/
	   str2num(str,myint);	
	   /*第一行，获取宽和高*/							
	   if(0==totalnum)
	    {
	      fishCorrect.w = myint[0];
              fishCorrect.h = myint[1];
	    }
	   /*提取第二行，获取第一个展开图的参数：方位角，仰角，视角*/
           else if(1==totalnum)
              {
                 fishCorrect.phi0 = myint[0];
		 fishCorrect.sita0 = myint[1];
		 fishCorrect.gama0 = myint[2];
	      }
	  /*提取第三行，获取第二个展开图的参数：方位角，仰角，视角*/
	   else if(2==totalnum)
	      {
	         fishCorrect.phi1 = myint[0];
                 fishCorrect.sita1 = myint[1];
		 fishCorrect.gama1 = myint[2];
	      }
	  /*提取第四行，获取第三个展开图的参数：方位角，仰角，视角*/
	    else if(3==totalnum)
	       {
		   fishCorrect.phi2 = myint[0];
		   fishCorrect.sita2 = myint[1];
		   fishCorrect.gama2 = myint[2];
		}
	   /*提取第五行，获取第四个展开图的参数：方位角，仰角，视角*/
	    else if(4==totalnum)
		{
		   fishCorrect.phi3 = myint[0];
		   fishCorrect.sita3 = myint[1];
		   fishCorrect.gama3 = myint[2];
		}	
		totalnum++;
	}
	cout<<"playing...."<<endl;
	/*循环处理视频*/
        int wflag = 0;
	int num =0;
	
	for(int i = 0;i < frameNumber;++i)               
	{
		pthread_t tid1,tid2;
     		void *tret;
		if(i <= 21)
		{
		    cap >> frame;	
			//resize(frame,frame,Size(1920,1080));		
		}
		if(i >20)
		{
		    if (flag == 0)
		    {
		    	/*获取鱼眼图像区域*/
			fishCorrect.GetArea(frame);
			flag =1;
		    }
		   if (i>21)
		    {
			
			/*创建线程2*/
		      if (pthread_create(&tid2,NULL,thrd_func2,NULL)!=0)
			 {
         		    printf("Create thread 2 error!\n");
         		    exit(1);
     			 }
	     		/*等待线程一执行完毕*/
			if (pthread_join(tid1,&tret)!=0)
			  { 
			      printf("Join thread 1 error!\n");
			      exit(1);
                           }
		       // 显示结果
		       if (wflag == 0)
		        {
		     	   namedWindow("Video0",1);
		     	   namedWindow("Video1",1);
			   wflag =1;
			}
		       // clock_t t1 = clock();
		       imshow("Video0",fishCorrect.orgImg);
		       imshow("Video1",fishCorrect.dstImg);
		      //  clock_t t2 = clock();
		      // cout<<(t2-t1)/1000.0<<endl;
		      /*等待线程二执行完毕*/
		      if (pthread_join(tid2,&tret)!=0)
			{
		           printf("Join thread 2 error!\n");
		       	   exit(1);
		        }
		        waitKey(1);				
		   }
		   /*如果没有视频数据，跳出循环*/
	  	   if (!frame.data)                                       
		     {
			  break;
		     }
		  /*将鱼眼区域提取出来，赋给orgImg变量*/
		  fishCorrect.orgImg  = frame(fishCorrect.correctArea);
		  if (i ==21)
		  {
		  	/*计算所需参数*/
		     fishCorrect.ParamFix();
		     fishCorrect.CalculateParam(fishCorrect.orgImg.cols,fishCorrect.orgImg.rows);
		     /*建立校正索引表*/
		     fishCorrect.FishImgIndex(fishCorrect.orgImg);
		  }
		if(i < frameNumber-1)
		{
		 /*创建线程一*/
     		 if (pthread_create(&tid1,NULL,thrd_func1,NULL)!=0) 
		  {
        	     printf("Create thread 1 error!\n");
                     exit(1);
         	  }
		}
	    }
	}
	      cout<<"play over"<<endl;
	      return 0;
}
/*线程函数一，视频帧畸变校正处理*/
void  *thrd_func1(void *argv)
{
   fishCorrect.ImageCorrect();
   pthread_exit(NULL); 
}
/*线程函数二，视频解码*/
void  *thrd_func2(void *argv)
{
	cap >> frame;
	pthread_exit(NULL); 	
}

/**********************************************
*功能：提取字符串中的数字
*输入参数：一个字符串
*输出参数：数字向量
*返回值：空
***********************************************/
void str2num(string& str,vector<int>& rint)
{
	/*通过字符'/'进行拆分为不同的字串，然后调用substr2num函数获取字串中的数字*/
	string strSep = "/";
	int size_pos = 0;
	string strresult;
	int size_prev_pos = 0;
	int itemp = 0;

	while((size_pos=str.find_first_of(strSep,size_pos))!=string::npos)
	{
		strresult = str.substr(size_prev_pos,size_pos - size_prev_pos);
		/*对字串进一步处理，获得数字*/
		itemp = substr2num(strresult);
		rint.push_back(itemp);
		size_prev_pos=++size_pos;
	}
	if (size_prev_pos!=str.size())
	{
		strresult = str.substr(size_prev_pos,size_pos - size_prev_pos);
		itemp = substr2num(strresult);
		rint.push_back(itemp);
	}
}
/**********************************************
*功能：提取字串中的数字
*输入参数：一个字符串
*输出参数：空
*返回值：一个整数
***********************************************/
int substr2num(string& str)
{
	/*依据等号提取数字*/
	int strlength = str.size();
	stringstream os;
	string strSep = "=";
	int size_pos=0;
	string tem;
	int result = 0;
	size_pos = str.find_first_of(strSep,size_pos);
	tem = str.substr(size_pos+1,strlength - size_pos);
	os<<tem;
	os>>result;
	return result;
}

