@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

set VALID=true
if "%1"=="" set VALID=false
if "%2"=="" set VALID=false

if %VALID%==false (
	echo Usage: NugetRestore ^<relative path to folder containing packages.config or .sln file^> ^<packages.config or .sln filename^> ^<path to packages folder - optional^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Restoring NuGet packages for %1%2
echo ------------------------------------------------------
echo.

IF /I "%1" NEQ "" (

  :: Copy a custom nuget.config if present, to allow a custom package source to be specified
  if exist "%DEPLOYMENT_SOURCE%\nuget.config" (
      copy "%DEPLOYMENT_SOURCE%\nuget.config" %1
  ) 

  :: NuGet restore to ./packages folder unless a path is specified
  if /I "%2" NEQ "" (
      
      pushd %1
      call "%NUGET_EXE%" restore %1%2 -OutputDirectory %3packages -NonInteractive 
      popd
      goto exit
  )

)

:exit
exit /b !ERRORLEVEL!