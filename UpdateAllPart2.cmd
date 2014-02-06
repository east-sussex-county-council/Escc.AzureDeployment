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

:: Add or update all the apps which are currently part of the website

call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 Escc.EastSussexGovUK.AzureDeployment
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 SeparateRepo
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 SeparateRepo.Tests
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 WebApplication1
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 WebApplication2

:: For any apps removed from the website, delete them from the deployment repo if present
:: so that they don't get redeployed
::
:: eg call %ESCC_DEPLOYMENT_SCRIPTS%DeleteApp Escc.ExampleApplication



:: Update the Kudu deployment script in case its source files have changed

type %ESCC_DEPLOYMENT_SCRIPTS%AzureKuduHeader.cmd %ESCC_DEPLOYMENT_SCRIPTS%AzureKuduApplications.cmd %ESCC_DEPLOYMENT_SCRIPTS%AzureKuduFooter.cmd > AzureKuduDeploy.cmd
call git commit AzureKuduDeploy.cmd -m "Update Kudu deployment script"