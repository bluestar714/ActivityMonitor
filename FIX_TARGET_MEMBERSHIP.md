# Target Membership 修正手順

## 問題

以下のエラーが表示されています：
```
Cannot infer contextual base in reference to member 'cpu'
Cannot find 'NotificationManager' in scope
Cannot find 'LiveActivityManager' in scope
```

これは、**MetricsManager.swift が誤って Widget Extension ターゲットに追加されている**ために発生しています。

## 原因

Widget Extension ターゲットには、以下のファイルは**追加してはいけません**：
- ❌ MetricsManager.swift（メインアプリ専用）
- ❌ NotificationManager.swift（メインアプリ専用）
- ❌ LiveActivityManager.swift（メインアプリ専用）
- ❌ SystemMetricsCollector.swift（メインアプリ専用）
- ❌ Settings.swift（メインアプリ専用）

Widget Extension に必要なのは**データモデルとデータ共有クラスのみ**です。

## 解決方法

### ステップ1: MetricsManager.swift の Target Membership を修正

1. **Xcode を開く**

2. **プロジェクトナビゲーターで MetricsManager.swift を選択**
   ```
   ActivityMonitor
   └── ActivityMonitor
       └── Services
           └── MetricsManager.swift  ← これを選択
   ```

3. **File Inspector を開く** (⌘+Option+1)

4. **Target Membership を確認**
   - 現在の状態（誤り）：
     ```
     ✅ ActivityMonitor
     ✅ ActivityMonitorWidgetExtension  ← このチェックを外す
     ```

5. **ActivityMonitorWidgetExtension のチェックを外す**
   - 正しい状態：
     ```
     ✅ ActivityMonitor
     ⬜ ActivityMonitorWidgetExtension  ← チェックを外した状態
     ```

### ステップ2: 他のメインアプリ専用ファイルも確認

以下のファイルも同様に、**ActivityMonitorWidgetExtension のチェックが外れている**ことを確認：

#### NotificationManager.swift
```
ActivityMonitor
└── ActivityMonitor
    └── Services
        └── NotificationManager.swift
```
Target Membership:
```
✅ ActivityMonitor
⬜ ActivityMonitorWidgetExtension  ← チェックを外す
```

#### LiveActivityManager.swift
```
ActivityMonitor
└── ActivityMonitor
    └── Services
        └── ActivityMonitorLiveActivity.swift
```
Target Membership:
```
✅ ActivityMonitor
⬜ ActivityMonitorWidgetExtension  ← チェックを外す
```

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
⬜ ActivityMonitorWidgetExtension  ← チェックを外す
```

#### Settings.swift
```
ActivityMonitor
└── ActivityMonitor
    └── Models
        └── Settings.swift
```
Target Membership:
```
✅ ActivityMonitor
⬜ ActivityMonitorWidgetExtension  ← チェックを外す
```

#### BackgroundTaskManager.swift
```
ActivityMonitor
└── ActivityMonitor
    └── Services
        └── BackgroundTaskManager.swift
```
Target Membership:
```
✅ ActivityMonitor
⬜ ActivityMonitorWidgetExtension  ← チェックを外す
```

### ステップ3: Widget Extension に必要なファイルのみチェック

以下の**2つのファイルのみ**が Widget Extension ターゲットに追加されている必要があります：

#### MetricsData.swift ✅
```
ActivityMonitor
└── ActivityMonitor
    └── Models
        └── MetricsData.swift
```
Target Membership:
```
✅ ActivityMonitor
✅ ActivityMonitorWidgetExtension  ← 両方にチェック
```

#### SharedDataManager.swift ✅
```
ActivityMonitor
└── ActivityMonitor
    └── Services
        └── SharedDataManager.swift
```
Target Membership:
```
✅ ActivityMonitor
✅ ActivityMonitorWidgetExtension  ← 両方にチェック
```

### ステップ4: クリーンビルド

1. **Clean Build Folder**
   - メニュー: `Product` → `Clean Build Folder`
   - または `⌘ + Shift + K`

2. **ビルド**
   - メニュー: `Product` → `Build`
   - または `⌘ + B`

## 正しい Target Membership 一覧表

| ファイル | ActivityMonitor | ActivityMonitorWidgetExtension |
|---------|-----------------|-------------------------------|
| MetricsData.swift | ✅ | ✅ |
| SharedDataManager.swift | ✅ | ✅ |
| Settings.swift | ✅ | ⬜ |
| MetricsManager.swift | ✅ | ⬜ |
| SystemMetricsCollector.swift | ✅ | ⬜ |
| NotificationManager.swift | ✅ | ⬜ |
| ActivityMonitorLiveActivity.swift | ✅ | ⬜ |
| BackgroundTaskManager.swift | ✅ | ⬜ |
| すべての View ファイル | ✅ | ⬜ |

## Widget Extension フォルダ内のファイル

Widget Extension フォルダ（ActivityMonitorWidget/）内のファイルは、**ActivityMonitorWidgetExtension ターゲットのみ**に所属します：

| ファイル | ActivityMonitor | ActivityMonitorWidgetExtension |
|---------|-----------------|-------------------------------|
| ActivityMonitorWidget.swift | ⬜ | ✅ |
| ActivityMonitorWidgetLiveActivity.swift | ⬜ | ✅ |
| ActivityMonitorWidgetBundle.swift | ⬜ | ✅ |

## なぜこうなるのか？

### Widget Extension の役割
- ホーム画面やロック画面にメトリクスを**表示するだけ**
- メインアプリが収集して保存したデータを**読み取るだけ**
- 独自にメトリクスを収集したり、通知を送ったりしない

### 必要なもの
- **データモデル**（MetricsData.swift）- メトリクスの構造を知るため
- **データ共有クラス**（SharedDataManager.swift）- App Groups からデータを読み取るため

### 不要なもの
- メトリクス収集ロジック（SystemMetricsCollector）
- 通知管理（NotificationManager）
- Live Activity 管理（LiveActivityManager）
- バックグラウンドタスク（BackgroundTaskManager）
- アプリの設定管理（SettingsManager）

## トラブルシューティング

### エラー: "Cannot find ... in scope"
→ そのファイルが Widget Extension ターゲットに誤って追加されています。Target Membership のチェックを外してください。

### エラー: "Cannot find type 'MetricsSnapshot' in scope" (Widget 側)
→ MetricsData.swift が Widget Extension ターゲットに追加されていません。Target Membership にチェックを入れてください。

### エラー: "Cannot find 'SharedDataManager' in scope" (Widget 側)
→ SharedDataManager.swift が Widget Extension ターゲットに追加されていません。Target Membership にチェックを入れてください。

## 完了後の確認

すべての設定が完了したら：

1. ✅ メインアプリがビルドできる
2. ✅ Widget Extension がビルドできる
3. ✅ 上記のエラーがすべて消えている
4. ✅ アプリを実行してメトリクスが表示される
5. ✅ ホーム画面にウィジェットを追加できる
6. ✅ ウィジェットにデータが表示される

---

**重要**: Widget Extension には**最小限のファイルのみ**を追加してください。多くのファイルを追加すると、依存関係の問題でビルドエラーが発生します。
