local vim = vim
local api = vim.api

local M = {}

local globals = require 'vimwiki_server/globals'
local u = require 'vimwiki_server/lib/utils'

-- Should be called after a buffer is displayed in a window
--
-- Will trigger the creation of a buffer's temporary file if it does not exist
function M.on_enter_buffer_window()
  local tmp = globals.tmp

  -- Force immediate writing of file
  tmp:write_buffer(u.get_autocmd_bufnr(), true)
end

-- Should be called before a buffer's text is freed
--
-- Will trigger removing the buffer from tmp tracker and deleting the buffer's
-- temporary file
function M.on_buffer_unload()
  local tmp = globals.tmp

  -- Remove buffer debouncer and temporary file
  tmp:remove_buffer(u.get_autocmd_bufnr())
end

-- Should be called when a buffer's text is changed
--
-- Will trigger a delayed refresh of the buffer's temporary file
function M.on_text_changed()
  local tmp = globals.tmp

  -- Trigger potential writing of file unless more text changes quickly
  tmp:write_buffer(u.get_autocmd_bufnr())
end

-- Should be called when leaving insert mode
--
-- Will refresh the buffer's temporary file immediately
function M.on_insert_leave()
  local tmp = globals.tmp

  -- Force immediate writing of file
  tmp:write_buffer(u.get_autocmd_bufnr(), true)
end

return M
