@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

:: ----------------------
:: KUDU Deployment Script
:: Version: 0.1.5
:: ----------------------

:: Prerequisites
:: -------------

:: Verify node.js installed
where node 2>nul >nul
IF %ERRORLEVEL% NEQ 0 (
  echo Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment.
  goto error
)

setlocal enabledelayedexpansion

SET ARTIFACTS=%~dp0%..\artifacts

IF NOT DEFINED DEPLOYMENT_SOURCE (
  SET DEPLOYMENT_SOURCE=%~dp0%.
)

:: Download deployment scripts
call Kudu\GitDownload Escc.AzureDeployment v6.1.0
IF !ERRORLEVEL! NEQ 0 goto error

:: Pass control to a script just downloaded
call Escc.AzureDeployment\Kudu\DeployPart2
IF !ERRORLEVEL! NEQ 0 goto error
