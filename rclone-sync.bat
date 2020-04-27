@ECHO off
chcp 65001
MODE 115,25
TITLE Script - Rsync for cloud storage:
SET SCRIPT_VERSION=1.0


:: Основные настройки;
CD /d "%~dp0"
SET ch="app\cecho.exe"
SET RCLONE_APP="app\rclone.exe"
SET CONF="conf\rclone.conf"
SET CONF_EF="conf\exclude-from.txt"
SET LOG_FILE="log\log.txt"

:: Задаем переменную среды для переопределения расположения конфига;
SETX RCLONE_CONFIG %CONF%

:: Подключаем конфигурационный файл;
<conf\rclone-sync.conf (for /f "delims=" %%a in ('more') do @set "%%a") 2>nul

:: Configure Storage;
SET CONFIGURE_STORAGE=%RCLONE_APP% config

:: 1. Source sync --> to 2. Dest | Откуда --> Куда;
SET SYNC_1=%RCLONE_APP% %MODE% -q -P %FOLDER% %STORAGE_PATH%:%CLOUD% --config=%CONF% --transfers=%RATE% --bwlimit=%LIMIT% --exclude-from=%CONF_EF% --log-file=%LOG_FILE% %MORE%
SET SYNC_2=%RCLONE_APP% %MODE% -q -P %STORAGE_PATH%:%CLOUD% %FOLDER% --config=%CONF% --transfers=%RATE% --bwlimit=%LIMIT% --exclude-from=%CONF_EF% --log-file=%LOG_FILE% %MORE%

:: Вывод информации о хранилище;
SET STORAGE_ABOUT=%RCLONE_APP% about %STORAGE_PATH%:

:Menu
cls
echo.
%ch% {08}  ╔══════════════════════════════════════════════════════════════════════╗ {\n #}
%ch% {08}  ║     {07}Script - Rsync for cloud storage:				 {08}║ {\n #}
%ch% {08}  ╚══════════════════════════════════════════════════════════════════════╝ {\n #}
echo.
%ch%		Текущее хранилище: {0a}%STORAGE_PATH%{#} ^| Режим работы: {0a}%MODE%{#}{\n #}
echo.
echo.	Варианты для выбора:
echo.
%ch% {0b}  [1]{#} = {0e}Sync{#} {0f}[Folder: {08}%FOLDER%{#}{0f}] {0e}--^>{#} {0f}[Cloud: {08}%CLOUD%{#}{0f}];{\n #}
echo.
%ch% {0b}  [2]{#} = {0e}Sync{#} {0f}[Cloud: {08}%CLOUD%{#}{0f}] {0e}--^>{#} {0f}[Folder: {08}%FOLDER%{#}{0f}];{\n #}
echo.
%ch% {0b}  [3]{#} = {0e}Запустить настройку {0a}RCLONE{#};{\n #}
echo.
%ch% {0b}  [4]{#} = {0e}Информация о хранилище{#};{\n #}
echo.
%ch% {0b}  [0]{#} = {0c}Выйти.{\n #}
%ch%												{08}^| Версия %SCRIPT_VERSION%{\n #}
echo.
set /p choice=--- Ваш выбор:
if '%choice%'=='1' goto GO_SYNC_1
if '%choice%'=='2' goto GO_SYNC_2
if '%choice%'=='3' goto GO_CONFIGURE_STORAGE
if '%choice%'=='4' goto GO_STORAGE_ABOUT
if '%choice%'=='0' goto END
if "%choice%"=="" ( endlocal & goto :RETURN
 ) else ( %ch% - {0c}Неправильный выбор!{\n #}
		TIMEOUT /T 2 >nul & endlocal & goto :RETURN )

:GO_SYNC_1
%SYNC_1% & PAUSE & goto RETURN

:GO_SYNC_2
%SYNC_2% & PAUSE & goto RETURN

:GO_CONFIGURE_STORAGE
%CONFIGURE_STORAGE% & goto RETURN

:GO_STORAGE_ABOUT
%STORAGE_ABOUT% & PAUSE & goto RETURN

:RETURN
goto MENU

:END
goto exit 2>nul
