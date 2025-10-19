# Введение
Это сборник моих Obsidian-заметок, для получения доступа к ним потребуется настроить синхронизацию этого репозитория с вашим компьютером
# Инструкция
1. Выберите место, где локально хотите хранить заметки, откройте в этой папке `PowerShell` и выполните

   `git clone https://github.com/SaprZheks/Study-notes.git`
3. Добавьте адрес репозитория, чтобы потом получать актуальную его версию автоматически:

   `git remote add origin https://github.com/SaprZheks/Study-notes.git`
5. Затем установите программу [Obsidian](https://obsidian.md/download) для просмотра заметок.
6. Щелкните по "Расположение файла" и сохраните путь до Obsidian
7. В корне папки с заметками создайте `Obsidian.bat` файл для запуска Obsidian и автоматического подтягивания всех изменений из этого репозитория со следующим содержимым
   (Путь `C:\Program Files\Obsidian\Obsidian.exe` заменить расположением `Obsidian.exe` с предыдущего шага):
```
@echo off
powershell -Command "git pull origin main"
powershell -Command "Start-Process \"C:\Program Files\Obsidian\Obsidian.exe\" -WindowStyle Hidden"
```
7. На рабочем столе создайте ярлык, указывающий на `Obsidian.bat`, для красоты можете добавить ему иконку из папки с заметками `Obsidian.ico`)

**Готово! Теперь при каждом заходе по этому ярлыку у вас будет доступ к актуальной версии моих заметок!**
