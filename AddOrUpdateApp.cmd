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

:: Check whether the git base URL and repo name were specified as parameters

set VALID=true
if String.Empty%1==String.Empty set VALID=false
if String.Empty%2==String.Empty set VALID=false

if %VALID%==false (
	echo.
	echo Usage: AddOrUpdateApp ^<git base URL^> ^<git repo name^> [^<type false to not return to master branch^>]
	echo.
	echo eg AddOrUpdateApp https://github.com/east-sussex-county-council/ ExampleProject
	echo. 
	goto exit
)

:: Get the script folder, even if executed from elsewhere, so we can call other scripts

for /f %%i in ("%0") do set ESCC_DEPLOYMENT_SCRIPTS=%%~dpi

:: Check whether the folder exists. If it doesn't, add the app. If it does, update it.

if not exist %2 (
	call %ESCC_DEPLOYMENT_SCRIPTS%AddApp %1 %2
	goto exit
)

if exist %2 (
	call %ESCC_DEPLOYMENT_SCRIPTS%UpdateApp %2 %3
	goto exit
)

:exit
exit /b %ERRORLEVEL%