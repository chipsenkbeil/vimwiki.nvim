-- Represents global state available to APIs
return {
  bridge = require 'vimwiki_server/lib'.new_bridge();
  tmp = require 'vimwiki_server/lib'.new_tmp();
}
