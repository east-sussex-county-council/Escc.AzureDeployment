@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: TransformConfig ^<folder name\target filename^> ^<folder name\transform filename^>
	echo.
	echo eg TransformConfig ExampleSite\web.config ExampleSite\web.mychanges.config
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1 using %2
echo ------------------------------------------------------
echo.

if exist "%DEPLOYMENT_SOURCE%\%1" (
  if exist "%DEPLOYMENT_TRANSFORMS%\%2" (

    "%MSBUILD_PATH%" "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfig.xml" /p:TransformInputFile="%DEPLOYMENT_SOURCE%\%1" /p:TransformFile="%DEPLOYMENT_TRANSFORMS%\%2" /p:TransformOutputFile="%DEPLOYMENT_SOURCE%\%1"

    REM Delete temp file created by transformation, because deleting it within the transformation fails due to file locking 
    if exist "%DEPLOYMENT_SOURCE%\%1.temp.config" (
      del "%DEPLOYMENT_SOURCE%\%1.temp.config" 
    )
  )
)

if not exist "%DEPLOYMENT_SOURCE%\%1" (
  echo %DEPLOYMENT_SOURCE%\%1 target file not found.
  exit /b 1
)

if not exist "%DEPLOYMENT_TRANSFORMS%\%2" (
  echo %DEPLOYMENT_TRANSFORMS%\%2 transform not found.
  exit /b 1
)

:exit
exit /b !ERRORLEVEL!