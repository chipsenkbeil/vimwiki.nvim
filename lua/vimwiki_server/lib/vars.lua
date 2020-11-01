local u = require 'vimwiki_server/lib/utils'

-- Module to provide a single place to retrieve variables from vim so we
-- know exactly what functionality we support
--
-- All external variables that users can configure should be provided here
return {
  -- Represents vimwiki plugin's list of wikis
  vimwiki_list = function()
    return u.nvim_get_var_or_default('vimwiki_list', {{}})
  end;

  -- Represents the delay when writing to a temporary file for a buffer
  vimwiki_server_buffer_delay = function()
    return u.nvim_get_var_or_default('vimwiki_server#buffer#delay', 100)
  end;
}
