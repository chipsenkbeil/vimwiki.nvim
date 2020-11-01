local M = {}

local u = require 'vimwiki_server/lib/utils'
local v = require 'vimwiki_server/lib/vars'

-- Load the specified wikis, defaulting to a wiki with no options
-- configured so it will use the defaults
function M.wikis()
  return u.filter_map(
    v.vimwiki_list(),
    function(wiki)
      local w = wiki.path or '~/vimwiki/'
      if w and wiki.name then
        w = wiki.name..':'..w
      end
      return w
    end
  )
end

return M
