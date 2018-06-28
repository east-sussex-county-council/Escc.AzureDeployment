@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

IF NOT DEFINED DEPLOYMENT_TARGET (
  SET DEPLOYMENT_TARGET=%ARTIFACTS%\wwwroot
)

IF NOT DEFINED NEXT_MANIFEST_PATH (
  SET NEXT_MANIFEST_PATH=%ARTIFACTS%\manifest

  IF NOT DEFINED PREVIOUS_MANIFEST_PATH (
    SET PREVIOUS_MANIFEST_PATH=%ARTIFACTS%\manifest
  )
)

IF NOT DEFINED KUDU_SYNC_CMD (
  :: Install kudu sync
  echo Installing Kudu Sync
  call npm install kudusync -g --silent
  IF !ERRORLEVEL! NEQ 0 goto exit

  :: Locally just running "kuduSync" would also work
  SET KUDU_SYNC_CMD=node "%appdata%\npm\node_modules\kuduSync\bin\kuduSync"
) 

IF NOT DEFINED DEPLOYMENT_TEMP (
  SET DEPLOYMENT_TEMP=%temp%\___deployTemp%random%
  SET CLEAN_LOCAL_DEPLOYMENT_TEMP=true
)

IF DEFINED CLEAN_LOCAL_DEPLOYMENT_TEMP (
  IF EXIST "%DEPLOYMENT_TEMP%" rd /s /q "%DEPLOYMENT_TEMP%"
  mkdir "%DEPLOYMENT_TEMP%"
)

IF NOT DEFINED MSBUILD_PATH (
  SET MSBUILD_PATH=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe
)

:: Work around bug which errors when building .NET 3.5 apps with RESX files
:: https://connect.microsoft.com/VisualStudio/feedback/details/758772/generateresource-fails-for-net-3-5-application-when-net-4-5-has-been-installed 
set DisableOutOfProcTaskHost=true

REM Output the SHA hash and commit message identifying which version of the deployment script is being run
echo.
echo -------------------------------------------------------
echo Deploying the following commit of the deployment script
echo -------------------------------------------------------
echo.
call git log -1

REM Set an environment variable for apps to access deployment scripts
set ESCC_DEPLOYMENT_SCRIPTS=%DEPLOYMENT_SOURCE%\Escc.AzureDeployment\Kudu

echo.
echo ------------------------------------------------------
echo Downloading NUnit test runner
echo ------------------------------------------------------
echo.
call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" %DEPLOYMENT_SOURCE%\Escc.AzureDeployment\ Escc.AzureDeployment.sln
IF !ERRORLEVEL! NEQ 0 goto exit

REM The user of this project should have created a script called DeployOnAzure.cmd with the commands specific to
REM their deployment. Hand over to that now.
call "%DEPLOYMENT_SOURCE%\DeployOnAzure"
IF !ERRORLEVEL! NEQ 0 goto exit

:exit
exit /b !ERRORLEVEL!