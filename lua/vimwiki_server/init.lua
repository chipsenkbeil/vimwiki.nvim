local vim = vim
local api = vim.api
local uv = vim.loop

-- Our module containing functions to call
local M = {}

-- Creates a new instance of our client library for the server
function M:new()
    local instance = {}
    instance.__state = {
      handle = nil;
      pid = nil;
      stdin = nil;
      callbacks = {};
    }
    self.__index = self
    return setmetatable(instance, self)
end

-- Indicates whether or not the server is running
function M:is_running()
    return self.__state.handle and self.__state.pid and self.__state.stdin
end

-- Internal helper to clear our state
function M:__clear_state()
  self.__state = {
    handle = nil;
    pid = nil;
    stdin = nil;
    callbacks = {};
  }
end

-- Starts an instance of vimwiki-server if not already running
function M:start(wikis)
  -- If server is already running, this function does nothing
  if self:is_running() then
      return
  end

  -- Build our arguments for the vimwiki server, expanding environment the
  -- environment variables for any of the wikis
  local args = {"--mode", "stdin"}
  if wikis then
    for _, wiki in ipairs(wikis) do
      args[#args+1] = "--wiki"
      args[#args+1] = api.nvim_call_function('expand', {wiki})
    end
  end

  local stdin = uv.new_pipe(false)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  -- Define our local closure that handles incoming chunks of data
  local stdout_buf = ''
  local function update_chunk(err, chunk)
    -- If we received some output (and not an error), process it
    if chunk then
      -- Because a chunk of output isn't guaranteed to end with a newline,
      -- we build up our ouput and consume all received lines using newline
      -- as the delimiter
      stdout_buf = stdout_buf..chunk
      local lines = vim.split(stdout_buf, '\n', true)

      -- For each line, if it is not empty, decode it and send to our handler
      for _, line in ipairs(lines) do
        if line ~= nil and line ~= "" then
          self:__handler(api.nvim_call_function('json_decode', {line}))
        end
      end
    end
  end

  -- We need to wrap our update function so it can be invoked within the
  -- event loop
  update_chunk = vim.schedule_wrap(update_chunk)

  -- Now, we spawn our vimwiki-server process
  -- TODO: Get list of wikis from vim config for use in arguments
  local handle, pid
  handle, pid = uv.spawn("vimwiki-server", {
    args = args;
    stdio = {stdin, stdout, stderr};
    cwd = cwd;
  }, function(code, signal)
    -- If the process has exited, we want to close all of our pipes
    stdin:close()
    stdout:close()
    stderr:close()
    handle:close()

    -- If the process exited properly, we do nothing, but if it exited badly,
    -- we want to report it!
    if code ~= 0 or signal ~= 0 then
      -- TODO: Report bad process exit
    end

    -- Regardless of exit, we want to reset our state
    self:__clear_state()
  end)

  -- After the process has been spawned, we want to begin reading from its
  -- output so we can monitor it
  stdout:read_start(update_chunk)
  stderr:read_start(update_chunk)

  -- Finally, we want to store our ability to communicate to the process
  self.__state = {
    handle = handle;
    pid = pid;
    stdin = stdin;
    callbacks = {};
  }
end

-- Starts an instance of vimwiki-server if running by killing the process
-- and resetting state
function M:stop()
  -- If server is not running, this does nothing
  if not self:is_running() then
    return
  end

  local handle = self.__state.handle

  -- Trigger the end of our server
  if handle then
    uv.process_kill(handle, "SIGINT")
    self:__clear_state()
  end
end

-- Send a message to our server
function M:send(msg, cb)
  -- If server is not running, this does nothing
  if not self:is_running() then
    return
  end

  -- Build a full message that wraps the provided message as the payload and
  -- includes an id that our server uses when relaying a response for the
  -- callback to process
  local full_msg = {
    id = math.floor(math.random() * 10000);
    payload = msg;
  }

  self.__state.callbacks[full_msg.id] = cb
  self.__state.stdin:write(api.nvim_call_function('json_encode', {full_msg}))
  self.__state.stdin:write("\n")
end

-- Primary event handler for our server, routing received events to the
-- corresponding callbacks
function M:__handler(msg)
  if not msg then
    return
  end

  -- {"id": ..., "payload": ...}
  local id = msg.id
  local payload = msg.payload

  if not id or not payload then
    return
  end

  -- The response payload is an encoded JSON string that we must decode
  local response = api.nvim_call_function('json_decode', {payload})

  -- Look up our callback and, if it exists, invoke it
  local cb = self.__state.callbacks[id]
  self.__state.callbacks[id] = nil
  if cb then
    cb(response)
  end
end

-- CHIP CHIP CHIP
--
-- So far, so good!
--
-- EXAMPLE:
--
--   s = require('vimwiki_server'):new()
--   s:start_server({"0:$HOME/vimwiki"})
--   s:send("{wikiAtIndex(index:0){path}}", function(msg) print(msg.data.wikiAtIndex.path) end)
--
--   prints /home/senkwich/vimwiki
--
-- Currently, neovim will not exit if the server is running and we :q
-- Need to figure out what I'm missing to enable vimwiki to exit. Is there
-- some event we can hook into to close the process?
return M
