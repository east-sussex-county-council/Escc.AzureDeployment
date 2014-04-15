@echo off

:: Check that this script is being run from the root of the deployment repository.
:: Exit if not, as we don't want to run these git commands anywhere else.

set VALID=true
if not exist .git set VALID=false
if not exist .deployment set VALID=false

if %VALID%==false (
  echo.
  echo This command must be run from the root of your deployment repository.
  echo.
  goto exit
)

:: Check that the git base URL and site scripts folder are specified as parameters.
::
:: There is a third parameter which is optional, and only needed by SetupDeploymentRepo.cmd, 
:: so don't document it for the user.

set VALID=true
if "%1"=="" set VALID=false
if "%2"=="" set VALID=false

if %VALID%==false (
	echo.
	echo Usage: UpdateAll ^<git base URL^> ^<site scripts folder^> 
	echo.
	echo eg UpdateAll http://github.com/east-sussex-county-council/ ExampleSite
	echo.
	goto exit
)

:: Get the current folder to come back to, and the script folder, even 
:: if executed from elsewhere, so we can call other scripts

set UPDATE_ALL_START_PATH=%cd% 
for /f %%i in ("%0") do set ESCC_DEPLOYMENT_SCRIPTS=%%~dpi

:: Switch to the script folder, run git pull to ensure the scripts are up-to-date,
:: then switch back to update the deployment repo

echo.
echo ------------------------------------------------------
echo Ensuring deployment scripts are up-to-date
echo ------------------------------------------------------
echo.

cd /d %ESCC_DEPLOYMENT_SCRIPTS%
call git pull origin master
cd /d %UPDATE_ALL_START_PATH%

:: Now that we have the latest scripts, update the deployment repo

:: Pull from Azure to make sure the deployment repo is in sync
:: %3 should always be blank unless this script is called by SetupDeploymentRepo.cmd, when it should be 'false'

if "%3"=="" (
  echo.
  echo ------------------------------------------------------
  echo Syncing deployment repo with Azure
  echo ------------------------------------------------------
  echo.

  call git pull azure master
)

:: Reset commit message
set DEPLOYMENT_COMMIT_MESSAGE=

:: Update the specific apps for this site
call %ESCC_DEPLOYMENT_SCRIPTS%..\%2\UpdateDeploymentRepo %1


:: Update the Kudu deployment script in case its source files have changed.
:: Combine 3 files to separate out the part of the script unique to each site.

echo.
echo ------------------------------------------------------
echo Updating custom Kudu deployment script
echo ------------------------------------------------------
echo.
echo. > KuduDeploy.cmd
echo ------------------------------------------------------ >> KuduDeploy.cmd
echo Running KuduDeploy.cmd generated at %date% %time% >> KuduDeploy.cmd
echo ------------------------------------------------------ >> KuduDeploy.cmd
echo. >> KuduDeploy.cmd
type %ESCC_DEPLOYMENT_SCRIPTS%Kudu\DeployPart1.cmd %ESCC_DEPLOYMENT_SCRIPTS%..\%2\DeployOnAzure.cmd %ESCC_DEPLOYMENT_SCRIPTS%Kudu\DeployPart3.cmd >> KuduDeploy.cmd
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

exit /b 