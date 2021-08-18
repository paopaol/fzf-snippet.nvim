if not pcall(require, 'fzf') then return end

local core = require('fzf-lua.core')
local path = require('fzf-lua.path')
local action = require('fzf.actions').action
local utils = require('fzf-lua.utils')

local M = {}

local function make_item_string_convertable(item)
  local function make_display_line(item)
    local icon = core.get_devicon(string.format('%s.%s', item.lang, item.lang),
                                  item.lang)
    return icon .. utils.nbsp .. item.lang .. ' | ' .. item.name
  end

  setmetatable(item, {
    __tostring = function(table) return make_display_line(table) end,
    __index = function(table, key)
      for _, v in pairs(table) do
        print(tostring(v))
        if tostring(v) == key then return v end
      end
      return nil
    end
  })

  return item
end

M.fzf_snip = function()
  coroutine.wrap(function()
    local snips = vim.call('vsnip#get_complete_items',
                           vim.api.nvim_get_current_buf())

    local items = {}
    for _, v in pairs(snips) do
      local item = make_item_string_convertable({
        lang = vim.opt.filetype:get(),
        name = v['abbr'],
        content = vim.call('json_decode', v['user_data'])['vsnip']['snippet']
      })
      table.insert(items, item)
      items[tostring(item)] = item
    end

    local snippet_preview = action(function(selected)
      local text = table.concat(items[selected[1]].content, '\n')
      text = text:gsub('${(%d+):([%w_]+)}', '${%2}')
      local lines = vim.split(text, "\n", true)
      return lines
    end)

    local choice = require"fzf".fzf(items, "--preview=" .. snippet_preview)
    if choice then
      local text = table.concat(items[choice[1]].content, '\n')
      vim.call('vsnip#anonymous', text)
    end
  end)()
end

return M
