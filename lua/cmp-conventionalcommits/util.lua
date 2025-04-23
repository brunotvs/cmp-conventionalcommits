local M = {}
---@type fun(props: {title: string?, description: string?}): string
function M.get_documentation(props)
  local typeTitle = props.title or ''
  local typeDesc = props.description or ''
  local sep = ''
  if typeTitle ~= '' and typeDesc ~= '' then
    sep = ': '
  end
  return typeTitle .. sep .. typeDesc
end

return M
