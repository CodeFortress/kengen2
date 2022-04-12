local AbstractParseNode = require("AbstractParseNode")
local Util = require("Util")

local ExecChainParseNode = Util.CreateClass("ExecChainParseNode", AbstractParseNode)

function ExecChainParseNode:New(nodesList)
    assert(Util.IsTable(self) and self:IsA(ExecChainParseNode))
    assert(Util.IsTable(nodesList))
    assert(#nodesList > 0)

    local startPos = nodesList[1].StartPos
    local endPos = nodesList[#nodesList].EndPos

    local instance = ExecChainParseNode.SuperClass().New(self, startPos, endPos)
    return instance
end

return ExecChainParseNode
