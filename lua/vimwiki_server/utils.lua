local vim = vim
local api = vim.api

local M = {}

function M.cursor_offset()
  -- Get the offset to the start of the line where our cursor is located,
  -- which is index 1, so we need to subtract 1
  local offset_to_line = api.nvim_call_function('line2byte', {'.'}) - 1

  -- Get the offset from start of line to where our cursor is located,
  -- which is index 1, so we need to subtract 1
  local offset_to_column = api.nvim_call_function('col', {'.'}) - 1

  return offset_to_line + offset_to_column
end

-- Performs a selection in vim from the specified offset to some end using
-- the given length. Assumes that the offset provided is from our server,
-- which is index 0.
function M.select_in_buffer(offset, len)
  -- Adjust our offset and len to start at index 1
  local offset = offset + 1
  local len = len - 1

  local line = api.nvim_call_function('byte2line', {offset})
  local col = offset - api.nvim_call_function('line2byte', {line}) + 1
  api.nvim_call_function('cursor', {line, col})

  api.nvim_command('normal! v')

  line = api.nvim_call_function('byte2line', {offset + len})
  col = offset + len - api.nvim_call_function('line2byte', {line}) + 1
  api.nvim_call_function('cursor', {line, col})
end

return M
