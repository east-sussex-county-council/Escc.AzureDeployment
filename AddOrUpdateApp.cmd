@echo off

set VALID=true
if String.Empty%1==String.Empty set VALID=false
if String.Empty%2==String.Empty set VALID=false

if %VALID%==false (
	echo.
	echo Usage: AddOrUpdateApp ^<git base URL^> ^<git repo name^>
	echo.
	echo eg AddOrUpdateApp https://github.com/east-sussex-county-council/ Escc.ExampleRepo
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
	call %ESCC_DEPLOYMENT_SCRIPTS%UpdateApp %2
	goto exit
)

:exit
exit /b %ERRORLEVEL%