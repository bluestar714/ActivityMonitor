# CPU表示の統一と詳細表示機能の追加

## 実装した変更

### 問題

- Widget と アプリで CPU 使用率の表示が異なっていた
- Widget: User + System の合計を表示
- アプリ: `cpu.usage` を表示（Nice を含むため、User + System と微妙に異なる）

### 解決策

すべての表示を **User + System の合計** に統一し、詳細表示モードも追加しました。

---

## 📱 アプリ側の変更

### 1. Settings.swift - 詳細表示オプションの追加

```swift
struct AppSettings: Codable {
    var showDetailedCPU: Bool // Show User/System breakdown instead of total
}
```

**デフォルト値**: `false`（合計表示）

### 2. DashboardView.swift - 表示ロジックの更新

#### CPU 表示の計算

**合計表示モード** (デフォルト):
- メイン値: `User + System` の合計（例: 45.2%）
- サブタイトル: 内訳を表示（User: 30%, System: 15% • Tap for details）

**詳細表示モード**:
- メイン値: User と System を別々に表示（例: 30.1% / 15.1%）
- サブタイトル: Idle を表示（User / System • Idle: 54.8%）

#### タップで切り替え

CPU カードをタップすることで、2つのモード間を切り替えできます：

```swift
.onTapGesture {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        settingsManager.settings.showDetailedCPU.toggle()
    }
}
.sensoryFeedback(.selection, trigger: settingsManager.settings.showDetailedCPU)
```

### 3. SettingsView.swift - 設定画面にトグルを追加

新しい **Display Options** セクションを追加：

```swift
Toggle("Detailed CPU View") {
    // Show User/System separately
}
```

- アイコン: CPU アイコンがパルスアニメーション
- 説明: タップで素早く切り替え可能
- フィードバック: 触覚フィードバック付き

---

## 🏠 Widget側の変更

### 1. ActivityMonitorWidget.swift - 全サイズの修正

すべてのWidget サイズで `cpu.usage` から `cpu.userTime + cpu.systemTime` に変更：

#### Small Widget (小サイズ)
```swift
Text("\(Int(metrics.cpu.userTime + metrics.cpu.systemTime))%")
```

#### Medium Widget (中サイズ)
```swift
Text("\(Int(metrics.cpu.userTime + metrics.cpu.systemTime))%")
```

#### Large Widget (大サイズ)
```swift
// メイン値
Text("\(Int(metrics.cpu.userTime + metrics.cpu.systemTime))%")

// 詳細
Text("User: \(Int(metrics.cpu.userTime))%")
Text("System: \(Int(metrics.cpu.systemTime))%")
Text("Idle: \(Int(metrics.cpu.idleTime))%")
```

### 2. デバッグログの改善

```swift
let cpuTotal = metrics.cpu.userTime + metrics.cpu.systemTime
print("✅ [Widget Timeline] Using real data - CPU: \(Int(cpuTotal))% (User: \(Int(metrics.cpu.userTime))%, System: \(Int(metrics.cpu.systemTime))%)")
```

---

## 🔴 Live Activity の変更

### ActivityMonitorLiveActivity.swift

Live Activity でも User + System の合計を表示するように修正：

```swift
// Start Live Activity
let cpuTotal = metrics.cpu.userTime + metrics.cpu.systemTime
let contentState = ActivityMonitorAttributes.ContentState(
    cpuUsage: cpuTotal,
    // ...
)

// Update Live Activity
let cpuTotal = metrics.cpu.userTime + metrics.cpu.systemTime
let contentState = ActivityMonitorAttributes.ContentState(
    cpuUsage: cpuTotal,
    // ...
)
```

---

## 🎨 ユーザー体験

### デフォルト表示（合計モード）

**メインアプリ**:
```
CPU
45.2%
User: 30.1% • System: 15.1% • Tap for details
```

**Widget (小)**:
```
CPU   45%
```

**Widget (大)**:
```
CPU Usage              45%
User: 30%  System: 15%  Idle: 55%
```

**Live Activity**:
```
CPU    45%
```

### 詳細表示モード（アプリのみ）

**メインアプリ**:
```
CPU
30.1% / 15.1%
User / System • Idle: 54.8%
```

### 切り替え方法

1. **CPUカードをタップ** - 即座に切り替え（アニメーション付き）
2. **設定画面** - "Display Options" → "Detailed CPU View"

---

## 🔍 技術的な詳細

### なぜ `cpu.usage` を使わないのか？

SystemMetricsCollector.swift での計算：

```swift
let totalTicks = totalUser + totalSystem + totalIdle + totalNice
userTime = Double(totalUser) / Double(totalTicks) * 100.0
systemTime = Double(totalSystem) / Double(totalTicks) * 100.0
idleTime = Double(totalIdle) / Double(totalTicks) * 100.0
totalUsage = 100.0 - idleTime  // ← Nice も含まれる
```

- `totalUsage` は `100.0 - idleTime` で計算される
- これには **Nice** プロセスの時間も含まれる
- `userTime + systemTime` は Nice を含まない純粋なCPU使用率

### 統一した計算式

すべての表示で以下を使用：

```swift
let cpuTotal = metrics.cpu.userTime + metrics.cpu.systemTime
```

これにより：
- ✅ アプリと Widget で同じ値が表示される
- ✅ より正確な CPU 使用率（Nice を除外）
- ✅ 詳細表示時に User と System の合計が一致する

---

## ✅ 確認事項

修正後、以下を確認してください：

### アプリ側
- [ ] CPU カードに User + System の合計が表示される
- [ ] サブタイトルに内訳が表示される
- [ ] CPUカードをタップすると表示が切り替わる
- [ ] 切り替え時にアニメーションと触覚フィードバックがある
- [ ] 設定画面に "Detailed CPU View" トグルがある

### Widget側
- [ ] 小・中・大すべてのサイズで User + System の合計が表示される
- [ ] アプリと同じ値が表示される
- [ ] 大サイズで User, System, Idle の内訳が表示される

### Live Activity側
- [ ] Dynamic Island で User + System の合計が表示される
- [ ] アプリと同じ値が表示される

### ログ確認
- [ ] コンソールに詳細なCPU値が表示される
- [ ] Widget のログにUser/System の内訳が表示される

---

## 🎯 期待される結果

**すべての場所で同じCPU使用率が表示される**:

```
メインアプリ:      45%  (User: 30%, System: 15%)
Widget (小):      45%
Widget (中):      45%
Widget (大):      45%  (User: 30%, System: 15%, Idle: 55%)
Live Activity:    45%
```

---

## 🚀 次のステップ

1. **クリーンビルド**
   ```
   ⌘ + Shift + K (Clean Build Folder)
   ⌘ + B (Build)
   ```

2. **アプリを実行**
   ```
   ⌘ + R
   ```

3. **動作確認**
   - メインアプリのCPU値を確認
   - CPUカードをタップして切り替えを確認
   - Widgetを追加して値を比較
   - Live Activity を起動して値を確認

4. **コンソールログを確認**
   - User, System, 合計値が正しく表示されるか
   - すべての表示で同じ値になっているか

---

**これで、アプリとWidgetでCPU使用率が統一され、詳細表示も可能になりました！** 🎉
