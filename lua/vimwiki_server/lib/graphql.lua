local vim = vim
local api = vim.api
local u = require 'vimwiki_server/lib/utils'

local M = {}

-- Builds a new GraphQL query
function M.query(s, vars)
  local query = u.interpolate_vars(u.compress(s), vars or {})

  -- If not prefixed with query keyword, we make one
  if query and string.sub(query, 1, 1) == '{' then
    query = 'query VimQuery'..query
  end

  return query
end

-- Builds a new GraphQL mutation
function M.mutation(s, vars)
  local mutation = u.interpolate_vars(u.compress(s), vars or {})

  -- If not prefixed with mutation keyword, we make one
  if mutation and string.sub(mutation, 1, 1) == '{' then
    mutation = 'mutation VimMutation'..mutation
  end

  return mutation
end

-- Builds a new GraphQL subscription
function M.subscription(s, vars)
  local subscription = u.interpolate_vars(u.compress(s), vars or {})

  -- If not prefixed with subscription keyword, we make one
  if subscription and string.sub(subscription, 1, 1) == '{' then
    subscription = 'subscription VimSubscription'..subscription
  end

  return subscription
end

return M
