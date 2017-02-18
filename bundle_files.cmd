@echo off

rem 遅延環境変数の展開（for内の変数が上手く動作するように）
rem 変数を使用するときも%ではなく!を使用する
setlocal ENABLEDELAYEDEXPANSION

echo ---process start---
set start_date=%date%
set start_time=%time%
echo %date%%time%

rem 引数が指定されていない時はから文字列が入り、
rem 文字列判定が正しく行われなくなるため、ダミー文字を付ける
set arg1=%1/
echo arg1: %arg1%

set format_date=%date:/=_%
set format_time=%time::=%
set format_time=%format_time: =%
echo start_time: %format_date%%format_time%

rem ====取得先フォルダ====
set target_dir=%USERPROFILE%\Desktop
rem ====保存先フォルダ=====
set save_dir=%USERPROFILE%\Documents\archives
echo save_dir: %save_dir%
rem ====ファイルを集めるフォルダ名====
set dir_name=archive_%format_date%_%format_time%
echo dir_name: %dir_name%
set save_dir=%save_dir%\%dir_name%

rem ====実行ファイルのパス取得====
set exe_dir=%~dp0
echo exe_dir: %exe_dir%

cd %target_dir%

rem ====ファイル・フォルダを一か所にコピーする====
rem ディレクトリの時はファイル構造ごとコピーする
for /f "usebackq delims=:" %%i in (`dir /b`) do (
    set copy_source=%target_dir%\%%i
    echo source: !copy_source!
    echo dest: %save_dir%\%dir_name%
    
    if exist !copy_source!\ (
        xcopy !copy_source! %save_dir%\%%i\ /e 
	echo ---copy directory---
    ) else (
	copy !copy_source! %save_dir%\ 
	echo ---copy file---
    )
)

rem ====ファイル・フォルダを削除する====
rem ディレクトリの時はファイル構造ごとコピーする
rem テストモードではファイル・フォルダの削除はしない
if not %arg1% == /test/ (
    for /f "usebackq delims=:" %%i in (`dir /b`) do (
        set copy_source=%target_dir%\%%i
        
        if exist !copy_source!\ (
            rd /s /q !copy_source!
            echo ---delete directory---
        ) else (
            del !copy_source!
            echo ---delete file---
        )
    )
)

cd %exe_dir%

set end_date=%date%
set end_time=%time%
echo ---process end---
echo start_time: %start_date% %start_time%
echo end_time  : %end_date% %end_time%

pause

