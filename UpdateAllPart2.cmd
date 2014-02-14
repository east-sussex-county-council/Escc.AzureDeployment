@echo off

:: Ensure git base URL is specified as a parameter

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

:: Pull from Azure to make sure the deployment repo is in sync
:: %2 should always be blank unless this script is called by SetupDeploymentRepo.cmd, when it should be 'false'

if String.Empty%2==String.Empty (
  echo.
  echo ------------------------------------------------------
  echo Syncing deployment repo with Azure
  echo ------------------------------------------------------
  echo.

  call git pull azure master
)

:: Reset commit message
set DEPLOYMENT_COMMIT_MESSAGE=

:: Add or update all the apps which are currently part of the website
::
:: eg call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 Escc.ExampleApplication

call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 Escc.AzureDeployment
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 SeparateRepo
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 SeparateRepo.Tests
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 WebApplication1
call %ESCC_DEPLOYMENT_SCRIPTS%AddOrUpdateApp %1 WebApplication2

:: For any apps removed from the website, delete them from the deployment repo if present
:: so that they don't get redeployed
::
:: eg call %ESCC_DEPLOYMENT_SCRIPTS%DeleteApp Escc.ExampleApplication



:: Update the Kudu deployment script in case its source files have changed.
:: Combine 3 files because we want to autogenerate the second one at some point.

echo.
echo ------------------------------------------------------
echo Updating custom Kudu deployment script
echo ------------------------------------------------------
echo.
type %ESCC_DEPLOYMENT_SCRIPTS%Kudu\DeployPart1.cmd %ESCC_DEPLOYMENT_SCRIPTS%Kudu\DeployPart2.cmd %ESCC_DEPLOYMENT_SCRIPTS%Kudu\DeployPart3.cmd > KuduDeploy.cmd
call git commit KuduDeploy.cmd -m "Updated Kudu deployment script"
if %ERRORLEVEL%==0 set DEPLOYMENT_COMMIT_MESSAGE=%DEPLOYMENT_COMMIT_MESSAGE%Updated Kudu deployment script.

:: If anything was updated, force another commit so we can control the message displayed 
:: in the Azure deployments list.
if "%DEPLOYMENT_COMMIT_MESSAGE%" neq "" (
  echo. >> KuduDeploy.cmd
  call git commit KuduDeploy.cmd -m "%DEPLOYMENT_COMMIT_MESSAGE%"
)

:exit

:: Reset commit message
set DEPLOYMENT_COMMIT_MESSAGE=

exit /b %ERRORLEVEL%