@echo off

:: Check that the git repo name to delete was specified as a parameter

if "%1"=="" (
	echo Usage: DeleteApp ^<git repo name^>
	goto exit
)

:: If a folder with the name of the repo exists, delete the folder from the master
:: branch, delete the tracking branch and delete the remote

if exist %1 (
  echo.
  echo ------------------------------------------------------
  echo Deleting %1
  echo ------------------------------------------------------
  echo.

  call git checkout master
  
  :: Check that this script is being run from the root of the deployment repository.
  :: Exit if not, as we don't want to run these git commands anywhere else.

  set VALID=true
  if not exist .git set VALID=false
  if not exist .deployment set VALID=false

  if %VALID%==false (
    echo.
    echo This command must be run from the root of your deployment repository.
    echo.
    goto exit
  )
  
  :: Delete the branch and the remote
  
  call git rm -rf %1
  call git branch -D %1
  call git remote remove %1
  call git commit -m "Deleted %1"
)

:exit
exit /b %ERRORLEVEL%