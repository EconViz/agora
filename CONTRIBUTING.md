# Contributing to agora

Thank you for helping improve the EconViz manuals. This guide covers the
build setup and the conventions every manual and edition follows.

## Setting up

```bash
git clone https://github.com/EconViz/agora.git
cd agora
make all
```

See the [README](README.md#requirements) for the required tools and fonts.
Run `uv sync` inside a manual's directory (e.g. `packages/utility-viz/`) before
`make figures MANUAL=<manual>` to install its package.

## How to contribute

- **Errors in the manual**: open an issue that names the edition, the page or
  section, and what is wrong.
- **Errors in a package itself**: report them in that package's repository,
  for example [EconViz/utility-viz](https://github.com/EconViz/utility-viz/issues).
- **Pull requests**: fork the repository, create a branch, and open a PR
  against `main`.

Before you submit a PR, check that `make all` finishes without warnings, and
review the pages you changed in every edition. Changes to `template/` affect
every manual: look through each of them.

## Keeping the editions in step

The editions of a manual share the same structure. A change in one chapter
goes into the same file in `chapters/en/`, `chapters/zh-TW/` and
`chapters/zh-CN/` of that manual:

- the same APIs, parameters, figures, tables and labels;
- the same `#changed(...)` entries, one per release note, placed next to the
  feature they describe;
- code, mathematics and cross-references unchanged across editions.

## Writing conventions

- Describe parameters, methods and returned fields with `#param(...)`, one per
  entry, never several in one sentence of prose.
- English uses British spelling.
- The Chinese editions follow [the rules below](#chinese-editions).
  zh-CN is localised, not just converted to simplified characters.
- In CJK text, write a reference followed directly by a CJK character as
  `#ref(<label>)`; `@label` would swallow the following characters.
- Cite works in the manual's `config/refs.bib` with `#citep` or `#citet`.
- While a revision is under review, wrap changed text in `#modify[...]`; it
  is set in alizarin red. Remove the markers before publishing.

### Chinese editions

本規範適用於 `chapters/zh-TW` 與 `chapters/zh-CN`。兩個版本共用內容結構、程式碼、數學式、圖表與交叉引用；用字、術語及字型依語系調整。

**敘述原則**

- 使用現在式與主動語態，直接說明功能、條件及結果。
- 每段處理一個概念。段首先寫主要資訊，再補充條件、限制或原因。
- 正文省略「我們」「作者」「你／您」等不必要的主詞。操作步驟以「執行」「傳入」「設定」「呼叫」「檢查」等動詞開頭。
- 不使用「簡單」「方便」「輕鬆」「強大」「完美」「只要」「即可」等缺乏判準的修飾語。
- 比較功能時列出可驗證的差異，不以偏好或宣傳語代替技術說明。

**章節結構**

- 教學先交代目標與先備條件，再提供可執行範例，最後解釋關鍵結果。
- 操作說明使用目標式標題，依序列出步驟與預期結果。
- API 參考依序說明用途、參數、回傳值、例外或限制及範例。
- 程式碼前說明用途；程式碼後僅解釋輸出與關鍵行為，不逐行改寫程式碼。
- 圖表題名不超過 13 個中文字。括號內引用圖或表時寫「參見」，引用章節時寫「詳見」。

**繁體中文（台灣）**

使用台灣慣用技術詞彙：程式碼、套件、儲存庫、檔案、函式、類別、物件、介面、回傳、預設值、設定、支援、資訊、影片、命令列、字型、圖層、透明度。

中文與半形英數之間留半形空格。API、參數、命令、檔名及程式碼維持原文。

**简体中文（中国大陆）**

使用中国大陆惯用技术词汇：代码、软件包、仓库、文件、函数、类、对象、接口、返回、默认值、配置、支持、信息、视频、命令行、字体、图层、不透明度。

简体版使用简体中文字体，并将叙述与界面术语本地化；不得只转换字形。

## Figures

Figures contain no prose, so every edition of a manual shares its
`figures/`. Change figures in the manual's `scripts/make_figures.py` or
`config/figures.toml`, then run `make figures MANUAL=<manual>`. Do not edit
the SVG files by hand.

## Updating for a new package release

1. In the manual's `manual.toml`, update `version` and `date` under
   `[package]` and add the release to `[releases]`.
2. Add a `#changed(...)` entry for each user-facing change, in all three
   editions. Leave out documentation-only changes.
3. Document new APIs and parameters, and regenerate figures if their output
   changed.
4. Once `main` builds cleanly, run `make publish MANUAL=<manual>` and commit the updated PDFs
   in econ-viz-docs (see the [README](README.md#publishing)).

## License

By contributing you agree that your work will be released under the
[MIT License](LICENSE).
