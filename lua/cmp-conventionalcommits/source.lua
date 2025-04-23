local plugin = require('cmp-conventionalcommits')
local util = require('cmp-conventionalcommits.util')

local source = {}

function source.new()
  local call_commitlint = [[npx --yes commitlint --print-config --no-color]]
  local commitlint_path = plugin.commitlint_path
  if commitlint_path then
    call_commitlint = ([[node %s --print-config --no-color]]):format(commitlint_path)
  end
  local commitlintConfigRaw =
    io.popen(([[node --eval 'eval("var obj ="+process.argv[1]);console.log(JSON.stringify(obj));'\
	"$(%s | tr '\n' ' ')" 2>/dev/null]]):format(call_commitlint)):read('*a')

  if commitlintConfigRaw == '' then
    commitlintConfigRaw = '{}'
  end
  local commitlintConfig = vim.fn.json_decode(commitlintConfigRaw)
  local commitlintTypes = (((commitlintConfig or {})['rules'] or {})['type-enum'] or {})[3] or {}
  source.types = {}
  for _, type in ipairs(commitlintTypes) do
    source.types[type] = { label = type, kind = require('cmp').lsp.CompletionItemKind.Keyword }
  end
  if next(commitlintTypes) ~= nil then
    plugin.types = {}
  end

  for _, value in pairs(plugin.types) do
    local key = value.label
    source.types[key] = value
  end

  source.scopes = {}
  local commitlintScopes = (((commitlintConfig or {})['rules'] or {})['scope-enum'] or {})[3] or {}
  for _, scope in ipairs(commitlintScopes) do
    source.scopes[scope] = { label = scope, kind = require('cmp').lsp.CompletionItemKind.Keyword }
  end
  if next(commitlintScopes) ~= nil then
    plugin.scopes = {}
  end

  for _, value in ipairs(plugin.scopes) do
    local key = value.label
    source.scopes[key] = value
  end

  local commitlintQuestionsEnum = ((((commitlintConfig or {})['prompt'] or {})['questions'] or {})['type'] or {})['enum']
    or {}

  for type, props in pairs(commitlintQuestionsEnum) do
    local documentation = util.get_documentation(props)

    if source.types[type] ~= nil then
      source.types[type]['documentation'] = documentation
    end
  end

  return setmetatable({}, { __index = source })
end

function source:is_available()
  return vim.bo.filetype == 'gitcommit'
end

function source:get_keyword_pattern()
  return [[\w\+]]
end

local function candidates(entries)
  local items = {}
  for _, v in pairs(entries) do
    table.insert(items, v)
  end
  return items
end

function source:complete(request, callback)
  if
    request.context.option.reason == 'manual'
    and request.context.cursor.row == 1
    and request.context.cursor.col == 1
  then
    callback({ items = candidates(self.types), isIncomplete = true })
  elseif
    request.context.option.reason == 'auto'
    and request.context.cursor.row == 1
    and request.context.cursor.col == 2
  then
    callback({ items = candidates(self.types), isIncomplete = true })
  elseif string.match(request.context.cursor_before_line, '%a+%(') and request.context.cursor.row == 1 then
    callback({ items = candidates(self.scopes), isIncomplete = true })
  else
    callback()
  end
end

return source
