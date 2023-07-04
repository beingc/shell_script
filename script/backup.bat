@echo off
setlocal EnableDelayedExpansion

REM 设置备份目录
set backup_dir=E:\\Backup

REM 获取当前时间并格式化为YYYYMMDD
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set datestr=%year%%month%%day%

REM 获取当前脚本所在目录
set dirname=%~dp0
set dirname=%dirname:~0,-1%
set dirname=%dirname:\\=\\\\%

REM 压缩当前目录并移动到备份目录
"C:\\Program Files\\7-Zip\\7z.exe" a -t7z "%dirname%_%datestr%.7z" "%dirname%" -mx9
move "%dirname%_%datestr%.7z" "%backup_dir%"

echo "Backup completed"

pause
