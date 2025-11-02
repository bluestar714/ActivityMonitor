# Widget Extension セットアップ手順

## 完了した作業 ✅

以下のファイルを自動的に更新しました：

1. **ActivityMonitorWidget.swift** - 実際のパフォーマンスメトリクスを表示するように更新
2. **ActivityMonitorWidgetLiveActivity.swift** - Live Activity UIを更新（CPU、メモリ、ネットワークを表示）
3. **ActivityMonitorWidgetBundle.swift** - Control Widgetの参照を削除
4. **ActivityMonitorWidgetControl.swift** - 削除（不要なため）

## 今すぐXcodeで実行する手順

### ステップ1: 共有ファイルをWidget Extension ターゲットに追加

Widget Extension が正常に動作するには、以下のファイルを **両方のターゲット** に追加する必要があります：

#### 追加するファイル：

1. **Models/MetricsData.swift**
   - CPUMetrics, MemoryMetrics, NetworkMetrics, StorageMetrics, MetricsSnapshot の定義

2. **Services/SharedDataManager.swift**
   - App Groups を使用したデータ共有

3. **Services/SystemMetricsCollector.swift** (オプション - Widget が直接収集する場合)
   - システムメトリクス収集機能

4. **ActivityMonitor-Bridging-Header.h**
   - C API のブリッジングヘッダー

#### Xcodeでの追加方法：

```
1. Xcodeプロジェクトナビゲーターで、上記のファイルを1つずつ選択

2. 右側の「File Inspector」パネル（⌘+Option+1）を開く

3. 「Target Membership」セクションを見つける

4. 以下の両方にチェックを入れる：
   ✅ ActivityMonitor
   ✅ ActivityMonitorWidgetExtension

5. すべてのファイルに対してこの手順を繰り返す
```

**重要**: ActivityMonitorLiveActivity.swift は **メインアプリのみ** に所属させます（Widget Extension には追加しない）。Widget Extension には独自の ActivityMonitorWidgetLiveActivity.swift があります。

### ステップ2: App Groups の設定

両方のターゲットで同じ App Group ID を設定する必要があります：

#### メインアプリ (ActivityMonitor) の設定：

```
1. プロジェクトナビゲーターで「ActivityMonitor」プロジェクトを選択
2. TARGETSから「ActivityMonitor」を選択
3. 「Signing & Capabilities」タブを開く
4. 左上の「+ Capability」ボタンをクリック
5. 「App Groups」を検索して追加
6. 「+ 」ボタンをクリックして新しいApp Groupを追加
7. 以下のIDを入力：
   group.com.activitymonitor.app
8. チェックマークを入れる
```

#### Widget Extension (ActivityMonitorWidgetExtension) の設定：

```
1. TARGETSから「ActivityMonitorWidgetExtension」を選択
2. 「Signing & Capabilities」タブを開く
3. 左上の「+ Capability」ボタンをクリック
4. 「App Groups」を検索して追加
5. 「+ 」ボタンをクリックして新しいApp Groupを追加
6. **同じID** を入力：
   group.com.activitymonitor.app
7. チェックマークを入れる
```

**重要**: 両方のターゲットで **全く同じ App Group ID** を使用する必要があります。

### ステップ3: Bridging Header の設定

Widget Extension 用のブリッジングヘッダーを設定：

```
1. TARGETSから「ActivityMonitorWidgetExtension」を選択
2. 「Build Settings」タブを開く
3. 検索ボックスに「bridging」と入力
4. 「Objective-C Bridging Header」を見つける
5. 値を設定：
   ActivityMonitor/ActivityMonitor-Bridging-Header.h
```

### ステップ4: プロジェクトから削除する参照

Widget Extension を Xcode で作成した際、project.pbxproj に自動的に追加された Control Widget の参照を削除する必要があります：

```
1. プロジェクトナビゲーターで「ActivityMonitorWidget」フォルダを確認
2. 「ActivityMonitorWidgetControl.swift」が表示されている場合、右クリック
3. 「Delete」を選択
4. 「Move to Trash」を選択（参照のみを削除する場合は「Remove Reference」）
```

### ステップ5: ビルドとテスト

```
1. Product → Clean Build Folder (⌘+Shift+K)
2. メインアプリのターゲットを選択
3. ビルド (⌘+B)
4. Widget Extension のターゲットを選択
5. ビルド (⌘+B)
```

エラーが表示される場合：
- すべての共有ファイルが両方のターゲットに追加されているか確認
- App Group ID が両方のターゲットで同じであることを確認
- Bridging Header のパスが正しいか確認

### ステップ6: 実機またはシミュレータで確認

```
1. アプリを実行 (⌘+R)
2. ホーム画面に移動
3. 長押しして「編集」モード
4. 左上の「+」ボタンをタップ
5. 「Activity Monitor」を検索
6. 小、中、大のサイズから選択してウィジェットを追加
7. Live Activity ボタンをタップして Dynamic Island を確認
```

## トラブルシューティング

### エラー: "Cannot find 'SharedDataManager' in scope"
→ SharedDataManager.swift が Widget Extension ターゲットに追加されていません。ステップ1を確認してください。

### エラー: "Cannot find type 'MetricsSnapshot' in scope"
→ MetricsData.swift が Widget Extension ターゲットに追加されていません。ステップ1を確認してください。

### ウィジェットにデータが表示されない
→ App Groups が正しく設定されていない可能性があります。ステップ2で両方のターゲットに同じ App Group ID が設定されているか確認してください。

### Live Activity が起動しない
→ Info.plist に NSSupportsLiveActivities が設定されているか確認してください（既に設定済みのはずです）。

## 確認リスト

セットアップが完了したら、以下を確認してください：

- [ ] MetricsData.swift が両方のターゲットに追加されている
- [ ] SharedDataManager.swift が両方のターゲットに追加されている
- [ ] SystemMetricsCollector.swift が両方のターゲットに追加されている
- [ ] ActivityMonitor-Bridging-Header.h が両方のターゲットに追加されている
- [ ] App Groups が両方のターゲットで `group.com.activitymonitor.app` に設定されている
- [ ] Widget Extension の Bridging Header パスが設定されている
- [ ] ActivityMonitorWidgetControl.swift が削除されている（または参照が削除されている）
- [ ] メインアプリがビルドできる
- [ ] Widget Extension がビルドできる
- [ ] ウィジェットがホーム画面に追加できる
- [ ] Live Activity が起動できる

## 次のステップ

すべてのセットアップが完了したら：

1. アプリを起動してメトリクスが表示されることを確認
2. ホーム画面ウィジェットを追加
3. Live Activity ボタンをタップして Dynamic Island で表示
4. アプリをバックグラウンドに移動してもメトリクスが表示され続けることを確認

---

質問や問題がある場合は、エラーメッセージの全文を提供してください。
