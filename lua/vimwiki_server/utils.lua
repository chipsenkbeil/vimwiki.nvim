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

-- Selects the byte range starting at offset with the specified byte length.
-- Optionally applies an operator on the visual selection.
--
-- Builds the key sequence to select in vim from the specified offset to some
-- end using the given length. Assumes that the offset provided is from our
-- server, which is index 0.
function M.select_in_buffer(offset, len, operator)
  -- Adjust our offset and len to start at index 1
  local offset = offset + 1
  local len = len - 1

  -- Calculate the starting and ending line/column positions for selection
  local lstart = api.nvim_call_function('byte2line', {offset})
  local cstart = offset - api.nvim_call_function('line2byte', {lstart}) + 1
  local lend = api.nvim_call_function('byte2line', {offset + len})
  local cend = offset + len - api.nvim_call_function('line2byte', {lend}) + 1

  -- Build the commands to apply in normal mode
  --
  -- Enter visual mode, jump to the beginning of our selection, then jump the
  -- cursor to where we were before, and move to the end of the selection
  --
  -- If we are given an operator to apply, do so
  cmd = movement_string(lend, cend)..'v'..movement_string(lstart, cstart)
  if operator then
    cmd = cmd..operator
  end

  api.nvim_command('echom "'..cmd..'"')
  api.nvim_command('normal! '..cmd)
end

-- Returns a string representing movement in vim to the given line and column
-- using keystrokes, not commands
function movement_string(line, col)
  -- Start by jumping to the specified line and starting from the beginning
  -- of that line
  s = line..'G0'

  -- If we have a column that isn't the beginning of the line, we add <N>l
  -- where <N> is the number of characters to move to the right
  if col > 1 then
    s = s..(col - 1)..'l'
  end

  return s
end

return M
