/*
*Copyright(c)2014,冉科信息技术有限公司
*All rights reserved.
*
*文件名称：Trace.h
*文件标识：跟踪程序运行的日志类头文件
*摘    要：一个好的代码应该具有跟踪功能。
*
*当前版本：1.0
*作    者：卫永波
*完成日期：2014.8.15
*/


#ifndef __CTRACE_H_
#define __CTRACE_H_



#include <stdio.h>//standard input & output
#include <Windows.h>
#include <iostream>


/*备注：
       string 与string.h是完全不同的两个文件。string和using namespace std一起用
	   string.h是C里面的头文件，具体看存储的文档*/
#include <string> 
using namespace std; //这两个头文件是为了让string类的头文件


//定义写log的地址，以及返回成功与否的一些结果
#define FILE_PATH "TraceLog.txt"

//int WriteToLog(char *str);
//关于函数WriteToLog(char *str)函数的一些返回结果
//{写log成功,打开文件失败,写log失败}
enum{WRITE_SUCCESS,OPENFILE_FAILED,WRITE_FAILED};


//添加时间标记的相关类
#include <ctime>
//三种类型{日期+时间、日期、时间}
enum{CTRACE_DATA_TIME,CTRACE_DATA,CTRACE_TIME};



//////////////////////////////////////////////////////////////////////////
//类名称：
//    CTrace
//类成员：
//    static bool traceIsActive-一个决定是否触发跟踪条件的静态成员
//    string *theFunctionName-存储待跟踪函数名称的指针                          
//成员函数：
//    void debug (const string&msg)-将调试信息输出到界面上的一个函数。写
//                                  txt文本则不需要用到该函数。
//    int WriteToLog(char *str)-将文本写到txt程序当中，str为对应文本
//    int getSystemTime(char *out,int fmt)-获取系统时间的函数
//说明：
//    该类的所有成员函数均采用内联的形式创建，主要目的是以空间换取时间
//    尽量减小调试部分对整个程序运行时间的影响。但是，需要注意：不要将
//    该记录类镶嵌到无限的循环等等while或for循环当中去，因为那样会影响
//    程序的运行效率。虽然已经进行过优化。
//用法：
//    第一步：首先要定义宏FILE_PATH的路径。
//    第二步：要注意使bool CMyTrace::traceIsActive的值为true
//    第三步：建议使用过程中采取
//                              #ifdef _CTRACE
//                              CMyTrace t("myFunction");
//                              t.WriteToLog("日志信息")
//                              #endif
//            的编译方式
//////////////////////////////////////////////////////////////////////////

class CMyTrace
{
public:
	CMyTrace(const char *name) : theFunctionName(0)
	{
		if (traceIsActive)//有条件的创造
		{
			//cout << "Enter function" << name << endl;
			theFunctionName = new string(name);
		}
	};
	~CMyTrace();
	void debug (const string &msg);
	int WriteToLog(char *str);
	
	static bool traceIsActive;
protected:
	int getSystemTime(char *out, int fmt);

private:
	string *theFunctionName;
	
};

//////////////////////////////////////////////////////////////////////////
//函数名称：
//    ~CTrace()
//
//说明：
//    在触发的条件下delete theFunctionName的空间。
//////////////////////////////////////////////////////////////////////////
inline CMyTrace::~CTrace()
{
	//
	if (traceIsActive)
	{
		//cout << "Exit function" << *theFunctionName<< endl;
		delete theFunctionName;
	}
}


//////////////////////////////////////////////////////////////////////////
//函数名称：
//    debug(const string &msg)
//
//函数参数：
//    const string &msg-给dos界面即将要输出的信息
//返回值：
//    无 
//说明：
//    当在dos系统下调试win32工程的时候，就不必在txt里面输出信息了。可以
//    使用cout直接输出信息。这个时候可以使用该函数。
//////////////////////////////////////////////////////////////////////////
inline void CMyTrace::debug(const string &msg)
{
	if (traceIsActive)
	{
		//cout << msg << endl;
	}
}


//////////////////////////////////////////////////////////////////////////
//函数名称：
//    getSystemTime(char *out, int fmt=ZH_CTRACE_TIME)
//
//函数参数：
//    char *out-将时间已经获取后，变成文本变量后存放的地方
//    int fmt-需要输出的格式,默认指定为CTRACE_TIME的输出方式
//            CTRACE_DATA_TIME ：年-月-日 时-分-秒的格式
//            CTRACE_DATA ：年-月-日的格式
//            CTRACE_TIME ：时-分-秒的格式
//            
//     
//返回值：
//    -1：文本容器为空，获取失败
//    0 :获取成功
//说明：
//    获取该程序运行时的实时时间。
//////////////////////////////////////////////////////////////////////////

inline int CMyTrace::getSystemTime(char *out, int fmt=CTRACE_TIME)
{
	//
	if (!traceIsActive)
	{
		return -1;
	}

	//
	if (NULL == out)
	{
		return -1;
	}

	time_t t;
	struct tm *tp;
	t = time(NULL);//不包含ctime头文件 time函数会不识别

	tp = localtime(&t);
	if (CTRACE_DATA_TIME == fmt)
	{
		sprintf_s(out,25,"%2.2d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d",
			tp->tm_year+1900,tp->tm_mon+1,tp->tm_mday,
			tp->tm_hour,tp->tm_min,tp->tm_sec);
	} 
	else if (CTRACE_DATA == fmt)
	{
		sprintf_s(out,25,"%2.2d-%2.2d-%2.2d ",
			tp->tm_year+1900,tp->tm_mon+1,tp->tm_mday);
	}
	else if (CTRACE_TIME == fmt)
	{
		sprintf_s(out,25,"%2.2d:%2.2d:%2.2d",
			tp->tm_hour,tp->tm_min,tp->tm_sec);
	}
	return 0;
}


//////////////////////////////////////////////////////////////////////////
//函数名称：
//    WriteToLog(char *str)
//
//函数参数：
//    char *strt-给txt中即将要写入的信息     
//返回值：
//    int型
//       {写log成功,打开文件失败,写log失败}
//       enum{WRITE_SUCCESS,OPENFILE_FAILED,WRITE_FAILED};
//说明：
//    给txt书写信息的结果。
//////////////////////////////////////////////////////////////////////////
inline int CMyTrace::WriteToLog(char *str)
{
	if (!traceIsActive)
	{
		return -1;
	}

	//
	FILE* pfile;
	if(NULL != fopen_s(&pfile,FILE_PATH,"a+"))
	{
		return OPENFILE_FAILED;
	};

	const char *pchar_theFunctionName=theFunctionName->c_str();

	char pchar_theTime[25];
	getSystemTime(pchar_theTime,CTRACE_DATA_TIME);

	if (NULL == fprintf_s(pfile,"%s%s%s%s%s%s%s%s\n\n",
		"The Tested Function ","\"",pchar_theFunctionName,"\""," : ",str,
		"------",pchar_theTime))
	{
		return WRITE_FAILED;
	};

	fclose(pfile);
	return WRITE_SUCCESS;

}
#endif

