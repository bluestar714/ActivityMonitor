# クイックスタートガイド

## 🚀 最速セットアップ（30秒）

このプロジェクトはXcodeでそのまま開いて使えます！

### ステップ1: プロジェクトを開く

```bash
# ターミナルで以下のコマンドを実行
cd ActivityMonitor
open ActivityMonitor.xcodeproj
```

または、Finderで `ActivityMonitor.xcodeproj` をダブルクリック

### ステップ2: チームを設定（初回のみ）

1. Xcodeでプロジェクトが開いたら、左側のナビゲーターで **ActivityMonitor** プロジェクトをクリック
2. **TARGETS** → **ActivityMonitor** を選択
3. **Signing & Capabilities** タブを開く
4. **Team** ドロップダウンから自分のApple IDを選択
   - まだ追加していない場合は「Add Account...」をクリック

### ステップ3: 実行

1. ターゲットデバイスを選択（シミュレータまたは実機）
2. ⌘R を押すか、再生ボタンをクリック

**完了！** アプリが起動します 🎉

## ⚙️ プロジェクト設定

すでに以下が設定済みです：

✅ iOS 17.0 デプロイメントターゲット
✅ ブリッジングヘッダー
✅ すべてのソースファイル
✅ Info.plist
✅ ビルド設定
✅ アプリアイコン設定

## 📱 テストのヒント

- **シミュレータ**: UIとアニメーションの確認に最適
- **実機**: 正確なメトリクス（特にネットワークとストレージ）のために推奨

## 🛠 トラブルシューティング

### 「Team」が見つからない

→ Xcode → Settings → Accounts から Apple ID を追加してください

### ビルドエラーが出る

→ Product → Clean Build Folder (⇧⌘K) を実行してから再ビルド

### iOS 17.0 が見つからない

→ このプロジェクトはiOS 17.0を必要とします。Xcode 15.0以降を使用してください

## 📖 詳細情報

- 完全なドキュメント: [README.md](README.md)
- セットアップ詳細: [SETUP_GUIDE.md](SETUP_GUIDE.md)

---

**それだけです！Xcodeで開いてすぐに使えます！** 🎊
