@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: Sync ^<relative path to deployment folder^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Syncing %1
echo ------------------------------------------------------
echo.

IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
  call %KUDU_SYNC_CMD% -v 50 -f "%DEPLOYMENT_TEMP%" -t "%DEPLOYMENT_TARGET%\%1" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
)

:exit
exit /b !ERRORLEVEL!