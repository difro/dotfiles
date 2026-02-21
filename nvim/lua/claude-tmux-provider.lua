local M = {}

local state = {
  pane_id = nil, -- tmux pane number (without % prefix)
}

function M.setup(_) end

function M.is_available()
  return vim.env.TMUX ~= nil
end

function M.get_active_bufnr()
  return nil
end

local function pane_alive()
  if not state.pane_id then
    return false
  end
  vim.fn.system("tmux display-message -t '%" .. state.pane_id .. "' -p ''")
  return vim.v.shell_error == 0
end

function M.open(cmd_string, env_table, effective_config, focus)
  if pane_alive() then
    if focus ~= false then
      vim.fn.system("tmux select-pane -t '%" .. state.pane_id .. "'")
    end
    return
  end

  -- Save nvim pane ID before split changes focus
  local nvim_pane = vim.trim(vim.fn.system("tmux display-message -p '#{pane_id}'"))

  -- Build shell command with env exports
  local parts = {}
  for k, v in pairs(env_table or {}) do
    table.insert(parts, string.format("export %s=%s", k, vim.fn.shellescape(v)))
  end
  table.insert(parts, cmd_string)
  local full_cmd = table.concat(parts, "; ")

  local cwd_flag = ""
  if effective_config and effective_config.cwd then
    cwd_flag = "-c " .. vim.fn.shellescape(effective_config.cwd)
  end

  -- Split horizontally before current pane (left), capture new pane ID
  local result = vim.trim(vim.fn.system(
    "tmux split-window -hb " .. cwd_flag .. " -P -F '#{pane_id}' -- sh -c " .. vim.fn.shellescape(full_cmd)
  ))
  state.pane_id = result:gsub("%%", "")

  -- Apply main-vertical layout (Claude = main left pane, nvim + others stacked right)
  vim.fn.system("tmux select-layout main-vertical")

  if focus == false then
    vim.fn.system("tmux select-pane -t '" .. nvim_pane .. "'")
  end
end

function M.close()
  if pane_alive() then
    vim.fn.system("tmux kill-pane -t '%" .. state.pane_id .. "'")
  end
  state.pane_id = nil
end

function M.simple_toggle(cmd_string, env_table, effective_config)
  if pane_alive() then
    M.close()
  else
    M.open(cmd_string, env_table, effective_config)
  end
end

function M.focus_toggle(cmd_string, env_table, effective_config)
  if not pane_alive() then
    M.open(cmd_string, env_table, effective_config)
    return
  end
  vim.fn.system("tmux select-pane -t '%" .. state.pane_id .. "'")
end

function M.ensure_visible() end

return M
