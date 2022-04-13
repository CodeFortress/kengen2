local Util = require("Util")

local AbstractParseNode = Util.CreateClass("AbstractParseNode", nil)

function AbstractParseNode:New(startPos, endPos)
    assert(Util.IsTable(self) and self:IsA(AbstractParseNode))
    assert(Util.IsNumber(startPos))
    assert(Util.IsNumber(endPos))
    assert(startPos <= endPos)

    local instance = self:Create()
    instance.StartPos = startPos
    instance.EndPos = endPos
    return instance
end

return AbstractParseNode
