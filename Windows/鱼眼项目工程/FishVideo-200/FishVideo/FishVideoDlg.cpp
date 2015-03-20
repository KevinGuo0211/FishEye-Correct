
// FishVideoDlg.cpp : 实现文件
//

#include "stdafx.h"
#include "FishVideo.h"
#include "FishVideoDlg.h"
#include "afxdialogex.h"
#include "FisheyeImgCorrection.h"
#include "CTrace.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif
  

// 用于应用程序“关于”菜单项的 CAboutDlg 对话框
FisheyeImgCorrect FIC;

bool CMyTrace::traceIsActive = false;
CMyTrace myTrace("");

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


// CFishVideoDlg 对话框




CFishVideoDlg::CFishVideoDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CFishVideoDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CFishVideoDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_Phi0, ChangePara1Value);
	DDX_Control(pDX, IDC_Phi1, ChangePara2Value);
	DDX_Control(pDX, IDC_Phi2, ChangePara3Value);
	DDX_Control(pDX, IDC_PROGRESS1, m_ctrlProgress);
	DDX_Control(pDX, IDC_EDIT1, m_strText);
	DDX_Control(pDX, IDC_VIDEO1, originalWindow);
	DDX_Control(pDX, IDC_VIDEO2, angle1Window);
	DDX_Control(pDX, IDC_VIDEO3, angle2Window);
	DDX_Control(pDX, IDC_VIDEO4, angle3Window);
	DDX_Control(pDX, IDC_WIDTH, changeWidth);
	DDX_Control(pDX, IDC_HIGHT, changeHight);
}

BEGIN_MESSAGE_MAP(CFishVideoDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDOPEN, &CFishVideoDlg::OnBnClickedOpen)
	ON_EN_CHANGE(IDC_Phi0, &CFishVideoDlg::OnEnChangeEdit1)
	ON_EN_CHANGE(IDC_Phi1, &CFishVideoDlg::OnEnChangeEdit2)
	ON_EN_CHANGE(IDC_Phi2, &CFishVideoDlg::OnEnChangeEdit3)
	ON_BN_CLICKED(IDC_ChangePara1, &CFishVideoDlg::OnBnClickedChangepara1)
	ON_BN_CLICKED(IDC_ChangePara2, &CFishVideoDlg::OnBnClickedChangepara2)
	ON_BN_CLICKED(IDC_ChangePara3, &CFishVideoDlg::OnBnClickedChangepara3)
	ON_BN_CLICKED(IDC_BUTTON2, &CFishVideoDlg::OnBnClickedButton2)
END_MESSAGE_MAP()


// CFishVideoDlg 消息处理程序

BOOL CFishVideoDlg::OnInitDialog()
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

	//ShowWindow(SW_MINIMIZE);

	// TODO: 在此添加额外的初始化代码
	//FisheyeImgCorrect FIC;
	FIC.FisheyeImgCorrectInit();
	FIC.Flag =1;
	FIC.w = 1930/2;
	FIC.h = 1930/2;
	FIC.wRatio = 5;
	FIC.hRatio = 6;

	SetDlgItemText(IDC_Phi0,_T("50"));
	SetDlgItemText(IDC_Sita0,_T("55"));
	SetDlgItemText(IDC_Gama0,_T("110"));

	SetDlgItemText(IDC_Phi1,_T("0"));
	SetDlgItemText(IDC_Sita1,_T("95"));
	SetDlgItemText(IDC_Gama1,_T("100"));

	SetDlgItemText(IDC_Phi2,_T("300"));
	SetDlgItemText(IDC_Sita2,_T("50"));
	SetDlgItemText(IDC_Gama2,_T("95"));

	SetDlgItemText(IDC_WIDTH,_T("480"));
	SetDlgItemText(IDC_HIGHT,_T("360"));

	SetDlgItemText(IDC_TEXT,_T("0"));
	//设置进度条的范围
	m_ctrlProgress.SetRange(0,100);
	//设置进度条的每一步的增量
	m_ctrlProgress.SetStep(1);
	//设置进度条的当前位置
	m_ctrlProgress.SetPos(0);

	return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

void CFishVideoDlg::OnSysCommand(UINT nID, LPARAM lParam)
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

void CFishVideoDlg::OnPaint()
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
HCURSOR CFishVideoDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CFishVideoDlg::ShowImage(Mat img, UINT ID)
{
	CDC *pDC = GetDlgItem(ID)->GetDC(); 
	HDC hDC= pDC->GetSafeHdc();
	CRect rect;  
	GetDlgItem(ID)->GetClientRect(&rect); 
	IplImage image = img;
	CvvImage cimg;  
	cimg.CopyOf(&image ); // 复制图片
	//cimg.m_img = &image;
	cimg.DrawToHDC( hDC, &rect ); // 将图片绘制到显示控件的指定区域内
	ReleaseDC( pDC );
}

UINT CFishVideoDlg::threadFunction(LPVOID pParam)
{
	//myTrace.theFunctionName = new string("th ：");
	CFishVideoDlg* pDlg = (CFishVideoDlg*)pParam;
	//打开视频文件：其实就是建立一个VideoCapture结构

//	myTrace.WriteToLog(" opv ");
	VideoCapture cap(pDlg->mPath);
	//检测是否正常打开:成功打开时，isOpened返回ture
	pDlg->frameNumber = cap.get(CV_CAP_PROP_FRAME_COUNT);
	pDlg->m_ctrlProgress.SetRange(0,pDlg->frameNumber);
	if(!cap.isOpened())
	{
		pDlg->MessageBox("读取视频失败！");
		return 0;
	}
	myTrace.WriteToLog(" ops ");
	Mat frame;
	ScanningMethod SM;
	//FisheyeImgCorrect FIC;
//	FIC.FisheyeImgCorrectInit();
	int flag = 0;
	//myTrace.theFunctionName = new string(" for ：");
	FIC.dstImg = Mat::zeros(Size(FIC.w*2,FIC.h*2),CV_8UC3);
	FIC.position =  (int*)malloc(FIC.w*FIC.h*8*sizeof(int));

	for(int i = 0;i <pDlg->frameNumber;++i)
	{
		//clock_t t1 = clock();
	/*	myTrace.WriteToLog(" jm.s ：");*/
		Mat frame;
		double posFrameIndex = cap.get(CV_CAP_PROP_POS_FRAMES);
		pDlg->m_ctrlProgress.SetPos(posFrameIndex);
		CString text;
		text.Format("%d",(int)posFrameIndex);
		pDlg->SetDlgItemText(IDC_TEXT,_T(text));
		cap >> frame;
		if (!frame.data)
		{
			break;
		}
		/*clock_t t2 = clock();
		CString time1;
		time1.Format("%d",t2 - t1);
		CString s1 = " jm.e,rz.s : " + time1;
		myTrace.WriteToLog(s1.GetBuffer(0));*/
		//resize(frame,frame,Size(frame.cols/2,frame.rows/2));
		/*clock_t t3 = clock();
		CString time2;
		time2.Format("%d",t3 - t2);
		CString s2 = " rz.e,sor.s :"+time2;
		myTrace.WriteToLog(s2.GetBuffer(0));*/

		//clock_t start = clock();
		//double fx = 241*4/frame.size().width;
		//double fy = 151*4/frame.size().height;
		//resize(frame,frame,Size(241*4,151*4),fx,fy,INTER_CUBIC);

		pDlg->ShowImage(frame,IDC_VIDEO1);
		/*clock_t t4 = clock();
		CString time3;
		time3.Format("%d",t4 - t3);
		CString s3 = " sor.e : "+time3;
		myTrace.WriteToLog(s3.GetBuffer(0));*/

		//clock_t end = clock();
		//flip(frame,frame,-1);
		//Mat temp;
		//resize(frame,temp,Size(241,151));
		//pDlg->ShowImage(CSize(frame.cols,frame.rows),24,frame.data,1);
		
		 //
		if (flag == 0)
		{
			//myTrace.WriteToLog(" frec.s :");
			SM.FindDeviceArea(frame);
			flag =1;
		}
		//Mat tempImg = frame(SM.minArea);
		FIC.orgImg = frame(SM.minArea);
	 // imwrite("C:\\Users\\Administrator\\Desktop\\test3.jpg",frame);
	//	imshow("111",tempImg);
		if (FIC.Flag ==1)
		{
			/*clock_t t5 = clock();
			CString time4;
			time4.Format("%d",t5 - t4); 
			CString s4 = " scIn.e :"+time4;
			myTrace.WriteToLog(s4.GetBuffer(0));*/
			FIC.FishCalculate(FIC.orgImg);
			FIC.FishImgIndex(FIC.orgImg);
			FIC.Flag = 0;
		}
		//clock_t start = clock();
		// SM.Standard_circle(tempImg,imgCircle);
		
		Mat dstImg1;
		Mat dstImg2;
		Mat dstImg3;
		//clock_t t6 = clock();
		/*CString time5;
		time5.Format("%d",t6 - t4);
		CString s5 = " IC.s : "+time5;
		myTrace.WriteToLog(s5.GetBuffer(0));*/
		FIC.ImageCorrect();
		/*clock_t end = clock();
		CString time;
		time.Format("%d",end - t6);*/
		//pDlg->MessageBox(time);
	
	
		//double angle = 90;
		//double scale = 1;
		//Mat WarpImg1;
		//Mat WarpImg2;
		//Mat WarpImg3;
		//pDlg->RotationwarpAffine(dstImg1,WarpImg1,angle,scale);
		//pDlg->RotationwarpAffine(dstImg2,WarpImg2,angle,scale);
		//pDlg->RotationwarpAffine(dstImg3,WarpImg3,angle,scale);
		
		//pDlg->ShowImage(CSize(WarpImg1.cols,WarpImg1.rows),24,WarpImg1.data,2);
		//pDlg->ShowImage(CSize(dstImg2.cols,dstImg2.rows),24,dstImg2.data,3);
		//pDlg->ShowImage(CSize(WarpImg2.cols,WarpImg2.rows),24,WarpImg2.data,4);
		/*clock_t t7 = clock();
		CString time6;
		time6.Format("%d",t7 - t6);
		CString s6 =" IC.e,sdst.s :"+time6;
		myTrace.WriteToLog(s6.GetBuffer(0));*/
		//clock_t start = clock();
		pDlg->ShowImage(FIC.dstImg,IDC_VIDEO2);
		//pDlg->ShowImage(dstImg2,IDC_VIDEO3);
		//pDlg->ShowImage(dstImg3,IDC_VIDEO4);
		//clock_t t8 = clock();
		//CString time7;
		//time7.Format("%d",t8 - t1);
		//CString s7 = " sdst.e : " + time7;
	//	myTrace.WriteToLog(s7.GetBuffer(0));*/
		//clock_t end = clock();
		//CString time;
		//time.Format("%d",end - start);
		//pDlg->MessageBox(time7);
		//imwrite("C:\\Users\\Administrator\\Desktop\\001.jpg",imgCircle);
		// if(waitKey(600) >= 0) break;
		
	}
	//myTrace.WriteToLog(" LogOver ");
	pDlg->MessageBox("处理完毕！");
	return 0;
}


void CFishVideoDlg::OnBnClickedOpen()
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
	GetDlgItem(IDC_VIDEO1)->ShowWindow(FALSE);
	GetDlgItem(IDC_VIDEO2)->ShowWindow(FALSE);
	GetDlgItem(IDC_VIDEO3)->ShowWindow(FALSE);
	GetDlgItem(IDC_VIDEO4)->ShowWindow(FALSE);
	//打开窗口显示,相当于把窗体重启,清除Picture控件的残余
	GetDlgItem(IDC_VIDEO1)->ShowWindow(TRUE); 
	GetDlgItem(IDC_VIDEO2)->ShowWindow(TRUE); 
	GetDlgItem(IDC_VIDEO3)->ShowWindow(TRUE); 
	GetDlgItem(IDC_VIDEO4)->ShowWindow(TRUE); 

	//打开图像的路径
	mPath = dlg.GetPathName();
	CWinThread * pThread;
	pThread =AfxBeginThread(threadFunction,(LPVOID) this);



	//UpdateData(false);
	//获取进度条的位置范围的最大值和最小值

	//int nLower=0;
	//int nUpper=0;
	//m_ctrlProgress.GetRange(nLower,nUpper);
	//if(m_ctrlProgress.GetPos()==nUpper){

	//	m_ctrlProgress.SetPos(nLower);

	//}
	////用每一步的增量来增加进度条的当前位置
	//m_ctrlProgress.StepIt();
	////获取进度条的当前位置
	//int nPos=(m_ctrlProgress.GetPos()-nLower)*100/(nUpper-nLower);
	//CString s;
	//CString text;
	//s.Format("%d",nPos);
	////m_strText=s+"%";
	//text = s + "%";
	//SetDlgItemText(IDC_TEXT,_T(text));
	//UpdateData(false);
}


void CFishVideoDlg::OnEnChangeEdit1()
{
	// TODO:  如果该控件是 RICHEDIT 控件，它将不
	// 发送此通知，除非重写 CDialogEx::OnInitDialog()
	// 函数并调用 CRichEditCtrl().SetEventMask()，
	// 同时将 ENM_CHANGE 标志“或”运算到掩码中。

	// TODO:  在此添加控件通知处理程序代码

}

void CFishVideoDlg::OnEnChangeEdit2()
{
	// TODO:  如果该控件是 RICHEDIT 控件，它将不
	// 发送此通知，除非重写 CDialogEx::OnInitDialog()
	// 函数并调用 CRichEditCtrl().SetEventMask()，
	// 同时将 ENM_CHANGE 标志“或”运算到掩码中。

	// TODO:  在此添加控件通知处理程序代码

}

void CFishVideoDlg::OnEnChangeEdit3()
{
	// TODO:  如果该控件是 RICHEDIT 控件，它将不
	// 发送此通知，除非重写 CDialogEx::OnInitDialog()
	// 函数并调用 CRichEditCtrl().SetEventMask()，
	// 同时将 ENM_CHANGE 标志“或”运算到掩码中。

	// TODO:  在此添加控件通知处理程序代码

}

void CFishVideoDlg::OnBnClickedChangepara1()
{
	// TODO: 在此添加控件通知处理程序代码
	
	CString paraString1 ;
	CString paraString2 ;
	CString paraString3 ;

	GetDlgItemText(IDC_Phi0,paraString1);
	GetDlgItemText(IDC_Sita0,paraString2);
	GetDlgItemText(IDC_Gama0,paraString3);
	FIC.phi0 = _ttoi(paraString1);
	FIC.phi0=FIC.phi0*3.14159265/180;
	FIC.sita0 = _ttoi(paraString2);
	FIC.sita0=(90-FIC.sita0)*3.14159265/180;
	FIC.gama0 = _ttoi(paraString3);
	FIC.gama0=FIC.gama0*3.14159265/180;
	FIC.Flag =1;
}


void CFishVideoDlg::OnBnClickedChangepara2()
{
	// TODO: 在此添加控件通知处理程序代码
	//FisheyeImgCorrect FIC;
	CString paraString1;
	CString paraString2 ;
	CString paraString3 ;

	GetDlgItemText(IDC_Phi1,paraString1);
	GetDlgItemText(IDC_Sita1,paraString2);
	GetDlgItemText(IDC_Gama1,paraString3);
	FIC.phi1 = _ttoi(paraString1);
	FIC.phi1=FIC.phi1*3.14159265/180;
	FIC.sita1 = _ttoi(paraString2);
	FIC.sita1=(90-FIC.sita1)*3.14159265/180;
	FIC.gama1 = _ttoi(paraString3);
	FIC.gama1=FIC.gama1*3.14159265/180;
	FIC.Flag =1;
}

void CFishVideoDlg::OnBnClickedChangepara3()
{
	// TODO: 在此添加控件通知处理程序代码
//	FisheyeImgCorrect FIC;
	CString paraString1;
	CString paraString2 ;
	CString paraString3 ;

	GetDlgItemText(IDC_Phi2,paraString1);
	GetDlgItemText(IDC_Sita2,paraString2);
	GetDlgItemText(IDC_Gama2,paraString3);
	FIC.phi2 = _ttoi(paraString1);
	FIC.phi2=FIC.phi2*3.14159265/180;
	FIC.sita2 = _ttoi(paraString2);
	FIC.sita2=(90-FIC.sita2)*3.14159265/180;
	FIC.gama2 = _ttoi(paraString3);
	FIC.gama2=FIC.gama2*3.14159265/180;
	FIC.Flag =1;
}


void CFishVideoDlg::RotationwarpAffine(Mat& ormImg,Mat& warpimage,double angle,double scale)
{
	warpimage= cv::Mat::zeros(ormImg.rows,ormImg.cols,ormImg.type());
	Mat warp_mat(cv::Size(2,3),CV_32F);
	Point2f center = Point2f(ormImg.cols/2,ormImg.rows/2);
	warp_mat = getRotationMatrix2D(center,angle,scale);
	warpAffine(ormImg,warpimage,warp_mat,warpimage.size());
}



void CFishVideoDlg::ShowImage(CSize imgsize, int BitCount, LPBYTE Image ,int WindowNumb)
{
	CPoint point(0,0);
	CDC *pDC=NULL;
	switch (WindowNumb)
	{
	case 1:
		pDC=originalWindow.GetDC();
		originalWindow.GetClientRect(&MyWindowRect);
		break;
	case 2:
		pDC=angle1Window.GetDC();
		angle1Window.GetClientRect(&MyWindowRect);
		break;
	case 3:
		pDC=angle2Window.GetDC();
		angle2Window.GetClientRect(&MyWindowRect);
		break;
	case 4:
		pDC=angle3Window.GetDC();
		angle3Window.GetClientRect(&MyWindowRect);
		break;
	}
	m_dib.Replacedib(imgsize,BitCount,Image);
	m_dib.Draw(pDC,point,CSize(MyWindowRect.Width(),MyWindowRect.Height()));
	ReleaseDC(pDC);
}



void CFishVideoDlg::OnBnClickedButton2()
{
	// TODO: 在此添加控件通知处理程序代码
	CString paraString1;
	CString paraString2 ;
	GetDlgItemText(IDC_WIDTH,paraString1);
	GetDlgItemText(IDC_HIGHT,paraString2);
	FIC.w = _ttoi(paraString1);
	FIC.h = _ttoi(paraString2);
}
