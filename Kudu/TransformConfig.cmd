@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: TransformConfig ^<folder name\configuration filename without extension^>
	echo.
	echo eg TransformConfig ExampleSite\web
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1.config
echo ------------------------------------------------------
echo.

if exist "%DEPLOYMENT_TRANSFORMS%%1.Release.config" (

  if exist "%DEPLOYMENT_TARGET%\%1.config" (
    %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfig.xml" /p:TransformInputFile="%DEPLOYMENT_TARGET%\%1.config" /p:TransformFile="%DEPLOYMENT_TRANSFORMS%%1.Release.config" /p:TransformOutputFile="%DEPLOYMENT_TARGET%\%1.config"
  )
  
  if not exist "%DEPLOYMENT_TARGET%\%1.config" (
    if exist "%DEPLOYMENT_SOURCE%\%1.example.config" (
      %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfig.xml" /p:TransformInputFile="%DEPLOYMENT_SOURCE%\%1.example.config" /p:TransformFile="%DEPLOYMENT_TRANSFORMS%%1.Release.config" /p:TransformOutputFile="%DEPLOYMENT_TARGET%\%1.config"
      
    )
  )      

  :: Delete temp file created by transformation, because deleting it within the transformation fails due to file locking 
  if exist "%DEPLOYMENT_TARGET%\%1.config.temp.config" (
    del "%DEPLOYMENT_TARGET%\%1.config.temp.config" 
  )
)

if not exist "%DEPLOYMENT_TRANSFORMS%%1.Release.config" (
  echo %DEPLOYMENT_TRANSFORMS%%1.Release.config not found.
)

:exit
exit /b %ERRORLEVEL%