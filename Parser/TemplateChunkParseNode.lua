local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local ExecutionState = require("kengen2.Execution.ExecutionState")
local Util = require("kengen2.Util")

local TemplateChunkParseNode = Util.ClassUtil.CreateClass("TemplateChunkParseNode", AbstractParseNode)

function TemplateChunkParseNode:Preprocess(preprocessState)
	-- TODO: Actually perform work...
end

function TemplateChunkParseNode:Execute(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(TemplateChunkParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	for index = self.StartPos, self.EndPos, 1 do
		executionState:WriteLine(executionState:GetCleanLine(index))
	end
end

return TemplateChunkParseNode
