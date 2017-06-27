@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: GitDownload ^<repo name^> ^<tag^> [^<repo path^>] [^<repo URL prefix>^]
	echo.
	echo eg GitDownload ExampleApplication v1.0.0 c:\some-path /git
	goto exit
)

echo.
echo ------------------------------------------------------
echo Updating %1 to %2 using git
echo ------------------------------------------------------
echo.

:: Initialise environment variable to prevent syntax error when running on Azure
set ESCC_CURRENT_GIT_TAG=none
if "%3"=="" (
  set ESCC_GIT_DEPLOYMENT_PATH=%DEPLOYMENT_SOURCE%
) else (
  set ESCC_GIT_DEPLOYMENT_PATH=%3
)

if "%4"=="" (
  set ESCC_GIT_REPO_URL_PREFIX=none
) else (
  set ESCC_GIT_REPO_URL_PREFIX=%4
)

if exist %ESCC_GIT_DEPLOYMENT_PATH%\%1 (
  pushd %ESCC_GIT_DEPLOYMENT_PATH%\%1

  REM Get the git tag which is currently at the HEAD of the repo
  FOR /F "delims=" %%i IN ('git describe') DO set ESCC_CURRENT_GIT_TAG=%%i

  REM If it's not the tag we want, get all tags and switch to the right one
  if %ESCC_CURRENT_GIT_TAG%==%2 (
    echo %1 already up-to-date.
  ) else (
    REM Because transforms can modify project files within the repo after download and before deployment,
    REM if we are deploying an update over existing files there may have been local changes that will prevent a 
    REM git pull. Resetting to HEAD, which will be the previous tag, fixes this. The transforms will then
    REM get re-applied to the new tag.
    call git reset --hard HEAD
    call git pull origin master --tags
    call git checkout tags/%2
  )

  popd
) else (
  REM Prefix is required, suffix is optional
  if "%ESCC_GIT_URL_PREFIX%"=="" (
    echo ERROR: You must set the ESCC_GIT_URL_PREFIX and, optionally, the ESCC_GIT_URL_SUFFIX environment variables to specify
    echo the path to your git repositories. The path will be built up as ESCC_GIT_URL_PREFIX + repo name + ESCC_GIT_URL_SUFFIX.
    set ERRORLEVEL=1
    goto exit
  )
  
  REM Download the project from git using a tagged commit, so that if the
  REM deployment is retried the same commit is used, not a newer one. 
  
  REM Two versions of the command differ only on whether to include the local URL prefix,
  REM because it's difficult to initialise an environment variable to an empty string.
  if "%ESCC_GIT_REPO_URL_PREFIX%"=="none" (
    call git clone -b %2 "%ESCC_GIT_URL_PREFIX%%1%ESCC_GIT_URL_SUFFIX%" "%ESCC_GIT_DEPLOYMENT_PATH%\%1"
  ) else (
    call git clone -b %2 "%ESCC_GIT_URL_PREFIX%%ESCC_GIT_REPO_URL_PREFIX%%1%ESCC_GIT_URL_SUFFIX%" "%ESCC_GIT_DEPLOYMENT_PATH%\%1"
  )
)

:exit
exit /b !ERRORLEVEL!