@echo off

if String.Empty%1==String.Empty (
	echo Usage: UpdateApp ^<git repo name^>
	goto exit
)

call git checkout %1
call git pull
call git checkout master
call git merge --squash -s subtree --no-commit %1
call git commit -m "Updated subtree for %1"

:exit
exit /b %ERRORLEVEL%