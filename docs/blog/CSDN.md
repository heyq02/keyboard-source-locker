# 🛠️ macOS 禁止切换输入法实操教程（含锁定工具推荐）

> **做完你会得到什么**  
> 输入法不再莫名其妙切到 **ABC**，日常可以稳定停在微信输入法 / 搜狗 / 鼠须管等你真正要用的那一个。

> **适用环境**  
> macOS 14+（Ventura 及更早版本路径略有不同，但思路一样）

> **最容易卡住的地方**  
> 系统设置里 **删不掉 ABC**；硬改 plist 可能搞坏密码框；很多人一上来就关 SIP，其实常常用不着。

---

## 目录

1. [先看清问题长什么样](#1-先看清问题长什么样)
2. [方案 A · 只改系统设置（优先试）](#2-方案-a--只改系统设置优先试)
3. [方案 B · 改 plist「删掉」ABC（有风险）](#3-方案-b--改-plist删掉abc有风险)
4. [方案 C · 用工具锁定输入法（推荐）](#4-方案-c--用工具锁定输入法推荐)
5. [Keyboard Source Locker 安装与使用](#5-keyboard-source-locker-安装与使用)
6. [怎么选、怎么验收](#6-怎么选怎么验收)
7. [参考链接](#7-参考链接)

---

## 1. 先看清问题长什么样

系统设置 → **键盘** → **文本输入** → **编辑** 里，你会看到类似这样的列表。

**内置 ABC**（减号往往是灰的，删不掉）

![macOS 输入法列表中的 ABC](https://raw.githubusercontent.com/heyq02/keyboard-source-locker/main/images/abc-input-source.png)

**第三方输入法**（例如微信输入法，通常可以正常移除）

![macOS 输入法列表中的微信输入法](https://raw.githubusercontent.com/heyq02/keyboard-source-locker/main/images/wx-input-source.png)

📌 **现象归纳**

- 打字中途突然变成英文 ABC  
- 从终端切到微信、从浏览器切回编辑器，输入法自己跳  
- `Control + 空格`、大写锁定键、Fn / 地球键一按就切走  

📌 **原因通常叠在一起**

| 触发源 | 常见表现 |
| --- | --- |
| 文稿自动切换 | 换窗口 / 换输入框后跳回上次布局 |
| 快捷键冲突 | Control-空格、大写锁定、Fn 被占用 |
| ABC 删不掉 | 列表里永远多一个候选，误触或系统切回去 |

下面三个方案**按推荐顺序**试。前一个够用就停，不必全做。

---

## 2. 方案 A · 只改系统设置（优先试）

🎯 **目标**  
关掉「帮倒忙」的自动切换，先排除系统自己在捣乱。

### 步骤 1 · 关闭「自动切换到文稿的输入法」

1. 打开 **系统设置** → **键盘**  
2. 找到 **文本输入**，点旁边的 **编辑**  
3. 取消勾选 **自动切换到文稿的输入法**（英文界面大致为 *Automatically switch to a document’s input source*）

✅ **可见结果**  
在两个 App 之间来回点几次，输入法不应再跟着「文稿记忆」乱跳。

### 步骤 2 · 检查大写锁定键 / Fn / 地球键

1. 仍在文本输入相关设置里，看是否有  
   **使用大写锁定键切换到 ABC**（或「上次使用的拉丁输入源」）  
2. 回到 **键盘** 设置，查看 **按下 fn 键时** / **按下 🌐 键时** 是否设成了「更改输入法」

✅ **可见结果**  
按一下大写锁定或 Fn，不应再偷偷切到 ABC（除非你刻意保留这个功能）。

### 步骤 3 · 检查输入法快捷键冲突

1. **系统设置** → **键盘** → **键盘快捷键** → **输入法**  
2. 看清这两项实际绑定了什么  
   - 选择上一个输入源（常见 `Control + 空格`）  
   - 选择下一个输入源（常见 `Control + Option + 空格`）  
3. 若和编辑器、远程桌面冲突，改成你几乎不会误触的组合，或先暂时关掉

✅ **可见结果**  
在常用编辑器里打字时，不应再「碰一下修饰键就切输入法」。

---

💡 **到这里就够了吗？**  
若误触和文稿记忆是主因，**方案 A 往往已经解决问题**。  
若你只想**永久钉死一个输入法**，而 ABC 仍会在各种时机冒出来，继续看方案 B / C。

---

## 3. 方案 B · 改 plist「删掉」ABC（有风险）

⚠️ **先读风险，再动手**

网上大量教程教你编辑

`~/Library/Preferences/com.apple.HIToolbox.plist`

从 `AppleEnabledInputSources` 里删掉 ABC 那一项。很多文章还说**不必关 SIP**（文件在用户目录，不在系统只读分区）。

但同一批实践记录里也有这些坑

- 登录界面 / 密码框出现「键按对了、结果却错」  
- 网络设置一点输入框就卡死，加回 ABC 才恢复  
- 删完又被系统写回，要立刻锁定文件才「暂时」生效  

👉 **我的建议**  
把方案 B 当成**可逆实验**，不要当成默认答案。密码框和登录态对英文布局有特殊要求时，硬删只是把麻烦挪地方。

### （可选）操作提纲

> 仅供排查或实验。动手前**先备份**该 plist。

```bash
# 1）备份
cp ~/Library/Preferences/com.apple.HIToolbox.plist \
   ~/Desktop/com.apple.HIToolbox.plist.bak

# 2）用 Xcode / PlistEdit Pro 打开
sudo open ~/Library/Preferences/com.apple.HIToolbox.plist
```

1. 展开 **AppleEnabledInputSources**  
2. 找到 `KeyboardLayout Name` = **ABC** 的整组 item，删除  
3. 保存；若教程要求，立刻在访达「显示简介」勾选 **已锁定**  
4. 重启，打开系统设置核对 ABC 是否还在  

🛟 **回滚**  
系统设置里重新添加 **ABC**，或用备份覆盖回去后注销 / 重启。

---

## 4. 方案 C · 用工具锁定输入法（推荐）

🎯 **思路一句话**  
*不删 ABC，只在偏离目标时自动切回来。*

菜单栏小工具会监听当前输入源变化（常见走 Text Input Source / TIS 接口）。一旦不是你锁定的那个，就在短防抖后切回。GitHub 上同类项目不少，例如 *Input Source Lock*、*ImeLock*、*LockIME*。

我也做了一个开源、MIT、专注「全局锁定」的工具

**Keyboard Source Locker**

![Keyboard Source Locker 预览](https://raw.githubusercontent.com/heyq02/keyboard-source-locker/main/images/hero-banner.jpg)

| 项目 | 说明 |
| --- | --- |
| 平台 | macOS **14+** |
| 形态 | 菜单栏应用，**无 Dock 图标** |
| 行为 | 锁定开启时，约 **200 ms** 防抖后切回目标 |
| 不会做的事 | 不删系统 ABC；不改第三方输入法内部中英文模式 |
| 许可证 | MIT，源码公开 |

🔗 [产品主页](https://keyboard-source-locker.heyq02.com/) · [最新下载](https://github.com/heyq02/keyboard-source-locker/releases/latest) · [源码仓库](https://github.com/heyq02/keyboard-source-locker)

---

## 5. Keyboard Source Locker 安装与使用

### 步骤 1 · 下载并安装

1. 打开 [Releases 最新页](https://github.com/heyq02/keyboard-source-locker/releases/latest)  
2. 下载 zip，解压得到 `KeyboardSourceLocker.app`  
3. 拖到 `/Applications`  
4. 首次从网络下载启动时，若被拦截，到 **系统设置 → 隐私与安全性 → 仍要打开**

✅ **可见结果**  
菜单栏出现锁图标，Dock **没有**常驻图标。

### 步骤 2 · 选中目标输入法并锁定

![菜单栏操作示意](https://raw.githubusercontent.com/heyq02/keyboard-source-locker/main/images/menu-preview.jpg)

1. 点击菜单栏锁图标  
2. **Select Input Source** → 选中你的目标（例如微信输入法）  
3. 打开 **Lock: On**  
4. （可选）勾选登录时启动  

✅ **可见结果**  
菜单里能看到当前锁定目标；手动切到 ABC 后，大约 **200 毫秒**会自动切回。

### 步骤 3 · 临时解锁 / 退出

| 你想做的事 | 操作 |
| --- | --- |
| 暂时允许自由切换 | 把 **Lock** 关掉，应用仍留在菜单栏 |
| 完全恢复系统行为 | 菜单里选 **Quit** |

---

✅ **推荐组合拳（最少折腾）**

1. 先做完 **方案 A**（关文稿自动切换、检查快捷键）  
2. 再装 **Keyboard Source Locker**，锁定日常输入法  
3. **不要**一上来就改 plist / 关 SIP  

---

## 6. 怎么选、怎么验收

### 怎么选

| 你的目标 | 建议 |
| --- | --- |
| 不同文稿各自记住输入法 | 保留苹果的「文稿自动切换」，不必上锁定工具 |
| 所有地方钉死同一个输入源 | 方案 A + **方案 C（Keyboard Source Locker）** |
| 一定要从列表里抹掉 ABC | 方案 B，务必备份，并验证登录 / 密码框 |

### 三轮验收（建议照做）

1. **同 App 两个输入框**来回点，看输入法是否符合预期  
2. **两个 App** 之间切换三次，结果应一致  
3. 故意按一次输入法快捷键切走，锁定开启时应在短延迟后**切回目标**

若结果仍乱，先关掉锁定工具，只测 macOS 自带设置；确认系统行为后，再只开一种自动方案，更容易定位是谁在抢。

---

有问题欢迎到 [GitHub Issues](https://github.com/heyq02/keyboard-source-locker/issues) 反馈。若这篇对你有用，也欢迎给仓库点个 ⭐。

---

## 7. 参考链接

1. [Apple Support · Change Input Sources settings on Mac](https://support.apple.com/guide/mac-help/change-input-sources-settings-mchl84525d76/mac)  
2. [伪斜杠青年 · 移除 ABC 及密码框副作用记录](https://i.lckiss.com/?p=8981)  
3. [ningxiaowa/mac-new · 删除 ABC 步骤与已知问题](https://github.com/ningxiaowa/mac-new)  
4. [Anionex/input-source-lock · 锁定思路与关闭文稿自动切换建议](https://github.com/Anionex/input-source-lock)  
5. [Keyboard Source Locker](https://github.com/heyq02/keyboard-source-locker)  
