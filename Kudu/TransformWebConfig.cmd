@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: TransformConfig ^<folder name^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1\web.example.config
echo ------------------------------------------------------
echo.

if exist "%DEPLOYMENT_TRANSFORMS%%1\Web.Release.config" (

  if exist "%DEPLOYMENT_TARGET%\%1\web.config" (                                 
    %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformWebConfig.xml" /p:TransformInputFile="%DEPLOYMENT_TARGET%\%1\web.config" /p:TransformFile="%DEPLOYMENT_TRANSFORMS%%1\Web.Release.config" /p:TransformOutputFile="%DEPLOYMENT_TARGET%\%1\web.config"
  )
  
  if not exist "%DEPLOYMENT_TARGET%\%1\web.config" (
    if exist "%DEPLOYMENT_SOURCE%\%1\web.example.config" (
      %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformWebConfig.xml" /p:TransformInputFile="%DEPLOYMENT_SOURCE%\%1\web.example.config" /p:TransformFile="%DEPLOYMENT_TRANSFORMS%%1\Web.Release.config" /p:TransformOutputFile="%DEPLOYMENT_TARGET%\%1\web.config"
      
    )
  )      
)

if not exist "%DEPLOYMENT_TRANSFORMS%%1\Web.Release.config" (
  echo %DEPLOYMENT_TRANSFORMS%%1\Web.Release.config not found.
)

:exit
exit /b %ERRORLEVEL%