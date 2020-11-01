local vim = vim
local api = vim.api

local globals = require 'vimwiki_server/globals'
local g = require 'vimwiki_server/lib/graphql'
local u = require 'vimwiki_server/lib/utils'

local M = {}

-- Synchronous function to select an element under cursor
function M.an_element()
  local bridge = globals.bridge
  local tmp = globals.tmp

  local path = tmp:get_current_buffer_tmp_path()
  local reload = true
  local offset = u.cursor_offset()
  local query = g.query([[
    {
      page(path: "$path", reload: $reload) {
        nodeAtOffset(offset: $offset) {
          region {
            offset
            len
          }
        }
      }
    }
  ]], {path=path, reload=reload, offset=offset})

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
function M.root_element()
  local bridge = globals.bridge
  local tmp = globals.tmp

  local path = tmp:get_current_buffer_tmp_path()
  local reload = true
  local offset = u.cursor_offset()
  local query = g.query([[
    {
      page(path: "$path", reload: $reload) {
        nodeAtOffset(offset: $offset) {
          root {
            region {
              offset
              len
            }
          }
        }
      }
    }
  ]], {path=path, reload=reload, offset=offset})

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
function M.parent_element()
  local bridge = globals.bridge
  local tmp = globals.tmp

  local path = tmp:get_current_buffer_tmp_path()
  local reload = true
  local offset = u.cursor_offset()
  local query = g.query([[
    {
      page(path: "$path", reload: $reload) {
        nodeAtOffset(offset: $offset) {
          parent {
            region {
              offset
              len
            }
          }
        }
      }
    }
  ]], {path=path, reload=reload, offset=offset})

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
function M.inner_element()
  local bridge = globals.bridge
  local tmp = globals.tmp

  local path = tmp:get_current_buffer_tmp_path()
  local reload = true
  local offset = u.cursor_offset()
  local query = g.query([[
    {
      page(path: "$path", reload: $reload) {
        nodeAtOffset(offset: $offset) {
          isLeaf
          children {
            region {
              offset
              len
            }
          }
          region {
            offset
            len
          }
        }
      }
    }
  ]], {path=path, reload=reload, offset=offset})

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
