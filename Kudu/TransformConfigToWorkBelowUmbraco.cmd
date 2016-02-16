@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: TransformConfigToWorkBelowUmbraco ^<folder name\configuration filename without extension^>
	echo.
	echo eg TransformConfigToWorkBelowUmbraco ExampleSite\web.config
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1.config to work below Umbraco
echo ------------------------------------------------------
echo.

if not exist "%1" (
  echo Creating %1
  echo ^<?xml version="1.0" encoding="utf-8"?^>^<configuration^>^</configuration^> > "%1"
)

"%MSBUILD_PATH%" "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfig.xml" /p:TransformInputFile="%1" /p:TransformFile="%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfigToWorkBelowUmbraco.xdt" /p:TransformOutputFile="%1"

:: Delete temp file created by transformation, because deleting it within the transformation fails due to file locking 
if exist "%1.temp.config" (
  del "%1.temp.config" 
)

:exit
exit /b !ERRORLEVEL!