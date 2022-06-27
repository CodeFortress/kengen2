local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local Util = require("kengen2.Util")

-- Parse node base class for any node that owns a list of child nodes
local ListParseNode = Util.ClassUtil.CreateClass("ListParseNode", AbstractParseNode)

function ListParseNode:New(nodesList)
    assert(Util.TestUtil.IsTable(self) and self:IsA(ListParseNode))
    assert(Util.TestUtil.IsTable(nodesList))
    assert(#nodesList > 0)

    self.NodeList = nodesList

    local startPos = nodesList[1].StartPos
    local endPos = nodesList[#nodesList].EndPos

    local instance = ListParseNode.SuperClass().New(self, startPos, endPos)
    return instance
end

return ListParseNode
