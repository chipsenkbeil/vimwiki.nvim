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

  -- Represents the directory to store vimwiki-server logs as files; if not
  -- available, will return nil indicating not to store logs as files
  vimwiki_server_log_dir = function()
    return u.nvim_get_var_or_default('vimwiki_server#log#dir')
  end;

  -- Represents the level at which to log information from vimwiki-server
  --
  -- 0 = warnings/errors
  -- 1 = info
  -- 2 = debug
  -- 3 = trace
  vimwiki_server_log_level = function()
    return u.nvim_get_var_or_default('vimwiki_server#log#level', 0)
  end;

  -- Represents the configuration for executing code for the specified language
  vimwiki_server_code = function(language)
    return u.nvim_get_var_or_default('vimwiki_server#code#'..language)
  end;

  -- Represents the configuration for executing code with no explicit language
  vimwiki_server_code_default = function()
    return u.nvim_get_var_or_default('vimwiki_server#code#default')
  end
}
