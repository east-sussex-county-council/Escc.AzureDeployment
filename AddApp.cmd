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

:: Check that the git base URL and repo name to add were specified as parameters

set VALID=true
if "%1"=="" set VALID=false
if "%2"=="" set VALID=false

if %VALID%==false (
	echo.
	echo Usage: AddApp ^<git base URL^> ^<git repo name^>
	echo.
	echo eg AddApp http://github.com/east-sussex-county-council/ ExampleProject
	echo. 
	goto exit
)

:: Read in the new repo into the current repo using subtree merging

echo.
echo ------------------------------------------------------
echo Adding %2
echo ------------------------------------------------------
echo.

call git remote add %2 %1%2
call git fetch %2
call git checkout -b %2 %2/master
call git checkout master
call git read-tree --prefix=%2/ -u %2
call git commit -m "Added %2"
if %ERRORLEVEL%==0 set DEPLOYMENT_COMMIT_MESSAGE=%DEPLOYMENT_COMMIT_MESSAGE%Added %2. 

:exit
exit /b %ERRORLEVEL%