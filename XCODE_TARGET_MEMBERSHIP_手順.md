# Xcode でファイルを Widget Extension ターゲットに追加する手順

## エラーの原因

以下のエラーが表示されています：
```
Cannot find 'SharedDataManager' in scope
Cannot find type 'MetricsSnapshot' in scope
```

これは、`MetricsData.swift` と `SharedDataManager.swift` が **ActivityMonitorWidgetExtension** ターゲットに追加されていないためです。

## 解決方法：Target Membership を設定する

### ステップ1: MetricsData.swift をターゲットに追加

1. **Xcode を開く**
   - ActivityMonitor.xcodeproj を開いてください

2. **プロジェクトナビゲーターでファイルを選択**
   - 左側のフォルダツリーで以下のパスを探します：
   ```
   ActivityMonitor
   └── ActivityMonitor
       └── Models
           └── MetricsData.swift  ← これを選択
   ```

3. **File Inspector を開く**
   - 方法1: メニューバーから `View` → `Inspectors` → `Show File Inspector`
   - 方法2: キーボードショートカット `⌘ + Option + 1`
   - 方法3: 右側の Inspector エリアの一番左のタブアイコンをクリック

4. **Target Membership を確認**
   - File Inspector の中段に「Target Membership」というセクションがあります
   - 現在の状態（おそらく）：
     ```
     ✅ ActivityMonitor
     ⬜ ActivityMonitorWidgetExtension  ← チェックが入っていない
     ```

5. **ActivityMonitorWidgetExtension にチェックを入れる**
   - `ActivityMonitorWidgetExtension` の横のチェックボックスをクリック
   - 最終的な状態：
     ```
     ✅ ActivityMonitor
     ✅ ActivityMonitorWidgetExtension  ← チェックを入れる
     ```

### ステップ2: SharedDataManager.swift をターゲットに追加

1. **ファイルを選択**
   ```
   ActivityMonitor
   └── ActivityMonitor
       └── Services
           └── SharedDataManager.swift  ← これを選択
   ```

2. **File Inspector を開く** (`⌘ + Option + 1`)

3. **Target Membership で両方にチェック**
   ```
   ✅ ActivityMonitor
   ✅ ActivityMonitorWidgetExtension
   ```

### ステップ3: （オプション）その他の共有ファイルも追加

Widget で直接メトリクスを収集したい場合は、以下も追加できます：

#### SystemMetricsCollector.swift
```
ActivityMonitor
└── ActivityMonitor
    └── Services
        └── SystemMetricsCollector.swift
```
Target Membership:
```
✅ ActivityMonitor
✅ ActivityMonitorWidgetExtension
```

#### ActivityMonitor-Bridging-Header.h
```
ActivityMonitor
└── ActivityMonitor
    └── ActivityMonitor-Bridging-Header.h
```
Target Membership:
```
✅ ActivityMonitor
✅ ActivityMonitorWidgetExtension
```

### ステップ4: ビルド設定の確認

Widget Extension の Bridging Header を設定する必要があります：

1. **プロジェクトナビゲーターでプロジェクトを選択**
   - 一番上の青い「ActivityMonitor」アイコンをクリック

2. **ターゲットを選択**
   - TARGETS のリストから `ActivityMonitorWidgetExtension` を選択

3. **Build Settings タブを開く**

4. **Bridging Header を検索**
   - 検索ボックスに「bridging」と入力

5. **Objective-C Bridging Header を設定**
   - `Objective-C Bridging Header` の行を見つける
   - 値を以下に設定：
     ```
     ActivityMonitor/ActivityMonitor-Bridging-Header.h
     ```

### ステップ5: クリーンビルド

1. **Clean Build Folder**
   - メニュー: `Product` → `Clean Build Folder`
   - または `⌘ + Shift + K`

2. **ビルド**
   - メニュー: `Product` → `Build`
   - または `⌘ + B`

## 確認方法

ビルドが成功したら、以下を確認：

### File Inspector での確認
各ファイルを選択して、Target Membership が以下のようになっているか確認：

**MetricsData.swift:**
```
✅ ActivityMonitor
✅ ActivityMonitorWidgetExtension
```

**SharedDataManager.swift:**
```
✅ ActivityMonitor
✅ ActivityMonitorWidgetExtension
```

### ビルドエラーの確認
以下のエラーが消えているはずです：
- ✅ Cannot find 'SharedDataManager' in scope
- ✅ Cannot find type 'MetricsSnapshot' in scope
- ✅ Cannot infer contextual base in reference to member 'placeholder'

## トラブルシューティング

### エラー: "Redefinition of ..."
→ ファイルが重複して追加されている可能性があります。Target Membership で1つのチェックを外してください。

### エラー: "No such file or directory"
→ Bridging Header のパスが間違っています。パスを確認してください。

### ビルドは成功するが、Widget にデータが表示されない
→ App Groups の設定を確認してください。両方のターゲットで同じ App Group ID (`group.com.activitymonitor.app`) が設定されている必要があります。

## App Groups の設定（重要）

Widget がメインアプリとデータを共有するには、App Groups を設定する必要があります：

### メインアプリ (ActivityMonitor)
1. TARGETS → `ActivityMonitor` を選択
2. `Signing & Capabilities` タブを開く
3. `+ Capability` ボタンをクリック
4. `App Groups` を選択
5. `+` ボタンで新しいグループを追加
6. ID: `group.com.activitymonitor.app` を入力
7. チェックマークを入れる

### Widget Extension (ActivityMonitorWidgetExtension)
1. TARGETS → `ActivityMonitorWidgetExtension` を選択
2. `Signing & Capabilities` タブを開く
3. `+ Capability` ボタンをクリック
4. `App Groups` を選択
5. `+` ボタンで新しいグループを追加
6. ID: `group.com.activitymonitor.app` を入力（**同じID**）
7. チェックマークを入れる

**重要**: 両方のターゲットで全く同じ App Group ID を使用してください。

## 完了後の確認

すべての設定が完了したら：

1. ✅ ビルドエラーがない
2. ✅ アプリが起動する
3. ✅ ホーム画面にウィジェットを追加できる
4. ✅ ウィジェットにメトリクスが表示される
5. ✅ Live Activity ボタンをタップすると Dynamic Island に表示される

---

**質問やエラーがある場合は、エラーメッセージの全文をコピーして共有してください。**
