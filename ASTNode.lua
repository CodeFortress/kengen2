local Util = require("Util")

local ASTNode = {}
ASTNode.__index = ASTNode

function ASTNode.New(grammarRuleOrItem, startPos, endPos)
    assert(Util.IsTable(grammarRuleOrItem))
    assert(Util.IsInteger(startPos))
    assert(Util.IsInteger(endPos))
    assert(startPos <= endPos)

    local self = setmetatable({}, ASTNode)
    self.Rule = grammarRuleOrItem
    self.StartPos = startPos
    self.EndPos = endPos
    return self
end

return ASTNode