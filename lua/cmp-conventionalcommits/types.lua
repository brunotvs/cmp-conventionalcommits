---@class cmp-conventionalcommits.PluginOptions
---@field types  string[] | table<string,ConventionalCommitsType> | nil
---@field scopes string[] | table<string,ConventionalCommitsType> | nil
---@field commitlint_path string | nil

---@class ConventionalCommitsType
---@field title string?
---@field description string?

---@class CmpEntry
---@field label string
---@field kind number
---@field documentation string?
