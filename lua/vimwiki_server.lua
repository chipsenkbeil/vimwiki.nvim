local vim = vim
local api = vim.api

local M = {}

local bridge = require('vimwiki_server/bridge'):new()
local utils = require('vimwiki_server/utils')

-- Primary entrypoint to start main vimwiki server instance
function M.start()
  if not bridge:is_running() then
    bridge:start()
  end
end

-- Primary entrypoint to stop main vimwiki server instance
function M.stop()
  if bridge:is_running() then
    bridge:stop()
  end
end

-- Helper method to restart the server
function M.restart()
  M.stop()
  M.start()
end

function M.select_an_element(apply_operator)
  -- If indicated that we should apply an operator at the end, determine
  -- which operator is supposed to be applied
  local operator = nil
  if apply_operator then
    operator = api.nvim_get_vvar('operator')
  end

  local path = api.nvim_call_function('expand', {'%:p'})
  local reload = 'true'
  local offset = utils.cursor_offset()
  local query = '{page(path:"'..path..'",reload:'..reload..'){nodeAtOffset(offset:'..offset..'){region{offset,len}}}}'

  bridge:send(query, (function(res)
    if res.data and res.data.page and res.data.page.nodeAtOffset then
      local region = res.data.page.nodeAtOffset.region
      utils.select_in_buffer(region.offset, region.len, operator)
    elseif res.errors then
      for i, e in ipairs(res.errors) do
        vim.api.nvim_command('echoerr '..e.message)
      end
    end
  end))
end

function M.select_inner_element()
  local query = '{}'
end

return M
