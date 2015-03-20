

// FishVideoDlg.h : 头文件
//

#pragma once
#include "CvvImage.h"
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "ScanningMethod.h"
#include "afxwin.h"
#include "afxcmn.h"

#include "cdib.h"

using namespace std;
using namespace cv;

// CFishVideoDlg 对话框
class CFishVideoDlg : public CDialogEx
{
// 构造
public:
	CFishVideoDlg(CWnd* pParent = NULL);	// 标准构造函数

// 对话框数据
	enum { IDD = IDD_FISHVIDEO_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV 支持

	
// 实现
protected:
	HICON m_hIcon;

	// 生成的消息映射函数
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	String mPath;
	afx_msg void OnBnClickedOpen();
	void ShowImage(Mat img, UINT ID);
    static UINT threadFunction(LPVOID pParam);
	CEdit ChangePara1Value;
	CEdit ChangePara2Value;
	CEdit ChangePara3Value;
	afx_msg void OnEnChangeEdit1();
	afx_msg void OnEnChangeEdit2();
	afx_msg void OnEnChangeEdit3();
	afx_msg void OnBnClickedChangepara1();
	afx_msg void OnBnClickedChangepara2();
	afx_msg void OnBnClickedChangepara3();
	CProgressCtrl m_ctrlProgress;
	CEdit m_strText;
	double frameNumber;
	void RotationwarpAffine(Mat& ormImg,Mat& warpimage,double angle,double scale);


	CDib m_dib;
	CRect MyWindowRect;
	void ShowImage(CSize imgsize, int BitCount, LPBYTE Image ,int WindowNumb);
	CStatic originalWindow;
	CStatic angle1Window;
	CStatic angle2Window;
	CStatic angle3Window;
};
