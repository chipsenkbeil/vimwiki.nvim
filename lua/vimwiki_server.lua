local vim = vim
local api = vim.api

local M = {}

local bridge = require 'vimwiki_server/globals'.bridge
local a = require 'vimwiki_server/api'

-- Primary entrypoint to start main vimwiki server instance
function M.start()
  if not bridge:is_running() then
    if a.version.is_valid(bridge) then
      local wikis = a.vars.wikis()
      bridge:start(wikis)
    end
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

return M
