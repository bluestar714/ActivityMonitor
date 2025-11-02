# ウィジェット & Live Activities セットアップガイド

このガイドでは、Activity MonitorアプリにWidget Extension、Live Activities、バックグラウンドタスク、通知機能を追加する手順を説明します。

## 📋 目次

1. [Widget Extensionの追加](#widget-extensionの追加)
2. [App Groupsの設定](#app-groupsの設定)
3. [Live Activitiesの有効化](#live-activitiesの有効化)
4. [通知の設定](#通知の設定)
5. [テスト方法](#テスト方法)

---

## 1. Widget Extensionの追加

### ステップ1: Widget Extensionターゲットを作成

1. Xcodeでプロジェクトを開く
2. **File** → **New** → **Target** を選択
3. **iOS** → **Widget Extension** を選択
4. **Next** をクリック
5. 以下の設定を入力：
   ```
   Product Name: ActivityMonitorWidget
   Include Configuration Intent: チェックなし
   ```
6. **Finish** をクリック
7. 「Activate "ActivityMonitorWidget" scheme?」と聞かれたら **Cancel** をクリック

### ステップ2: ファイルを配置

作成済みのウィジェットファイルを以下のように配置：

```
ActivityMonitorWidget/
├── ActivityMonitorWidget.swift        # ホーム画面ウィジェット
├── ActivityMonitorLiveActivityWidget.swift  # Live Activity UI
└── Info.plist                          # ウィジェット設定
```

**重要**: Xcodeで上記のファイルを `ActivityMonitorWidget` ターゲットに追加してください。

1. 各ファイルを選択
2. **File Inspector** (⌥⌘1) を開く
3. **Target Membership** で `ActivityMonitorWidget` にチェックを入れる

### ステップ3: 共有ファイルをターゲットに追加

以下のファイルを **両方** のターゲット（`ActivityMonitor` と `ActivityMonitorWidget`）に追加：

- `Models/MetricsData.swift`
- `Models/Settings.swift`
- `Services/SharedDataManager.swift`
- `Services/SystemMetricsCollector.swift`
- `ActivityMonitor-Bridging-Header.h`

**手順**:
1. 各ファイルを選択
2. **File Inspector** で
3. **Target Membership** で `ActivityMonitor` と `ActivityMonitorWidget` の両方にチェック

---

## 2. App Groupsの設定

App Groupsを使用してメインアプリとウィジェット間でデータを共有します。

### メインアプリ (ActivityMonitor)

1. プロジェクトナビゲーターで **ActivityMonitor** プロジェクトを選択
2. **TARGETS** → **ActivityMonitor** を選択
3. **Signing & Capabilities** タブを開く
4. **+ Capability** をクリック
5. **App Groups** を選択
6. **+ (プラス)** ボタンをクリック
7. 以下のApp Group IDを入力：
   ```
   group.com.activitymonitor.app
   ```
8. **OK** をクリック

### Widget Extension (ActivityMonitorWidget)

1. **TARGETS** → **ActivityMonitorWidget** を選択
2. **Signing & Capabilities** タブを開く
3. **+ Capability** をクリック
4. **App Groups** を選択
5. 同じApp Group IDにチェックを入れる：
   ```
   ✅ group.com.activitymonitor.app
   ```

### 確認

両方のターゲットで同じApp Group IDが選択されていることを確認してください。

---

## 3. Live Activitiesの有効化

### メインアプリの設定

1. **TARGETS** → **ActivityMonitor** を選択
2. **Info** タブを開く
3. すでに `NSSupportsLiveActivities` が `YES` に設定されているはずです
4. 設定されていない場合は、**+** をクリックして追加：
   - Key: `Supports Live Activities`
   - Type: Boolean
   - Value: YES

### バックグラウンドタスクの設定

`Info.plist` にすでに以下が追加されています：

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.activitymonitor.app.refresh</string>
    <string>com.activitymonitor.app.cleanup</string>
</array>
```

### Widget Extensionでの設定

1. **TARGETS** → **ActivityMonitorWidget** を選択
2. **Build Settings** タブを開く
3. "**Bridging Header**" を検索
4. **Objective-C Bridging Header** に以下を設定：
   ```
   ActivityMonitor/ActivityMonitor-Bridging-Header.h
   ```

---

## 4. 通知の設定

### Capabilityの追加

1. **TARGETS** → **ActivityMonitor** を選択
2. **Signing & Capabilities** タブ
3. **+ Capability** をクリック
4. **Push Notifications** を追加（Live Activities用、オプション）

### 通知権限

アプリ起動時に自動的に通知権限を要求します。コードは `ActivityMonitorApp.swift` に実装済みです。

---

## 5. テスト方法

### ホーム画面ウィジェットのテスト

1. アプリをビルド＆実行（⌘R）
2. ホーム画面に移動
3. 空いているスペースを長押し
4. 左上の **+** ボタンをタップ
5. **Activity Monitor** を検索
6. ウィジェットサイズを選択：
   - **Small**: CPU使用率のみ
   - **Medium**: CPU + メモリ
   - **Large**: CPU + メモリ + ネットワーク + ストレージ
7. **Add Widget** をタップ

### Live Activitiesのテスト

1. アプリを起動
2. ナビゲーションバーの **Live Activity** ボタン（紫色）をタップ
3. Dynamic Island（iPhone 14 Pro以降）またはLock Screenに表示を確認
4. バックグラウンドに移動してもDynamic Islandで継続表示されます

**Dynamic Islandの表示内容**:
- **Compact**: CPUアイコンと使用率
- **Expanded**: CPU、メモリ、ネットワーク詳細

### バックグラウンド更新のテスト

#### シミュレータでテスト

```bash
# シミュレータでバックグラウンドrefreshをシミュレート
e -n -e "e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@\"com.activitymonitor.app.refresh\"]"
```

#### 実機でテスト

1. アプリを起動
2. ホームボタンまたはスワイプでバックグラウンドに移動
3. 15分待機
4. ウィジェットが自動的に更新されます

### 通知のテスト

1. アプリを起動
2. **Settings** を開く
3. 通知のしきい値を設定（例: CPU 50%）
4. メトリクスがしきい値を超えると通知が表示されます

---

## 🔧 トラブルシューティング

### ウィジェットにデータが表示されない

**原因**: App Groupsが正しく設定されていない

**解決策**:
1. メインアプリとウィジェット拡張機能の両方で同じApp Group IDが選択されているか確認
2. `SharedDataManager.swift` の `appGroupIdentifier` が正しいか確認：
   ```swift
   private let appGroupIdentifier = "group.com.activitymonitor.app"
   ```

### Live Activityが開始されない

**原因**: iOS 16.1未満、またはInfo.plistの設定不足

**解決策**:
1. iOS 16.1以降のデバイス/シミュレータを使用
2. Info.plistに `NSSupportsLiveActivities = YES` があるか確認
3. デバイスを再起動

### ウィジェットのビルドエラー

**原因**: 共有ファイルがウィジェットターゲットに追加されていない

**解決策**:
1. 以下のファイルが `ActivityMonitorWidget` ターゲットに追加されているか確認：
   - MetricsData.swift
   - Settings.swift
   - SharedDataManager.swift
   - SystemMetricsCollector.swift
   - ActivityMonitor-Bridging-Header.h

### バックグラウンドタスクが実行されない

**原因**: バックグラウンドタスクの制限

**解決策**:
- iOSはバックグラウンドタスクの実行を制限しています
- 充電中、Wi-Fi接続時に実行される可能性が高い
- デバッグには `e -n -e` コマンドを使用

---

## 📱 使用方法

### ホーム画面ウィジェット

- 自動的に1分ごとに更新されます
- タップするとアプリが開きます
- 3つのサイズから選択可能

### Live Activities

- **開始**: アプリ内の「Start Live Activity」ボタンをタップ
- **停止**: 「Stop Live Activity」ボタンをタップ
- バックグラウンドでもリアルタイム更新
- Dynamic Island（対応機種）またはLock Screenに表示

### 通知

- Settings画面でしきい値を設定
- メトリクスが設定値を超えると自動通知
- 5分間のクールダウン期間あり

### バックグラウンド更新

- アプリがバックグラウンドでも自動的にメトリクスを収集
- 15分ごとにウィジェットとLive Activityを更新
- バッテリーに優しい設計

---

## ✅ チェックリスト

セットアップが完了したら以下を確認：

- [ ] Widget Extensionターゲットが作成されている
- [ ] App Groupsが両方のターゲットで設定されている
- [ ] 共有ファイルが両方のターゲットに追加されている
- [ ] `NSSupportsLiveActivities = YES` がInfo.plistに設定されている
- [ ] バックグラウンドタスクIDがInfo.plistに登録されている
- [ ] ウィジェットがホーム画面に追加できる
- [ ] Live Activityが開始できる
- [ ] 通知が表示される
- [ ] バックグラウンドでも更新される

---

## 🎉 完了！

これですべての機能が動作するはずです！

**バックグラウンドでも継続的にメトリクスを表示できます：**

1. ✅ ホーム画面ウィジェット
2. ✅ Live Activities (Dynamic Island)
3. ✅ Lock Screen表示
4. ✅ 通知によるアラート
5. ✅ バックグラウンド自動更新

質問がある場合は、README.mdを参照してください。
