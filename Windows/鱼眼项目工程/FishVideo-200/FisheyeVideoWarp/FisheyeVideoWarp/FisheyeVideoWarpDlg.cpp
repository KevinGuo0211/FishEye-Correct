
// FisheyeVideoWarpDlg.cpp : 实现文件
//

#include "stdafx.h"
#include "FisheyeVideoWarp.h"
#include "FisheyeVideoWarpDlg.h"
#include "afxdialogex.h"
#include "ImgWarp.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

ImgWarp IW;
// 用于应用程序“关于”菜单项的 CAboutDlg 对话框

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// 对话框数据
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持

// 实现
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// CFisheyeVideoWarpDlg 对话框




CFisheyeVideoWarpDlg::CFisheyeVideoWarpDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CFisheyeVideoWarpDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CFisheyeVideoWarpDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_SLIDER1, mSlider);
}

BEGIN_MESSAGE_MAP(CFisheyeVideoWarpDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDOpen, &CFisheyeVideoWarpDlg::OnBnClickedOpen)
	ON_NOTIFY(NM_CUSTOMDRAW, IDC_SLIDER1, &CFisheyeVideoWarpDlg::OnNMCustomdrawSlider1)
END_MESSAGE_MAP()


// CFisheyeVideoWarpDlg 消息处理程序

BOOL CFisheyeVideoWarpDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// 将“关于...”菜单项添加到系统菜单中。

	// IDM_ABOUTBOX 必须在系统命令范围内。
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// 设置此对话框的图标。当应用程序主窗口不是对话框时，框架将自动
	//  执行此操作
	SetIcon(m_hIcon, TRUE);			// 设置大图标
	SetIcon(m_hIcon, FALSE);		// 设置小图标

	// TODO: 在此添加额外的初始化代码
	//IW.theta = 120;
	mSlider.SetRange(120,180);
	mSlider.SetTicFreq(5);

	return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

void CFisheyeVideoWarpDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
}

// 如果向对话框添加最小化按钮，则需要下面的代码
//  来绘制该图标。对于使用文档/视图模型的 MFC 应用程序，
//  这将由框架自动完成。

void CFisheyeVideoWarpDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // 用于绘制的设备上下文

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// 使图标在工作区矩形中居中
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// 绘制图标
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

//当用户拖动最小化窗口时系统调用此函数取得光标
//显示。
HCURSOR CFisheyeVideoWarpDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}




void CFisheyeVideoWarpDlg::OnBnClickedOpen()
{
	// TODO: 在此添加控件通知处理程序代码

	CFileDialog dlg(TRUE);
	//打开图像，按OK确认，否则返回
	if(dlg.DoModal()!=IDOK)
	{
		MessageBox("打开失败！请重试！");
		return;
	}
	//关闭窗口显示
	GetDlgItem(IDC_ORG)->ShowWindow(FALSE);
	GetDlgItem(IDC_DST)->ShowWindow(FALSE);
	//打开窗口显示,相当于把窗体重启,清除Picture控件的残余
	GetDlgItem(IDC_ORG)->ShowWindow(TRUE); 
	GetDlgItem(IDC_DST)->ShowWindow(TRUE); 
	//打开图像的路径
	mPath = dlg.GetPathName();
	CWinThread * pThread;
	pThread =AfxBeginThread(threadFunction,(LPVOID) this);
}

UINT CFisheyeVideoWarpDlg::threadFunction(LPVOID pParam)
{

	CFisheyeVideoWarpDlg* pDlg = (CFisheyeVideoWarpDlg*)pParam;


	//打开视频文件：其实就是建立一个VideoCapture结构
	//VideoCapture cap(pDlg->mPath);
	//检测是否正常打开:成功打开时，isOpened返回ture
	//pDlg->frameNumber = cap.get(CV_CAP_PROP_FRAME_COUNT);
	/*if(!cap.isOpened())
	{
		pDlg->MessageBox("读取视频失败！");
		return 0;
	}
	for(int i = 0;i < pDlg->frameNumber;++i)
	{
		Mat frame;
		cap >> frame;	i	
		
	}*/
	Mat orgImg = imread(pDlg->mPath);
	pDlg->ShowImage(orgImg,IDC_ORG);
	Mat dstImg;
   // const uint theta = 120;
	CSliderCtrl   *pSlidCtrl=(CSliderCtrl*)pDlg->GetDlgItem(IDC_SLIDER1);
	IW.theta = pSlidCtrl->GetPos();  //取得当前位置值 
	uint z = orgImg.cols / tan(CV_PI*IW.theta/360);

	//z = 100;

	//IW.ImageWarp(orgImg,dstImg);
	IW.Plane2Sphere(orgImg,dstImg,z);
	pDlg->ShowImage(dstImg,IDC_DST);

	waitKey(0);
	return 0;
}

void CFisheyeVideoWarpDlg::ShowImage(Mat img, UINT ID)
{
	CDC *pDC = GetDlgItem(ID)->GetDC(); 
	HDC hDC= pDC->GetSafeHdc();
	CRect rect;  
	GetDlgItem(ID)->GetClientRect(&rect); 
	IplImage image=img;
	CvvImage cimg;  
	cimg.CopyOf(&image ); // 复制图片
	cimg.DrawToHDC( hDC, &rect ); // 将图片绘制到显示控件的指定区域内
	ReleaseDC( pDC );
}


void CFisheyeVideoWarpDlg::OnNMCustomdrawSlider1(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMCUSTOMDRAW pNMCD = reinterpret_cast<LPNMCUSTOMDRAW>(pNMHDR);
	// TODO: 在此添加控件通知处理程序代码
	*pResult = 0;
}
