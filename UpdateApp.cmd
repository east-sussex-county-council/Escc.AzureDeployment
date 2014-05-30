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
	echo Usage: UpdateApp ^<git repo name^> [^<type false to not return to master branch^>]
	goto exit
)

:: Check whether switching back to the master branch can be skipped.
:: This option should only be used by UpdateAll, because it saves a 
:: lot of time writing and re-writing files to disk.

set SWITCH_TO_MASTER=false
if "%2"=="" set SWITCH_TO_MASTER=true

echo.
echo ------------------------------------------------------
echo Updating %1
echo ------------------------------------------------------
echo.

call git checkout %1
call git pull | find "Already up-to-date."
set REPO_UP_TO_DATE=%ERRORLEVEL% 
if %REPO_UP_TO_DATE%==1 (
  call git checkout master
  call git merge --squash -s subtree --no-commit %1
  call git commit -m "Updated %1"
  if %ERRORLEVEL%==0 set DEPLOYMENT_COMMIT_MESSAGE=%DEPLOYMENT_COMMIT_MESSAGE%Updated %1. 
)
if %REPO_UP_TO_DATE%==0 (
  if %SWITCH_TO_MASTER%==true (
    call git checkout master
  )
) 

:exit
exit /b %ERRORLEVEL%