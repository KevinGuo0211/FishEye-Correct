#include <time.h>
#include <stdio.h>
#include <stdlib.h>
/**********************************
//获取当前的系统时间
************************************/
int MyGetCurrentTime()
{
	time_t rawtime;
	struct tm* timeinfo;
	int savetime=time(&rawtime);
	return savetime;
}
/**********************************
//获取文件中保存的累加时间
************************************/
int GetSaveTime()
{
	char sz[15],sz1[15];
	FILE* fp;
	//FILE* fp1;
	if ((fp=fopen("../../Documents/documents.dat","rt+"))==NULL)    /*(fp=fopen("/bin/fsystem.txt","a+"))==NULL*/
	{
		sprintf(sz,"%d",0);
		fp=fopen("../../Documents/documents.dat","wt+");
		fputs(sz,fp);
		fclose(fp);
		return 0;
	}
	else
	{
		int tem;
		fgets(sz1,15,fp);
		tem = strtol(sz1,NULL,10);
		return tem;
	}
}
/**********************************
//保存此次运行时间到总的累加时间
************************************/
void SaveInternalTime(int val)
{
	char sz[15],sz1[15];
	FILE* fp;
	if ((fp=fopen("../../Documents/documents.dat","rt+"))==NULL)
	{
		sprintf(sz,"%d",val);
		fp=fopen("../../Documents/documents.dat","wt+");
		fputs(sz,fp);
		fclose(fp);
	}
	else
	{
		sprintf(sz,"%d",val);
		fp=fopen("../../Documents/documents.dat","wt+");
		fputs(sz,fp);
		fclose(fp);
	}
}
