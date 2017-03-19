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
rem   /test ... テストモード。ファイルのコピーのみする。
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
set IS_TEST=0
if %arg1% == /test/ (
    set IS_TEST=1
    call :logging [TEST MODE]
)

rem アーカイブフォルダのフォルダ名の設定
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

rem アーカイブ用のディレクトリを作成
mkdir %save_dir%
cd %target_dir%

rem ====ファイル・フォルダを一か所にコピーする====
rem ディレクトリの時はファイル構造ごとコピーする
rem 
rem TODO:
rem    copyやmoveの結果をログに出力するようにしたい。
rem    方法は > `ログ名`とすればよい。がパイプとか使えないかな？

call :logging "Start File Backup-->"
for /f "usebackq delims=:" %%i in (`dir /b`) do (
    set copy_source=%target_dir%\%%i
    call :logging source: !copy_source!
    call :logging dest: %save_dir%

    call :isTarget %%i
    if errorlevel 1 (
        call :logging Ignore
    ) else (
        rem echo "!copy_source!" "%save_dir%\%%i"\
        if exist !copy_source!\ (
            call :logging ---copy directory---
            if %IS_TEST% == 0 (
                rem echo "!copy_source!" "%save_dir%"
                move /Y "!copy_source!" "%save_dir%"
                if errorlevel 1 (
                    call :logging Move Error
                )
            ) else (
                xcopy /E /I "!copy_source!" "%save_dir%\%%i" 
            )
        ) else (
            call :logging ---copy file---
            if %IS_TEST% == 0 (
                move /Y "!copy_source!" "%save_dir%"
                if errorlevel 1 (
                    call :logging Move Error
                )
            ) else (
                copy "!copy_source!" "%save_dir%"
            )
        )
    )
)

cd %exe_dir%

call :logging ---process end---

endlocal
echo Finish.

rem ===========
rem ファイル/ディレクトリが対象かどうか判定。対象可否は%ERRORLEVEL%で判定
rem Windowsでは空白ファイル名を許可するので、全引数を受け取るようにしている

:isTarget
set IGNORE_FILE=%USERPROFILE%\archive_ignores.ini
if exist %IGNORE_FILE% (
    for /f "delims=" %%i in (%IGNORE_FILE%) do (
        if "%*" == "%%i" (
            rem call :logging %1 is ignore.
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
