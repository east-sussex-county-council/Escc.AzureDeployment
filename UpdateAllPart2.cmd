@echo off

set VALID=true
if String.Empty%1==String.Empty set VALID=false

if %VALID%==false (
	echo.
	echo This script is only meant to be called from UpdateAll.cmd. Run that instead. 
	echo.
	echo eg UpdateAll http://github.com/east-sussex-county-council/
	echo.
	goto exit
)


:: Get the script folder, even if executed from elsewhere, so we can call other scripts
for /f %%i in ("%0") do set ESCC_DEPLOYMENT_SCRIPTS=%%~dpi

call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 Escc.EastSussexGovUK.AzureDeployment
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 SeparateRepo
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 WebApplication1
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 WebApplication2