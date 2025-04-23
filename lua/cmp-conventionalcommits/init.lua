local util = require('cmp-conventionalcommits.util')
---@class Plugin
---@field default_config cmp-conventionalcommits.PluginOptions
---@field types CmpEntry[]
---@field scopes CmpEntry[]
---@field commitlint_path string?
local M = {
  default_config = {
    types = {
      feat = {
        description = 'A new feature',
        title = 'Features',
      },
      fix = {
        description = 'A bug fix',
        title = 'Bug Fixes',
      },
      docs = {
        description = 'Documentation only changes',
        title = 'Documentation',
      },
      style = {
        description = 'Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)',
        title = 'Styles',
      },
      refactor = {
        description = 'A code change that neither fixes a bug nor adds a feature',
        title = 'Code Refactoring',
      },
      perf = {
        description = 'A code change that improves performance',
        title = 'Performance Improvements',
      },
      test = {
        description = 'Adding missing tests or correcting existing tests',
        title = 'Tests',
      },
      build = {
        description = 'Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)',
        title = 'Builds',
      },
      ci = {
        description = 'Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)',
        title = 'Continuous Integrations',
      },
      chore = {
        description = "Other changes that don't modify src or test files",
        title = 'Chores',
      },
      revert = {
        description = 'Reverts a previous commit',
        title = 'Reverts',
      },
    },
    scopes = {},
  },
}

---Plugin setup
---@param opts cmp-conventionalcommits.PluginOptions
function M.setup(opts)
  opts = opts or {}
  M.options = {
    types = opts.types or M.default_config.types,
    scopes = opts.scopes or M.default_config.scopes,
  }
  local function set_default_global_entry(global_table, configuration_table)
    for key, value in pairs(configuration_table) do
      local is_table = type(configuration_table[key]) == 'table'

      ---@type CmpEntry
      local entry = {
        label = is_table and key or value,
        kind = require('cmp').lsp.CompletionItemKind.Keyword,
        documentation = is_table and util.get_documentation(value) or nil,
      }
      table.insert(global_table, entry)
    end
  end

  M.types = {}
  set_default_global_entry(M.types, M.options.types)
  M.scopes = {}
  set_default_global_entry(M.scopes, M.options.scopes)

  local commitlint_path = opts.commitlint_path
  if not commitlint_path then
    return
  end

  if type(commitlint_path) == 'string' then
    M.commitlint_path = commitlint_path
  elseif type(commitlint_path) == 'function' then
    M.commitlint_path = commitlint_path()
  end
end

return M
