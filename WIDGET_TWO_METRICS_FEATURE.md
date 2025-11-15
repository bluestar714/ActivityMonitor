# Widget 2項目表示機能の実装

## 概要

ホーム画面Widgetの表示項目を2つまでに制限し、ユーザーが表示する項目を選択できるようになりました。

---

## ✨ 新機能

### 1. Widget表示項目の選択

ユーザーは設定画面から、Widgetに表示する2つのメトリクスを選択できます：

- **CPU** (デフォルト)
- **Memory** (デフォルト)
- **Network**
- **Storage**

### 2. 統一されたレイアウト

すべてのWidgetサイズで2項目のみを表示：

- **小サイズ**: コンパクトな2行表示
- **中サイズ**: 左右分割の大きな数値表示
- **大サイズ**: 詳細情報付きの2セクション表示

### 3. リアルタイム更新

設定を変更すると、すべてのWidgetが自動的に更新されます。

---

## 🎨 Widget デザイン

### Small Widget (小サイズ)

```
┌─────────────────┐
│ Activity Monitor│
│                 │
│ CPU         45% │
│ Memory      62% │
│                 │
│ 10:30          │
└─────────────────┘
```

### Medium Widget (中サイズ)

```
┌───────────────────────────────────┐
│                                   │
│  CPU               Memory        │
│                                   │
│                                   │
│  45%               62%            │
│                                   │
│  User+System      3.5/6.0 GB    │
│                                   │
│  10:30            10:30          │
└───────────────────────────────────┘
```

### Large Widget (大サイズ)

```
┌───────────────────────────────────┐
│ Activity Monitor         10:30   │
├───────────────────────────────────┤
│ CPU                           45% │
│ User: 30%  System: 15%  Idle: 55%│
├───────────────────────────────────┤
│ Memory                        62% │
│ Used: 3.5 GB  Free: 2.5 GB       │
│                                   │
└───────────────────────────────────┘
```

---

## 🔧 実装の詳細

### 変更されたファイル

#### 1. Settings.swift

Widget表示項目の設定を追加：

```swift
struct AppSettings: Codable {
    var widgetMetric1: MetricType // First metric
    var widgetMetric2: MetricType // Second metric
}
```

**デフォルト値**:
- `widgetMetric1`: `.cpu`
- `widgetMetric2`: `.memory`

**自動保存機能**:
- 設定が変更されるたびにApp Groupsに保存
- Widget Centerに更新を通知

#### 2. SharedDataManager.swift

Widget設定の共有機能を追加：

```swift
// 設定を保存
func saveWidgetSettings(metric1: MetricType, metric2: MetricType)

// 設定を読み込み
func loadWidgetSettings() -> (MetricType, MetricType)
```

**特徴**:
- App Groups (`group.com.activitymonitor.app`) を使用
- デバッグログ付き
- デフォルト値のフォールバック

#### 3. ActivityMonitorWidget.swift

Widget Viewを2項目表示に完全リニューアル：

**新しいView構造**:

```swift
// 小サイズ
CompactTwoMetricsView(metrics, metric1, metric2, date)

// 中サイズ
MediumTwoMetricsView(metrics, metric1, metric2, date)

// 大サイズ
LargeTwoMetricsView(metrics, metric1, metric2, date)
```

**共通機能**:
- 動的にメトリクスタイプを受け取る
- タイプに応じて値と色を自動選択
- すべてのメトリクスタイプに対応

#### 4. SettingsView.swift

Widget Display セクションを追加：

```swift
Section("Widget Display") {
    Picker("First Metric", selection: $settings.widgetMetric1) {
        // CPU, Memory, Network, Storage
    }

    Picker("Second Metric", selection: $settings.widgetMetric2) {
        // CPU, Memory, Network, Storage
    }
}
```

**UI特徴**:
- メニューピッカースタイル
- アイコン付きラベル
- 触覚フィードバック
- 変更時に即座にWidget更新

---

## 📊 メトリクスタイプ別の表示

### CPU
- **値**: User + System の合計
- **サブタイトル**: "User+System"
- **詳細** (大サイズ): User, System, Idle の内訳
- **色**: 青

### Memory
- **値**: 使用率 (%)
- **サブタイトル**: "X.X/X.X GB"
- **詳細** (大サイズ): Used, Free, Total
- **色**: 緑

### Network
- **値**: ダウンロード速度
- **サブタイトル**: "MB/s" または "KB/s"
- **詳細** (大サイズ): Download, Upload
- **色**: 紫

### Storage
- **値**: 空き容量 (GB)
- **サブタイトル**: "GB free"
- **詳細** (大サイズ): Used, Free, 使用率
- **色**: オレンジ

---

## 🔄 データフロー

```
メインアプリ
  ↓
  1. ユーザーが設定画面でメトリクスを選択
  ↓
  2. SettingsManager.settings.widgetMetric1/2 が更新
  ↓
  3. SharedDataManager が App Groups に保存
  ↓
  4. WidgetCenter.shared.reloadAllTimelines()
  ↓
Widget Extension
  ↓
  5. SharedDataManager.loadWidgetSettings()
  ↓
  6. 選択されたメトリクスに基づいて表示
```

---

## 🎯 使用方法

### 設定手順

1. **アプリを開く**
2. **設定アイコン (⚙️) をタップ**
3. **"Widget Display" セクションまでスクロール**
4. **"First Metric" を選択** (例: CPU)
5. **"Second Metric" を選択** (例: Memory)
6. **設定を閉じる**

→ ホーム画面のWidgetが自動的に更新されます！

### Widget追加手順

1. **ホーム画面を長押し**
2. **左上の "+" ボタンをタップ**
3. **"Activity Monitor" を検索**
4. **サイズを選択**（小・中・大）
5. **"ウィジェットを追加" をタップ**

---

## 🔍 デバッグ

### コンソールログ

設定保存時：
```
✅ [SharedDataManager] Saved widget settings - Metric 1: CPU, Metric 2: Memory
```

設定読み込み時：
```
✅ [SharedDataManager] Loaded widget settings - Metric 1: CPU, Metric 2: Memory
```

### 確認ポイント

- [ ] 設定画面に "Widget Display" セクションがある
- [ ] First Metric と Second Metric が選択できる
- [ ] 設定を変更するとWidgetが即座に更新される
- [ ] 選択したメトリクスがWidgetに表示される
- [ ] すべてのサイズで2項目のみ表示される
- [ ] コンソールに保存/読み込みログが表示される

---

## 💡 設定例

### デフォルト設定 (推奨)
- **First Metric**: CPU
- **Second Metric**: Memory
- **理由**: 最も重要な2つのメトリクス

### ネットワーク重視
- **First Metric**: Network
- **Second Metric**: Storage
- **理由**: ダウンロード/アップロードを監視

### バランス型
- **First Metric**: CPU
- **Second Metric**: Network
- **理由**: パフォーマンスとネットワークの両方

### ストレージ重視
- **First Metric**: Storage
- **Second Metric**: Memory
- **理由**: 容量管理が重要な場合

---

## ⚙️ 技術的な詳細

### App Groups の重要性

Widget設定は **App Groups** を通じて共有されます：

```
group.com.activitymonitor.app
  ├── widgetMetric1 (String)
  └── widgetMetric2 (String)
```

両方のターゲットで同じApp Group IDを設定する必要があります：
- ✅ ActivityMonitor
- ✅ ActivityMonitorWidgetExtension

### 自動更新の仕組み

1. **設定変更時**: `WidgetCenter.shared.reloadAllTimelines()`
2. **メトリクス更新時**: `WidgetCenter.shared.reloadAllTimelines()`
3. **Widget側**: 1分ごとに自動更新

### メトリクスタイプの拡張性

新しいメトリクスタイプを追加する場合：

1. `MetricType` enum に追加
2. `valueString(for:)` に表示ロジック追加
3. `subtitleString(for:)` にサブタイトル追加
4. `detailStrings(for:)` に詳細情報追加
5. `colorFor(_:)` に色を追加

---

## 🐛 トラブルシューティング

### Widget に設定が反映されない

**原因**: App Groups が正しく設定されていない

**解決方法**:
1. 両方のターゲットの Signing & Capabilities を確認
2. App Groups が追加されているか確認
3. 同じGroup ID (`group.com.activitymonitor.app`) を使用しているか確認

### Widget が古いレイアウトを表示

**原因**: Widget のキャッシュが残っている

**解決方法**:
1. Widgetを削除
2. アプリを再インストール
3. Widgetを再度追加

### デフォルト値が表示される

**原因**: 設定がまだ保存されていない

**解決方法**:
1. アプリを起動
2. 設定画面を開く
3. Widget Display の設定を確認
4. 必要に応じて変更

---

## 📝 まとめ

### 実装した機能

✅ Widget表示項目を2つに制限
✅ ユーザーが表示項目を選択可能
✅ すべてのサイズで統一された2項目表示
✅ 設定の自動保存と共有
✅ リアルタイムWidget更新
✅ 4種類のメトリクスタイプ対応
✅ サイズごとに最適化されたレイアウト
✅ デバッグログ付き

### 次のステップ

1. **ビルド**: `⌘+B`
2. **実行**: `⌘+R`
3. **設定画面を開く**: "Widget Display" で設定
4. **Widgetを追加**: ホーム画面で確認
5. **設定を変更**: リアルタイム更新を確認

---

**これで、ユーザーが自由にWidget表示をカスタマイズできるようになりました！** 🎉
