# Windowsデスクトップ掃除ツール

Windowsのデスクトップのファイルを掃除するツール。

## 使い方
ファイルのコマンドを実行すれば自動的に実施される。  
ファイルは`%USERPROFILE%\Documents\archives`配下に日付ごとに配置される。  
ログファイルは`%USERPROFILE%\Documents\log.txt`として出力される。

### 実行方法
```cmd
rem 単純に実行する場合
bundle_files.bat

rem テストモード
rem アーカイブは作成するが、デスクトップ上からファイルを削除しない。
bundle_files.bat /test/
```

## 注意事項
ファイルをデスクトップ上から削除するため、再度必要になった場合は、`%USERPROFILE%\Documents\archives`から取得するようにすること。

## ライセンス
MIT
