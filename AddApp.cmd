@echo off

set VALID=true
if not exist .git set VALID=false
if not exist .deployment set VALID=false

if %VALID%==false (
  echo.
  echo This command must be run from the root of your deployment repository.
  echo.
  goto exit
)

set VALID=true
if String.Empty%1==String.Empty set VALID=false
if String.Empty%2==String.Empty set VALID=false

if %VALID%==false (
	echo.
	echo Usage: AddApp ^<git base URL^> ^<git repo name^>
	echo.
	echo eg AddApp http://github.com/east-sussex-county-council/ Escc.ExampleRepo
	echo. 
	goto exit
)


call git remote add %2 %1%2.git
call git fetch %2
call git checkout -b %2 %2/master
call git checkout master
call git read-tree --prefix=%2/ -u %2
call git commit -m "Added %2 as subtree"

:exit
exit /b %ERRORLEVEL%