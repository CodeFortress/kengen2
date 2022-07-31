local AbstractParseNode = require("kengen2.Parser.Nodes.AbstractParseNode")
local ExecutionState = require("kengen2.Execution.ExecutionState")
local PreprocessState = require("kengen2.Execution.PreprocessState")
local Util = require("kengen2.Util")

local EmptyParseNode = Util.ClassUtil.CreateClass("EmptyParseNode", AbstractParseNode)

function EmptyParseNode:Preprocess(preprocessState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(EmptyParseNode))
	assert(Util.TestUtil.IsTable(preprocessState) and preprocessState:IsA(PreprocessState))
	-- Nothing to do
end

function EmptyParseNode:Execute(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(EmptyParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	-- Nothing to do
end

return EmptyParseNode
