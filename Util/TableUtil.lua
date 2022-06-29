local TableUtil = {}

-- From https://stackoverflow.com/questions/7925090/lua-find-a-key-from-a-value
function TableUtil.Invert(t)
    local s={}
    for k,v in pairs(t) do
      s[v]=k
    end
    return s
end

function TableUtil.CalcLength(table)
	local length = 0
	for _ in pairs(table) do
		length = length + 1
	end
	return length
end

return TableUtil