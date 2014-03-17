@echo off

:: Check if the current directory is empty. The command to check this is an odd one. It works, but doesn't find a .git directory.

dir /b | find /v "Some arbitrary string that won't be found" >nul && (set VALID=false) || (set VALID=true)
if exist .git set VALID=false
if %VALID%==false (
  echo.
  echo This script must be run from an empty directory, which will become the root of your deployment repository.
  echo.
  goto exit
)

:: Check that a git base URL and site scripts folders have been specified as parameters

set VALID=true
if "%1"=="" set VALID=false
if "%2"=="" set VALID=false

if %VALID%==false (
	echo.
	echo Usage: SetupDeploymentRepo ^<git base URL^> ^<site scripts folder^>
	echo.
	echo eg SetupDeploymentRepo http://github.com/east-sussex-county-council/ ExampleSite
	echo.
	echo ExampleSite should be a sibling folder of Escc.AzureDeployment, and a git repository
	echo when the name is appended to the git base URL.
	echo.
	goto exit
)

:: Get the script folder, even if executed from elsewhere, so we can call other scripts

for /f %%i in ("%0") do set ESCC_DEPLOYMENT_SCRIPTS=%%~dpi

:: Initialise a git repo. We have to use call for git commands otherwise the script terminates.

echo.
echo -------------------------------------------------------------------------
echo Creating git deployment repository and configuring Kudu deployment script
echo -------------------------------------------------------------------------
echo.

call git init

:: Create and commit file to trigger Kudu custom deployment script, and add useful shortcuts
:: to scripts for adding and updating applications.
::
:: Commiting this to master *before* adding any subtrees also prevents master 
:: automatically tracking the first subtree remote branch.

echo [config] > .deployment
echo command = KuduDeploy.cmd >> .deployment

echo. > KuduDeploy.cmd

call git add .deployment
call git add KuduDeploy.cmd
call git commit -m "Configure Kudu deployment script"

:: Pull in the applications to deploy as git subtrees.
:: The 'false' parameter prevents syncing with Azure as the git remote won't be setup yet.

call %ESCC_DEPLOYMENT_SCRIPTS%UpdateAll %1 %2 false

echo.
echo -------------------------------------------------------------------------
echo Deployment repository created. 
echo.
echo Next, set up a git remote called 'azure' with the URL of your Azure 
echo website's git repository. You can find the URL on the Deployments 
echo page for your website in the Azure portal.
echo -------------------------------------------------------------------------
echo.

:exit
exit /b 