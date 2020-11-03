local vim = vim
local api = vim.api

local globals = require 'vimwiki_server/globals'
local g = require 'vimwiki_server/lib/graphql'
local u = require 'vimwiki_server/lib/utils'
local v = require 'vimwiki_server/lib/vars'

local M = {}

-- Synchronous function to execute code under cursor
function M.execute_under_cursor()
  local bridge = globals.bridge
  local tmp = globals.tmp

  local path = tmp:get_current_buffer_tmp_path()
  local reload = true
  local offset = u.cursor_offset()
  local query = g.query([[
    {
      page(path: "$path", reload: $reload) {
        nodeAtOffset(offset: $offset) {
          element {
            ... on PreformattedText {
              language
              lines
            }
          }
        }
      }
    }
  ]], {path=path, reload=reload, offset=offset})

  local res = bridge:send_wait_ok(query)

  if res then
    local language = u.get(res, 'data.page.nodeAtOffset.element.language')
    local lines = u.get(res, 'data.page.nodeAtOffset.element.lines')
    local result = nil

    -- Special case for vim since we want to evalute it within our active
    -- neovim session
    if language == 'vim' and lines then
      -- TODO: This cannot capture echos until neovim 0.5
      local code = table.concat(lines or {}, '\n')
      result = u.nvim_exec(code, true)

    -- Otherwise, if we know the language, try to evaluate it
    elseif language ~= nil and lines then
      local cmd = v.vimwiki_server_code(language)
      if cmd then
        result = api.nvim_call_function('system', {cmd, lines})
      end

    -- Finally, if we don't know, we can default to a language if specified
    elseif lines then
      local cmd = v.vimwiki_server_code_default()
      if cmd then
        result = api.nvim_call_function('system', {cmd, lines})
      end
    end

    -- Display our result somewhere
    if result and api.nvim_get_vvar('shell_error') == 0 then
      api.nvim_command('echo "'..tostring(result)..'"')
    else
      api.nvim_err_writeln(tostring(result))
    end
  end
end

return M
