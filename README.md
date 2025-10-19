# Введение
Это сборник моих Obsidian-заметок, для получения доступа к ним потребуется настроить синхронизацию этого репозитория с вашим компьютером
# Инструкция
1. Выберите место, где локально хотите хранить заметки, откройте в этой папке `PowerShell` и выполните
`git clone https://github.com/SaprZheks/Study-notes.git`
2. Добавьте адрес репозитория, чтобы потом получать актуальную его версию автоматически:
`git remote add origin https://github.com/SaprZheks/Study-notes.git`
4. Затем установите программу [Obsidian](https://obsidian.md/download) для просмотра заметок.
5. Щелкните по "Расположение файла" и сохраните путь до Obsidian
6. Создайте `.bat` файл для запуска Obsidian и автоматического подтягивания всех изменений из этого репозитория со следующим содержимым
   (Путь `C:\Program Files\Obsidian\Obsidian.exe` заменить расположеием Obsidian.exe с предыдущего шага,
   путь `C:\Users\Path\to\your\repository\folder` заменить расположеием папки с заметками):
```
@echo off
powershell -Command "cd \"C:\Users\Path\to\your\repository\folder\""
powershell -Command "git pull origin main"
powershell -Command "Start-Process \"C:\Program Files\Obsidian\Obsidian.exe\" -WindowStyle Hidden"
```
