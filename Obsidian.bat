@echo off
powershell -Command "git stash"
powershell -Command "git pull origin main"
powershell -Command "git submodule update --init --remote --recursive"
call run.bat
exit