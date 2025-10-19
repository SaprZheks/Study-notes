@echo off
powershell -Command "git stash"
powershell -Command "git pull origin main"
start "" "C:\Program Files\Obsidian\Obsidian.exe"
exit