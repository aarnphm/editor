local ls = require "luasnip"
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

return {
  s("checkbox", fmt("- {} {}", { c(1, { t "[ ]", t "[x]" }), i(0, "Todo") })),
  s("today", fmt("{}", Util.nit.current_date())),
  s("todaylink", fmt("[[{}]]", Util.nit.current_date())),
  s("tomorrow", fmt("{}", Util.nit.tomorrow_date())),
  s("tomorrowlink", fmt("[[{}]]", Util.nit.tomorrow_date())),
  s("yesterday", fmt("{}", Util.nit.yesterday_date())),
  s("yesterdaylink", fmt("[[{}]]", Util.nit.yesterday_date())),
  s(
    "callout",
    fmt("> [!{}] {}\n> {}", {
      c(1, {
        t "note",
        t "abstract",
        t "summary",
        t "tldr",
        t "info",
        t "todo",
        t "tip",
        t "hint",
        t "important",
        t "success",
        t "check",
        t "done",
        t "question",
        t "help",
        t "faq",
        t "warning",
        t "caution",
        t "attention",
        t "failure",
        t "fail",
        t "missing",
        t "danger",
        t "error",
        t "bug",
        t "example",
        t "quote",
        t "cite",
      }),
      i(2, "Title"),
      i(0, "Text"),
    })
  ),
  s("link", fmt("[{}]({})", { i(1, "Text"), i(2, "URL") })),
  s("backlinks", fmt "[[{}]]", { i(1, "path") }),
  s("latex_align", "$$\n\\begin{align*}\n{}\n\\end{align*}\n$$", {
    i(1, "Equation"),
  }),
  s("frac", "$\\frac{}{}$", {
    i(1, "Numerator"),
    i(2, "Denominator"),
  }),
  s("ffrac", "$$\n\\frac{}{}\n$$", {
    i(1, "Numerator"),
    i(2, "Denominator"),
  }),
}
