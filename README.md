# Activity Monitor for iOS

**iOS 17+対応 - 最新技術を活用** システムパフォーマンスをリアルタイムで監視するネイティブiOSアプリケーション。Mac版アクティビティモニタと同様の機能をiPhoneで実現します。

## ✨ 主要機能

### 📊 リアルタイム・パフォーマンス監視
- **CPU使用率** - ユーザー、システム、アイドル時間の詳細表示
- **メモリ使用率** - 使用中、空き、アクティブ、圧縮済みメモリの分析
- **ネットワーク速度** - ダウンロード/アップロード速度のリアルタイム表示
- **ストレージ情報** - 使用容量と空き容量の可視化

### 📈 iOS 17 Swift Chartsによる美しい可視化
- ネイティブSwift Chartsフレームワークによる滑らかなアニメーション
- チャートに影とグラデーションを追加した最新ビジュアル
- リアルタイムラインチャートとグラデーション塗りつぶし
- 履歴データ追跡（設定可能な期間）
- メトリック別のカラーコーディング

### ⚙️ カスタマイズ可能な設定
- 個別メトリックの有効/無効切り替え
- リフレッシュレート調整（0.5秒〜5秒）
- チャート履歴の長さ設定
- バッテリー効率に最適化

### 🎨 iOS 17モダンデザイン
- **@Observable マクロ** - 最新のObservation framework
- **Sensory Feedback** - すべてのインタラクションで感覚フィードバック
- **Symbol Effects** - アニメーションするSF Symbols（.bounce, .pulse）
- **Enhanced Materials** - より洗練されたぼかし効果
- **Multicolor Symbols** - フルカラーのSF Symbols
- **Ultra Thin Material** - 背景の美しいぼかし効果
- **SF Symbols 6** - 最新のシンボルセット
- **SF Pro Rounded** - システムフォント
- **Enhanced Gradients** - より鮮やかなグラデーション
- **Advanced Spring Animations** - より自然な物理ベースアニメーション
- **#Preview マクロ** - 新しいプレビュー構文

### 🔒 iOSサンドボックス準拠
- 標準iOS APIのみを使用
- ジェイルブレイク不要
- プライバシーとセキュリティガイドライン遵守

## 🎯 iOS 17の新機能を活用

### @Observable マクロ
ObservableObjectから@Observableマクロに移行し、よりシンプルで効率的な状態管理を実現。

```swift
@Observable
@MainActor
class MetricsManager {
    var currentMetrics: MetricsSnapshot = .zero
    // ...
}
```

### Environment Values
@EnvironmentObjectから新しい@Environmentパターンへ移行。

```swift
@Environment(MetricsManager.self) private var metricsManager
```

### Sensory Feedback
すべてのインタラクションで触覚フィードバックを提供。

```swift
.sensoryFeedback(.selection, trigger: showingSettings)
.sensoryFeedback(.impact(weight: .medium), trigger: isDragging)
```

### Symbol Effects
アニメーションするSF Symbolsで生き生きとしたUI。

```swift
.symbolEffect(.bounce, value: animateGradient)
.symbolEffect(.pulse)
```

### Swift Charts Enhanced
iOS 17でさらに洗練されたチャート描画。

```swift
.lineStyle(.init(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
.shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
```

### Presentation Enhancements
より細かい制御が可能なプレゼンテーション。

```swift
.presentationCornerRadius(24)
.presentationBackground(.ultraThinMaterial)
```

### #Preview Macro
新しいプレビュー構文でより簡潔なコード。

```swift
#Preview {
    ContentView()
        .environment(MetricsManager.shared)
}
```

## 🛠 技術実装

### システムメトリクス収集

iOSサンドボックス制約内で低レベルC APIを使用：

- **CPUメトリクス**: `host_processor_info()`, `PROCESSOR_CPU_LOAD_INFO`
- **メモリメトリクス**: `host_statistics64()`, `HOST_VM_INFO64`, `vm_statistics64`
- **ネットワークメトリクス**: `getifaddrs()`, `if_data`構造体
- **ストレージメトリクス**: `FileManager`属性と`NSHomeDirectory()`

### アーキテクチャ

```
ActivityMonitor/
├── Models/
│   ├── MetricsData.swift           # メトリクスデータ構造
│   └── Settings.swift              # @Observable設定管理
├── Services/
│   ├── SystemMetricsCollector.swift # 低レベルメトリクス収集
│   └── MetricsManager.swift         # @Observable マネージャー
├── Views/
│   ├── ModernLineChartView.swift   # Swift Charts実装
│   ├── ModernMetricCardView.swift  # iOS 17デザインカード
│   ├── DashboardView.swift         # メインダッシュボード
│   ├── SettingsView.swift          # 設定画面
│   └── ContentView.swift           # メインナビゲーション
├── Utils/
│   └── FormatHelpers.swift         # フォーマットユーティリティ
└── ActivityMonitorApp.swift        # アプリエントリーポイント
```

## 📋 セットアップ手順

### 必要要件

- macOS 14.0以降を搭載したMac
- Xcode 15.0以降
- **iOS 17.0以降** のデプロイメントターゲット
- Apple Developer アカウント（実機テスト用）

### Xcodeプロジェクトの作成

1. **Xcodeを開く** - 新しいiOSアプリプロジェクトを作成：
   - File → New → Project
   - 「iOS」→「App」を選択
   - Product Name: `ActivityMonitor`
   - Interface: SwiftUI
   - Language: Swift
   - 「Next」をクリックして場所を選択

2. **ソースファイルをプロジェクトに追加**：
   - `ActivityMonitor`フォルダをXcodeプロジェクトナビゲーターにドラッグ
   - 「Copy items if needed」をチェック
   - グループを作成（フォルダ参照ではない）
   - ターゲットに追加: ActivityMonitor

3. **ブリッジングヘッダーを設定**：
   - Build Settingsで「Objective-C Bridging Header」を見つける
   - 値を設定: `ActivityMonitor/ActivityMonitor-Bridging-Header.h`

4. **デプロイメントターゲットを設定**：
   - プロジェクト設定で、iOS Deployment Targetを **19.0以降** に設定

### ビルドと実行

1. シミュレータまたは接続されたiOSデバイスを選択
2. プロジェクトをビルド（⌘+B）
3. アプリを実行（⌘+R）

**注意**: 一部のメトリクス（特にネットワークとストレージ）はシミュレータでは限定的なデータしか表示されません。完全な機能を確認するには、実機でテストしてください。

## 使用方法

### メインダッシュボード

メイン画面では、有効化されたすべてのメトリクスがリアルタイムチャートと共に表示されます：
- **歯車アイコン** (⚙️) をタップして設定にアクセス
- **Live Activityボタン** (iOS 16.1+) をタップしてDynamic Islandで表示
- **下にプルしてリフレッシュ** - 手動でメトリクスを更新
- **Sensory Feedback** - すべての操作で触覚フィードバックを体験

### 設定

監視体験をカスタマイズ：
- 個別メトリクスのオン/オフ切り替え（アニメーション付き）
- リフレッシュレート調整（低い値 = より頻繁な更新）
- チャート履歴期間の変更
- 蓄積されたデータのクリア

### Live Activities（バックグラウンド表示）

1. ナビゲーションバーの **Live Activity** ボタン（紫色）をタップ
2. Dynamic Island（iPhone 14 Pro以降）またはLock Screenに表示
3. アプリをバックグラウンドに移動しても継続表示
4. リアルタイムでメトリクスが更新される
5. もう一度ボタンをタップして停止

## ⚡️ パフォーマンス最適化

最小限のリソース使用のために設計：

- **@Observable マクロ**: より効率的な状態管理
- **async/await**: 非同期処理の最適化
- **Task.detached**: バックグラウンドでのメトリクス収集
- **効率的なデータ構造**: 循環バッファでメモリ使用を制限
- **設定可能なリフレッシュレート**: ニーズに基づいて更新頻度を調整
- **選択的監視**: 未使用メトリクスを無効化してCPUサイクルを節約
- **最適化されたレンダリング**: Swift Chartsネイティブフレームワーク

## 🔐 プライバシーと制限事項

### アプリが監視できること

- **デバイス全体のCPU使用率**: すべてのプロセス全体の合計CPU負荷
- **デバイスメモリ**: システムメモリ統計の合計
- **ネットワークインターフェース**: すべてのネットワークトラフィック（アプリ別ではない）
- **システムストレージ**: デバイスストレージ使用量の合計

### iOSサンドボックスの制限

iOSサンドボックスのため、アプリは以下を実行できません：
- 個別アプリのCPU/メモリ使用量の監視
- プロセスリストや名前へのアクセス
- 詳細なアプリ別ネットワーク使用量の表示
- システム設定や他のアプリの変更

これは意図的なもので、Appleのセキュリティモデルに従っています。

## 🎨 iOS 17デザインの特徴

- **@Observable Macro**: 最新の状態管理パターン
- **Sensory Feedback**: すべてのインタラクションで触覚フィードバック
- **Symbol Effects**: .bounce、.pulseなどのアニメーション効果
- **Multicolor Symbols**: フルカラーのSF Symbols
- **Ultra Thin Material**: より洗練された背景のぼかし効果
- **Continuous Corner Radius**: より滑らかな角丸
- **Enhanced Gradients**: より鮮やかで深みのあるグラデーション
- **Advanced Spring Animations**: 物理ベースのスムーズなアニメーション
- **Interactive Spring**: ドラッグ操作時の自然な動き
- **#Preview Macro**: 新しいプレビュー構文

## 必要要件

- **iOS 17.0以降**
- Xcode 15.0以降
- Swift 5.9以降

## ライセンス

このプロジェクトは教育および個人使用を目的として提供されています。

## 謝辞

- SwiftUIで構築
- 標準iOSフレームワーク使用: Foundation, UIKit, Observation, Charts
- システムAPI: Mach, sysctl, BSDソケット

## コントリビューション

問題の報告、リポジトリのフォーク、改善のためのプルリクエストを歓迎します。

## サポート

問題や質問がある場合：
1. iOS 17.0以降を使用していることを確認
2. 正確なメトリクスのために実機でテストしていることを確認
3. Xcode 15.0以降を使用していることを確認

---

**注意**: このアプリは自分のデバイスの監視用です。他のデバイスからデータを収集したり、iOSプライバシーポリシーに違反することはできません。

---

**iOS 17の最新技術でシステムパフォーマンスを監視しましょう！** 📊✨🚀
