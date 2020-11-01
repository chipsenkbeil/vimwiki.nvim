local vim = vim
local api = vim.api
local uv = vim.loop
local u = require 'vimwiki_server/lib/utils'

-- Our module containing functions to call
local M = {}
M.__index = M

-- Creates a new instance of our client library for the server
function M:new()
  local instance = {}
  setmetatable(instance, M)
  instance.__state = {
    handle = nil;
    pid = nil;
    stdin = nil;
    callbacks = {};
  }
  return instance
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

-- Validates the version of vimwiki-server, returning true if it is okay
function M:check_version(major, minor, patch, pre_release, pre_release_ver)
  local v = self:version()
  if not v then
    return false
  end

  local major_okay = not major or v[1] == major
  local minor_okay = not minor or v[2] == minor
  local patch_okay = not patch or v[3] == patch
  local pre_release_okay = not pre_release or v[4] == pre_release
  local pre_release_ver_okay = not pre_release_ver or v[5] == pre_release_ver

  return major_okay and minor_okay and patch_okay and pre_release_okay and pre_release_ver_okay
end

-- Retrieves the current version of vimwiki-server, returning it in the form
-- of [major, minor, patch, pre-release, pre-release-ver] or nil if not available.
--
-- Note that pre-release and pre-release ver are optional
function M:version()
  local raw_version = self:raw_version()
  if not raw_version then
    return nil
  end

  local version_string = vim.trim(u.strip_prefix(raw_version, 'vimwiki-server'))
  if not version_string then
    return nil
  end

  local version = nil

  local semver, ext = unpack(vim.split(version_string, '-', true))
  local major, minor, patch = unpack(vim.split(semver, '.', true))
  if ext then
    local ext_label, ext_ver = unpack(vim.split(ext, '.', true))
    version = {major, minor, patch, ext_label, ext_ver}
  else
    version = {major, minor, patch}
  end

  return u.filter_map(version, (function(v)
    return tonumber(v) or v
  end))
end

-- Retrieves the raw version of vimwiki-server from calling --version
function M:raw_version()
  local text = api.nvim_call_function('system', {'vimwiki-server --version'})
  if text then
    return vim.trim(text)
  end
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
  local stdin = self.__state.stdin

  -- Trigger the end of our server
  if handle then
    stdin:shutdown()

    -- NOTE: This seems to be the required aspect for cleanup
    if not handle:is_closing() then
      handle:kill(15)
    end

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

-- Send a message to our server and wait synchronously for the result
function M:send_wait(msg, timeout, interval)
  local tmp_name = '__vimwiki_server_bridge_send_wait__'
  assert(not u.nvim_has_var(tmp_name))

  self:send(msg, function(data)
    local data_str = api.nvim_call_function('json_encode', {data})
    api.nvim_set_var(tmp_name, data_str)
  end)

  -- Timeout and interval are in milliseconds
  local timeout = timeout or 1000
  local interval = interval or 200

  -- Wait for the result to be set, or time out
  api.nvim_call_function('wait', {timeout, 'exists("'..tmp_name..'")', interval})

  -- Finally, grab and clear our temporary variable if it is set and return
  -- its value
  local result = u.nvim_remove_var(tmp_name)
  if result then
    result = api.nvim_call_function('json_decode', {result})
  end

  return result
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

return M
