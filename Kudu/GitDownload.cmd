@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: GitDownload ^<repo name^> ^<tag^>
	echo.
	echo eg GitDownload ExampleApplication v1.0.0
	goto exit
)

echo.
echo ------------------------------------------------------
echo Updating %1 to %2 using git
echo ------------------------------------------------------
echo.

:: Initialise environment variable to prevent syntax error when running on Azure
set ESCC_CURRENT_GIT_TAG=none

if exist %1 (
  pushd %1

  :: Get the git tag which is currently at the HEAD of the repo
  FOR /F "delims=" %%i IN ('git describe') DO set ESCC_CURRENT_GIT_TAG=%%i

  :: If it's not the tag we want, get all tags and switch to the right one
  if %ESCC_CURRENT_GIT_TAG%==%2 (
    echo %1 already up-to-date.
  ) else (
    call git pull origin master --tags
    call git checkout tags/%2
  )

  popd
) else (
  :: Download the project from github using a tagged commit, so that if the
  :: deployment is retried the same commit is used, not a newer one
  call git clone -b %2 "https://github.com/east-sussex-county-council/%1.git" "%DEPLOYMENT_SOURCE%\%1"
)

:exit
exit /b %ERRORLEVEL%