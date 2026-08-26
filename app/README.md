# 3D 打印耗材管理 · 巨魔 App（原生 UIKit）

一个运行在 iOS 15.4（已装巨魔 TrollStore）上的原生 App，用于管理 3D 打印耗材（料卷）。
按**材质类别自动分组**，支持**新增 / 编辑 / 删除**与本地持久化，界面为 iOS 原生风格。

> 技术栈：**Theos 工程 + Objective-C + UIKit**，无需 Mac，可在 Windows(WSL)/Linux 上编译，
> 产物经巨魔直接安装（无需 Apple ID / 签名）。

> ⚠️ **关于「在这台机器编译」**：生成此工程的 Windows 主机**安全策略禁用了 WSL**，
> 且没有 Mac / iOS SDK，因此**无法在此机器实机编译出 .tipa**。
> 原生命令行工程已完整就绪，请在有权限的环境（自己的 WSL / Mac / Linux）按下方步骤编译。

> ✅ **想马上在手机上用？** 见 **[零、免编译：WebClip 网页版](#零免编译webclip-网页版)** ——
> 一个 iOS 15.4 Safari 直接「添加到主屏幕」即可当 App 用的版本，**无需任何编译**，立即可用。

---

## 功能

- 添加 / 编辑 / 删除耗材料卷
- 字段：名称、品牌、材质（PLA/ABS/PETG/TPU/树脂/尼龙/其他）、颜色、总重(g)、剩余(g)、购入日期、备注
- **自动按材质分类**：列表按材质分区块（`titleForHeaderInSection` 显示「材质 · N卷 · 余Xg」）
- 顶部统计卡：总卷数、总余量、总已用量
- 颜色色板预览、剩余百分比、滑动删除、点击编辑
- 数据保存在 App 沙盒 `Documents/filaments.plist`，删除 App 即清空

---

## 零、免编译：WebClip 网页版（推荐先试）

`webclip/` 目录是一个**自包含的单页网页应用**，功能和原生版一致（增/删/改、按材质分类、
统计、颜色、iOS 风格界面、本地持久化），但**不需要任何编译工具链**。

### 在 iPhone 上使用（iOS 15.4 Safari）
1. 把 `webclip/` 整个目录传到任意可访问的地方：
   - 最简单：用电脑起一个本地服务器，手机连同一 Wi‑Fi 访问
     ```bash
     cd webclip
     python3 -m http.server 8000
     # 手机 Safari 打开 http://<电脑局域网IP>:8000
     ```
   - 或部署到任意静态托管（GitHub Pages / Netlify / 对象存储），拿到一个 https 链接。
2. 手机 Safari 打开该页面 → 底部「**分享**」→「**添加到主屏幕**」。
3. 桌面出现「耗材管理」图标，点开即全屏运行，像原生 App 一样。

### 优势 / 注意
- 数据存在 Safari 的 `localStorage`，**删除主屏幕图标会清空数据**；可用「导出备份」存一份 JSON。
- `sw.js` 提供离线缓存（需通过 http**s** 或 `localhost` 打开才生效，局域网 http 仅在线可用）。
- 想换回原生 `.tipa`，见下面的巨魔编译流程。

### 部署到 GitHub Pages（获得 https 链接，支持离线 + 扫码即装）

> 仅需上传 `webclip/` 里的 4 个文件，无需命令行、无需本地工具链。

**方法 A：网页拖拽（最简单，推荐）**
1. 打开 <https://github.com/new> 新建一个**公开(Public)**仓库，名字如 `filament-manager`，其余默认，点 **Create repository**。
2. 在仓库页点 **Add file → Upload files**，把下面 4 个文件拖进去，提交（Commit）：
   - `webclip/index.html`
   - `webclip/icon.png`
   - `webclip/manifest.webmanifest`
   - `webclip/sw.js`
   （务必放在仓库**根目录**，不要套一层 `webclip/` 子目录。）
3. 仓库 **Settings → Pages → Build and deployment → Source 选 “Deploy from a branch”**，
   Branch 选 **main** / 目录 **/(root)**，Save。
4. 等 1–2 分钟，访问 `https://<你的用户名>.github.io/<仓库名>/`，手机 Safari 打开 → 分享 → 添加到主屏幕。

**方法 B：命令行（你本地已登录 gh）**
```bash
cd webclip
git init -q && git add -A && git commit -qm "filament manager webclip"
gh repo create filament-manager --public -d "3D 打印耗材管理 WebClip" --source=. --remote=origin --push
gh repo edit --enable-pages --pages-source=main --pages-path=/
```

> 通过 `https://*.github.io` 打开时，`sw.js` 离线缓存生效，断网也能用；局域网 http 方式仅在线可用。

---

## 一、准备编译环境（只需一次）

### 方式 A：Windows 用户用 WSL（推荐）
1. 安装 WSL + Ubuntu：`wsl --install`（或商店装 Ubuntu 22.04）。
2. 进入 Ubuntu 终端，安装依赖：
   ```bash
   sudo apt update
   sudo apt install -y git bash curl python3 zip dpkg-dev libtinfo5
   ```
3. 安装 Theos：
   ```bash
   git clone --recursive https://github.com/theos/theos.git ~/theos
   echo 'export THEOS=~/theos' >> ~/.bashrc
   echo 'export PATH=$THEOS/bin:$PATH' >> ~/.bashrc
   source ~/.bashrc
   ```
4. 下载 iOS SDK（放到 `$THEOS/sdks/`，需要 iOS 15.x 或更新的 SDK）：
   ```bash
   # 例如从 https://github.com/theos/sdks 下载 iPhoneOS.sdk 解压到下面目录
   mkdir -p $THEOS/sdks
   # 解压 iPhoneOS15.5.sdk.tar.xz 到 $THEOS/sdks/
   ```

### 方式 B：Linux / macOS
同上，依赖安装命令换成对应系统的包管理器即可；macOS 也可用 Xcode 自带的 SDK。

---

## 二、编译与打包

把本工程目录（含 `Makefile`）放进 WSL 环境，例如 `~/FilamentManager`。

```bash
cd ~/FilamentManager
make              # 仅编译（可选，用于排查错误）
make package      # 打包，会自动调用 package_tipa.sh 生成 FilamentManager.tipa
```

成功后当前目录会出现 **`FilamentManager.tipa`**。

> 若 `make package` 提示 SDK 版本问题，可调 `Makefile` 里的
> `TARGET = iphone:clang:latest:15.0`（第一个版本号改成你有的 SDK 版本，如 `15.5`）。

---

## 三、用巨魔安装到手机

1. 把 `FilamentManager.tipa` 传到 iPhone（AirDrop / 网盘 / 文件 App / SMB 均可）。
2. 在 iPhone 上用 **TrollStore** 打开该 `.tipa`（分享菜单 → TrollStore，或 TrollStore 内「+」导入）。
3. 等待安装完成，桌面出现「耗材管理」即可使用。

> 巨魔支持的系统：iOS 14.0–16.6.1（含你的 15.4）。无需越狱、无需联网验证。

---

## 四、自定义

- **Bundle ID / 名称**：修改 `layout/DEBIAN/control` 与 `layout/Applications/FilamentManager.app/Info.plist`
  里的 `com.yourname.filamentmanager` / `FilamentManager` / `耗材管理`。
- **图标**：`tools/make_icon.py` 重新生成，或用你自己的 PNG 替换 `.app` 目录下的 `AppIcon*.png`。
- **新增材质类别**：在 `src/FilamentItem.m` 的 `allMaterials` 里加一项即可（列表与选择器自动出现）。

---

## 五、目录结构

```
FilamentManager/
├── Makefile
├── package_tipa.sh          # deb → tipa 打包脚本
├── layout/
│   ├── DEBIAN/control
│   └── Applications/FilamentManager.app/
│       ├── Info.plist
│       └── AppIcon*.png
├── src/
│   ├── main.m
│   ├── AppDelegate.h/.m
│   ├── Helpers.h/.m          # 颜色解析工具
│   ├── FilamentItem.h/.m     # 数据模型
│   ├── FilamentStore.h/.m    # 单例 + plist 持久化 + 分组
│   ├── ListViewController.h/.m   # 主列表（分组/统计/删除）
│   └── EditViewController.h/.m   # 新增/编辑表单
├── tools/make_icon.py
└── webclip/                 # 免编译网页版（见「零」）
    ├── index.html           # 自包含单页应用
    ├── icon.png             # apple-touch-icon (180×180)
    ├── manifest.webmanifest
    ├── sw.js                # 离线缓存
    └── make_icon.py         # 重新生成图标
```

---

## 六、常见问题

- **`make` 报 SDK not found**：确认 `$THEOS/sdks/` 下有 `iPhoneOS*.sdk`，且 `Makefile` 的
  `TARGET` 第一个版本号与之一致。
- **安装后打不开 / 闪退**：确认系统版本在巨魔支持范围内；用 TrollStore「重新注册」一次。
- **数据在哪**：App 沙盒 `Documents/filaments.plist`；卸载 App 会一并删除。
- **想改默认剩余/总重单位**：目前以「克(g)」为单位，逻辑在 `EditViewController` 与 `FilamentStore` 中。
