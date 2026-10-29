# macOS 总把输入法切回 ABC？先别急着删系统输入法

搜「macOS 禁止切换输入法」「删掉 ABC」这类关键词，中文站里几乎全是改 `com.apple.HIToolbox.plist` 的教程。英文侧则更多是菜单栏锁定小工具。两边其实在回答同一件事。系统设置里 ABC 的减号是灰的，第三方输入法却可以被移走。只要 ABC 还在列表里，Control-空格、文稿记忆、大写锁定键，都可能在你打字时把当前输入源拽走。

下面按「先系统、再硬改、最后用工具锁住」这条线写。我自己也做了一个开源菜单栏工具 Keyboard Source Locker，文末会说明它适合谁。

## 先确认是谁在切

苹果官方帮助里写得很清楚。打开「系统设置」→「键盘」→「文本输入」旁的「编辑」，可以看到几项会直接参与切换。

「自动切换到文稿的输入法」开着时，macOS 会按文档记住上次用过的输入源。你在终端敲完英文，回到聊天窗口，系统可能仍停在 ABC。关掉它，再在两个 App 之间来回点几下，很多莫名其妙的切换会立刻少一截。

装了中文类输入法以后，还可能出现「使用大写锁定键切换到 ABC（或上次使用的拉丁输入源）」。Fn / 地球键也可以被设成「更改输入法」。如果你每次切走都刚好发生在按了这些键之后，先改快捷键，比重装输入法管用。

系统快捷键这边也值得扫一眼。「键盘快捷键」→「输入法」里，Control-空格选上一个输入源，Control-Option-空格选下一个。和编辑器、远程桌面抢键时，表现出来就像输入法自己跳。

把这几项调完再测。如果切走仍然发生，文稿记忆已经解释不完。输入法列表里还永远留着一个你删不掉的候选。

## 为什么系统设置里删不掉 ABC

日常只想用微信输入法、搜狗、鼠须管时，用户会本能地去输入法列表点减号。第三方可以删，ABC 不行。这是系统行为，不是某个输入法的锅。

于是网上流行起第二类办法。用 Xcode 或 PlistEdit Pro 打开用户目录下的配置文件

```bash
sudo open ~/Library/Preferences/com.apple.HIToolbox.plist
```

在 `AppleEnabledInputSources` 里找到 `KeyboardLayout Name` 为 ABC 的那一项，整组删掉，保存，有人还会立刻把该 plist「显示简介」勾上「已锁定」，再重启。不少文章强调这一步不必关 SIP，因为文件在 `~/Library/Preferences/`，不在系统只读分区。

这条路确实能让设置界面里暂时看不见 ABC。代价也写在同一批文章和评论里。有人发现登录界面或密码框「键按对了、结果却错」；有人写网络偏好设置一点输入框就卡死，把 ABC 加回去才恢复。伪斜杠青年那篇后续里，作者自己也把 ABC 补了回去，并承认密码一类场景系统会强制要求某种英文布局。

所以我把「删 ABC」看成可逆实验，不看成默认答案。能改配置不代表该改。密码框和登录态对布局有特殊要求时，硬删只会把麻烦挪到更难复现的地方。

## 第三种思路，不删，锁住

如果目标只是「工作时始终停在某一个已启用的输入源」，更干净的做法是监听当前输入源变化，一旦偏离目标就切回来。GitHub 上这类菜单栏工具已经不少，例如 Input Source Lock、ImeLock、LockIME。它们都不去动系统输入法列表，只在用户会话里纠正偏离。

实现上通常走 Text Input Source（TIS）一类公开接口。列出已启用输入源，读当前激活项，需要时再 `select` 回去。为了避免和短暂的过渡状态打架，很多实现会加几十到几百毫秒的防抖。连续快速切换时，只对「落稳」的那一次做恢复。

这条路线有边界。登录窗口、安全输入框、远程桌面等场景，系统仍可能按自己的规则处理。锁定工具解决的是普通会话里的漂移，不是绕过安全边界。

## 我做的 Keyboard Source Locker

日常需求很窄。主用某一个第三方输入法，不想被 ABC 长期占住，也不想改 plist、关 SIP。于是做了 Keyboard Source Locker。

它是 macOS 14+ 的菜单栏应用，无 Dock 图标。点锁图标后可以

- 从已安装输入源里选一个锁定目标
- 打开或关闭锁定
- 开启登录时启动
- 查看版本并退出

锁定打开时，系统或快捷键把你切走，大约 200 毫秒后会切回目标。关锁定或退出应用，行为立刻还给 macOS。它不会从系统列表里删除 ABC，也不会改第三方输入法内部的中英文模式。

下载与说明

- 主页 https://keyboard-source-locker.heyq02.com/
- 最新包 https://github.com/heyq02/keyboard-source-locker/releases/latest
- 源码（MIT）https://github.com/heyq02/keyboard-source-locker

建议安装顺序也很短。先关掉不需要的文稿自动切换和大写锁定切换；再装 Keyboard Source Locker，选中你日常要用的输入法，打开 Lock。若只是误触快捷键，有时只改系统设置就够了，不必上工具。

## 怎么选

希望不同文稿各自记住输入法，保留苹果的文稿切换选项。

希望所有地方钉死同一个输入源，关无关紧要的自动切换，再用锁定类工具。

坚持从列表里抹掉 ABC，先备份 `com.apple.HIToolbox.plist`，改完务必验证登录与密码框，出问题就加回 ABC。

我更推荐前两条。删系统默认布局换来的是脆弱的一致性；锁住当前会话，换来的是可随时关闭的行为。Keyboard Source Locker 做的就是后一件事。如果你也在和 ABC 拉锯，欢迎试用，有问题可以在 GitHub Issues 提。

## 参考

1. Apple Support，Change Input Sources settings on Mac  
   https://support.apple.com/guide/mac-help/change-input-sources-settings-mchl84525d76/mac
2. 伪斜杠青年，MacOS 15 移除自带系统 ABC 输入法（含密码框副作用记录）  
   https://i.lckiss.com/?p=8981
3. ningxiaowa/mac-new，删除自带 ABC 输入法步骤与已知问题  
   https://github.com/ningxiaowa/mac-new
4. Anionex/input-source-lock，菜单栏锁定思路与「关闭文稿自动切换」建议  
   https://github.com/Anionex/input-source-lock
5. Keyboard Source Locker 项目说明  
   https://github.com/heyq02/keyboard-source-locker
