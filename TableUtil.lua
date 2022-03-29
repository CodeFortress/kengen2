local TableUtil = {}

-- From https://stackoverflow.com/questions/7925090/lua-find-a-key-from-a-value
function TableUtil.Invert(t)
    local s={}
    for k,v in pairs(t) do
      s[v]=k
    end
    return s
end

return TableUtil