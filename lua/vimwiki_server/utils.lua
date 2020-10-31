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

-- Short wrapper to load a spcific global variable if it exists, returning
-- the default value if it does not
function M.nvim_get_var_or_default(name, default)
  if M.nvim_has_var(name) then
    return api.nvim_get_var(name)
  else
    return default
  end
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

-- Returns a string with the given prefix removed if it is found in the string
function M.strip_prefix(s, prefix)
  local offset = string.find(s, prefix, 1, true)
  if offset == 1 then
    return string.sub(s, string.len(prefix) + 1)
  else
    return s
  end
end

-- Returns the value from the provided table using the given path to get to
-- it; if the table is nil or the path is unable to be completed, nil is returned
function M.get(tbl, path)
  local keys = vim.split(path, '.', true)
  local value = tbl
  for i = 1, #keys do
    value = value[keys[i]]

    if value == nil or i == #keys then
      return value
    end
  end
end

-- Returns the maximum value from the array, or nil if there are no elements
function M.max(array)
  if not M.is_empty(array) then
    local max = nil
    for _, value in ipairs(array) do
      if not max or value > max then
        max = value
      end
    end
    return max
  end
end

-- Returns the minimum value from the array, or nil if there are no elements
function M.min(array)
  if not M.is_empty(array) then
    local min = nil
    for _, value in ipairs(array) do
      if not min or value < min then
        min = value
      end
    end
    return min
  end
end

-- Maps and filters out nil elements in an array using the given function,
-- returning nil if given nil as the array
function M.filter_map(array, f)
  if array == nil then
    return nil
  end

  local new_array = {}
  for i,v in ipairs(array) do
    local el = f(v)
    if el then
      table.insert(new_array, el)
    end
  end
  return new_array
end

-- Concats an array using the provided separator, returning the resulting
-- string if non-empty, otherwise will return nil
function M.concat_nonempty(array, sep)
  if array and #array > 0 then
    return table.concat(array, sep)
  end
end

-- Checks if an array is empty, returning true if not nil and not empty
function M.is_empty(array)
  return next(array or {}) == nil
end

-- Interpolates a string similar to Rust's println!(...) using {} to mark
-- a replacement and replacing one {} at a time using the given varargs
--
-- Does not check for dangling {} or missing {}!
function M.interpolate(s, ...)
  -- For each item provided, we will replace the next instance of {} with it
  for i = 1, select('#', ...) do
    local item = select(i, ...)
    s = string.gsub(s, '{}', item, 1)
  end

  return s
end

-- Compresses a string by trimming whitespace on each line and replacing
-- newlines with a single space so that it can be sent as a single
-- line to command line interfaces while also ensuring that lines aren't
-- accidentally merged together
function M.compress(s)
  return M.concat_nonempty(
    M.filter_map(
      vim.split(s, '\n', true),
      (function(line)
        return vim.trim(line)
      end)
    ),
    ' '
  )
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
