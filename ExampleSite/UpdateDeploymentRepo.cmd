@echo off

:: Ensure git base URL is specified as a parameter

set VALID=true
if "%1"=="" set VALID=false

if %VALID%==false (
	echo.
	echo This script is only meant to be called from UpdateAll.cmd. Run that instead. 
	echo.
	echo eg UpdateAll http://github.com/east-sussex-county-council/ EastSussexGovUK
	echo.
	goto exit
)

:: Add or update all the apps which are currently part of the website. 
:: Always start by including the Escc.AzureDeployment application.
:: Add 'false' to the end of each line to speed up the UpdateAll process
::
:: eg call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 Escc.ExampleApplication false

call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 Escc.AzureDeployment false
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 SeparateRepo false
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 SeparateRepo.Tests false
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 WebApplication1 false
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 WebApplication2 false

:: For any apps removed from the website, delete them from the deployment repo if present
:: so that they don't get redeployed
::
:: eg call %ESCC_DEPLOYMENT_SCRIPTS%DeleteApp Escc.ExampleApplication



:exit
exit /b %ERRORLEVEL%