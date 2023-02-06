return function()
  local crates = require("crates")
  local icons = {
    diagnostics = require("utils.icons").get("diagnostics", true),
    git = require("utils.icons").get("git", true),
    misc = require("utils.icons").get("misc", true),
    ui = require("utils.icons").get("ui", true),
    kind = require("utils.icons").get("kind", true),
  }

  crates.setup({
    avoid_prerelease = false,
    smart_insert = true,
    insert_closing_quote = true,
    autoload = true,
    autoupdate = true,
    autoupdate_throttle = 250,
    loading_indicator = true,
    date_format = "%Y-%m-%d",
    thousands_separator = ",",
    notification_title = "Crates",
    curl_args = { "-sL", "--retry", "1" },
    disable_invalid_feature_diagnostic = false,
    text = {
      loading = " " .. icons.misc.Watch .. "Loading",
      version = " " .. icons.ui.Check .. "%s",
      prerelease = " " .. icons.diagnostics.Warning_alt .. "%s",
      yanked = " " .. icons.diagnostics.Error .. "%s",
      nomatch = " " .. icons.diagnostics.Question .. "No match",
      upgrade = " " .. icons.diagnostics.Hint_alt .. "%s",
      error = " " .. icons.diagnostics.Error .. "Error fetching crate",
    },
    popup = {
      autofocus = false,
      hide_on_select = true,
      copy_register = '"',
      style = "minimal",
      border = "rounded",
      show_version_date = true,
      show_dependency_version = true,
      max_height = 30,
      min_width = 20,
      padding = 1,
      text = {
        title = icons.ui.Package .. "%s",
        description = "%s",
        created_label = icons.misc.Added .. "created" .. "        ",
        created = "%s",
        updated_label = icons.misc.ManUp .. "updated" .. "        ",
        updated = "%s",
        downloads_label = icons.ui.CloudDownload .. "downloads      ",
        downloads = "%s",
        homepage_label = icons.misc.Campass .. "homepage       ",
        homepage = "%s",
        repository_label = icons.git.Repo .. "repository     ",
        repository = "%s",
        documentation_label = icons.diagnostics.Information_alt .. "documentation  ",
        documentation = "%s",
        crates_io_label = icons.ui.Package .. "crates.io      ",
        crates_io = "%s",
        categories_label = icons.kind.Class .. "categories     ",
        keywords_label = icons.kind.Keyword .. "keywords       ",
        version = "  %s",
        prerelease = icons.diagnostics.Warning_alt .. "%s prerelease",
        yanked = icons.diagnostics.Error .. "%s yanked",
        version_date = "  %s",
        feature = "  %s",
        enabled = icons.ui.Play .. "%s",
        transitive = icons.ui.List .. "%s",
        normal_dependencies_title = icons.kind.Interface .. "Dependencies",
        build_dependencies_title = icons.misc.Gavel .. "Build dependencies",
        dev_dependencies_title = icons.misc.Glass .. "Dev dependencies",
        dependency = "  %s",
        optional = icons.ui.BigUnfilledCircle .. "%s",
        dependency_version = "  %s",
        loading = " " .. icons.misc.Watch,
      },
    },
    src = {
      insert_closing_quote = true,
      text = {
        prerelease = " " .. icons.diagnostics.Warning_alt .. "pre-release ",
        yanked = " " .. icons.diagnostics.Error_alt .. "yanked ",
      },
    },
  })

  vim.api.nvim_set_keymap("n", "<leader>ct", "", { noremap = true, silent = true, callback = crates.toggle })
  vim.api.nvim_set_keymap("n", "<leader>cr", "", { noremap = true, silent = true, callback = crates.reload })

  vim.api.nvim_set_keymap(
    "n",
    "<leader>cv",
    "",
    { noremap = true, silent = true, callback = crates.show_versions_popup }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>cf",
    "",
    { noremap = true, silent = true, callback = crates.show_features_popup }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>cd",
    "",
    { noremap = true, silent = true, callback = crates.show_dependencies_popup }
  )

  vim.api.nvim_set_keymap("n", "<leader>cu", "", { noremap = true, silent = true, callback = crates.update_crate })
  vim.api.nvim_set_keymap("v", "<leader>cu", "", { noremap = true, silent = true, callback = crates.update_crates })
  vim.api.nvim_set_keymap("n", "<leader>ca", "", { noremap = true, silent = true, callback = crates.update_all_crates })
  vim.api.nvim_set_keymap("n", "<leader>cU", "", { noremap = true, silent = true, callback = crates.upgrade_crate })
  vim.api.nvim_set_keymap("v", "<leader>cU", "", { noremap = true, silent = true, callback = crates.upgrade_crates })
  vim.api.nvim_set_keymap(
    "n",
    "<leader>cA",
    "",
    { noremap = true, silent = true, callback = crates.upgrade_all_crates }
  )

  vim.api.nvim_set_keymap("n", "<leader>cH", "", { noremap = true, silent = true, callback = crates.open_homepage })
  vim.api.nvim_set_keymap("n", "<leader>cR", "", { noremap = true, silent = true, callback = crates.open_repository })
  vim.api.nvim_set_keymap(
    "n",
    "<leader>cD",
    "",
    { noremap = true, silent = true, callback = crates.open_documentation }
  )
  vim.api.nvim_set_keymap("n", "<leader>cC", "", { noremap = true, silent = true, callback = crates.open_crates_io })
end
