@echo off
powershell -Command "git submodule foreach --recursive 'git stash'"
powershell -Command "git submodule update --init --remote --recursive"
start "" "obsidian://open"
exit