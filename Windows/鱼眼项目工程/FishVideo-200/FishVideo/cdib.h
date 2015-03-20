// cdib.h declaration for Inside Visual C++ CDib class

#ifndef _INSIDE_VISUAL_CPP_CDIB
#define _INSIDE_VISUAL_CPP_CDIB

class CDib : public CObject
{
	friend class CDib;
	enum Alloc {noAlloc, crtAlloc, heapAlloc};
	DECLARE_SERIAL(CDib)
public:
	LPVOID m_lpvColorTable; // 调色板指针
	HBITMAP m_hBitmap;
	LPBYTE m_lpImage;  // starting address of DIB bits
	LPBITMAPINFOHEADER m_lpBMIH; //指向信息头 BITMAPINFOHEADER的指针
	DWORD m_dwSizeImage; // 数据区的大小(byte) -- not BITMAPINFOHEADER or BITMAPFILEHEADER
	int m_nColorTableEntries; // 调色板的大小(byte)
	HPALETTE m_hPalette; // 调色板
private:
	HGLOBAL m_hGlobal; // For external windows we need to free;
	//  could be allocated by this class or allocated externally
	Alloc m_nBmihAlloc;
	Alloc m_nImageAlloc;
	
	
	HANDLE m_hFile;
	HANDLE m_hMap;
	LPVOID m_lpvFile;  
	
public:
	
	bool ZoomDIB(LPBYTE lpImage);
	WORD GetSizePerLine();
	CDib();
	CDib(CSize size, int nBitCount);	// builds BITMAPINFOHEADER
	~CDib();
	int GetSizeImage() {return m_dwSizeImage;}
	int GetSizeHeader()
	{return sizeof(BITMAPINFOHEADER) + sizeof(RGBQUAD) * m_nColorTableEntries;}
	CSize GetDimensions();
	BOOL AttachMapFile(CString strPathname, BOOL bShare = FALSE);
	BOOL CopyToMapFile(CString strPathname);
	BOOL AttachMemory(LPVOID lpvMem, BOOL bMustDelete = FALSE, HGLOBAL hGlobal = NULL);
	BOOL Draw(CDC* pDC, CPoint origin, CSize size);  // until we implemnt CreateDibSection
	HBITMAP CreateSection(CDC* pDC = NULL);
	UINT UsePalette(CDC* pDC, BOOL bBackground = FALSE);
	BOOL MakePalette();
	BOOL SetSystemPalette(CDC* pDC);
	BOOL Compress(CDC* pDC, BOOL bCompress = TRUE); // FALSE means decompress
	HBITMAP CreateBitmap(CDC* pDC);
	BOOL Read(CFile* pFile);
	BOOL ReadSection(CFile* pFile, CDC* pDC = NULL);
	BOOL Write(CFile* pFile);
	void Serialize(CArchive& ar);
	void Empty();
	void Replacedib(CSize size, int nBitCount,BYTE *data);
private:
	void DetachMapFile();
	void ComputePaletteSize(int nBitCount);
	void ComputeMetrics();
};
#endif // _INSIDE_VISUAL_CPP_CDIB
