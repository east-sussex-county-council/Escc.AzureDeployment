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

if exist %1 (
  pushd %1
  FOR /F "delims=" %%i IN ('git describe') DO set ESCC_CURRENT_GIT_TAG=%%i

  if %ESCC_CURRENT_GIT_TAG%==%2 (
    echo %1 already up-to-date.
  ) else (
    call git pull origin master
  )

  popd
) else (
  call git clone -b %2 "https://github.com/east-sussex-county-council/%1.git" "%DEPLOYMENT_SOURCE%\%1"
)

:exit
exit /b %ERRORLEVEL%