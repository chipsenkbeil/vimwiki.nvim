local u = require 'vimwiki_server/lib/utils'

-- Module to provide a single place to retrieve variables from vim so we
-- know exactly what functionality we support
--
-- All external variables that users can configure should be provided here
local M = {}

-- Represents vimwiki plugin's list of wikis
function M.vimwiki_list()
  return u.nvim_get_var_or_default('vimwiki_list', {{}})
end

-- Represents vimwiki server's list of wikis, which is based on the
-- vimwiki plugin configuration
--
-- Returns a list of paths, each optionally prefixed with <NAME>: to
-- indicate the name of the wiki
function M.vimwiki_server_wikis()
  return u.filter_map(
    M.vimwiki_list(),
    function(wiki)
      local w = wiki.path or '~/vimwiki/'
      if w and wiki.name then
        w = wiki.name..':'..w
      end
      return w
    end
  )
end

-- Represents the delay when writing to a temporary file for a buffer
function M.vimwiki_server_buffer_delay()
  return u.nvim_get_var_or_default('vimwiki_server#buffer#delay', 100)
end

-- Represents the directory to store vimwiki-server logs as files; if not
-- available, will return nil indicating not to store logs as files
function M.vimwiki_server_log_dir()
  return u.nvim_get_var_or_default('vimwiki_server#log#dir')
end

-- Represents the level at which to log information from vimwiki-server
--
-- 0 = warnings/errors
-- 1 = info
-- 2 = debug
-- 3 = trace
function M.vimwiki_server_log_level()
  return u.nvim_get_var_or_default('vimwiki_server#log#level', 0)
end

-- Represents the configuration for executing code for the specified language
function M.vimwiki_server_code(language)
  return u.nvim_get_var_or_default('vimwiki_server#code#'..language)
end

-- Represents the configuration for executing code with no explicit language
function M.vimwiki_server_code_default()
  return u.nvim_get_var_or_default('vimwiki_server#code#default')
end

return M
