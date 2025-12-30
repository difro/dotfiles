-- Claude Translate: Translate text using Claude CLI
local M = {}

-- Translate selected text and show in floating window
local function translate_selection(opts)
  opts = opts or {}
  local model = opts.model or "haiku"
  local content = opts.content
  local source_filetype = opts.filetype or vim.bo.filetype

  if not content or content == "" then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  -- Create temp file for input
  local tmpdir = os.getenv("TMPDIR") or "/tmp"
  local input_file = tmpdir .. "/claude_translate_sel_" .. os.time() .. ".txt"

  local f = io.open(input_file, "w")
  if not f then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return
  end
  f:write(content)
  f:close()

  -- Create floating window
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(20, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Claude Translation (" .. model .. ") ",
    title_pos = "center",
  })

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = true
  if source_filetype and source_filetype ~= "" then
    vim.bo[buf].filetype = source_filetype
  end

  -- Show progress
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "Translating...",
    "",
    "Please wait...",
  })

  -- Close with q or Esc
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })

  -- Build command - use shell for proper expansion
  local cmd = string.format(
    'cat %s | claude --model %s --no-session-persistence -p "Translate the following text to Korean. Output ONLY the translated text, nothing else:"',
    vim.fn.shellescape(input_file),
    model
  )

  local output_lines = {}
  local first_output = true

  vim.fn.jobstart({ "sh", "-c", cmd }, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      if data then
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buf) then return end

          if first_output then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            first_output = false
          end

          for _, line in ipairs(data) do
            if line ~= "" or #output_lines > 0 then
              table.insert(output_lines, line)
            end
          end
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
        end)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buf) then return end
          for _, line in ipairs(data) do
            if line ~= "" then
              table.insert(output_lines, "[stderr] " .. line)
            end
          end
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
        end)
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        os.remove(input_file)
        if not vim.api.nvim_buf_is_valid(buf) then return end

        if exit_code ~= 0 then
          vim.api.nvim_buf_set_lines(buf, 0, 0, false, {
            "[ERROR] Translation failed (exit code: " .. exit_code .. ")",
            "",
          })
        end
      end)
    end,
  })
end

-- Translate buffer and show in split window
local function translate_buffer(opts)
  opts = opts or {}
  local model = opts.model or "haiku"
  local split_type = opts.split or "split"
  local source_filetype = vim.bo.filetype

  -- Get current buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  if content == "" then
    vim.notify("Buffer is empty", vim.log.levels.WARN)
    return
  end

  -- Create temp file for input
  local tmpdir = os.getenv("TMPDIR") or "/tmp"
  local input_file = tmpdir .. "/claude_translate_input_" .. os.time() .. ".txt"

  local f = io.open(input_file, "w")
  if not f then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return
  end
  f:write(content)
  f:close()

  -- Open split window first with progress indicator
  vim.cmd(split_type .. " | enew")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, "[Claude Translation - " .. model .. "]")
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  if source_filetype and source_filetype ~= "" then
    vim.bo[buf].filetype = source_filetype
  end

  -- Show initial progress message
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "Translating with Claude (" .. model .. ")...",
    "",
    "Please wait...",
  })

  -- Build claude command - use shell for proper piping
  local cmd = string.format(
    'cat %s | claude --model %s -p "Translate the following text to Korean. Output ONLY the translated text, nothing else:"',
    vim.fn.shellescape(input_file),
    model
  )

  local output_lines = {}
  local first_output = true

  -- Run command asynchronously with streaming output
  vim.fn.jobstart({ "sh", "-c", cmd }, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      if data then
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buf) then return end

          if first_output then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            first_output = false
          end

          for _, line in ipairs(data) do
            if line ~= "" or #output_lines > 0 then
              table.insert(output_lines, line)
            end
          end
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)

          -- Scroll to bottom
          local win = vim.fn.bufwinid(buf)
          if win ~= -1 then
            vim.api.nvim_win_set_cursor(win, { #output_lines, 0 })
          end
        end)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buf) then return end
          for _, line in ipairs(data) do
            if line ~= "" then
              table.insert(output_lines, "[stderr] " .. line)
            end
          end
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
        end)
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        os.remove(input_file)
        if not vim.api.nvim_buf_is_valid(buf) then return end

        if exit_code ~= 0 then
          vim.api.nvim_buf_set_lines(buf, 0, 0, false, {
            "[ERROR] Claude translation failed (exit code: " .. exit_code .. ")",
            "",
          })
        else
          vim.notify("Translation complete!", vim.log.levels.INFO, { timeout = 1500 })
        end
      end)
    end,
  })
end

-- Helper to get visual selection and call translate
local function translate_visual_selection(model)
  local source_filetype = vim.bo.filetype
  local saved_reg = vim.fn.getreg('"')
  local saved_regtype = vim.fn.getregtype('"')
  vim.cmd('normal! y')
  local content = vim.fn.getreg('"')
  vim.fn.setreg('"', saved_reg, saved_regtype)
  translate_selection({ model = model, content = content, filetype = source_filetype })
end

-- Setup function
function M.setup(opts)
  opts = opts or {}

  -- Register which-key group
  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add {
      { '<leader>ct', group = '[C]laude [T]ranslate' },
    }
  end

  -- Commands
  vim.api.nvim_create_user_command("ClaudeTranslate", function(cmd_opts)
    local args = {}
    for _, arg in ipairs(cmd_opts.fargs) do
      local key, value = arg:match("^%-%-(%w+)=?(.*)$")
      if key then
        args[key] = value ~= "" and value or true
      end
    end
    translate_buffer({
      model = args.model or "haiku",
      split = args.vsplit and "vsplit" or "split",
    })
  end, {
    nargs = "*",
    desc = "Translate buffer to Korean using Claude",
    complete = function()
      return { "--model=haiku", "--model=sonnet", "--model=opus", "--vsplit" }
    end,
  })

  -- Shorthand commands for each model
  vim.api.nvim_create_user_command("ClaudeTranslateHaiku", function(cmd_opts)
    local vsplit = vim.tbl_contains(cmd_opts.fargs, "--vsplit")
    translate_buffer({ model = "haiku", split = vsplit and "vsplit" or "split" })
  end, { nargs = "*", desc = "Translate with Claude Haiku" })

  vim.api.nvim_create_user_command("ClaudeTranslateSonnet", function(cmd_opts)
    local vsplit = vim.tbl_contains(cmd_opts.fargs, "--vsplit")
    translate_buffer({ model = "sonnet", split = vsplit and "vsplit" or "split" })
  end, { nargs = "*", desc = "Translate with Claude Sonnet" })

  vim.api.nvim_create_user_command("ClaudeTranslateOpus", function(cmd_opts)
    local vsplit = vim.tbl_contains(cmd_opts.fargs, "--vsplit")
    translate_buffer({ model = "opus", split = vsplit and "vsplit" or "split" })
  end, { nargs = "*", desc = "Translate with Claude Opus" })

  -- Selection translation command
  vim.api.nvim_create_user_command("ClaudeTranslateSelection", function(cmd_opts)
    local model = "haiku"
    local source_filetype = vim.bo.filetype
    for _, arg in ipairs(cmd_opts.fargs) do
      local key, value = arg:match("^%-%-(%w+)=?(.*)$")
      if key == "model" and value ~= "" then
        model = value
      end
    end
    local start_line = cmd_opts.line1
    local end_line = cmd_opts.line2
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local content = table.concat(lines, "\n")
    translate_selection({ model = model, content = content, filetype = source_filetype })
  end, {
    nargs = "*",
    range = true,
    desc = "Translate selection in floating window",
    complete = function()
      return { "--model=haiku", "--model=sonnet", "--model=opus" }
    end,
  })

  -- Normal mode keybindings (buffer translation)
  vim.keymap.set('n', '<leader>cth', function() translate_buffer({ model = "haiku", split = "split" }) end,
    { desc = 'Claude Translate (Haiku)' })
  vim.keymap.set('n', '<leader>cts', function() translate_buffer({ model = "sonnet", split = "split" }) end,
    { desc = 'Claude Translate (Sonnet)' })
  vim.keymap.set('n', '<leader>cto', function() translate_buffer({ model = "opus", split = "split" }) end,
    { desc = 'Claude Translate (Opus)' })

  -- Vertical split variants
  vim.keymap.set('n', '<leader>ctH', function() translate_buffer({ model = "haiku", split = "vsplit" }) end,
    { desc = 'Claude Translate Vsplit (Haiku)' })
  vim.keymap.set('n', '<leader>ctS', function() translate_buffer({ model = "sonnet", split = "vsplit" }) end,
    { desc = 'Claude Translate Vsplit (Sonnet)' })
  vim.keymap.set('n', '<leader>ctO', function() translate_buffer({ model = "opus", split = "vsplit" }) end,
    { desc = 'Claude Translate Vsplit (Opus)' })

  -- Visual mode keybindings (selection translation)
  vim.keymap.set('v', '<leader>cth', function() translate_visual_selection("haiku") end,
    { desc = 'Translate Selection (Haiku)' })
  vim.keymap.set('v', '<leader>cts', function() translate_visual_selection("sonnet") end,
    { desc = 'Translate Selection (Sonnet)' })
  vim.keymap.set('v', '<leader>cto', function() translate_visual_selection("opus") end,
    { desc = 'Translate Selection (Opus)' })
end

return M
