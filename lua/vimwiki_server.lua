local M = {
  bridge = require 'vimwiki_server/bridge';
}

local server = nil

-- Primary entrypoint to start main vimwiki server instance
function M.start()
  vim.api.nvim_command('echo "CALLING START"')
  if not server or not server:is_running() then
    server = M.bridge:new()
    server:start()
  end
end

-- Primary entrypoint to stop main vimwiki server instance
function M.stop()
  if server then
    server:stop()
    server = nil
  end
end

-- Helper method to restart the server
function M.restart()
  M.stop()
  M.start()
end

return M
