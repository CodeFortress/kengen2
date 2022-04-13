local AbstractParseNode = require("AbstractParseNode")
local Util = require("Util")

-- Parse node base class for any node that owns a list of child nodes
local ListParseNode = Util.CreateClass("ListParseNode", AbstractParseNode)

function ListParseNode:New(nodesList)
    assert(Util.IsTable(self) and self:IsA(ListParseNode))
    assert(Util.IsTable(nodesList))
    assert(#nodesList > 0)

    self.NodeList = nodesList

    local startPos = nodesList[1].StartPos
    local endPos = nodesList[#nodesList].EndPos

    local instance = ListParseNode.SuperClass().New(self, startPos, endPos)
    return instance
end

return ListParseNode
