#import "/template/manual.typ": *

#let edition = sys.inputs.at("edition", default: "en")
#let config = (
  editions: ("en", "zh-TW", "zh-CN"),
  package: (
    name: "fixture",
    version: "1.0.0",
    date: "2026-10-04",
    repo: "https://example.com/repo",
    site: "https://example.com",
  ),
  title: (
    en: "The fixture Package",
    zh-TW: "fixture 套件",
    zh-CN: "fixture 软件包",
  ),
  releases: (:),
  authors: ((name: (en: "Test Author", zh-TW: "測試作者", zh-CN: "测试作者")),),
)

#show: manual.with(config, edition: edition)

= Statements

#theorem(name: [Identity])[For every $x$, $x = x$.] <thm-identity>

#proof(of: <thm-identity>)[Reflexivity gives the result.]

#show: appendix

= Details <app-details>

#proof[The appendix proof is complete.]
