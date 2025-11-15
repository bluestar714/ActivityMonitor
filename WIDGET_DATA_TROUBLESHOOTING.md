# ウィジェットとアプリのデータ不一致のトラブルシューティング

## 問題

ウィジェットに表示される値とアプリを開いた時に表示される値が異なる。

## 実装した修正

### 1. デバッグログの追加 ✅

以下のファイルにデバッグログを追加しました：

- **SharedDataManager.swift** - データの保存・読み込み時にログ出力
- **ActivityMonitorWidget.swift** - Widgetがデータを読み込む時にログ出力

### 2. Widget のタイムライン更新を改善 ✅

- 以前：60個のエントリを作成して1時間後に更新
- 現在：1個のエントリを作成して1分後に更新（より頻繁に最新データを取得）

### 3. データ同期の強化 ✅

- `defaults.synchronize()` を追加してデータを確実に保存

## 診断手順

### ステップ1: App Groups の設定を確認

**最も重要な確認事項です。**

#### メインアプリの確認

1. Xcodeでプロジェクトを開く
2. TARGETS → `ActivityMonitor` を選択
3. `Signing & Capabilities` タブを開く
4. `App Groups` が追加されているか確認
5. `group.com.activitymonitor.app` にチェックが入っているか確認

#### Widget Extension の確認

1. TARGETS → `ActivityMonitorWidgetExtension` を選択
2. `Signing & Capabilities` タブを開く
3. `App Groups` が追加されているか確認
4. `group.com.activitymonitor.app` にチェックが入っているか確認（**メインアプリと同じID**）

#### 重要ポイント

✅ 両方のターゲットに App Groups が追加されている
✅ 両方のターゲットで**全く同じ** App Group ID が使用されている
✅ App Group ID にチェックマークが入っている

もし App Groups が正しく設定されていない場合：

```
メインアプリ：データを保存 → 自分専用のストレージに保存
Widget：データを読み込み → 自分専用のストレージから読み込み（空）
→ 結果：Widget はプレースホルダーデータを表示
```

### ステップ2: コンソールログを確認

1. **アプリを実行**
   - Xcode で Product → Run (⌘+R)

2. **コンソールを開く**
   - View → Debug Area → Activate Console (⌘+Shift+Y)

3. **ログを確認**

   メインアプリが起動すると、以下のようなログが表示されるはずです：

   ```
   ✅ [SharedDataManager] Saved metrics - CPU: 45%, Memory: 62%
   ```

   もしこのログが表示されず、代わりに以下が表示される場合：
   ```
   ❌ [SharedDataManager] UserDefaults for app group is nil!
   ```

   → **App Groups の設定が正しくありません**。ステップ1に戻ってください。

4. **ホーム画面に戻り、Widgetを追加**

   Widget が更新される時、以下のログが表示されるはずです：

   ```
   ✅ [SharedDataManager] Loaded metrics - CPU: 45%, Memory: 62%
   ✅ [Widget Timeline] Using real data - CPU: 45%, Memory: 62%
   ```

   もし以下のログが表示される場合：
   ```
   ⚠️ [SharedDataManager] No data found for currentMetrics
   ⚠️ [Widget Timeline] No data available, using placeholder
   ```

   → **データが共有されていません**。App Groups の設定を確認してください。

### ステップ3: データの年齢を確認

コンソールログに以下のようなメッセージが表示されます：

```
📅 [SharedDataManager] Data age: 5 seconds
```

もしデータの年齢が非常に古い（例：300秒以上）場合：
- メインアプリがバックグラウンドで動作していない
- メトリクス収集が停止している

### ステップ4: Widget を強制更新

1. **ホーム画面でWidgetを長押し**
2. **「ウィジェットを編集」を選択**
3. **完了をタップ**

これにより Widget のタイムラインが即座に更新されます。

コンソールで以下のログを確認：
```
✅ [Widget Timeline] Using real data - CPU: XX%, Memory: XX%
📅 [Widget Timeline] Next update scheduled at: ...
```

### ステップ5: 実機でテスト

シミュレータではなく、実機でテストしてください：

**シミュレータの制限：**
- App Groups が正しく動作しない場合がある
- バックグラウンド更新が制限される
- 一部のシステムメトリクスが正確でない

**実機でのテスト手順：**
1. 実機をMacに接続
2. Xcode でターゲットデバイスを実機に設定
3. アプリをビルド＆実行
4. ホーム画面でWidgetを追加
5. Xcodeのコンソールでログを確認

## よくある問題と解決方法

### 問題1: Widget が常にプレースホルダーデータを表示

**症状：**
- Widget に常に同じ値が表示される（CPU: 45%, Memory: 58%など）
- コンソールに `⚠️ [Widget Timeline] No data available, using placeholder` が表示

**原因：**
- App Groups が正しく設定されていない
- メインアプリとWidgetで異なる App Group ID を使用している

**解決方法：**
1. 両方のターゲットの `Signing & Capabilities` を確認
2. App Groups で同じID（`group.com.activitymonitor.app`）が使用されているか確認
3. Clean Build (⌘+Shift+K) → Build (⌘+B)
4. アプリを再インストール

### 問題2: Widget のデータが古い

**症状：**
- Widget のデータが更新されない
- メインアプリとは異なる古い値が表示される

**原因：**
- Widget のタイムライン更新が遅い
- メインアプリがバックグラウンドで実行されていない

**解決方法：**
1. Widget を長押し → 編集 → 完了（手動更新）
2. メインアプリを開いて、バックグラウンドに移動
3. Background App Refresh が有効になっているか確認
   - 設定 → 一般 → Appのバックグラウンド更新 → ActivityMonitor をオン

### 問題3: Widget に全くデータが表示されない

**症状：**
- Widget が空白または "No Data" を表示
- クラッシュする

**原因：**
- MetricsData.swift または SharedDataManager.swift が Widget Extension ターゲットに追加されていない

**解決方法：**
1. 両ファイルの Target Membership を確認
2. ActivityMonitorWidgetExtension にチェックが入っているか確認
3. Clean Build → Build

### 問題4: ビルドエラー "Cannot find ... in scope"

**症状：**
- Widget Extension のビルド時にエラー
- `Cannot find 'MetricsSnapshot' in scope`

**原因：**
- 必要なファイルが Widget Extension ターゲットに追加されていない

**解決方法：**
FIX_TARGET_MEMBERSHIP.md を参照

## 正常に動作している場合のログ例

### メインアプリの起動時

```
✅ [SharedDataManager] Saved metrics - CPU: 23%, Memory: 54%
✅ [SharedDataManager] Saved metrics - CPU: 25%, Memory: 55%
✅ [SharedDataManager] Saved metrics - CPU: 24%, Memory: 54%
（1秒ごとに繰り返し）
```

### Widget の更新時

```
✅ [SharedDataManager] Loaded metrics - CPU: 24%, Memory: 54%
📅 [SharedDataManager] Data age: 2 seconds
✅ [Widget Timeline] Using real data - CPU: 24%, Memory: 54%
📅 [Widget Timeline] Next update scheduled at: 2025-11-02 16:15:30 +0000
```

## デバッグコマンド

### App Groups のデータを確認（実機の場合）

実機でデバッグする場合、App Groups のデータは以下の場所に保存されます：

```
/var/mobile/Containers/Shared/AppGroup/<UUID>/Library/Preferences/group.com.activitymonitor.app.plist
```

Xcodeの Devices and Simulators ウィンドウからコンテナを確認できます。

### Widget を強制的に再読み込み

```swift
// デバッグコードとして一時的に追加
import WidgetKit

// アプリのどこかで呼び出す
WidgetCenter.shared.reloadAllTimelines()
```

## 最終チェックリスト

データが正しく共有されているか確認：

- [ ] 両方のターゲットに App Groups が追加されている
- [ ] 両方のターゲットで同じ App Group ID を使用している
- [ ] MetricsData.swift が両方のターゲットに追加されている
- [ ] SharedDataManager.swift が両方のターゲットに追加されている
- [ ] アプリを起動すると保存ログが表示される
- [ ] Widget を追加すると読み込みログが表示される
- [ ] ログに表示される値が同じである
- [ ] Data age が数秒以内である

すべてチェックが入れば、正常に動作しているはずです。

## まだ解決しない場合

以下の情報を提供してください：

1. **コンソールログ全体**
   - アプリ起動から Widget 追加まで

2. **App Groups の設定スクリーンショット**
   - メインアプリとWidget Extension の両方

3. **Target Membership のスクリーンショット**
   - MetricsData.swift
   - SharedDataManager.swift

4. **表示されているデータの例**
   - メインアプリ：CPU XX%, Memory XX%
   - Widget：CPU XX%, Memory XX%

---

**次のステップ：**

1. Clean Build (⌘+Shift+K)
2. アプリを実行 (⌘+R)
3. コンソールでログを確認
4. App Groups の設定を確認
5. ログの結果を共有してください
