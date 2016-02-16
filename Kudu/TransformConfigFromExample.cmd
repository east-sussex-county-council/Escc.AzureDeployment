@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: TransformConfigFromExample ^<folder name\configuration filename without extension^> ^<transform file^>
	echo.
	echo eg TransformConfigFromExample ExampleSite\web ExampleSiteTransforms\web.release.config
	goto exit
)

if String.Empty%2==String.Empty (
	echo Usage: TransformConfigFromExample ^<folder name\configuration filename without extension^> ^<transform file^>
	echo.
	echo eg TransformConfigFromExample ExampleSite\web ExampleSiteTransforms\web.release.config
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1.config using %2
echo ------------------------------------------------------
echo.

if exist "%2" (

  REM Look first for *.example.config
  if exist "%1.example.config" (
    "%MSBUILD_PATH%" "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfig.xml" /p:TransformInputFile="%1.example.config" /p:TransformFile="%2" /p:TransformOutputFile="%1.config"
  )
  
  REM If that wasn't found, fall back to the possibility that web.config has been created some other way, or create a basic one
  if not exist "%1.example.config" (
    if not exist "%1.config" (
      echo Creating %1.config
      echo ^<?xml version="1.0" encoding="utf-8"?^>^<configuration^>^</configuration^> > "%1.config"
    )
    "%MSBUILD_PATH%" "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfig.xml" /p:TransformInputFile="%1.config" /p:TransformFile="%2" /p:TransformOutputFile="%1.config"
  )      

  REM Delete temp file created by transformation, because deleting it within the transformation fails due to file locking 
  if exist "%1.config.temp.config" (
    del "%1.config.temp.config" 
  )
)

if not exist "%2" (
  echo %2 not found.
  exit /b 1
)

:exit
exit /b !ERRORLEVEL!