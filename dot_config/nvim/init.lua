vim.g.mapleader = ","
vim.g.maplocalleader = " "

vim.opt.autoread = true
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 4
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.timeoutlen = 400
vim.opt.undofile = true
vim.opt.updatetime = 250

-- Keep matches visible while jumping between them, then clear the highlight
-- after the cursor is moved for another reason. Scheduling is required because
-- :nohlsearch state is restored when it is called directly from an autocmd.
local keep_search_highlight = false
for _, key in ipairs({ "*", "#", "n", "N" }) do
  vim.keymap.set("n", key, function()
    keep_search_highlight = true
    return key
  end, { expr = true, silent = true })
end

vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
  group = vim.api.nvim_create_augroup("clear-search-highlight", { clear = true }),
  callback = function()
    if keep_search_highlight then
      keep_search_highlight = false
    elseif vim.v.hlsearch == 1 then
      vim.schedule(function()
        if vim.v.hlsearch == 1 then
          vim.cmd.nohlsearch()
        end
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  desc = "Briefly highlight yanked text",
  callback = function()
    vim.hl.on_yank({ higroup = "YankHighlight", timeout = 250 })
  end,
})

-- Files change under open buffers routinely here: an agent editing the working
-- tree, scripts/format_files.py, a branch switch. 'autoread' only reacts when
-- something runs :checktime, and Neovim runs it on its own for very few events,
-- so poll on idle time and on entering a buffer as well.
local disk_sync = vim.api.nvim_create_augroup("sync-with-disk", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "FocusGained", "TermClose", "TermLeave" }, {
  group = disk_sync,
  nested = true, -- Without this, :checktime cannot fire FileChangedShell below.
  callback = function()
    -- :checktime is not allowed from the command-line window.
    if vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime()
    end
  end,
})

-- Answering here replaces the "file changed on disk" prompt: take what is on
-- disk for a clean buffer, and keep unsaved edits when they would be lost.
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = disk_sync,
  callback = function()
    local reason = vim.v.fcs_reason
    local safe = reason == "changed" or reason == "mode" or reason == "time"
    vim.v.fcs_choice = safe and "reload" or ""
  end,
})

-- The file's mtime as this buffer last saw it, mirroring the timestamp :write
-- compares against. Formatted rather than added up: sec * 1e9 + nsec does not
-- fit in a double.
local function disk_mtime(file)
  local stat = file ~= "" and vim.uv.fs_stat(file) or nil
  return stat and string.format("%d.%09d", stat.mtime.sec, stat.mtime.nsec) or nil
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "FileChangedShellPost" }, {
  group = disk_sync,
  callback = function(args)
    -- A modified buffer here means FileChangedShell just declined to reload, so
    -- the buffer is still older than the file and the stamp must not move.
    if not vim.bo[args.buf].modified then
      vim.b[args.buf].disk_mtime = disk_mtime(vim.api.nvim_buf_get_name(args.buf))
    end
  end,
})

-- :write refuses to overwrite a file whose mtime moved since the buffer read it
-- ("WARNING: The file has been changed since reading it!!!"). Only re-reading
-- the file clears that, which is exactly what unsaved edits rule out, and no
-- merge is possible either. So let the buffer win with a bang, and report it
-- instead of asking. `command` is the write command to run, e.g. "write".
local function save(command)
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  local stamp = vim.b[bufnr].disk_mtime
  local stale = stamp ~= nil and disk_mtime(file) ~= stamp

  if stale and not vim.bo[bufnr].modified then
    -- Nothing of ours to lose: pick up the new contents, then write those.
    vim.cmd.checktime()
    stale = false
  end
  if stale then
    local message = vim.fs.basename(file) .. " also changed on disk; wrote the buffer over it"
    vim.notify(message, vim.log.levels.WARN)
  end
  vim.cmd(command .. (stale and "!" or ""))
end

-- Keep the existing editing vocabulary.
vim.keymap.set("n", "zj", "o<Esc>k", { silent = true })
vim.keymap.set("n", "zk", "O<Esc>j", { silent = true })
vim.keymap.set("n", "zl", ">>", { silent = true })
vim.keymap.set("n", "zh", "<<", { silent = true })
vim.keymap.set("n", "<space>", "i<space><Esc>", { silent = true })
vim.keymap.set("c", "<C-j>", "<Down>")
vim.keymap.set("c", "<C-k>", "<Up>")
vim.keymap.set("c", "<A-j>", "<Down>")
vim.keymap.set("c", "<A-k>", "<Up>")
vim.keymap.set({ "n", "v" }, ";", ":")
vim.keymap.set({ "n", "v" }, ":", ";")
vim.keymap.set("n", "j", "gj", { silent = true })
vim.keymap.set("n", "k", "gk", { silent = true })
vim.keymap.set("", "<Up>", "<C-w>+")
vim.keymap.set("", "<Down>", "<C-w>-")
vim.keymap.set("", "<Left>", "3<C-w><")
vim.keymap.set("", "<Right>", "3<C-w>>")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { silent = true })
vim.keymap.set("n", "<leader>w", function()
  save("write")
end, { silent = true, desc = "Write buffer" })

local function switch_source_header_fallback()
  local file = vim.api.nvim_buf_get_name(0)
  local extension = vim.fn.fnamemodify(file, ":e"):lower()
  local header_extensions = { "h", "hh", "hpp", "hxx" }
  local source_extensions = { "c", "cc", "cpp", "cxx" }
  local is_header = vim.tbl_contains(header_extensions, extension)
  local is_source = vim.tbl_contains(source_extensions, extension)
  if file == "" or not (is_header or is_source) then
    vim.notify("Source/header switch requires a C or C++ file", vim.log.levels.WARN)
    return
  end

  local stem = vim.fn.fnamemodify(file, ":t:r")
  local wanted = is_header and source_extensions or header_extensions
  local directory = vim.fs.dirname(file)
  for _, candidate_extension in ipairs(wanted) do
    local candidate = string.format("%s/%s.%s", directory, stem, candidate_extension)
    if vim.uv.fs_stat(candidate) then
      vim.api.nvim_cmd({ cmd = "edit", args = { candidate } }, {})
      return
    end
  end

  local root = vim.fs.root(file, { ".git", "compile_commands.json", "CMakeLists.txt" }) or directory
  vim.system({ "fd", "--type", "f", "--fixed-strings", stem, root }, { text = true }, function(result)
    vim.schedule(function()
      local matches = {}
      for path in (result.stdout or ""):gmatch("[^\r\n]+") do
        local candidate_extension = vim.fn.fnamemodify(path, ":e"):lower()
        if vim.fn.fnamemodify(path, ":t:r") == stem and vim.tbl_contains(wanted, candidate_extension) then
          table.insert(matches, vim.fs.normalize(path))
        end
      end
      if #matches == 0 then
        vim.notify("No source/header counterpart found for " .. vim.fs.basename(file), vim.log.levels.WARN)
      elseif #matches == 1 then
        vim.api.nvim_cmd({ cmd = "edit", args = { matches[1] } }, {})
      else
        vim.ui.select(matches, { prompt = "Source/header counterpart" }, function(choice)
          if choice then
            vim.api.nvim_cmd({ cmd = "edit", args = { choice } }, {})
          end
        end)
      end
    end)
  end)
end

vim.keymap.set("n", "<leader>h", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clangd = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
  if not clangd then
    switch_source_header_fallback()
    return
  end

  clangd:request("textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(bufnr) }, function(err, uri)
    vim.schedule(function()
      if not err and type(uri) == "string" and uri ~= "" then
        vim.api.nvim_cmd({ cmd = "edit", args = { vim.uri_to_fname(uri) } }, {})
      else
        switch_source_header_fallback()
      end
    end)
  end, bufnr)
end, { silent = true, desc = "Switch source/header" })

-- MiniTabline uses this same Neovim buffer order, keeping the displayed
-- ordinal and the jump mappings in lockstep.
local function listed_buffers()
  return vim.tbl_filter(function(bufnr)
    return vim.bo[bufnr].buflisted
  end, vim.api.nvim_list_bufs())
end

for index = 1, 9 do
  vim.keymap.set("n", "<leader>" .. index, function()
    local bufnr = listed_buffers()[index]
    if bufnr then
      vim.api.nvim_set_current_buf(bufnr)
    else
      vim.notify("No buffer " .. index, vim.log.levels.INFO)
    end
  end, { silent = true, desc = "Buffer " .. index })
end

vim.keymap.set("n", "<leader>d", function()
  if #listed_buffers() <= 1 then
    vim.cmd.quitall()
  else
    require("mini.bufremove").delete(0, false)
  end
end, { silent = true, desc = "Delete buffer or quit" })
vim.keymap.set("n", "0", "^")
vim.keymap.set("n", "^", "0")
vim.keymap.set("", "<leader>q", "<cmd>quitall<cr>", { silent = true, desc = "Quit Neovim" })
vim.keymap.set("", "<leader>x", function()
  save("xit")
end, { silent = true, desc = "Write buffer and quit" })
vim.keymap.set("n", "<C-g>", function()
  vim.api.nvim_echo({ { "File path: " .. vim.fn.expand("%:p"), "Title" } }, true, {})
end, { silent = true })

local function context_path()
  local absolute = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  if absolute == "" then
    return nil
  end
  local relative = vim.fs.relpath(vim.fn.getcwd(), absolute)
  if relative and not relative:match("^%.%.[/\\]") then
    return relative
  end
  return absolute
end

local function copy_context(reference)
  if not reference then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", reference)
  vim.fn.setreg('"', reference)
  vim.notify("Copied " .. reference)
end

vim.keymap.set("n", "<leader>yp", function()
  copy_context(context_path())
end, { silent = true, desc = "Copy file path" })

vim.keymap.set("x", "<leader>yr", function()
  local first = math.min(vim.fn.line("v"), vim.fn.line("."))
  local last = math.max(vim.fn.line("v"), vim.fn.line("."))
  local path = context_path()
  copy_context(path and string.format("%s:%d-%d", path, first, last) or nil)
end, { silent = true, desc = "Copy file and line range" })

vim.keymap.set("", "gV", "`[v`]")
vim.keymap.set("n", "tp", "<cmd>pclose<cr>", { silent = true })
vim.keymap.set("n", "Y", "y$")
vim.keymap.set("v", "q", "<Esc>")

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = { current_line = true, spacing = 2 },
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
  end,
})

-- Run clang-tidy explicitly when a one-off check is useful. clangd also runs
-- it continuously for diagnostics. An optional argument checks another file.
vim.api.nvim_create_user_command("ClangTidy", function(command)
  local file = command.args ~= "" and vim.fs.abspath(command.args) or vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("ClangTidy needs a file on disk", vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.root(file, { ".clangd", ".clang-tidy", ".clang-format", "CMakeLists.txt", ".git" })
    or vim.fs.dirname(file)
  local databases = { root .. "/build/editor", root .. "/build", root, root .. "/out/build" }
  local database
  for _, candidate in ipairs(databases) do
    if vim.uv.fs_stat(candidate .. "/compile_commands.json") then
      database = candidate
      break
    end
  end
  if not database then
    vim.notify("No compile_commands.json found under " .. root, vim.log.levels.ERROR)
    return
  end

  vim.notify("clang-tidy: " .. vim.fs.basename(file))
  vim.system({ "clang-tidy", "-p", database, file }, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local output = (result.stdout or "") .. (result.stderr or "")
      local lines = vim.split(output, "\n", { trimempty = true })
      vim.fn.setqflist({}, " ", { title = "clang-tidy", lines = lines })
      if #lines > 0 then
        vim.cmd.copen()
      end
      local level = result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      vim.notify("clang-tidy finished (exit " .. result.code .. ")", level)
    end)
  end)
end, { nargs = "?", complete = "file", desc = "Run clang-tidy using the project compilation database" })

-- pwin's code convention is clang-format plus a Python post-pass in
-- scripts/format_files.py: rewriting ") {" into "){", padding /***** banner
-- comments out to column 80, and a hard 80-column limit. None of those are
-- expressible as clang-format options, so plain clang-format leaves a buffer
-- non-conformant and CI rejects it.
--
-- The script's CLI only formats whole files, or every changed line in the whole
-- repository. Neither fits one buffer, so drive its module entry points
-- instead: they take a {path: [(first, last)]} map, which is exactly the
-- scoping both "the lines I changed" and "the lines I selected" need.
local pwin_format_driver = [==[
import contextlib
import fnmatch
import subprocess
import sys

scripts_dir, path, spec, base = sys.argv[1:5]
sys.path.insert(0, scripts_dir)
import format_files as ff


def changed_ranges():
    return ff.get_modified_ranges(base).get(path)


def tracked():
    listed = subprocess.run(
        ["git", "ls-files", "--", path], stdout=subprocess.PIPE, check=True
    )
    return bool(listed.stdout.strip())


if any(fnmatch.fnmatch(path, p) for p in ff.EXCLUDE_PATTERNS):
    print("warn\t" + path + " is excluded from pwin formatting")
    raise SystemExit(0)

notes = []
whole_file = False

if spec != "changed":
    ranges = [tuple(int(n) for n in spec.split(":"))]
elif tracked():
    ranges = changed_ranges()
    if not ranges:
        print("info\tNo lines changed from " + base)
        raise SystemExit(0)
else:
    # get_modified_ranges() only reports committed and staged files, so an
    # untracked file has no changed lines to speak of: all of it is new. This is
    # the range the script itself uses for a file it formats end to end.
    whole_file = True
    ranges = [(1, 10**9)]
    notes.append(("info", "Formatted all of " + path + " (untracked)"))

# The per-file progress chatter is only useful for a repo-wide run. Send it to
# stderr so stdout carries nothing but "level<TAB>message" for the editor.
with contextlib.redirect_stdout(sys.stderr):
    clang_ranges = ff.run_clang_format({path: ranges}, False, 1)
    if spec == "changed" and not whole_file:
        # clang-format moves lines, so the pre-format numbers are stale.
        ranges = changed_ranges() or ranges
    ranges = ff.union_ranges(clang_ranges, {path: ranges}).get(path, ranges)
    too_long, messages = ff.apply_custom_rules(path, ranges)

for level, text in notes + messages:
    print(level + "\t" + text)
raise SystemExit(1 if too_long else 0)
]==]

-- Mirrors FILE_TYPES in format_files.py; everything else falls back to conform.
local pwin_format_extensions = {
  c = true, h = true, cpp = true, hpp = true, m = true, mm = true, proto = true,
}

local pwin_format_levels = {
  error = vim.log.levels.ERROR,
  warn = vim.log.levels.WARN,
  info = vim.log.levels.INFO,
}

-- The repo root and repo-relative path when the pwin formatter owns this
-- buffer, or nil when the caller should fall back to conform.
local function pwin_format_target(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" or not pwin_format_extensions[vim.fn.fnamemodify(file, ":e")] then
    return nil
  end
  local root = vim.fs.root(file, ".git")
  if not root or not vim.uv.fs_stat(root .. "/scripts/format_files.py") then
    return nil
  end
  return root, assert(vim.fs.relpath(root, file))
end

-- format_files.py restores the original mtime whenever no line moved (so ninja
-- does not rebuild), which means :checktime can miss a whitespace-only rewrite.
-- Diff against disk instead and splice the buffer, which also keeps the undo
-- history and the cursor position that :edit would throw away.
local function pwin_format_reload(bufnr, file)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  local ok, disk = pcall(vim.fn.readfile, file)
  if not ok then
    return
  end
  -- The buffer now matches the file the script wrote, whether or not any line
  -- differs, so the next save has nothing to warn about.
  vim.b[bufnr].disk_mtime = disk_mtime(file)
  if vim.deep_equal(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true), disk) then
    return
  end
  local view = bufnr == vim.api.nvim_get_current_buf() and vim.fn.winsaveview() or nil
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, disk)
  vim.bo[bufnr].modified = false
  if view then
    vim.fn.winrestview(view)
  end
end

-- Format the current buffer with scripts/format_files.py. `spec` is "changed"
-- for the lines that differ from `base`, or "first:last" for a line range.
-- Returns false when this buffer is not the pwin formatter's to handle.
local function pwin_format(spec, base)
  local bufnr = vim.api.nvim_get_current_buf()
  local root, relative = pwin_format_target(bufnr)
  if not root then
    return false
  end

  -- The script reads and rewrites the file on disk, not the buffer.
  vim.cmd.update()
  local file = vim.api.nvim_buf_get_name(bufnr)
  local command = {
    "python3", "-c", pwin_format_driver,
    root .. "/scripts", relative, spec, base,
  }
  vim.system(command, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      pwin_format_reload(bufnr, file)

      local level = vim.log.levels.INFO
      local lines = {}
      for _, line in ipairs(vim.split(result.stdout or "", "\n", { trimempty = true })) do
        local tag, text = line:match("^(%a+)\t(.*)$")
        level = math.max(level, pwin_format_levels[tag] or vim.log.levels.INFO)
        lines[#lines + 1] = text or line
      end

      if #lines > 0 then
        vim.notify(table.concat(lines, "\n"), level)
      elseif result.code ~= 0 then
        local output = vim.trim((result.stderr or "") .. (result.stdout or ""))
        vim.notify(output ~= "" and output or "format_files.py failed", vim.log.levels.ERROR)
      else
        local scope = spec == "changed" and "changed lines" or ("lines " .. spec)
        vim.notify("Formatted " .. scope .. " in " .. relative)
      end
    end)
  end)
  return true
end

-- :PwinFormat [ref]    format the lines differing from ref (default HEAD)
-- :{range}PwinFormat   format that line range unconditionally
vim.api.nvim_create_user_command("PwinFormat", function(cmd)
  local spec = cmd.range > 0 and (cmd.line1 .. ":" .. cmd.line2) or "changed"
  if not pwin_format(spec, cmd.args ~= "" and cmd.args or "HEAD") then
    vim.notify("PwinFormat needs a pwin C/C++/ObjC file in the repository", vim.log.levels.ERROR)
  end
end, { range = true, nargs = "?", desc = "Format with pwin's scripts/format_files.py" })

local function github_repository_from_remote(remote_url)
  local host, path = remote_url:match("^git@([^:]+):(.+)$")
  if not host then
    host, path = remote_url:match("^ssh://[^@]+@([^/]+)/(.+)$")
  end
  if not host then
    host, path = remote_url:match("^https?://([^/]+)/(.+)$")
  end
  if not host or not path then
    return nil, nil
  end
  return host, path:gsub("%.git/?$", "")
end

-- Resolve the current branch's tracking remote. This keeps GitHub actions on
-- the right fork and also preserves the hostname for GitHub Enterprise.
local function github_repository(root, callback)
  vim.system({ "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" }, {
    cwd = root,
    text = true,
  }, function(upstream_result)
    local upstream = upstream_result.code == 0 and vim.trim(upstream_result.stdout or "") or ""
    local remote = upstream:match("^([^/]+)/") or "origin"
    vim.system({ "git", "remote", "get-url", remote }, { cwd = root, text = true }, function(remote_result)
      local remote_url = remote_result.code == 0 and vim.trim(remote_result.stdout or "") or ""
      local host, repository = github_repository_from_remote(remote_url)
      vim.schedule(function()
        callback(host, repository)
      end)
    end)
  end)
end

local function open_github_pr_for_commit(commit, root)
  if not commit or not commit:match("^%x+$") then
    vim.notify("No Git commit selected", vim.log.levels.WARN)
    return
  end
  root = root or vim.fs.root(vim.api.nvim_buf_get_name(0), ".git") or vim.fs.root(vim.uv.cwd(), ".git")
  if not root then
    vim.notify("GitHub commit lookup requires a Git repository", vim.log.levels.WARN)
    return
  end

  vim.system({ "git", "rev-parse", "--verify", commit .. "^{commit}" }, { cwd = root, text = true }, function(sha_result)
    if sha_result.code ~= 0 then
      vim.schedule(function()
        vim.notify("Unable to resolve commit " .. commit, vim.log.levels.ERROR)
      end)
      return
    end
    local sha = vim.trim(sha_result.stdout or "")

    github_repository(root, function(host, repository)
      if not host or not repository then
        vim.notify("Unable to resolve the GitHub remote", vim.log.levels.ERROR)
        return
      end
      vim.system({
        "gh", "api", "--hostname", host,
        "repos/" .. repository .. "/commits/" .. sha .. "/pulls",
      }, { cwd = root, text = true }, function(api_result)
        vim.schedule(function()
          if api_result.code ~= 0 then
            local message = vim.trim(api_result.stderr or "")
            vim.notify(message ~= "" and message or "GitHub PR lookup failed", vim.log.levels.ERROR)
            return
          end

          local ok, pull_requests = pcall(vim.json.decode, api_result.stdout)
          if not ok then
            vim.notify("GitHub returned an invalid PR response", vim.log.levels.ERROR)
            return
          end
          if #pull_requests == 0 then
            vim.ui.open(string.format("https://%s/%s/commit/%s", host, repository, sha))
          elseif #pull_requests == 1 then
            vim.ui.open(pull_requests[1].html_url)
          else
            vim.ui.select(pull_requests, {
              prompt = "Pull request for " .. sha:sub(1, 12),
              format_item = function(pr)
                return string.format("#%d %s", pr.number, pr.title)
              end,
            }, function(pr)
              if pr then
                vim.ui.open(pr.html_url)
              end
            end)
          end
        end)
      end)
    end)
  end)
end

vim.keymap.set("n", "<leader>gP", function()
  open_github_pr_for_commit(vim.fn.expand("<cword>"))
end, { silent = true, desc = "GitHub PR for commit under cursor" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local result = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not install lazy.nvim:\n" .. result)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      custom_highlights = function(colors)
        return {
          -- Keep the active search match distinct without Catppuccin's red.
          CurSearch = { fg = colors.crust, bg = colors.lavender, bold = true },
          YankHighlight = { fg = colors.crust, bg = colors.lavender },
        }
      end,
      integrations = {
        blink_cmp = true,
        diffview = true,
        gitsigns = true,
        mini = { enabled = true },
        native_lsp = { enabled = true },
        telescope = { enabled = true },
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.ai").setup()
      require("mini.pairs").setup()
      require("mini.icons").setup()
      require("mini.bufremove").setup()
      local statusline = require("mini.statusline")
      statusline.setup({
        use_icons = true,
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
            local git = statusline.section_git({ trunc_width = 40 })
            local diff = statusline.section_diff({ trunc_width = 75 })
            local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
            local lsp = statusline.section_lsp({ trunc_width = 75 })
            local filename = statusline.section_filename({ trunc_width = 140 })
            local search = statusline.section_searchcount({ trunc_width = 75 })
            -- line2byte() uses Neovim's existing line index; wordcount()
            -- rescans the whole buffer on every statusline redraw.
            local bytes = math.max(vim.fn.line2byte(vim.fn.line("$") + 1) - 1, 0)
            local size
            if bytes < 1024 then
              size = bytes .. "B"
            elseif bytes < 1024 * 1024 then
              size = math.floor(bytes / 1024 + 0.5) .. "KiB"
            else
              size = math.floor(bytes / (1024 * 1024) + 0.5) .. "MiB"
            end

            return statusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
              "%<",
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=",
              { hl = "MiniStatuslineFileinfo", strings = { vim.bo.filetype, size } },
              { hl = mode_hl, strings = { search, "%l/%L:%v" } },
            })
          end,
        },
      })
      local tabline = require("mini.tabline")
      local subscript_digits = {
        ["0"] = "₀",
        ["1"] = "₁",
        ["2"] = "₂",
        ["3"] = "₃",
        ["4"] = "₄",
        ["5"] = "₅",
        ["6"] = "₆",
        ["7"] = "₇",
        ["8"] = "₈",
        ["9"] = "₉",
      }
      local function subscript(number)
        return tostring(number):gsub("%d", subscript_digits)
      end
      tabline.setup({
        show_icons = false,
        tabpage_section = "right",
        format = function(buf_id, label)
          local ordinal = 0
          for index, bufnr in ipairs(listed_buffers()) do
            if bufnr == buf_id then
              ordinal = index
              break
            end
          end
          local suffix = vim.bo[buf_id].modified and " ●" or ""
          return string.format(" %s%s%s ", label, subscript(ordinal), suffix)
        end,
      })

      -- Mini deliberately inherits Vim's generic TabLine groups. Give it a
      -- flatter Catppuccin treatment with a strong, but not loud, active tab.
      local colors = require("catppuccin.palettes").get_palette("mocha")
      local set_hl = vim.api.nvim_set_hl
      set_hl(0, "MiniTablineCurrent", { fg = colors.crust, bg = colors.mauve, bold = true })
      set_hl(0, "MiniTablineVisible", { fg = colors.text, bg = colors.surface1 })
      set_hl(0, "MiniTablineHidden", { fg = colors.subtext0, bg = colors.mantle })
      set_hl(0, "MiniTablineModifiedCurrent", { fg = colors.crust, bg = colors.mauve, bold = true })
      set_hl(0, "MiniTablineModifiedVisible", { fg = colors.peach, bg = colors.surface1, bold = true })
      set_hl(0, "MiniTablineModifiedHidden", { fg = colors.peach, bg = colors.mantle })
      set_hl(0, "MiniTablineFill", { bg = colors.base })
      set_hl(0, "MiniTablineTabpagesection", { fg = colors.blue, bg = colors.surface0, bold = true })
      set_hl(0, "MiniTablineTrunc", { fg = colors.overlay1, bg = colors.base })
    end,
  },
  {
    "dlyongemallo/diffview-plus.nvim",
    version = "*",
    cmd = {
      "DiffviewOpen",
      "DiffviewToggle",
      "DiffviewFileHistory",
      "DiffviewClose",
      "DiffviewRefresh",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewToggle<cr>", desc = "Git review changes" },
      { "<leader>gh", "<cmd>DiffviewFileHistory --follow %<cr>", desc = "Git file history" },
      {
        "<leader>gh",
        "<Esc><cmd>'<,'>DiffviewFileHistory<cr>",
        mode = "x",
        desc = "Git selection history",
      },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git repository history" },
    },
    opts = function()
      local actions = require("diffview.actions")
      local function open_history_pr()
        local view = require("diffview.lib").get_current_view()
        local item = view and view.panel and view.panel:get_item_at_cursor() or nil
        local commit = item and item.commit or nil
        local hash = type(commit) == "table" and commit.hash or commit
        local root = view and view.adapter and view.adapter.ctx and view.adapter.ctx.dir or nil
        open_github_pr_for_commit(hash, root)
      end

      local function update_index_hunk(operation)
        return function()
          local view = require("diffview.lib").get_current_view()
          local entry = view and view.cur_entry or nil
          local layout = view and view.cur_layout or nil
          local old = layout and layout.a or nil
          local new = layout and layout.b or nil
          if not old or not new or not old.file or not new.file then
            vim.notify("This Diffview layout has no stageable hunk", vim.log.levels.WARN)
            return
          end

          local target, source
          if operation == "stage" and entry.kind == "working" then
            -- Working-tree entries compare INDEX (a) against LOCAL (b).
            target, source = old, new
          elseif operation == "unstage" and entry.kind == "staged" then
            -- Staged entries compare HEAD (a) against INDEX (b).
            target, source = new, old
          else
            local expected = operation == "stage" and "Changes" or "Staged changes"
            vim.notify("Select a file under " .. expected .. " first", vim.log.levels.WARN)
            return
          end

          target:focus()
          vim.cmd("diffget " .. source.file.bufnr)
          vim.cmd.write()
        end
      end

      local panel_maps = {
        q = "<cmd>DiffviewClose<cr>",
        ["<Esc>"] = "<cmd>DiffviewClose<cr>",
        ["<leader>b"] = false,
        ["<leader>e"] = false,
        ["<leader>ge"] = actions.focus_files,
        ["<leader>gE"] = actions.toggle_files,
      }
      local view_maps = vim.tbl_extend("force", panel_maps, {
        ["<leader>gs"] = update_index_hunk("stage"),
        ["<leader>gu"] = update_index_hunk("unstage"),
      })
      return {
        use_icons = false,
        enhanced_diff_hl = true,
        clean_up_buffers = true,
        auto_close_on_empty = true,
        show_help_hints = false,
        diffopt = { algorithm = "histogram", linematch = 60 },
        view = {
          default = { layout = "diff2_horizontal" },
          file_history = { layout = "diff2_horizontal" },
          merge_tool = {
            layout = "diff4_mixed",
            disable_diagnostics = true,
            winbar_info = true,
          },
        },
        file_panel = {
          listing_style = "tree",
          show_branch_name = true,
          win_config = { position = "left", width = 35 },
        },
        file_history_panel = { date_format = "relative" },
        keymaps = {
          view = view_maps,
          file_panel = panel_maps,
          file_history_panel = vim.tbl_extend("force", panel_maps, {
            gx = open_history_pr,
            y = actions.copy_hash,
          }),
        },
      }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Enrich the on-demand blame popup with linked PR numbers via `gh`.
      -- This stays off the cursor-movement path, so normal editing remains local.
      gh = true,
      -- Show authorship only after the cursor settles, keeping normal editing quiet.
      -- :Gitsigns blame_line opens the full commit details when more context is useful.
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 600,
        virt_text_pos = "eol",
      },
      current_line_blame_formatter = " <author>, <author_time:%Y-%m-%d> • <summary>",
      preview_config = { border = "rounded" },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        local function visual_range()
          return { vim.fn.line("."), vim.fn.line("v") }
        end
        local function open_line_provenance()
          gitsigns.blame_line({}, function(err)
            vim.schedule(function()
              if err then
                vim.notify(err, vim.log.levels.ERROR)
                return
              end
              for _, winid in ipairs(vim.api.nvim_list_wins()) do
                if vim.w[winid].gitsigns_preview == "blame" then
                  local popup_bufnr = vim.api.nvim_win_get_buf(winid)
                  local title = vim.api.nvim_buf_get_lines(popup_bufnr, 0, 1, false)[1] or ""
                  local pr_col = title:find("#%d+")
                  local sha_col = title:find("%x%x%x%x%x%x%x")
                  vim.api.nvim_set_current_win(winid)
                  vim.api.nvim_win_set_cursor(winid, { 1, (pr_col or sha_col or 1) - 1 })
                  vim.keymap.set("n", "<Esc>", "<cmd>quit!<cr>", {
                    buffer = popup_bufnr,
                    silent = true,
                    desc = "Close Git provenance",
                  })
                  vim.keymap.set("n", "<CR>", "gx", {
                    buffer = popup_bufnr,
                    remap = true,
                    silent = true,
                    desc = "Open Git link",
                  })
                  local initial_cursor = vim.api.nvim_win_get_cursor(winid)
                  local transient_group = vim.api.nvim_create_augroup("gitsigns-provenance-" .. popup_bufnr, {
                    clear = true,
                  })
                  vim.api.nvim_create_autocmd("CursorMoved", {
                    buffer = popup_bufnr,
                    group = transient_group,
                    callback = function()
                      if not vim.api.nvim_win_is_valid(winid) then
                        return
                      end
                      local cursor = vim.api.nvim_win_get_cursor(winid)
                      if cursor[1] ~= initial_cursor[1] or cursor[2] ~= initial_cursor[2] then
                        vim.api.nvim_win_close(winid, true)
                        pcall(vim.api.nvim_del_augroup_by_id, transient_group)
                      end
                    end,
                  })
                  return
                end
              end
            end)
          end)
        end
        local function open_file_blame()
          gitsigns.blame({}, function(err)
            vim.schedule(function()
              if err then
                vim.notify(err, vim.log.levels.ERROR)
                return
              end
              local blame_bufnr = vim.api.nvim_get_current_buf()
              if vim.bo[blame_bufnr].filetype ~= "gitsigns-blame" then
                return
              end
              for _, key in ipairs({ "q", "<Esc>" }) do
                vim.keymap.set("n", key, "<cmd>close<cr>", {
                  buffer = blame_bufnr,
                  silent = true,
                  desc = "Close Git blame",
                })
              end
            end)
          end)
        end
        local function open_github_blame()
          local file = vim.api.nvim_buf_get_name(bufnr)
          local line = vim.api.nvim_win_get_cursor(0)[1]
          local root = file ~= "" and vim.fs.root(file, ".git") or nil
          if not root then
            vim.notify("GitHub blame requires a file in a Git repository", vim.log.levels.WARN)
            return
          end

          vim.system({ "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" }, {
            cwd = root,
            text = true,
          }, function(upstream_result)
            local upstream_remote
            local upstream_branch
            if upstream_result.code == 0 then
              local upstream = vim.trim(upstream_result.stdout or "")
              upstream_remote, upstream_branch = upstream:match("^([^/]+)/(.+)$")
            end

            local function open_for_repository(repository_arg)
              local command = { "gh", "repo", "view" }
              if repository_arg then
                vim.list_extend(command, { repository_arg })
              end
              vim.list_extend(command, { "--json", "url,defaultBranchRef" })

              vim.system(command, { cwd = root, text = true }, function(result)
                vim.schedule(function()
                  if result.code ~= 0 then
                    local message = vim.trim(result.stderr or "")
                    vim.notify(message ~= "" and message or "Unable to resolve the GitHub repository", vim.log.levels.ERROR)
                    return
                  end

                  local ok, repository = pcall(vim.json.decode, result.stdout)
                  local default_branch = ok and repository.defaultBranchRef and repository.defaultBranchRef.name or nil
                  local branch = upstream_branch or default_branch
                  local relative = vim.fs.relpath(root, file)
                  if not ok or not repository.url or not branch or not relative then
                    vim.notify("GitHub did not return a repository URL and usable branch", vim.log.levels.ERROR)
                    return
                  end

                  local encoded_path = relative:gsub("[^/]+", function(segment)
                    return vim.uri_encode(segment)
                  end)
                  local url = string.format(
                    "%s/blame/%s/%s#L%d",
                    repository.url,
                    vim.uri_encode(branch),
                    encoded_path,
                    line
                  )
                  vim.ui.open(url)
                end)
              end)
            end

            local function gh_repository(remote_url)
              local host, path = remote_url:match("^git@([^:]+):(.+)$")
              if not host then
                host, path = remote_url:match("^ssh://[^@]+@([^/]+)/(.+)$")
              end
              if not host then
                host, path = remote_url:match("^https?://([^/]+)/(.+)$")
              end
              if not host or not path then
                return nil
              end
              return host .. "/" .. path:gsub("%.git/?$", "")
            end

            if not upstream_remote then
              open_for_repository(nil)
              return
            end

            -- Resolve the repository from the branch's configured remote too.
            -- This matters when the tracking branch lives on a fork or on a
            -- non-origin remote.
            vim.system({ "git", "remote", "get-url", upstream_remote }, {
              cwd = root,
              text = true,
            }, function(remote_result)
              local remote_url = remote_result.code == 0 and vim.trim(remote_result.stdout or "") or nil
              open_for_repository(remote_url and gh_repository(remote_url) or nil)
            end)
          end)
        end

        map("n", "<leader>go", open_line_provenance, "Git line provenance and PR")
        map("n", "<leader>gb", open_file_blame, "Git blame file")
        map("n", "<leader>gB", open_github_blame, "GitHub blame current file")
        map("n", "<leader>gj", function() gitsigns.nav_hunk("next") end, "Git next hunk")
        map("n", "<leader>gk", function() gitsigns.nav_hunk("prev") end, "Git previous hunk")
        map("n", "<leader>gp", gitsigns.preview_hunk, "Git preview hunk")
        map("n", "<leader>gi", gitsigns.preview_hunk_inline, "Git preview hunk inline")
        map("n", "<leader>gs", gitsigns.stage_hunk, "Git stage or unstage hunk")
        map("x", "<leader>gs", function() gitsigns.stage_hunk(visual_range()) end, "Git stage selected lines")
        map("n", "<leader>gr", gitsigns.reset_hunk, "Git reset hunk")
        map("x", "<leader>gr", function() gitsigns.reset_hunk(visual_range()) end, "Git reset selected lines")
        map("n", "<leader>gS", gitsigns.stage_buffer, "Git stage buffer")
        map("n", "<leader>gU", gitsigns.reset_buffer_index, "Git unstage buffer")
        map("n", "<leader>gd", function() gitsigns.diffthis("HEAD") end, "Git diff buffer against HEAD")
        map("n", "<leader>gq", function() gitsigns.setqflist("all") end, "Git list repository changes")
      end,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    opts = {
      ensure_installed = { "c", "cmake", "cpp", "html", "lua", "markdown", "markdown_inline", "vim", "vimdoc", "yaml" },
    },
    config = function(_, opts)
      local treesitter = require("nvim-treesitter")
      treesitter.setup({})
      treesitter.install(opts.ensure_installed)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        pattern = { "c", "cmake", "cpp", "help", "html", "lua", "markdown", "vim", "yaml" },
        callback = function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          local stat = path ~= "" and vim.uv.fs_stat(path) or nil
          local too_large = (stat and stat.size > 2 * 1024 * 1024)
            or vim.api.nvim_buf_line_count(args.buf) > 50000
          if not too_large then
            pcall(vim.treesitter.start, args.buf)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      latex = { enabled = true, converter = { "latex2text" } },
      render_modes = { "n", "c", "t" },
    },
  },
  {
    "Derrekito/devdocs.nvim",
    ft = "c",
    cmd = { "Devdocs", "DevdocsUpdate", "DevdocsNote" },
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      viewer = "markdown",
      width = 88,
      docsets = {
        c = { slug = "c", lang = "c" },
      },
      filetypes = { c = "c" },
    },
    config = function(_, opts)
      require("devdocs").setup(opts)

      -- DevDocs currently opens pages in a split. Turn only its documentation
      -- buffers into a centered float; ordinary Markdown buffers stay normal.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("devdocs-float", { clear = true }),
        pattern = "markdown",
        callback = function(args)
          if not vim.b[args.buf].devdocs then
            return
          end

          local win = vim.fn.bufwinid(args.buf)
          if win == -1 then
            return
          end
          local width = math.min(100, vim.o.columns - 4)
          local height = math.min(36, vim.o.lines - 4)
          -- Neovim cannot turn the sole editor window into a float. DevDocs
          -- normally creates a split first, but keep direct/test buffers safe.
          if #vim.api.nvim_tabpage_list_wins(0) == 1 then
            return
          end
          vim.api.nvim_win_set_config(win, {
            relative = "editor",
            row = math.floor((vim.o.lines - height) / 2 - 1),
            col = math.floor((vim.o.columns - width) / 2),
            width = width,
            height = height,
            border = "rounded",
            style = "minimal",
            title = " cppreference ",
            title_pos = "center",
          })
        end,
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      triggers = {
        { "<auto>", mode = "nixsotc" },
        { "t", mode = { "n", "x" } },
      },
      spec = {
        { "t", group = "search", mode = { "n", "x" } },
        { "<leader>a", group = "AI / Claude" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "symbols" },
        { "<leader>y", group = "copy context" },
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = {
        preset = "super-tab",
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            end
            return cmp.select_and_accept()
          end,
          "snippet_forward",
          "fallback",
        },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        menu = { border = "rounded" },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          window = { border = "rounded" },
        },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ft = { "c", "cpp", "objc", "objcpp" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--compile-commands-dir=build/editor",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
        },
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        root_markers = { ".clangd", ".clang-tidy", ".clang-format", "CMakeLists.txt", ".git" },
      })
      vim.lsp.enable("clangd")
    end,
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>f",
        function()
          -- pwin C files go through format_files.py, which only touches the
          -- lines that differ from HEAD. Everything else conform formats whole.
          if not pwin_format("changed", "HEAD") then
            require("conform").format({ async = true, lsp_format = "fallback" })
          end
        end,
        mode = "n",
        desc = "Format changed lines (pwin) or whole file",
      },
      {
        "<leader>f",
        function()
          local mode = vim.fn.mode()
          local anchor = vim.fn.getpos("v")
          local cursor = vim.fn.getpos(".")
          local first, last = anchor, cursor
          if anchor[2] > cursor[2] or (anchor[2] == cursor[2] and anchor[3] > cursor[3]) then
            first, last = cursor, anchor
          end

          -- format_files.py works in whole lines, and rewrites the buffer from
          -- disk afterwards, so leave visual mode before handing it the range.
          if pwin_format_target(vim.api.nvim_get_current_buf()) then
            vim.cmd("normal! " .. vim.keycode("<Esc>"))
            pwin_format(first[2] .. ":" .. last[2], "HEAD")
            return
          end

          local start_col = mode == "V" and 0 or math.max(first[3] - 1, 0)
          local last_line = vim.api.nvim_buf_get_lines(0, last[2] - 1, last[2], true)[1]
          local end_col = mode == "V" and #last_line or math.min(last[3], #last_line)
          require("conform").format({
            async = true,
            lsp_format = "fallback",
            range = {
              start = { first[2], start_col },
              ["end"] = { last[2], end_col },
            },
          })
        end,
        mode = "v",
        desc = "Format selection",
      },
    },
    opts = {
      notify_on_error = true,
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        objc = { "clang_format" },
        objcpp = { "clang_format" },
        cmake = { "cmake_format", stop_after_first = true },
        lua = { "stylua", stop_after_first = true },
        nix = { "nixfmt", stop_after_first = true },
      },
    },
  },
  {
    "Civitasv/cmake-tools.nvim",
    init = function()
      vim.api.nvim_create_autocmd("BufReadPre", {
        group = vim.api.nvim_create_augroup("load-cmake-tools", { clear = true }),
        callback = function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          local extension = vim.fn.fnamemodify(path, ":e")
          local c_family = vim.tbl_contains({ "c", "cc", "cpp", "cxx", "h", "hh", "hpp", "hxx" }, extension)
          if c_family and vim.fs.root(args.buf, { "CMakeLists.txt", "CMakePresets.json" }) then
            -- plenary.scandir probes the hard-coded UID/GID 1000 while loading.
            -- On macOS, Directory Services can block for many seconds resolving
            -- that nonexistent account. Its FFI branch only adds owner/group
            -- names to `ls` output; cmake-tools only needs scan_dir().
            require("lazy").load({ plugins = { "plenary.nvim" } })
            local jit_runtime = _G.jit
            _G.jit = nil
            local loaded, scandir = pcall(require, "plenary.scandir")
            _G.jit = jit_runtime
            if not loaded then
              error(scandir)
            end
            require("lazy").load({ plugins = { "cmake-tools.nvim" } })
          end
        end,
      })
    end,
    cmd = {
      "CMakeBuild",
      "CMakeClean",
      "CMakeGenerate",
      "CMakeInstall",
      "CMakeOpen",
      "CMakeQuickBuild",
      "CMakeQuickRun",
      "CMakeRun",
      "CMakeSelectBuildTarget",
      "CMakeSelectBuildDir",
      "CMakeSelectBuildType",
      "CMakeSelectConfigurePreset",
      "CMakeSelectKit",
      "CMakeSelectLaunchTarget",
      "CMakeSelectWorkflowPreset",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- Keep Neovim's configure/build artifacts separate from the build tree
      -- used to run pwin (resolved relative to each CMake project root).
      cmake_build_directory = "build/editor",
      cmake_compile_commands_options = { action = "none" },
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    },
  },
  {
    "mcuste/herdr-context.nvim",
    cmd = { "HerdrContextSendBuffer" },
    opts = {},
    keys = {
      { "<leader>af", "<cmd>HerdrContextSendBuffer<cr>", desc = "Send file to agent" },
      { "<leader>as", "<cmd>HerdrContextSendBuffer<cr>", mode = "x", desc = "Send selection to agent" },
    },
  },
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
    keys = {
      { "-", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Open yazi at current file" },
    },
    opts = {
      open_for_directories = false,
      floating_window_scaling_factor = 0.9,
      yazi_floating_window_border = "rounded",
    },
  },
  {
    "dmtrKovalenko/fff",
    build = "nix run .#release",
    lazy = false,
    opts = {
      layout = {
        border = "rounded",
      },
      keymaps = {
        move_up = { "<Up>", "<C-p>", "<A-k>" },
        move_down = { "<Down>", "<C-n>", "<A-j>" },
      },
    },
    keys = {
      { "tt", function() require("fff").find_files() end, desc = "Find files" },
      { "tg", function() require("fff").live_grep() end, desc = "Live grep" },
      {
        "tw",
        function() require("fff").live_grep_under_cursor() end,
        mode = { "n", "x" },
        desc = "Grep word or selection",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        mappings = {
          i = {
            ["<Esc>"] = function(prompt_bufnr)
              local action_state = require("telescope.actions.state")
              if action_state.get_current_line() == "" then
                require("telescope.actions").close(prompt_bufnr)
              else
                action_state.get_current_picker(prompt_bufnr):set_prompt("")
              end
            end,
          },
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")
    end,
    keys = {
      { "to", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Definition" },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "<leader>sb", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Buffer symbols" },
      { "<leader>sw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>cb", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Buffer diagnostics" },
    },
  },
}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
})
