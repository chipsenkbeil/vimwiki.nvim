local M = {}
local u = require 'vimwiki_server/utils'

-- Builds a query using the given fields, arguments, fragments, aliases, and more
--
-- new_query({
--   {
--     'name' = '...',
--     'args' = {},
--     'alias' = '...',
--     'children' = {},
--   }
-- })
function M.new_query(fields)
  local fields = u.concat_nonempty(u.filter_map(fields, (function(f)
    return make_field_string(f)
  end)), ',')

  if fields then
    return '{'..fields..'}'
  end
end

-- tbl: {"name" = "...", "args" = {...}?, "alias" = "..."?, "children" = {...}?}
--
-- Produces "[alias:]<name>[("arg1": ..., ...)][{ ... }]" where the alias,
-- arguments, and children fields are optional.
function make_field_string(tbl)
  local name = assert(tbl['name'])
  local args = make_field_args_string(tbl['args'])
  local alias = make_field_alias_string(tbl['alias'])
  local children = u.concat_nonempty(u.filter_map(tbl['children'], (function(c)
    return make_field_string(c)
  end)), ',')

  local field = name
  if alias then
    field = alias..field
  end
  if args then
    field = field..'('..args..')'
  end
  if children then
    field = field..'{'..children..'}'
  end
  return field
end

-- alias: "..."?
--
-- Produces "alias: " if alias is not nil, otherwise returns nil
function make_field_alias_string(alias)
  if alias then
    return alias..': '
  end
end

-- args: {{name, value}, {...}, ...}
--
-- Produces "arg1: value1, arg2: value2, ..." string if at least one arg has
-- a non-nil value. Otherwise, returns nil
function make_field_args_string(args)
  local args = u.filter_map(args, (function(arg)
    if arg[1] then
      return make_field_arg_string(arg[1], arg[2])
    end
  end))

  if args and not u.is_empty(args) then
    return table.concat(args, ',')
  end
end

-- Converts name and value into a field argument in the form of
-- "arg: value" string if the value is not nil, otherwise returns nil
function make_field_arg_string(name, value)
  local field_arg = nil
  local field_value = make_value_string(value)
  if field_value then
    field_arg = name..': '..field_value
  end
  return field_arg
end

-- Converts Lua value to GraphQL value (as Lua string), or nil if not a
-- valid value (or nil)
function make_value_string(value)
  local value_t = type(value)

  if value_t == 'boolean' then
    return tostring(value)
  elseif value_t == 'number' then
    return tostring(value)
  elseif value_t == 'string' then
    return '"'..tostring(value)..'"'
  else
    return nil
  end
end

return M
