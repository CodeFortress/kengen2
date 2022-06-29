local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local ExecutionState = require("kengen2.Execution.ExecutionState")
local Util = require("kengen2.Util")

local ScriptChunkParseNode = Util.ClassUtil.CreateClass("ScriptChunkParseNode", AbstractParseNode)

function ScriptChunkParseNode:Preprocess(preprocessState)
	-- TODO: Actually perform work...
end

function ScriptChunkParseNode:Execute(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ScriptChunkParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	local scriptLines = {}
	for index = self.StartPos, self.EndPos, 1 do
		scriptLines[#scriptLines + 1] = executionState:GetRawLine(index)
	end
	
	local fullChunk = table.concat(scriptLines, "\n")
	load(fullChunk)()
end

return ScriptChunkParseNode
