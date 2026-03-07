@echo off
powershell -Command "git stash"
powershell -Command "git pull origin main"
exit