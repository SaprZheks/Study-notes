@echo off
powershell -Command "git pull origin main"
powershell -Command "Start-Process \"C:\Program Files\Obsidian\Obsidian.exe\" -WindowStyle Hidden"