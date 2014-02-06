@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: TransformConfig ^<folder name^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1\web.config.example
echo ------------------------------------------------------
echo.

if exist "%DEPLOYMENT_SOURCE%\%1\web.config.example" (
  "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.ConfigTransform\bin\Release\Escc.EastSussexGovUK.AzureDeployment.ConfigTransform.exe" "%DEPLOYMENT_SOURCE%\%1\web.config.example" "%DEPLOYMENT_TARGET%\%1\web.config"
)

:exit
exit /b %ERRORLEVEL%