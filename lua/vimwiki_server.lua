local vim = vim
local api = vim.api

local M = {}

local bridge = require 'vimwiki_server/bridge':new()
local g = require 'vimwiki_server/graphql'
local u = require 'vimwiki_server/utils'

-- Primary entrypoint to start main vimwiki server instance
function M.start()
  if not bridge:is_running() then
    if not bridge:check_version(0, 1, 0, 'alpha', 4) then
      api.nvim_command('echoerr "Incompatible version of vimwiki-server: '..bridge:raw_version()..'"')
    else
      bridge:start()
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

-- Synchronous function to select an element under cursor
function M.select_an_element()
  local path = api.nvim_call_function('expand', {'%:p'})
  local reload = true
  local offset = u.cursor_offset()
  local query = g.new_query({
    {
      name = 'page',
      args = {{'path', path}, {'reload', reload}},
      children = {
        {
          name = 'nodeAtOffset',
          args = {{'offset', offset}},
          children = {
            {
              name = 'region',
              children = {
                {name = 'offset'},
                {name = 'len'},
              }
            }
          }
        }
      }
    }
  })

  local res = bridge:send_wait(query)

  if res then
    local region = u.get(res, 'data.page.nodeAtOffset.region')
    if region then
      u.select_in_buffer(region.offset, region.len)
    elseif res.errors then
      for i, e in ipairs(res.errors) do
        vim.api.nvim_command('echoerr '..e.message)
      end
    end
  else
    api.nvim_command('echoerr "Max timeout reached waiting for result"')
  end
end

-- Synchronous function to select root of an element under cursor
function M.select_root_element()
  local path = api.nvim_call_function('expand', {'%:p'})
  local reload = true
  local offset = u.cursor_offset()
  local query = g.new_query({
    {
      name = 'page',
      args = {{'path', path}, {'reload', reload}},
      children = {
        {
          name = 'nodeAtOffset',
          args = {{'offset', offset}},
          children = {
            {
              name = 'root',
              children = {
                {
                  name = 'region',
                  children = {
                    {name = 'offset'},
                    {name = 'len'},
                  }
                }
              }
            }
          }
        }
      }
    }
  })

  local res = bridge:send_wait(query)

  if res then
    local region = u.get(res, 'data.page.nodeAtOffset.root.region')
    if region then
      u.select_in_buffer(region.offset, region.len)
    elseif res.errors then
      for i, e in ipairs(res.errors) do
        vim.api.nvim_command('echoerr '..e.message)
      end
    end
  else
    api.nvim_command('echoerr "Max timeout reached waiting for result"')
  end
end

-- Synchronous function to select parent of an element under cursor
function M.select_parent_element()
  local path = api.nvim_call_function('expand', {'%:p'})
  local reload = true
  local offset = u.cursor_offset()
  local query = g.new_query({
    {
      name = 'page',
      args = {{'path', path}, {'reload', reload}},
      children = {
        {
          name = 'nodeAtOffset',
          args = {{'offset', offset}},
          children = {
            {
              name = 'parent',
              children = {
                {
                  name = 'region',
                  children = {
                    {name = 'offset'},
                    {name = 'len'},
                  }
                }
              }
            }
          }
        }
      }
    }
  })

  local res = bridge:send_wait(query)

  if res then
    local region = u.get(res, 'data.page.nodeAtOffset.parent.region')
    if region then
      u.select_in_buffer(region.offset, region.len)
    elseif res.errors then
      for i, e in ipairs(res.errors) do
        vim.api.nvim_command('echoerr '..e.message)
      end
    end
  else
    api.nvim_command('echoerr "Max timeout reached waiting for result"')
  end
end

-- Synchronous function to select the child element(s) of the element under
-- cursor, or the element under cursor itself if it has no children
function M.select_inner_element()
  local path = api.nvim_call_function('expand', {'%:p'})
  local reload = true
  local offset = u.cursor_offset()
  local query = g.new_query({
    {
      name = 'page',
      args = {{'path', path}, {'reload', reload}},
      children = {
        {
          name = 'nodeAtOffset',
          args = {{'offset', offset}},
          children = {
            {name = 'isLeaf'},
            {
              name = 'children',
              children = {
                {
                  name = 'region',
                  children = {
                    {name = 'offset'},
                    {name = 'len'},
                  }
                }
              }
            },
            {
              name = 'region',
              children = {
                {name = 'offset'},
                {name = 'len'},
              }
            }
          }
        }
      }
    }
  })

  local res = bridge:send_wait(query)

  if res then
    local node = u.get(res, 'data.page.nodeAtOffset')
    if node then
      local region = nil

      -- If element under cursor is a leaf node, we use its region
      if node.isLeaf then
        region = node.region

      -- Otherwise, we calculate the start and len from the children
      else
        local offset = u.min(u.filter_map(node.children, (function(c)
          return c.region.offset
        end)))
        local len = u.max(u.filter_map(node.children, (function(c)
          return c.region.offset + c.region.len
        end))) - offset

        region = {
          offset = offset,
          len = len,
        }
      end

      if region then
        u.select_in_buffer(region.offset, region.len)
      end
    elseif res.errors then
      for i, e in ipairs(res.errors) do
        vim.api.nvim_command('echoerr '..e.message)
      end
    end
  else
    api.nvim_command('echoerr "Max timeout reached waiting for result"')
  end
end

return M
