local Util = require("Util")

local Token = Util.CreateClass("Token", nil)

function Token:New(tokenType, startPos, endPos)
    assert(Util.IsTable(self) and self:IsA(Token))
    assert(Util.IsNumber(tokenType))
    assert(Util.IsNumber(startPos))
    assert(Util.IsNumber(endPos))
    assert(startPos <= endPos)

    local result = self:Create()
    result.Type = tokenType
    result.StartPos = startPos
    result.EndPos = endPos
    return result
end

return Token