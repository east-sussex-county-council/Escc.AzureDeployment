@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: NugetRestore ^<relative path to .sln file^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Restoring NuGet packages for %1
echo ------------------------------------------------------
echo.

IF /I "%1" NEQ "" (

  set NUGET_RESTORE_FROM=%1

  :: Allow restore from a solution file, useful when the solution file is in the same folder as the project file being built
  if /I "%NUGET_RESTORE_FROM:~-4%"==".sln"
  (
      call "%NUGET_EXE%" restore %NUGET_RESTORE_FROM% -NonInteractive
      goto exit
  )

)

:exit
exit /b %ERRORLEVEL%