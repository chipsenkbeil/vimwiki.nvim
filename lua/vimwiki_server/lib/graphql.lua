local vim = vim
local api = vim.api
local u = require 'vimwiki_server/lib/utils'

local M = {}

-- Builds a new GraphQL query
function M.query(s, vars)
  local query = interpolate_vars(u.compress(s), vars or {})

  -- If not prefixed with query keyword, we make one
  if query and string.sub(query, 1, 1) == '{' then
    query = 'query VimQuery'..query
  end

  return query
end

-- Builds a new GraphQL mutation
function M.mutation(s, vars)
  local mutation = interpolate_vars(u.compress(s), vars or {})

  -- If not prefixed with mutation keyword, we make one
  if mutation and string.sub(mutation, 1, 1) == '{' then
    mutation = 'mutation VimMutation'..mutation
  end

  return mutation
end

-- Builds a new GraphQL subscription
function M.subscription(s, vars)
  local subscription = interpolate_vars(u.compress(s), vars or {})

  -- If not prefixed with subscription keyword, we make one
  if subscription and string.sub(subscription, 1, 1) == '{' then
    subscription = 'subscription VimSubscription'..subscription
  end

  return subscription
end

-- Interpolates variables provided in the form of {name="value", name_two=3}
-- into a string using $name and $name_two
--
-- Converts values from variables table into their tostring form. If value is
-- nil, the key/value pair is removed.
--
-- Names only allow alphanumeric characters and underscores
function interpolate_vars(s, variables)
  local clean_variables = {}

  -- Iterate through variables table, removing nil values and tostring-ing
  -- all of the other values so they can be provided to gsub
  for k, v in pairs(variables) do
    if v ~= nil then
      clean_variables[k] = tostring(v)
    end
  end

  return string.gsub(s, '%$([%w_]+)', clean_variables)
end

return M
