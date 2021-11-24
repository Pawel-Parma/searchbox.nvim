local M = {}
local utils = require('searchbox.utils')

M.incsearch = function(value, opts, state, win_exe)
  opts = opts or {}
  local search_flags = 'cn'
  local query = utils.build_search(value, opts)

  if opts.reverse then
    search_flags = 'bcn'
  end

  if value == '' then
    return
  end

  local no_match = '\n[0, 0]'
  local wincmd = [[ echo searchpos("%s", '%s') ]]
  local escaped_query = vim.fn.escape(query, '"')
  local ok, pos = pcall(win_exe, wincmd, {escaped_query, search_flags})

  if not ok or pos == no_match then
    return
  end

  pos = vim.split(pos, ',')
  state.line = tonumber(pos[1]:sub(3))
  local col = tonumber(pos[2]:sub(1, pos[2]:len() - 1))
  local off = col + value:len()

  vim.api.nvim_buf_add_highlight(
    state.bufnr,
    utils.hl_namespace,
    utils.hl_name,
    state.line - 1,
    col - 1,
    off - 1
  )

  if state.line ~= state.line_prev then
    vim.fn.setreg('/', query)
    if opts.reverse then
      win_exe('normal N')
    else
      win_exe('normal n')
    end
    state.line_prev = state.line
  end
end

return M
