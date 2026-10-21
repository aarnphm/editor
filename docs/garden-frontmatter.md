# Garden frontmatter

Markdown notes under `~/workspace/garden/content/**/*.md` attach a `garden_frontmatter` LSP client beside Markdown Oxide. It reuses the installed `yaml-language-server` with a local JSON schema. Blink receives key, value, and nested-property completions through its existing LSP source. `K` displays the field documentation, including its owning Garden source when known. YAML syntax and schema errors appear through normal Neovim diagnostics.

Value suggestions open after `:`, a space, or an opening quote, and refresh as you type. This includes `pageLayout`, its aliases, booleans, and nested enum fields. Accepting a key also opens the value menu. Quoted choices preserve paired quotes. Blink uses the Garden client for LSP completion inside frontmatter so edits use YAML string syntax.

`flashcards.default` completes as an optional boolean. Set `flashcards: {default: true}` to render a companion deck at `/<slug>` and the source note at `/<slug>/source`. Leaving the setting absent or setting it to `false` keeps the source at `/<slug>` and the study page at `/<slug>/flashcards`.

`description` and `abstract` support Markdown links (`[label](https://example.org/page#section)`), wikilinks, authored HTML, and LaTeX. Descriptions retain complete link destinations and authored length. Search, feeds, and social previews receive readable link labels.

`tags` values complete from existing notes' frontmatter tags and inline hashtags. Scalar, comma-separated, block-list, and flow-list forms are supported, including hierarchical tags. Each suggestion reports how many notes use it. The Markdown parser excludes code and links when collecting inline tags.

Type `[[` inside a frontmatter value to complete a note or attachment target. Suggestions also match note titles and aliases. `[[note#` completes headings, and `[[#` completes the current note's headings. Completions retain link aliases, existing closing brackets, surrounding text, and list punctuation. A plain value beginning with a wikilink becomes a quoted YAML string when accepted.

The completion index builds asynchronously on the first Garden note and stays in memory. Saving a note refreshes its record. Use `:GardenFrontmatterIndex` to rescan after external file changes. It reads notes without saving them or adding authored values to the schema.

The server sees only the opening YAML block. Its text keeps the original line and column positions. Markdown body text is excluded, and completion and hover requests outside the block return no result. Formatting, sorting code actions, and renaming are disabled for this client.

Saving writes the current buffer immediately. Conform then runs the frontmatter updater as an in-process `nvim-nio` task, followed by the configured Markdown formatters, and persists the final result in one follow-up write. The task awaits `yq` asynchronously and uses the timestamp captured at the initial save. Changes made while processing is running cause its result to be discarded. Tag notes, flashcard exclusions, and frontmatter toggles keep their existing rules. The `bigfile` filetype runs only the frontmatter updater.

Use `:GardenFrontmatter` to jump into the frontmatter. If the note has none, the command inserts an empty fenced block above the body. It does not write the file.

Use `:GardenFrontmatterSchema` after changing the Garden's metadata contract. It regenerates `schemas/garden-frontmatter.json` and reattaches the frontmatter clients for open notes. Generation needs Node and the Garden's already installed `typescript` and `js-yaml` packages. The runtime tag and link index uses Node with the Garden's installed `js-yaml`, `unified`, `remark-parse`, and `remark-frontmatter` packages. The YAML server is already managed by Mason here. No packages are installed by these helpers.

The generator reads the transformer declarations and alias lists, direct frontmatter reads across Quartz, layout-specific SCSS, and authored top-level property names. Parser-specific overrides describe the raw YAML shapes for course resources, study records, citation settings, and triathlon records. The raw and normalized types can differ, so check those overrides when a parser changes. Authored values never enter the generated schema. Additional properties and null placeholders remain allowed.

Run the checks from this Neovim config directory:

```sh
node scripts/garden_frontmatter_schema.mjs
node scripts/check_garden_frontmatter_schema.mjs
node scripts/check_garden_frontmatter_index.mjs
NVIM_APPNAME=nvim nvim --headless -u NONE -l scripts/check_garden_frontmatter.lua
NVIM_APPNAME=nvim nvim --headless '+lua dofile("scripts/check_garden_frontmatter_blink.lua")'
NVIM_APPNAME=nvim nvim --headless '+lua dofile("scripts/check_async_frontmatter.lua")' +qa!
```

The schema check validates existing Garden frontmatter without writing notes. The index check uses the actual Markdown and YAML parsers against temporary fixtures. The headless integration check uses the real language server to exercise completions, nested choices, tag and link edits, Unicode, hover, diagnostic positions, fence changes, path boundaries, insertion, and schema refresh. The Blink check types into unsaved buffers using the normal config startup path and accepts automatic key, value, tag, and link suggestions. Completion fixtures are never saved. The asynchronous save check writes temporary copies with the real `yq` and `oxfmt` executables, delays `yq`, and verifies responsiveness, concurrent edits, rapid saves, metadata rules, and YAML failures.
