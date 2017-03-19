@echo off

rem Windowsデスクトップ掃除ツール
rem   Windowsのデスクトップのファイルを全てアーカイブする。
rem 
rem 処理フロー
rem   - 各種設定
rem   - ファイルのコピー
rem   - ファイルの削除
rem 
rem オプション
rem   /test/ ... テストモード。ファイルのコピーのみする。
rem 
rem その他
rem   %USERPROFILE%\archive_ignores.ini に無視ファイルorディレクトリを記載
rem   すると無視するような仕様とした

echo Start. This log is in %USERPROFILE%\archives\log.txt

rem 遅延環境変数の展開（for内の変数が上手く動作するように）
rem 変数を使用するときも%ではなく!を使用する
setlocal ENABLEDELAYEDEXPANSION

call :logging ---process start---
set start_date=%date%
set start_time=%time%
call :logging  %date%%time%

rem 引数が指定されていない時はから文字列が入り、
rem 文字列判定が正しく行われなくなるため、ダミー文字を付ける

set arg1=%1/
call :logging arg1: %arg1%

set format_date=%date:/=_%
set format_time=%time::=%
set format_time=%format_time: =%
call :logging start_time: %format_date%%format_time%

rem ====取得先フォルダ====
set target_dir=%USERPROFILE%\Desktop
rem ====保存先フォルダ=====
set save_dir=%USERPROFILE%\Documents\archives
call :logging save_dir: %save_dir%
rem ====ファイルを集めるフォルダ名====
set dir_name=archive_%format_date%_%format_time%
call :logging dir_name: %dir_name%
set save_dir=%save_dir%\%dir_name%
call :logging exe_dir: %save_dir%

rem ====実行ファイルのパス取得====
set exe_dir=%~dp0
call :logging exe_dir: %exe_dir%

mkdir %save_dir%
cd %target_dir%

rem ====ファイル・フォルダを一か所にコピーする====
rem ディレクトリの時はファイル構造ごとコピーする

for /f "usebackq delims=:" %%i in (`dir /b`) do (
    rem set copy_source=%target_dir%\%%i
    set file=%%i
    echo !file!
    call :logging source: !copy_source!
    call :logging dest: %save_dir%
    
    echo !copy_source!

    call :isTarget %%i

    if errorlevel 1 (
        call :logging Ignore
    ) else (
        if exist !copy_source!\ (
            xcopy !copy_source! %save_dir%\%%i\ /e 
            call :logging ---copy directory---
            move %copy_source% %save_dir%\%%i
            if errorlevel 1 (
                call :logging Move Error
            )
        ) else (
            copy !copy_source! %save_dir%\ 
            call :logging ---copy file---
            move %copy_source% %save_dir%\
            if errorlevel 1 (
                call :logging Move Error
            )
        )
    )
)


rem rem ====ファイル・フォルダを削除する====
rem rem ディレクトリの時はファイル構造ごとコピーする
rem rem テストモードではファイル・フォルダの削除はしない
rem if not %arg1% == /test/ (
rem     for /f "usebackq delims=:" %%i in (`dir /b`) do (
rem         set copy_source=%target_dir%\%%i
rem         
rem         call :isTarget %%i
rem         if errorlevel 1 (
rem             echo Ignore File
rem         ) else (
rem             if exist !copy_source!\ (
rem                 rd /s /q !copy_source!
rem                 echo ---delete directory---
rem             ) else (
rem                 del !copy_source!
rem                 echo ---delete file---
rem             )
rem         )
rem     )
rem )

cd %exe_dir%

call :logging ---process end---

endlocal
echo Finish.

rem ===========
rem ファイル/ディレクトリが対象かどうか判定。対象可否は%ERRORLEVEL%で判定

:isTarget
set IGNORE_FILE=%USERPROFILE%\archive_ignores.ini
if exist %IGNORE_FILE% (
    for /f "delims=" %%i in (%IGNORE_FILE%) do (
        if "%1" == "%%i" (
            call :logging %1 is ignore.
            exit /B 1
        )
    )
)
exit /B 0

rem ===========
rem ログ作成。ファイルが存在しない場合は、ディレクトリとファイルを作成する。
:logging
set BACKUP_DIR=%USERPROFILE%\Documents\archives
set LOG_NAME=%BACKUP_DIR%\log.txt

if not exist %BACKUP_DIR% (
    mkdir %BACKUP_DIR%
)

echo [%DATE% %TIME:~0,8%] %* >> %LOG_NAME%
