local ExecutionState = require("kengen2.Execution.ExecutionState")
local ListParseNode = require("kengen2.Parser.ListParseNode")
local PreprocessState = require("kengen2.Execution.PreprocessState")
local Util = require("kengen2.Util")

local StartTemplateParseNode = Util.ClassUtil.CreateClass("StartTemplateParseNode", ListParseNode)

function StartTemplateParseNode:Preprocess(preprocessState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(StartTemplateParseNode))
	assert(Util.TestUtil.IsTable(preprocessState) and preprocessState:IsA(PreprocessState))
	
	-- Not actually any work to do other than call children; script mode change already handled by parsing
	
	StartTemplateParseNode.SuperClass().Preprocess(self, preprocessState)
end

function StartTemplateParseNode:Execute(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(StartTemplateParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	-- Not actually any work to do other than call children; script mode change already handled by parsing
	
	StartTemplateParseNode.SuperClass().Execute(self, executionState)
end

return StartTemplateParseNode
