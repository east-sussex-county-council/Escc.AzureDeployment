@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

set VALID=true
if "%1"=="" set VALID=false
if "%2"=="" set VALID=false

if %VALID%==false (
	echo Usage: NugetRestore ^<relative path to folder containing packages.config or .sln file^> ^<packages.config or .sln filename^> ^<output directory - defaults to 'packages'^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Restoring NuGet packages for %1%2
echo ------------------------------------------------------
echo.

IF /I "%1" NEQ "" (

  :: Copy a custom nuget.config if present, to allow a custom package source to be specified
  if exist "%DEPLOYMENT_TRANSFORMS%nuget.config" (
      copy "%DEPLOYMENT_TRANSFORMS%nuget.config" %1
  )

  :: NuGet restore to packages folder unless otherwise specified
  if /I "%2" NEQ "" (
      set NUGET_OUTPUT_DIRECTORY=packages
      
      if /I "%3" NEQ "" (
        set NUGET_OUTPUT_DIRECTORY=%3
      )
      
      call "%NUGET_EXE%" restore %1%2 -OutputDirectory %NUGET_OUTPUT_DIRECTORY% -NonInteractive 
      goto exit
  )

)

:exit
exit /b %ERRORLEVEL%