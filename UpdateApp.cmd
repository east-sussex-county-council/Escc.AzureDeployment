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

:: Check that the git repo name to update is specified as a parameter

if "%1"=="" (
	echo Usage: UpdateApp ^<git repo name^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Updating %1
echo ------------------------------------------------------
echo.

call git checkout %1
call git pull
call git checkout master
call git merge --squash -s subtree --no-commit %1
call git commit -m "Updated %1"
if %ERRORLEVEL%==0 (
  if "%DEPLOYMENT_COMMIT_MESSAGE%" neq "" set DEPLOYMENT_COMMIT_MESSAGE=%DEPLOYMENT_COMMIT_MESSAGE%, 
  set DEPLOYMENT_COMMIT_MESSAGE=%DEPLOYMENT_COMMIT_MESSAGE%Updated %1
)

:exit
exit /b %ERRORLEVEL%