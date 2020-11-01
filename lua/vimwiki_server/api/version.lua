local globals = require 'vimwiki_server/globals'

local M = {}

-- Version of vimwiki-server that we require to use this plugin
local VERSION = {
  MAJOR = 0,
  MINOR = 1,
  PATCH = 0,
  PRERELEASE = 'alpha',
  PRERELEASE_VER = 4,
}

function M.is_valid()
  local bridge = globals.bridge

  local is_valid = bridge:check_version(
      VERSION.MAJOR,
      VERSION.MINOR,
      VERSION.PATCH,
      VERSION.PRERELEASE,
      VERSION.PRERELEASE_VER
  )

  if not is_valid then
    local v = VERSION.MAJOR..'.'..VERSION.MINOR..'.'..VERSION.PATCH
    if VERSION.PRERELEASE then
      v = v..'-'..VERSION.PRERELEASE
      if VERSION.PRERELEASE_VER then
        v = v..'.'..VERSION.PRERELEASE_VER
      end
    end
    local raw_v = bridge:raw_version()
    api.nvim_command('echoerr "Incompatible version of vimwiki-server: '..raw_v..', wanted '..v..'"')
  end

  return is_valid
end

return M
