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
--
-- Builds the key sequence to select in vim from the specified offset to some
-- end using the given length. Assumes that the offset provided is from our
-- server, which is index 0.
function M.select_in_buffer(offset, len)
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
  cmd = movement_string(lend, cend)..'v'..movement_string(lstart, cstart)
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

-- Short wrapper to check if a specific global variable exists
function M.nvim_has_var(name)
  return api.nvim_call_function('exists', {'g:'..name}) == 1
end

-- Short wrapper to remove a global variable if it exists, returning its
-- value; if it does not exist, nil is returned
function M.nvim_remove_var(name)
  if not M.nvim_has_var(name) then
    return nil
  end

  local value = api.nvim_get_var(name)
  api.nvim_del_var(name)

  return value
end

-- Short wrapper to remove a global variable if it exists, returning its
-- value; if it does not exist, nil is returned
--
-- NOTE: nvim_call_atomic seems to not be available via the Lua API right now,
--       so this is only kept here in case it becomes available later
function M.__unused_nvim_remove_var(name)
  local results, errors = unpack(api.nvim_call_atomic({
      {'nvim_get_var', {name}},
      {'nvim_del_var', {name}},
  }))

  -- For now, we assume that if any error occurred, this was a failure
  --
  -- There is an edge case of get succeeding and del failing, but in that
  -- case I'd rather flag it as an error as opposed to having the variable
  -- floating around
  if errors then
    return nil
  else
    -- Otherwise, the very first result is our variable's value
    local value = unpack(results)
    return value
  end
end

-- Converts a table to its values as a string, rather than a pointer
-- From https://stackoverflow.com/a/6081639
function M.serialize_table(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. M.serialize_table(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

return M
