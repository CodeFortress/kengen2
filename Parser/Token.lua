local TokenTypes = require("kengen2.Parser.TokenTypes")
local Util = require("kengen2.Util")

local Token = Util.ClassUtil.CreateClass("Token", nil)

function Token:New(tokenType, startPos, endPos)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Token))
    assert(TokenTypes.IsToken(tokenType))
    assert(Util.TestUtil.IsNumber(startPos))
    assert(Util.TestUtil.IsNumber(endPos))
    assert(startPos <= endPos)

    local result = self:Create()
    result.Type = tokenType
    result.StartPos = startPos
    result.EndPos = endPos
    return result
end

return Token