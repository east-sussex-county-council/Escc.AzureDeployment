@echo off


set VALID=true
if String.Empty%1==String.Empty set VALID=false
if String.Empty%2==String.Empty set VALID=false

if %VALID%=false (
	echo.
	echo Usage: SetupDeploymentRepo ^<directory to create^> ^<git base URL^>
	echo.
	echo ^<directory to create^> must be a full path which does not exist yet
	echo and is not inside an existing git repository.
	echo.
	echo eg SetupDeploymentRepo c:\git\new-directory http://github.com/east-sussex-county-council/
	echo.
	goto exit
)


if exist %1 (
	echo.
	echo The directory %1 already exists.
	echo.
	echo ^<directory-to-create^> must be a full path which does not exist yet
	echo and is not inside an existing git repository.
	echo.
	goto exit
)


:: Get the current folder to come back to at the end, and the script folder, even 
:: if executed from elsewhere, so we can call other scripts

set START_PATH=%cd% 
for /f %%i in ("%0") do set ESCC_DEPLOYMENT_SCRIPTS=%%~dpi


:: Create the new folder and initialise a git repo. Have to use call for git commands
:: otherwise the script terminates.

md %1
cd /d %1
call git init


:: Create and commit file to trigger Kudu custom deployment script, and add useful shortcuts
:: to scripts for adding and updating applications.
::
:: Commiting this to master *before* adding any subtrees also prevents master 
:: automatically tracking the first subtree remote branch.

echo [config] > .deployment
echo command = AzureKuduDeploy.cmd >> .deployment

type Escc.EastSussexGovUK.AzureDeployment\AzureKuduHeader.cmd Escc.EastSussexGovUK.AzureDeployment\AzureKuduApplications.cmd Escc.EastSussexGovUK.AzureDeployment\AzureKuduFooter.cmd > AzureKuduDeploy.cmd

echo @echo off > AddApp.cmd
echo Escc.EastSussexGovUK.AzureDeployment\AddApp.cmd %%1 >> AddApp.cmd

echo @echo off > UpdateApp.cmd
echo Escc.EastSussexGovUK.AzureDeployment\AddApp.cmd %%1 >> UpdateApp.cmd

call git add .deployment
call git add AddApp.cmd
call git add UpdateApp.cmd
call git add AzureKuduDeploy.cmd
call git commit -m "Configure Kudu deployment script, and add shortcuts to add and update repo"


:: Pull in the applications to deploy as git subtrees.

call %ESCC_DEPLOYMENT_SCRIPTS%AddApp %2 Escc.EastSussexGovUK.AzureDeployment
call %ESCC_DEPLOYMENT_SCRIPTS%AddApp %2 SeparateRepo
call %ESCC_DEPLOYMENT_SCRIPTS%AddApp %2 WebApplication1
call %ESCC_DEPLOYMENT_SCRIPTS%AddApp %2 WebApplication2


:: Take user back to where they started
cd /d %START_PATH%

:exit
exit /b 