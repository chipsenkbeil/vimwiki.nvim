local vim = vim
local api = vim.api
local uv = vim.loop

local M = {}
M.__index = M

-- Wraps the given function in a debouncer, which will prevent calling the
-- function until after N milliseconds of inactivity
function M:wrap(n, f)
  local instance = {}
  setmetatable(instance, M)
  instance.__state = {
    timeout = n;
    f = f;
    timer = nil;
  }
  return instance
end

-- Triggers the start of calling the wrapped function, waiting N milliseconds
-- of inactivity from calling the function before actually invoking it
--
-- Each new execution of this call function will reset the waiting period
--
-- NOTE: If timeout provided to debouncer was 0 or less, no delay is triggered
-- and the function will be called immediately
function M:call(...)
  -- Get rid of any running timer
  self:cancel()

  -- If our timeout is >0, make a new timer to represent the start of our
  -- waiting period
  if self.__state.timeout > 0 then
    local args = {...}
    self.__state.timer = uv.new_timer()
    self.__state.timer:start(self.__state.timeout, 0, vim.schedule_wrap(function()
      return self.__state.f(unpack(args))
    end))
  -- Otherwise, invoke directly
  else
    return self.__state.f(...)
  end
end

-- Forces the underlying function to be executed immediately, cancelling the
-- debouncer mid-state if it was in the process of waiting for inactivity
function M:force_call(...)
  -- Get rid of any running timer
  self:cancel()

  return self.__state.f(...)
end

-- Cancels the debouncer mid-state if it was in the process of waiting
-- for inactivity to trigger a function call
function M:cancel()
  local timer = self.__state.timer
  self.__state.timer = nil

  if timer then
    timer:stop()
    timer:close()
  end
end

return M
