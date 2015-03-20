echo off
title Dependency Walker 右键菜单管理

:主菜单
color 1B
cls
echo.*-----------------------------------------------------------------------------*
echo * *************************** 安装/卸载右键菜单 *******************************
echo.*-----------------------------------------------------------------------------*
echo.*    　　　　　　　　　                                                       *
echo.*         (1) 安装右键菜单                                                    *
echo.*    　　　　　　　　　                                                       *
echo.*         (2) 卸载右键菜单                                                    *
echo.*    　　　　　　　　　                                                       *
echo.*-----------------------------------------------------------------------------*
echo.* (A)安装  (U)卸载                                                   (X)退出  *
echo.*-----------------------------------------------------------------------------*
echo.*     请在管理员下运行...........               by Webenvoy (www.newasp.net)  *
echo *******************************************************************************
SET /P runcd=   请输入（）中的数字键并按回车 :
if /I "%runcd%"=="1" goto Installation
if /I "%runcd%"=="2" goto Uninstallation
if /I "%runcd%"=="A" goto Installation
if /I "%runcd%"=="U" goto Uninstallation
if /I "%runcd%"=="X" goto EX
goto 主菜单

:EX
exit

:Installation
cls
color 1B
REG ADD "HKCR\dllfile\shell\Open with Dependency Walker" /v "" /t REG_SZ /d "用 Dependency Walker 打开" /f
REG ADD "HKCR\dllfile\shell\Open with Dependency Walker" /v "Icon" /t REG_SZ /d "%cd%\depends.exe" /f
REG ADD "HKCR\dllfile\shell\Open with Dependency Walker\command" /v "" /t REG_SZ /d "%cd%\depends.exe \"%%1\"" /f

REG ADD "HKCR\exefile\shell\Open with Dependency Walker" /v "" /t REG_SZ /d "用 Dependency Walker 打开" /f
REG ADD "HKCR\exefile\shell\Open with Dependency Walker" /v "Icon" /t REG_SZ /d "%cd%\depends.exe" /f
REG ADD "HKCR\exefile\shell\Open with Dependency Walker\command" /v "" /t REG_SZ /d "%cd%\depends.exe \"%%1\"" /f

echo ***************************************************************************
echo.
echo     右键菜单安装完成......
echo.
echo ***************************************************************************
pause
exit

:Uninstallation
cls
color 1B
REG DELETE "HKCR\dllfile\shell\Open with Dependency Walker" /f
REG DELETE "HKCR\exefile\shell\Open with Dependency Walker" /f
echo ***************************************************************************
echo.
echo     右键菜单卸载完成......
echo.
echo ***************************************************************************
pause
exit
