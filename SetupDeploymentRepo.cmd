@echo off


set VALID=true
if String.Empty%1==String.Empty set VALID=false
if String.Empty%2==String.Empty set VALID=false

if %VALID%==false (
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

type %ESCC_DEPLOYMENT_SCRIPTS%AzureKuduHeader.cmd %ESCC_DEPLOYMENT_SCRIPTS%AzureKuduApplications.cmd %ESCC_DEPLOYMENT_SCRIPTS%AzureKuduFooter.cmd > AzureKuduDeploy.cmd

call git add .deployment
call git add AzureKuduDeploy.cmd
call git commit -m "Configure Kudu deployment script"


:: Pull in the applications to deploy as git subtrees.

call %ESCC_DEPLOYMENT_SCRIPTS%UpdateAll %2


:: Take user back to where they started
cd /d %START_PATH%

:exit
exit /b 