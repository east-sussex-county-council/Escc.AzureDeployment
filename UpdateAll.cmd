@echo off

set VALID=true
if String.Empty%1==String.Empty set VALID=false

if %VALID%==false (
	echo.
	echo Usage: UpdateAll ^<git base URL^> 
	echo.
	echo eg UpdateAll http://github.com/east-sussex-county-council/
	echo.
	goto exit
)


:: Get the current folder to come back to, and the script folder, even 
:: if executed from elsewhere, so we can call other scripts

set UPDATE_ALL_START_PATH=%cd% 
for /f %%i in ("%0") do set ESCC_DEPLOYMENT_SCRIPTS=%%~dpi


:: Switch to the script folder, run git pull to ensure the scripts are up-to-date,
:: then switch back to update the deployment repo

cd /d %ESCC_DEPLOYMENT_SCRIPTS%
call git pull origin master
cd /d %UPDATE_ALL_START_PATH%


:: Now that we have the latest scripts, update the deployment repo

call %ESCC_DEPLOYMENT_SCRIPTS%UpdateAllPart2 %1

:exit
exit /b 