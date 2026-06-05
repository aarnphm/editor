local root = vim.env.MARKDOWN_FRONTMATTER_ROOT
local path = vim.api.nvim_buf_get_name(0)
local ignored_suffixes = {
  "%.flashcards%.md$",
  "%.fc%.md$",
}

if not root or root == "" then error "MARKDOWN_FRONTMATTER_ROOT is not set" end
if path == "" then error "buffer has no file path" end

for _, suffix in ipairs(ignored_suffixes) do
  if path:match(suffix) then return end
end

local function system(cmd, input)
  local result = vim.system(cmd, { stdin = input, text = true }):wait()
  if result.code ~= 0 then error((result.stderr or "") ~= "" and result.stderr or table.concat(cmd, " ")) end
  return result.stdout or ""
end

local function yaml_to_table(yaml)
  if vim.trim(yaml) == "" then return {} end
  local json = system({ "yq", "eval", "-o=json", "-" }, yaml)
  local ok, parsed = pcall(vim.fn.json_decode, json)
  if ok and type(parsed) == "table" then return parsed end
  return {}
end

local function table_to_yaml(tbl)
  local yaml = system({ "yq", "eval", "sort_keys(..)", "-P", "-p=json", "-" }, vim.fn.json_encode(tbl))
  local lines = {}
  for line in yaml:gmatch "[^\r\n]+" do
    table.insert(lines, line)
  end
  return lines
end

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
local fm_start, fm_end

if lines[1] and lines[1]:match "^---%s*$" then
  fm_start = 1
  for i = 2, #lines do
    if lines[i]:match "^---%s*$" then
      fm_end = i
      break
    end
  end
end

local existing = {}
if fm_start and fm_end and fm_end > fm_start + 1 then
  existing = yaml_to_table(table.concat(vim.list_slice(lines, fm_start + 1, fm_end - 1), "\n"))
end

local filename = vim.fs.basename(path)
local id = filename:gsub("%.md$", "")
local normalized_root = vim.fs.normalize(root)
local normalized_path = vim.fs.normalize(path)
local is_tag_note = normalized_path:find(normalized_root .. "/tags/", 1, true) ~= nil

local defaults = is_tag_note and { title = id }
  or { date = os.date "%Y-%m-%d", id = id, tags = { "seed" }, title = id }
local frontmatter = vim.tbl_deep_extend("force", defaults, existing)

if frontmatter.title == nil then frontmatter.title = id end
if frontmatter.aliases and #frontmatter.aliases == 0 then frontmatter.aliases = nil end
if not is_tag_note then
  local offset = os.date "%z"
  frontmatter.modified = os.date "%Y-%m-%d %H:%M:%S"
    .. string.format(" GMT%s%s:%s", offset:sub(1, 1), offset:sub(2, 3), offset:sub(4, 5))
end

local new_fm = { "---" }
vim.list_extend(new_fm, table_to_yaml(frontmatter))
table.insert(new_fm, "---")

if fm_start and fm_end then
  vim.api.nvim_buf_set_lines(0, fm_start - 1, fm_end, false, new_fm)
else
  vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.list_extend(new_fm, { "" }))
end
