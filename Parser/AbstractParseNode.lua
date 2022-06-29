local Util = require("kengen2.Util")

local AbstractParseNode = Util.ClassUtil.CreateClass("AbstractParseNode", nil)

function AbstractParseNode:New(startPos, endPos)
    assert(Util.TestUtil.IsTable(self) and self:IsA(AbstractParseNode))
    assert(Util.TestUtil.IsNumber(startPos))
    assert(Util.TestUtil.IsNumber(endPos))
    assert(startPos <= endPos)

    local instance = self:Create()
    instance.StartPos = startPos
    instance.EndPos = endPos
    return instance
end

function AbstractParseNode:Preprocess(preprocessState)
	error(self:ClassName().." needs to override Preprocess")
end

function AbstractParseNode:Execute(executionState)
	error(self:ClassName().." needs to override Execute")
end

return AbstractParseNode
