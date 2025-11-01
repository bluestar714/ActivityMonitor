# Activity Monitor iOS 16+ セットアップガイド

このガイドでは、iOS 16の最新機能を活用したActivity MonitorアプリをXcodeでセットアップ・ビルドする手順を詳しく説明します。

## クイックスタート

すぐに始めたい場合は、以下の手順に従ってください：

1. Xcodeを開く（14.0以降）
2. File → New → Project
3. 「iOS」→「App」を選択
4. Product Name: `ActivityMonitor`
5. Interface: SwiftUI、Language: Swift
6. デフォルトファイルを提供されたソースコードに置き換え
7. ブリッジングヘッダーを設定（下記参照）
8. **iOS Deployment Targetを16.0に設定**
9. ビルド＆実行！

## 詳細セットアップ手順

### ステップ1: 新しいXcodeプロジェクトを作成

1. Xcode（バージョン14.0以降）を開く
2. **File → New → Project** (⇧⌘N) を選択
3. テンプレート選択画面で:
   - **iOS** プラットフォームタブを選択
   - **App** テンプレートを選択
   - **Next** をクリック

4. プロジェクトを設定:
   ```
   Product Name: ActivityMonitor
   Team: [あなたのチーム]
   Organization Identifier: com.yourcompany
   Bundle Identifier: com.yourcompany.ActivityMonitor
   Interface: SwiftUI
   Language: Swift
   Storage: None
   ```
5. **Next** をクリックして保存場所を選択
6. **Create** をクリック

### ステップ2: iOS 16.0をターゲットに設定

**重要**: このアプリはiOS 16.0以降が必要です。

1. プロジェクトナビゲーターでプロジェクトを選択
2. **ActivityMonitor** ターゲットを選択
3. **General** タブへ移動
4. **Minimum Deployments** を **iOS 16.0** に設定

### ステップ3: ソースファイルを追加

1. **デフォルトファイルを削除**:
   - Xcodeから `ContentView.swift` を削除（置き換えます）
   - `ActivityMonitorApp.swift` は保持（置き換えます）

2. **プロジェクトフォルダを追加**:
   - Finderで `ActivityMonitor` ソースフォルダを見つける
   - 以下のフォルダをXcodeナビゲーターにドラッグ:
     - `Models/`
     - `Services/`
     - `Views/`
     - `Utils/`

3. **ダイアログが表示されたら**:
   - ✅ 「Copy items if needed」をチェック
   - ✅ 「Create groups」を選択
   - ✅ Add to targets: ActivityMonitor
   - **Finish** をクリック

4. **メインアプリファイルを置き換え**:
   - 提供された `ActivityMonitorApp.swift` を開く
   - 内容をコピー
   - プロジェクトの `ActivityMonitorApp.swift` の内容を置き換え

### ステップ4: ブリッジングヘッダーを設定

アプリはC APIを使用するため、ブリッジングヘッダーが必要です。

1. **ブリッジングヘッダーファイルを追加**:
   - Xcodeでプロジェクトルートを選択
   - 右クリック → **New File** (⌘N)
   - **Header File** を選択
   - 名前: `ActivityMonitor-Bridging-Header.h`
   - 提供されたブリッジングヘッダーコードで内容を置き換え

2. **Build Settingsを設定**:
   - プロジェクトを選択
   - **ActivityMonitor** ターゲットを選択
   - **Build Settings** タブへ移動
   - 「bridging」で検索
   - **Objective-C Bridging Header** を見つける
   - 値を設定: `ActivityMonitor/ActivityMonitor-Bridging-Header.h`

### ステップ5: Info.plistを置き換え

1. ナビゲーターで `Info.plist` を見つける
2. 削除するか、提供された `Info.plist` で内容を置き換え
3. 提供されたInfo.plistには以下が含まれます:
   - バックグラウンドモード設定
   - プライバシーAPI使用宣言
   - 起動画面設定
   - サポートされる向き

### ステップ6: Assetsを設定

1. **App Iconを追加**（オプション）:
   - ナビゲーターで `Assets.xcassets` を見つける
   - 提供された `AppIcon.appiconset` がすでに設定されている
   - 必要に応じて独自のアイコン画像を追加（サイズ: 20pt-1024pt）

### ステップ7: デプロイメント設定を確認

1. ナビゲーターでプロジェクトを選択
2. **ActivityMonitor** ターゲットを選択
3. **General** タブへ移動
4. 以下を設定:
   ```
   Minimum Deployment: iOS 16.0
   Devices: iPhone（またはUniversal）
   Orientation: Portrait、Landscape Left、Landscape Right
   ```

5. **Signing & Capabilities** へ移動:
   - チームを選択
   - Xcodeが自動的に署名を管理

### ステップ8: ビルドと実行

1. **ターゲットを選択**:
   - クイックテスト: iOSシミュレータ（iPhone 14以降）
   - 完全機能: 接続されたiOSデバイス

2. **プロジェクトをビルド**:
   - ⌘B または **Product → Build**
   - ビルドエラーを修正（通常はファイルパスまたはブリッジングヘッダー関連）

3. **アプリを実行**:
   - ⌘R または **Product → Run**
   - シミュレータまたはデバイスでアプリが起動

### ステップ9: 機能を確認

初回起動時に確認:
- ✅ メトリクスがリアルタイムで更新される
- ✅ Swift Chartsが美しく表示される
- ✅ iOS 16のマテリアルエフェクトが機能している
- ✅ 設定画面にアクセスできる
- ✅ PiPモードが動作（PiPアイコンをタップ）
- ✅ ハプティクスフィードバックが感じられる

**注意**: 正確なメトリクス（特にネットワークとストレージ）のためには、実機でテストしてください。

## iOS 16特有の機能

### NavigationStack
従来の`NavigationView`の代わりに`NavigationStack`を使用しています。これによりナビゲーションがよりスムーズで予測可能になります。

### Swift Charts
iOS 16のネイティブチャートフレームワークを使用しています。これにより:
- パフォーマンスが向上
- アニメーションが滑らか
- アクセシビリティが向上
- Appleのデザイン言語に準拠

### Materials
`ultraThinMaterial`と`regularMaterial`を使用し、iOS 16らしい洗練されたビジュアルを実現。

### Presentation Detents
設定画面で`.presentationDetents([.medium, .large])`を使用し、ハーフモーダルをサポート。

### Symbol Rendering
`.symbolRenderingMode(.hierarchical)`でSF Symbolsに深みを追加。

### Content Transitions
`.contentTransition(.numericText())`で数値変化を滑らかにアニメーション。

## 一般的な問題と解決策

### 問題: 「No such module 'ActivityMonitor'」

**解決策**: すべてのソースファイルがターゲットに追加されていることを確認:
1. 各Swiftファイルを選択
2. File Inspector (⌥⌘1) で「Target Membership」を確認
3. 「ActivityMonitor」がチェックされていることを確認

### 問題: 「Bridging header not found」

**解決策**:
1. Build Settingsのブリッジングヘッダーパスを確認
2. ファイルがそのパスに存在することを確認
3. 相対パス試行: `ActivityMonitor/ActivityMonitor-Bridging-Header.h`
4. または絶対パス: `$(SRCROOT)/ActivityMonitor/ActivityMonitor-Bridging-Header.h`

### 問題: C APIでビルドエラー

**解決策**:
1. ブリッジングヘッダーが正しく設定されていることを確認
2. ブリッジングヘッダーのすべてのインポートが正しいことを確認
3. ビルドフォルダをクリーン: ⇧⌘K、その後再ビルド

### 問題: Swift Chartsが利用できない

**解決策**:
1. iOS Deployment Targetが16.0以降であることを確認
2. Xcode 14.0以降を使用していることを確認
3. ファイルの先頭に`import Charts`があることを確認
4. `@available(iOS 16.0, *)`アノテーションが付いていることを確認

### 問題: メトリクスが更新されない

**解決策**:
1. `MetricsManager.startMonitoring()`がonAppearで呼ばれていることを確認
2. 設定でリフレッシュ間隔を確認
3. 実機でテスト（シミュレータには制限がある）

### 問題: 起動時にアプリがクラッシュ

**解決策**:
1. コンソールでエラーメッセージを確認
2. すべての@Publishedプロパティが初期化されていることを確認
3. SettingsとMetricsManagerが正しくインスタンス化されていることを確認
4. すべてのViewファイルが正しくインポートされていることを確認

## プロジェクト構造の確認

最終的なプロジェクト構造は以下のようになるはずです:

```
ActivityMonitor/
├── ActivityMonitor/
│   ├── ActivityMonitorApp.swift
│   ├── ActivityMonitor-Bridging-Header.h
│   ├── Info.plist
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── Models/
│   │   ├── MetricsData.swift
│   │   └── Settings.swift
│   ├── Services/
│   │   ├── SystemMetricsCollector.swift
│   │   └── MetricsManager.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── DashboardView.swift
│   │   ├── SettingsView.swift
│   │   ├── ModernLineChartView.swift
│   │   ├── ModernMetricCardView.swift
│   │   ├── LineChartView.swift (後方互換用)
│   │   ├── MetricCardView.swift (後方互換用)
│   │   └── PiPView.swift
│   └── Utils/
│       └── FormatHelpers.swift
├── ActivityMonitor.xcodeproj
├── README.md
├── SETUP_GUIDE.md
└── .gitignore
```

## テストチェックリスト

- [ ] アプリがエラーなしでビルドされる
- [ ] アプリが正常に起動する
- [ ] iOS 16のデザイン要素が表示される（マテリアル、グラデーション等）
- [ ] CPUメトリクスが表示・更新される
- [ ] メモリメトリクスが表示・更新される
- [ ] ネットワークメトリクスが表示される（実機でテスト）
- [ ] ストレージメトリクスが表示される
- [ ] Swift Chartsが美しくレンダリングされる
- [ ] 設定画面が開く
- [ ] メトリクスのオン/オフ切り替えができる
- [ ] リフレッシュ間隔を変更できる
- [ ] PiPモードが起動する
- [ ] PiPオーバーレイがドラッグ可能
- [ ] チャートがスムーズにレンダリングされる
- [ ] ハプティクスフィードバックが動作する
- [ ] アニメーションが滑らか
- [ ] メモリリークがない（Instrumentsでテスト）

## パフォーマンステスト

アプリのリソース効率を確認するには:

1. **Instrumentsを開く**:
   - Xcode → Open Developer Tool → Instruments
   - 「Activity Monitor」テンプレートを選択
   - アプリを実行

2. **メトリクスを監視**:
   - アイドル時のCPU使用率は5%未満であるべき
   - メモリは50MB未満であるべき
   - 更新中に大きなCPUスパイクがないこと

3. **バッテリー影響をテスト**:
   - アプリを30分間実行
   - 設定 → バッテリーでバッテリー使用状況を確認
   - 最小限の影響であるべき

## 次のステップ

セットアップが成功した後:

1. **UIをカスタマイズ**: Views/で色、フォント、レイアウトを変更
2. **メトリクスを追加**: SystemMetricsCollectorに追加データを拡張
3. **チャートを改善**: ズーム、パン、異なるチャートタイプを追加
4. **ウィジェット追加**: WidgetKitでホーム画面ウィジェットを作成
5. **通知追加**: メトリクスがしきい値を超えたらユーザーに警告
6. **Live Activitiesを実装**: iOS 16のDynamic Islandを活用

## iOS 16デザインのベストプラクティス

1. **マテリアルを使用**: `.ultraThinMaterial`と`.regularMaterial`
2. **SF Pro Roundedフォント**: `.font(.system(size: X, weight: Y, design: .rounded))`
3. **階層的シンボル**: `.symbolRenderingMode(.hierarchical)`
4. **スプリングアニメーション**: `.animation(.spring(response:dampingFraction:))`
5. **ハプティクス**: すべてのインタラクションにフィードバックを追加
6. **グラデーション**: `.foregroundStyle(color.gradient)`を使用
7. **Continuous Corners**: `RoundedRectangle(cornerRadius: X, style: .continuous)`

## サポート

問題が発生した場合:
1. ビルドフォルダをクリーン（⇧⌘K）
2. SPMを使用している場合、パッケージキャッシュをリセット
3. Xcodeを再起動
4. 最小iOSバージョンを確認（16.0+）
5. Xcode 14.0以降を使用していることを確認

詳細については:
- AppleのSwiftUIドキュメント
- Xcodeヘルプリソース
- メインのREADME.mdファイル

---

**iOS 16の最新機能で素晴らしいアプリを作りましょう！** 🚀✨
