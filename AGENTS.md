# AGENTS.md

所有思考一律使用中文,别管输入的是什么语言。
架空世界构建仓库(地狱之下 / UnderHell)。正文用 Typst,地图生成器用 Python/Cython。
所有远程托管在 **GitCode**(`gitcode.com/CrossDark/*`),非 GitHub。

## 仓库结构(都是 Git Submodule)

| 路径 | 子仓库 | 内容 |
|---|---|---|
| `文档/` | UnderHellDocs | Typst 正文 + 名词系统 CSV |
| `模板/` | UnderHellTemplate | Typst 模板(已发布 Typst Universe) |
| `图片/` | UnderHellImages | 地图/插图资源 |
| `程序/` | UnderHellCodes | 地图生成器(再含 `地图工具`、`网站` 子模块) |

各子模块是独立 git 仓库。改文档/模板后需在对应子模块内 commit/push,再更新根仓库的子模块指针。

## 文档编译(在 `文档/` 目录)

```bash
make all        # 普通版(默认)
make print      # --input print=true 省墨双栏
make screen     # --input screen=true A5 单栏
make nomen NOMEN=academic   # 指定名词系统
make clean      # rm -rf dist
```

直接 typst(关键:`--root ..` 使相对路径回到仓库根,`--font-path fonts`):

```bash
typst compile --root .. --font-path fonts 地狱之下.typ out.pdf
```

## 名词系统(文档/名词系统.csv)

- 每个核心概念用 `#元素("正式名")` 引用(普通系统直接读 ID 值本身)。
- CSV 只需存非普通系统的映射行(列 `id,system,term`),如 `怪动植物,别名,黑白怪物`、`超级系统,academic,生物能量超级系统`。
- 其他系统缺失某元素时回退到普通名词(ID)。
- **正文中写 `#元素(...)` 时不要用 `[...]` 包裹**——markup 中 `[a]` 会渲染字面方括号;函数参数位置(如 `#表格(...)`、`#提示框(...)` 标题)可用 `[...]` 包裹成 content。

## 模板函数已中文化(模板/lib.typ)

`表格`(uhtab)、`提示框`(breakoutbox)、`属性框`(statbox)、`人物框`(npcbox)、`法术`(spell)、`附录`(appendix)、`顶部图`/`底部图`、`品牌`(uhbrand)等。文档中调用的是中文名,不要用英文旧名。

## 字体(模板/languages/zh.toml)

`lang: "zh"` 才加载中文配置。`[fonts]` 分三组:`header`(标题=段宁毛笔小楷)、`body`(正文=霞鹜文楷等宽)、`italic`(斜体=等距更纱黑体 SC)。斜体 show rule 只设 `font` 不设 `style`——emph 自带 italic,显式 style 会破坏字体变体选择。

## 地图生成器(程序/地图工具)

Python/Cython 项目,详见其自带技能:`程序/地图工具/.opencode/skills/map-tool/SKILL.md`(模块布局、`make` 构建、测试命令、已知坑)。动手前先读该文件。

## 常用坑

- 文档正文顶层曾出现裸 `#p` 导致编译失败——`#` 后必须是已定义符号。
- 子模块处于 detached HEAD 时,推送前先 `git checkout main && git merge --ff-only <local-commit>`。
- 交叉引用标签用中文名或名词元素(ID),引用 `@标签` 需与 `<标签>` 一致。
