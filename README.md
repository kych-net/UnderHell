# 地狱之下 (UnderHell)

一个架空世界构建项目——正文文档、排版模板、程序化地图生成器与图片资源。

正文用 [Typst](https://typst.app),地图生成器用 Python/Cython。主要远程在 **GitCode**,镜像在 [GitHub](https://github.com/kych-net/UnderHell)。

## 仓库

以 **GitCode** 为主远程,各仓库地址:

| 组件 | 仓库 |
|---|---|
| 主仓库 | <https://gitcode.com/CrossDark/UnderHell.git> |
| 文档 | <https://gitcode.com/CrossDark/UnderHellDocs.git> |
| 模板 | <https://gitcode.com/CrossDark/UnderHellTemplate.git> |
| 图片 | <https://gitcode.com/CrossDark/UnderHellImages.git> |
| 程序 | <https://gitcode.com/CrossDark/UnderHellCodes.git> |

## 项目结构

本仓库使用 Git Submodule 管理各组件:

```
UnderHell/
├── 文档/          → UnderHellDocs       — Typst 文档源码 + 元素系统 CSV
├── 模板/          → UnderHellTemplate   — 架空世界 Typst 模板(已发布至 Typst Universe)
├── 图片/          → UnderHellImages     — 地图、插图等图片资源
├── 程序/          → UnderHellCodes      — 地图生成器(CLI + GUI)、元素工具、脚本
└── .github/       — CI/CD 自动编译发布
```

## 文档编译

文档使用 [Typst](https://typst.app) 编译,支持多种输出版本:

| 版本 | 命令 | 说明 |
|---|---|---|
| 普通版 | `make all` | A4 双栏、彩色背景图、深红标题 |
| 打印版 | `make print` | A4 双栏、无背景图、纯黑标题、宽边距(省墨) |
| 小屏版 | `make screen` | A5 单栏、保留背景、窄边距、小字号(手机/平板阅读) |
| 网页版 | `make web` | 单栏 HTML 多页站点(见下节) |
| 元素系统版 | `make 元素系统 元素系统名=academic` | 指定元素系统编译 |

一次性编译全部三种 PDF 版本:

```bash
cd 文档 && make all print screen
```

也可直接调用 typst:

```bash
typst compile --root .. --font-path fonts 内容/index.typ 输出.pdf
typst compile --root .. --font-path fonts --input 元素系统=academic 内容/index.typ 输出.pdf
```

## 网页文档站

`make web` 用 Typst 的 HTML 导出生成多页站点,输出到 `文档/dist/`:

| 产物 | 内容 |
|---|---|
| `dist/index.html` | 全量文档(站点首页),`#目录` 前有站内导航卡片 |
| `dist/<路径>/index.html` | 各章节独立页(如 `怪动植物/`、`特殊能力/仙术/`) |
| `dist/assets/underhell.css` | 抽出的共享样式 |
| `dist/webfonts/` | 自托管网页字体 |

站点配置写在 `文档/配置.typ`(导航卡片、导航链接、元素系统 CSV);页面集合由构建期扫描 `文档/内容/` 目录树得到,不经 Typst。页面自带右上角导航、浮动目录与阅读器面板(可调字号与字体),纯 CSS 实现。站内导航只出现在网页,PDF 不含。

## 元素系统

核心概念用"元素"标识,通过 `#元素[ID]` 引用。不同元素系统(普通/别名/academic)在同一 CSV 中以宽表存储。编译时通过 `--input 元素系统=xxx` 选择,默认为"普通"(直接返回 ID 本身)。

```csv
id,别名,academic
怪物,,
怪动物,白色怪物,
怪动植物,黑白怪物,
超级系统,,生物能量超级系统
```

- `#元素(id)`:渲染某元素在**当前**元素系统下的深红名词;已定义时自动链接到其定义标题。
- `#设定元素(id, level: none)`:普通模式为深红文本;**传入 `level`**(如 `#设定元素(level: 2)[伪神]`)即"标题+锚点"模式,生成带 `<id>` 标签的编号标题,可用 `@id` 交叉引用。样式由 `show heading` 统一应用。
- `#评论(body)`:以标题字体、**灰色**显示注释(默认无删除线);编译时 `--input 隐藏评论=true` 可整体隐藏。

未定义元素:引用但暂无定义小节的元素,在 PDF 编译时会产生编译期 warning;在 HTML 输出(`--features html --input html=true`)时渲染为悬停弹窗提示"未定义"。

## 地图生成器

基于断层生长算法的程序化地图生成工具,支持 PNG/SVG 双格式输出。详细用法参见 [程序/地图工具/.opencode/skills/map-tool/SKILL.md](程序/地图工具/.opencode/skills/map-tool/SKILL.md)。

## 元素工具

`程序/元素工具/` 下的 Python CLI,用于维护文档与 `附件/元素系统.csv`:

```bash
cd 程序/元素工具
python3 元素工具.py 扫描              # 查找源文件中的所有元素,标注未收录的
python3 元素工具.py 补全              # 把缺失元素追加到 附件/元素系统.csv
python3 元素工具.py 清理              # 直接删除 CSV 中文档已不再引用的元素
python3 元素工具.py 改名 旧id 新id     # 同步重命名文档引用与 CSV
```

详细说明参见 [程序/元素工具/README.md](程序/元素工具/README.md)。

## 模板

架空世界 Typst 模板,已发布至 Typst Universe(`@preview/underhell`)。

所有模板函数已中文化: `表格`(uhtab)、`提示框`(breakoutbox)、`属性框`(statbox)、`人物框`(npcbox)、`法术`(spell)、`附录`(appendix)、`顶部图`/`底部图`、`元素`、`设定元素`、`评论`、`品牌` 等。

提供封面、六级差异化标题样式、元素(深红+特殊字体)、元素系统切换、属性方块、NPC 卡片、法术卡片、跨页图片、附录编号等功能。

详细用法参见 [模板/README.md](模板/README.md)。

## AI 技能

各组件内置 AI 助手技能文件,描述各自的开发规范:

| 技能 | 位置 | 内容 |
|------|------|------|
| 模板开发 | `模板/.skills/SKILL.md` | 模板函数、元素系统、字体、网页输出、Typst Universe 发布 |
| 正文写作 | `文档/.skills/SKILL.md` | 编译命令、章节结构、元素系统用法、语法规范 |
| 元素系统 | `文档/.opencode/skills/元素系统/SKILL.md` | 元素系统深度说明 |

## CI/CD

GitCode Actions 会在推送 main 分支或打 tag 时自动编译并发布:

- 三种 PDF 版本(普通版、打印版、小屏版) + 元素系统版本
- 地图生成器 CLI(Windows / macOS / Linux)

## 快速开始

```bash
# 克隆(含子模块,以 GitCode 为主远程)
git clone --recursive https://gitcode.com/CrossDark/UnderHell.git

# 编译文档
cd UnderHell/文档
make all print screen

# 用指定元素系统编译
make 元素系统 元素系统名=academic
```
