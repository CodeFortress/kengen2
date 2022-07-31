local AbstractParseNode = require("kengen2.Parser.Nodes.AbstractParseNode")
local ExecutionState = require("kengen2.Execution.ExecutionState")
local Util = require("kengen2.Util")

local TemplateChunkParseNode = Util.ClassUtil.CreateClass("TemplateChunkParseNode", AbstractParseNode)

function TemplateChunkParseNode:Preprocess(preprocessState)
	-- Nothing to do here
end

function TemplateChunkParseNode:Execute(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(TemplateChunkParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	for index = self.StartPos, self.EndPos, 1 do
		local cleanLine = executionState:GetCleanLine(index)
		executionState:WriteLine(cleanLine)
	end
end

return TemplateChunkParseNode
