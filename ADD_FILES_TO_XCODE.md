# Xcodeに新規ファイルを追加する手順

現在、新しく作成されたファイルがXcodeプロジェクトに登録されていないため、ビルドエラーが発生しています。

## ❌ 現在のエラー

```
Cannot find 'SharedDataManager' in scope
Cannot find 'LiveActivityManager' in scope
```

## ✅ 解決方法: Xcodeでファイルを追加

### ステップ1: Xcodeでプロジェクトを開く

```bash
open /Users/aokiy/Development/analyzer/ActivityMonitor/ActivityMonitor.xcodeproj
```

### ステップ2: 新規ファイルをプロジェクトに追加

以下のファイルをXcodeプロジェクトに追加する必要があります：

#### メインアプリターゲット（ActivityMonitor）に追加

1. **Services/SharedDataManager.swift**
   - Xcodeの左側ナビゲーターで `Services` フォルダを右クリック
   - **Add Files to "ActivityMonitor"...** を選択
   - `/Users/aokiy/Development/analyzer/ActivityMonitor/ActivityMonitor/Services/SharedDataManager.swift` を選択
   - ✅ **Copy items if needed** にチェック
   - ✅ **Add to targets**: `ActivityMonitor` にチェック
   - **Add** をクリック

2. **Services/ActivityMonitorLiveActivity.swift**
   - 同様の手順で追加

3. **Services/BackgroundTaskManager.swift**
   - 同様の手順で追加

4. **Services/NotificationManager.swift**
   - 同様の手順で追加

### より簡単な方法: ドラッグ&ドロップ

1. Finderで以下のフォルダを開く：
   ```
   /Users/aokiy/Development/analyzer/ActivityMonitor/ActivityMonitor/Services/
   ```

2. 以下の4つのファイルを選択：
   - `SharedDataManager.swift`
   - `ActivityMonitorLiveActivity.swift`
   - `BackgroundTaskManager.swift`
   - `NotificationManager.swift`

3. Xcodeの左側ナビゲーター（Project Navigator）の `Services` フォルダにドラッグ&ドロップ

4. 表示されるダイアログで：
   - ✅ **Copy items if needed** にチェック
   - ✅ **Create groups** を選択
   - ✅ **Add to targets**: `ActivityMonitor` にチェック
   - **Finish** をクリック

### ステップ3: ビルドして確認

1. **⌘B** を押してビルド
2. エラーが解消されているはずです

---

## 📋 追加が必要なファイル一覧

### メインアプリ (ActivityMonitor ターゲット)

```
ActivityMonitor/Services/
├── SharedDataManager.swift              ← 追加必要
├── ActivityMonitorLiveActivity.swift    ← 追加必要
├── BackgroundTaskManager.swift          ← 追加必要
└── NotificationManager.swift            ← 追加必要
```

### ウィジェット拡張機能（まだWidget Extensionを作成していない場合）

**注意**: Widget Extensionターゲットは別途作成する必要があります。
詳細は `WIDGET_LIVEACTIVITY_SETUP.md` を参照してください。

---

## 🔍 ファイルが正しく追加されたか確認する方法

### 方法1: Project Navigatorで確認

1. Xcodeの左側のProject Navigatorを開く
2. `ActivityMonitor` → `Services` フォルダを展開
3. 以下のファイルが表示されていることを確認：
   - ✅ SharedDataManager.swift
   - ✅ ActivityMonitorLiveActivity.swift
   - ✅ BackgroundTaskManager.swift
   - ✅ NotificationManager.swift

### 方法2: File Inspectorで確認

1. 各ファイルを選択
2. 右側のFile Inspector (⌥⌘1) を開く
3. **Target Membership** セクションで `ActivityMonitor` にチェックが入っているか確認

---

## 🚀 次のステップ

ファイルを追加したら：

1. **クリーンビルド**:
   ```
   Product → Clean Build Folder (⇧⌘K)
   ```

2. **リビルド**:
   ```
   Product → Build (⌘B)
   ```

3. **実行**:
   ```
   Product → Run (⌘R)
   ```

---

## ⚠️ よくある問題

### 問題1: ファイルが灰色で表示される

**原因**: ファイルはプロジェクトに参照されているが、ターゲットに追加されていない

**解決策**:
1. ファイルを選択
2. File Inspector (⌥⌘1) を開く
3. **Target Membership** で `ActivityMonitor` にチェックを入れる

### 問題2: 「Cannot find ... in scope」エラーが続く

**原因**: ファイルがコンパイルされていない

**解決策**:
1. Product → Clean Build Folder (⇧⌘K)
2. Xcodeを再起動
3. プロジェクトを再度開いてビルド

### 問題3: ファイルが2回表示される

**原因**: ファイルが重複して追加されている

**解決策**:
1. 重複しているファイルの1つを右クリック
2. **Delete** を選択
3. **Remove Reference** を選択（**Move to Trash**ではない）

---

## 📖 参考

- [Xcode Help - Add files to a project](https://developer.apple.com/documentation/)
- [WIDGET_LIVEACTIVITY_SETUP.md](./WIDGET_LIVEACTIVITY_SETUP.md) - Widget Extension作成手順

---

**これらの手順を完了すれば、ビルドエラーが解消され、すべての新機能が動作します！**
