local vim = vim
local api = vim.api
local uv = vim.loop

-- Our module containing functions to call
local M = {}

-- Creates a new instance of our client library for the server
function M:new()
    local instance = {}
    instance._state = {
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
    return self._state.handle and self._state.pid and self._state.stdin
end

function M:clear_state()
  self._state = {
    handle = nil;
    pid = nil;
    stdin = nil;
    callbacks = {};
  }
end

-- Starts a new instance of vimwiki-server
function M:start_server()
  -- If server is already running, this function does nothing
  if self:is_running() then
      return
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
      local lines = vim.split(output_buf, '\n', true)

      for line in lines do
        self:__handler(vim.api.nvim_call_function('json_decode', {line}))
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
    args = {"--mode", "stdin", "--wiki", "0:$HOME/vimwiki"};
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
    self:clear_state()
  end)

  -- After the process has been spawned, we want to begin reading from its
  -- output so we can monitor it
  stdout:read_start(update_chunk)
  stderr:read_start(update_chunk)

  -- Finally, we want to store our ability to communicate to the process
  self._state = {
    handle = handle;
    pid = pid;
    stdin = stdin;
    callbacks = {};
  }
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

  self._state.callbacks[full_msg.id] = cb
  stdin:write(vim.api.nvim_call_function('json_encode', {full_msg}))
  stdin:write("\n")
end

-- Primary event handler for our server, routing received events to the
-- corresponding callbacks
function M:__handler(msg)
  local id = msg.id
  local payload = msg.payload

  -- Look up our callback and, if it exists, invoke it
  local cb = self._state.callbacks[id]
  self._state.callbacks[id] = nil
  if cb then
    cb(payload)
  end
end

return M
