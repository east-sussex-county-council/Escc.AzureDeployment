@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: Sync ^<relative path to deployment folder^>
	goto exit
)

IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
  call %KUDU_SYNC_CMD% -v 50 -f "%DEPLOYMENT_TEMP%" -t "%DEPLOYMENT_TARGET%\%1" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
)

:exit
exit /b %ERRORLEVEL%