@echo off

if String.Empty%1==String.Empty (
	echo Usage: DeleteApp ^<git repo name^>
	goto exit
)

if exist %1 (
  call git checkout master
  call git rm -rf %1
  call git branch -D %1
  call git commit -m "Deleted subtree for %1"
)

:exit
exit /b %ERRORLEVEL%