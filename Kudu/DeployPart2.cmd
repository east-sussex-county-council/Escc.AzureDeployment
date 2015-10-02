@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

:: Work around bug which errors when building .NET 3.5 apps with RESX files
:: https://connect.microsoft.com/VisualStudio/feedback/details/758772/generateresource-fails-for-net-3-5-application-when-net-4-5-has-been-installed 
set DisableOutOfProcTaskHost=true

echo.
echo ------------------------------------------------------
echo Making a copy of the build folder for this deployment
echo ------------------------------------------------------
echo.

REM Initialise environment variable to prevent syntax error when running on Azure
set ESCC_CURRENT_GIT_COMMIT=none

REM Get the git commit SHA which is currently at the HEAD of the repo
FOR /F "delims=" %%i IN ('git rev-parse HEAD') DO set ESCC_CURRENT_GIT_COMMIT=%%i

REM Copy the entire build folder to a new location based on the current commit of the deployment script.
REM When "redeploy" is clicked in the Azure interface it will use the same commit of the deployment script,
REM and therefore the same copy of these assets as when that deployment was originally run.
if not exist %DEPLOYMENT_SOURCE%\builds\%ESCC_CURRENT_GIT_COMMIT% (
  robocopy %DEPLOYMENT_TRANSFORMS% %DEPLOYMENT_SOURCE%\builds\%ESCC_CURRENT_GIT_COMMIT% /MIR
  IF !ERRORLEVEL! GTR 7 (
    echo Error %ERRORLEVEL% copying build files
    goto exit
  )
) else (
  echo Using existing build folder for this deployment at %DEPLOYMENT_SOURCE%\builds\%ESCC_CURRENT_GIT_COMMIT%
)

REM Update the original environment variable for the duration of this script
set DEPLOYMENT_TRANSFORMS=%DEPLOYMENT_SOURCE%\builds\%ESCC_CURRENT_GIT_COMMIT%

echo.
echo ------------------------------------------------------
echo Downloading NUnit test runner
echo ------------------------------------------------------
echo.
call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" %DEPLOYMENT_SOURCE%\Escc.AzureDeployment\ Escc.AzureDeployment.sln
IF !ERRORLEVEL! NEQ 0 goto error

:exit
exit /b %ERRORLEVEL%