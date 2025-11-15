# Info.plist 重複エラーの修正手順

## エラーメッセージ

```
Multiple commands produce '/Users/aokiy/Library/Developer/Xcode/DerivedData/ActivityMonitor-dhthrnwxzjfnxjfkphpxvdbnlxpi/Build/Products/Debug-iphoneos/ActivityMonitorWidgetExtension.appex/Info.plist'
```

## 原因

`Info.plist` ファイルが誤って **Copy Bundle Resources** ビルドフェーズに追加されています。

Info.plist は自動的に処理されるファイルなので、手動でコピーする必要はありません。

## 解決方法

### ステップ1: Build Phases を開く

1. **Xcode でプロジェクトを開く**

2. **プロジェクトナビゲーターでプロジェクトを選択**
   - 左側の一番上にある青い「ActivityMonitor」アイコンをクリック

3. **Widget Extension ターゲットを選択**
   - TARGETS のリストから `ActivityMonitorWidgetExtension` を選択

4. **Build Phases タブを開く**
   - 上部のタブから「Build Phases」をクリック

### ステップ2: Copy Bundle Resources から Info.plist を削除

1. **Copy Bundle Resources セクションを展開**
   - ▶ マークをクリックして展開

2. **Info.plist を探す**
   - ファイルリストの中に `Info.plist` があるか確認

3. **Info.plist を削除**
   - `Info.plist` を見つけたら、選択して `-` ボタンをクリック
   - または、右クリック → Delete

### ステップ3: メインアプリのターゲットも確認

同様に、メインアプリの `ActivityMonitor` ターゲットでも確認：

1. TARGETS → `ActivityMonitor` を選択
2. Build Phases タブを開く
3. Copy Bundle Resources を展開
4. Info.plist があれば削除

### ステップ4: クリーンビルド

1. **Clean Build Folder**
   - メニュー: `Product` → `Clean Build Folder`
   - または `⌘ + Shift + K`

2. **Derived Data を削除**（オプションだが推奨）
   - メニュー: `Xcode` → `Settings...` (または `Preferences...`)
   - `Locations` タブを開く
   - `Derived Data` の横の矢印をクリックしてFinderで開く
   - `ActivityMonitor-xxx` フォルダを削除

3. **ビルド**
   - メニュー: `Product` → `Build`
   - または `⌘ + B`

## 視覚的な手順

```
Xcode Project Navigator
└── ActivityMonitor (青いアイコン) ← クリック
    ├── TARGETS
    │   ├── ActivityMonitor
    │   └── ActivityMonitorWidgetExtension ← 選択
    └── Build Phases タブ ← クリック
        ├── Dependencies
        ├── Compile Sources
        ├── Link Binary With Libraries
        └── Copy Bundle Resources ← 展開
            ├── Assets.xcassets ✅ OK
            ├── Info.plist ❌ これを削除！
            └── その他のファイル
```

## 正しい設定

### Copy Bundle Resources に含めるべきファイル：

✅ Assets.xcassets
✅ その他のリソースファイル（画像、音声など）

### Copy Bundle Resources に含めてはいけないファイル：

❌ Info.plist（自動的に処理される）
❌ .swift ファイル（Compile Sources に含まれる）
❌ .h ファイル（Headers に含まれる）

## Info.plist の正しい設定場所

Info.plist は Build Settings で指定されます：

1. TARGETS → `ActivityMonitorWidgetExtension` を選択
2. `Build Settings` タブを開く
3. 検索ボックスに「info」と入力
4. `Packaging` セクションを見つける
5. `Info.plist File` の値を確認：
   ```
   ActivityMonitorWidget/Info.plist
   ```

この設定があれば、Info.plist は自動的に正しく処理されます。

## トラブルシューティング

### エラーが解決しない場合

1. **全ターゲットの Copy Bundle Resources を確認**
   - ActivityMonitor
   - ActivityMonitorWidgetExtension
   - 他にあれば全て

2. **Derived Data を完全に削除**
   ```
   1. Xcode を終了
   2. Finder で以下のフォルダを開く：
      ~/Library/Developer/Xcode/DerivedData/
   3. ActivityMonitor で始まるフォルダを全て削除
   4. Xcode を再起動
   ```

3. **プロジェクトをクリーン**
   ```
   ⌘ + Shift + K (Clean Build Folder)
   ⌘ + Option + Shift + K (Clean ALL)
   ```

4. **ビルド**
   ```
   ⌘ + B
   ```

### 別のエラーが表示される場合

エラーメッセージの全文を確認してください。

## よくある関連エラー

### "Multiple commands produce ... Assets.car"

同じ解決方法で対処できます：
- Build Phases → Copy Bundle Resources
- 重複しているファイルを1つだけにする

### "Multiple commands produce ... .swift"

.swift ファイルが Copy Bundle Resources に誤って追加されています：
- .swift ファイルは Compile Sources にのみあるべき
- Copy Bundle Resources から削除

## 確認リスト

修正後、以下を確認：

- [ ] ActivityMonitorWidgetExtension の Copy Bundle Resources に Info.plist がない
- [ ] ActivityMonitor の Copy Bundle Resources に Info.plist がない
- [ ] Build Settings で Info.plist File が正しく設定されている
- [ ] Derived Data を削除した
- [ ] Clean Build を実行した
- [ ] ビルドエラーが解消された

## 完了後

エラーが解消されたら、前のタスクに戻ってください：

1. アプリをビルド (⌘+B)
2. アプリを実行 (⌘+R)
3. コンソールでログを確認
4. Widget とアプリのデータが一致しているか確認

---

**注意**: Info.plist を削除するのは Copy Bundle Resources から**のみ**です。ファイル自体は削除しないでください！
