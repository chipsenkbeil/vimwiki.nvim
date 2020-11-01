local vim = vim
local api = vim.api

local M = {}
M.__index = M

local d = require 'vimwiki_server/lib/debounce'
local u = require 'vimwiki_server/lib/utils'
local v = require 'vimwiki_server/lib/vars'

-- Creates a new temporary file manager for buffers
function M:new()
  local instance = {}
  setmetatable(instance, M)
  instance.__state = {
    buffers = {};
  }
  return instance
end

-- Adds a temporary file representing the buffer with the specified number
function M:add_buffer(n)
  -- If we already have a buffer assigned, don't assign it again
  if self.__state.buffers[n] then
    return self.__state.buffers[n]
  end

  local delay = v.vimwiki_server_buffer_delay()

  -- TODO: In the future when we support link resolution and other file-relative
  --       support, do we need to not use tempname or control the location
  --       by setting $TEMPVAR to the wiki where the real file is?
  --
  --       Could be handled by vimwiki-server supporting loading an alias
  --       file, which would set the file's containing directory used in
  --       link resolution to that of the real file
  local tmp_path = api.nvim_call_function('tempname', {})

  local buffer = {
    tmp_path = tmp_path;
    debouncer = d:wrap(delay, function()
      -- Retrieve all lines currently in buffer
      local lines = api.nvim_call_function('getbufline', {n, 1, '$'})

      -- Write buffer lines out to file using binary mode (no trailing newline)
      -- and not calling fsync, meaning will finish faster but OS will
      -- determine when the write will appear on disk
      api.nvim_call_function('writefile', {lines, tmp_path, 'bS'})
    end);
  }

  self.__state.buffers[n] = buffer

  return buffer
end

-- Removes the temporary file representing the buffer with the specified number
function M:remove_buffer(n)
  local buffer = self.__state.buffers[n]
  self.__state.buffers[n] = nil
  cleanup_buffer(buffer)
end

-- Will write the buffer's contents to the managed temporary file
--
-- If the buffer is not managed, will start managing it
--
-- Write calls are debounced to avoid excessive writing to a file, this
-- can be forced by including true as second argument
function M:write_buffer(n, force)
  -- Load existing tmp info or create new one
  local buffer = self.__state.buffers[n] or self:add_buffer(n)

  if force then
    buffer.debouncer:force_call()
  else
    buffer.debouncer:call()
  end
end

-- Retrieves the temporary file path tied to the buffer, or nil if the buffer
-- with the specified number is not being tracked
function M:get_buffer_tmp_path(n)
  local buffer = self.__state.buffers[n]
  if buffer then
    return buffer.tmp_path
  end
end

-- Retrievces the temporary file path tied to the current buffer, or nil if
-- the current buffer is not being tracked
function M:get_current_buffer_tmp_path()
  return self:get_buffer_tmp_path(api.nvim_call_function('bufnr', {}))
end

-- Removes all buffers from the manager and deletes their associated
-- temporary files
function M:clear()
  local buffers = self.__state.buffers
  self.__state.buffers = {}

  -- Stop any pending writes to each buffer's temporary file and then
  -- delete the associated temporary file
  for _, buffer in pairs(buffers) do
    cleanup_buffer(buffer)
  end
end

-- Internal helper to do cleanup for a buffer
--
-- Stop any pending writes to each buffer's temporary file and then
-- delete the associated temporary file
function cleanup_buffer(buffer)
  if buffer then
    buffer.debouncer:cancel()
    api.nvim_call_function('delete', {buffer.tmp_path})
  end
end

return M
