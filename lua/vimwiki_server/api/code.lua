local vim = vim
local api = vim.api

local globals = require 'vimwiki_server/globals'
local g = require 'vimwiki_server/lib/graphql'
local u = require 'vimwiki_server/lib/utils'
local v = require 'vimwiki_server/lib/vars'

local M = {}

-- Synchronous function to execute code under cursor
function M.execute_under_cursor()
  local bridge = globals.bridge
  local tmp = globals.tmp

  local path = tmp:get_current_buffer_tmp_path()
  local reload = true
  local offset = u.cursor_offset()
  local query = g.query([[
    {
      page(path: "$path", reload: $reload) {
        nodeAtOffset(offset: $offset) {
          element {
            ... on PreformattedText {
              language
              lines
              input: metadataForKey(key: ":input")
              output: metadataForKey(key: ":output")
            }
          }
          region {
            offset
            len
          }
          nextSibling {
            element {
              ... on Paragraph {
                elements {
                  ... on MultiLineComment {
                    lines
                    region {
                      offset
                      len
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ]], {path=path, reload=reload, offset=offset})

  local res = bridge:send_wait_ok(query)

  if res then
    local language = u.get(res, 'data.page.nodeAtOffset.element.language')
    local lines = u.get(res, 'data.page.nodeAtOffset.element.lines')
    local input = u.get(res, 'data.page.nodeAtOffset.element.input')
    local output = u.get(res, 'data.page.nodeAtOffset.element.output')
    local region = u.get(res, 'data.page.nodeAtOffset.region')
    local comment = find_first_comment(
      u.get(res, 'data.page.nodeAtOffset.nextSibling.element.elements')
    )
    local result = nil

    -- If we are given input, interpolate within the code to execute
    if lines and input then
      lines = interpolate_lines(lines, input)
    end

    -- Evaluate our result based on the language
    local result = do_eval(language, lines)

    -- Display our result somewhere
    return output_result(result, output, region, comment)
  end
end

function find_first_comment(elements)
  if elements then
    for _, element in ipairs(elements) do
      if element.lines and element.region then
        return element
      end
    end
  end

  return nil
end

function interpolate_lines(lines, input)
    local lines_str = table.concat(lines, '\n')
    local input_val = api.nvim_buf_get_var(0, 'vimwiki_server#internal#result#'..input)

    for i, line in ipairs(lines) do
      lines[i] = u.interpolate_vars(line, {input = input_val})
    end

    return lines
end

function do_eval(language, lines)
  local result = nil

  -- Special case for vim since we want to evalute it within our active
  -- neovim session
  if language == 'vim' and lines then
    local code = table.concat(lines or {}, '\n')
    result = u.nvim_exec(code, true)

  -- Otherwise, if we know the language, try to evaluate it
  elseif language ~= nil and lines then
    local cmd = v.vimwiki_server_code(language)
    if cmd then
      result = api.nvim_call_function('system', {cmd, lines})
    end

  -- Finally, if we don't know, we can default to a language if specified
  elseif lines then
    local cmd = v.vimwiki_server_code_default()
    if cmd then
      result = api.nvim_call_function('system', {cmd, lines})
    end
  end

  return result
end

function inject_result_into_buffer(result, code_region, comment)
  -- If our result is made up of more than one line post-trim, we want to
  -- show it on its own lines between the comment syntax, otherwise we want
  -- to show it inline with a single space delimiter
  local result_str = vim.trim(tostring(result))
  local sep = (string.find(result_str, '\n', 1, true) ~= nil) and '\n' or ' '
  local text = '%%+RESULT+'..sep..result_str..sep..'+%%'

  -- Check if we have an element below our code that starts with a comment
  -- containing our result. If we do, then we want to replace that comment with
  -- a new version containing our result. If we do not, we want to append a
  -- blank line after our code followed by a line containing the comment with
  -- our result.
  if comment and u.starts_with(comment.lines[1], 'RESULT+') then
    u.change_in_buffer(comment.region.offset, comment.region.len, text)
  elseif code_region.offset and code_region.len then
    local line_nums = u.get_line_numbers(code_region.offset, code_region.len)
    local last_line_num = line_nums[#line_nums]
    if last_line_num then
      -- Jump to the last line of our code block
      api.nvim_command(tostring(last_line_num))

      -- Insert two blank lines
      api.nvim_command('normal! o')
      api.nvim_command('normal! o')

      -- Replace second blank line with our text
      u.change_in_buffer(code_region.offset + code_region.len + 1, 1, text)
    end
  end
end

function output_result(result, output, code_region, comment)
  if result and api.nvim_get_vvar('shell_error') == 0 then
    -- If given a specific location for output, store it
    if output then
      local result = vim.trim(u.escape_newline(result))
      api.nvim_buf_set_var(0, 'vimwiki_server#internal#result#'..output, result)

    -- Otherwise, output it into our buffer
    else
      return inject_result_into_buffer(result, code_region, comment)
    end
  else
    api.nvim_err_writeln(tostring(result))
  end
end

return M
