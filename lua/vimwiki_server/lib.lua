
local bridge = require 'vimwiki_server/lib/bridge'
local debounce = require 'vimwiki_server/lib/debounce'
local graphql = require 'vimwiki_server/lib/graphql'
local tmp = require 'vimwiki_server/lib/tmp'
local utils = require 'vimwiki_server/lib/utils'
local vars = require 'vimwiki_server/lib/vars'

-- Top-level library functions for use externally
return {
  new_bridge = function()
    return bridge:new()
  end;
  new_tmp = function()
    return tmp:new()
  end;
}
