local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local PreprocessParams = require("kengen2.Execution.PreprocessParams")
local Util = require("kengen2.Util")

-- Parse node base class for any node that owns a list of child nodes
local ListParseNode = Util.ClassUtil.CreateClass("ListParseNode", AbstractParseNode)

function ListParseNode:New(nodesList)
    assert(Util.TestUtil.IsTable(self) and self:IsA(ListParseNode))
    assert(Util.TestUtil.IsTable(nodesList))
    assert(#nodesList > 0)
	
	local curPos = 0
	for _, node in ipairs(nodesList) do
		assert(Util.TestUtil.IsTable(node) and node:IsA(AbstractParseNode))
		assert(node.StartPos > curPos)
		assert(node.EndPos >= node.StartPos)
		curPos = node.EndPos
	end

    local startPos = nodesList[1].StartPos
    local endPos = nodesList[#nodesList].EndPos

    local instance = ListParseNode.SuperClass().New(self, startPos, endPos)
	instance.NodeList = nodesList
    return instance
end

function ListParseNode:Preprocess(preprocessParams)
	assert(Util.TestUtil.IsTable(preprocessParams) and preprocessParams:IsA(PreprocessParams))
	
	for _, node in ipairs(self.NodeList) do
		node:Preprocess(preprocessParams)
	end
end

return ListParseNode
