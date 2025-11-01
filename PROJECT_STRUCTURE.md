# プロジェクト構造

## 📂 完全なディレクトリ構造

```
ActivityMonitor/
├── ActivityMonitor.xcodeproj/              ← Xcodeプロジェクトファイル ⭐️
│   ├── project.pbxproj                      # プロジェクト設定
│   ├── project.xcworkspace/
│   │   └── contents.xcworkspacedata
│   └── xcshareddata/
│       └── xcschemes/
│           └── ActivityMonitor.xcscheme     # ビルドスキーム
│
├── ActivityMonitor/                         # ソースコード
│   ├── ActivityMonitorApp.swift            # アプリエントリーポイント
│   ├── ActivityMonitor-Bridging-Header.h   # C APIブリッジング
│   ├── Info.plist                          # アプリ設定
│   │
│   ├── Models/
│   │   ├── MetricsData.swift               # データモデル
│   │   └── Settings.swift                  # @Observable設定
│   │
│   ├── Services/
│   │   ├── SystemMetricsCollector.swift    # 低レベルメトリクス収集
│   │   └── MetricsManager.swift            # @Observableマネージャー
│   │
│   ├── Views/
│   │   ├── ContentView.swift               # メインナビゲーション
│   │   ├── DashboardView.swift             # ダッシュボード
│   │   ├── SettingsView.swift              # 設定画面
│   │   ├── PiPView.swift                   # ピクチャーインピクチャー
│   │   ├── ModernLineChartView.swift       # iOS 17チャート
│   │   ├── ModernMetricCardView.swift      # iOS 17カード
│   │   ├── LineChartView.swift             # 後方互換チャート
│   │   └── MetricCardView.swift            # 後方互換カード
│   │
│   ├── Utils/
│   │   └── FormatHelpers.swift             # フォーマッター
│   │
│   └── Assets.xcassets/                    # アセット
│       ├── AppIcon.appiconset/
│       │   └── Contents.json
│       └── Contents.json
│
├── README.md                                # メインドキュメント
├── SETUP_GUIDE.md                          # 詳細セットアップ
├── QUICK_START.md                          # クイックスタート ⭐️
├── PROJECT_STRUCTURE.md                    # このファイル
└── .gitignore                              # Git設定
```

## 🎯 重要なファイル

### すぐに使える！

**ActivityMonitor.xcodeproj** 📦
- ダブルクリックするだけでXcodeで開けます
- すべての設定が完了済み
- ビルドしてすぐに実行可能

### プロジェクト設定

**project.pbxproj**
- すべてのソースファイルが登録済み
- ビルド設定が完了
- iOS 17.0デプロイメントターゲット設定済み
- ブリッジングヘッダー設定済み

**ActivityMonitor.xcscheme**
- ビルドスキームが設定済み
- デバッグ/リリース構成完了

## 🔧 プロジェクト設定内容

### ビルド設定

```
iOS Deployment Target:      17.0
Swift Version:              5.0
Bundle Identifier:          com.activitymonitor.app
Version:                    1.0.0
Build Number:               100
Bridging Header:            ActivityMonitor/ActivityMonitor-Bridging-Header.h
```

### 有効な機能

✅ SwiftUI
✅ Swift Charts
✅ @Observable マクロ
✅ Sensory Feedback
✅ Symbol Effects
✅ バックグラウンドモード
✅ プライバシーAPI宣言

### ターゲットデバイス

- iPhone（ポートレート、ランドスケープ）
- iPad（全方向）

## 📝 ファイル数

- Swift ファイル: 14
- ヘッダーファイル: 1
- 設定ファイル: 1 (Info.plist)
- アセット: 1 (Assets.xcassets)
- ドキュメント: 4 (README, SETUP_GUIDE, QUICK_START, PROJECT_STRUCTURE)

## 🚀 使用方法

### 1. Xcodeで開く

```bash
open ActivityMonitor.xcodeproj
```

### 2. チームを設定

Signing & Capabilities → Team → 自分のApple IDを選択

### 3. 実行

⌘R を押す

**それだけです！**

## 🎨 iOS 17 の機能

このプロジェクトは以下のiOS 17機能を使用：

- @Observable マクロ
- @Environment 値
- Sensory Feedback API
- Symbol Effects (.bounce, .pulse)
- Multicolor Symbols
- Enhanced Swift Charts
- Presentation Enhancements
- #Preview マクロ
- @Bindable
- async/await 最適化

## 📖 ドキュメント

1. **QUICK_START.md** - 30秒で始める方法
2. **README.md** - 完全な機能説明とAPI解説
3. **SETUP_GUIDE.md** - 詳細なセットアップ手順
4. **PROJECT_STRUCTURE.md** - このファイル（プロジェクト構造）

## ✅ チェックリスト

すでに完了している項目：

- [x] Xcodeプロジェクトファイル作成
- [x] すべてのソースファイル登録
- [x] ビルド設定完了
- [x] ブリッジングヘッダー設定
- [x] Info.plist設定
- [x] Assets設定
- [x] スキーム設定
- [x] iOS 17.0ターゲット設定
- [x] ドキュメント完備

## 💡 次のステップ

1. Xcodeで開く
2. チームを設定
3. 実行
4. 楽しむ！ 🎉

---

**すべて設定済み！すぐに使えます！** ✨
