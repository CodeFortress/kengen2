local ExecutionState = require("kengen2.Execution.ExecutionState")
local ListParseNode = require("kengen2.Parser.ListParseNode")
local PreprocessState = require("kengen2.Execution.PreprocessState")
local Util = require("kengen2.Util")

local REGEX_MATCH_IF = "^%s*%.?%s*IF%s+(.*)%s+THEN%s*$"

local IfParseNode = Util.ClassUtil.CreateClass("IfParseNode", ListParseNode)

function IfParseNode:New(nodesList)
    assert(Util.TestUtil.IsTable(self) and self:IsA(IfParseNode))
    -- parent class will validate the nodesList

    local instance = IfParseNode.SuperClass().New(self, nodesList)
	instance.IfLine = instance.StartPos - 1
	instance.IfContents = nil
	instance.IfFunc = nil
    return instance
end

function IfParseNode:Preprocess(preprocessState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(IfParseNode))
	assert(Util.TestUtil.IsTable(preprocessState) and preprocessState:IsA(PreprocessState))
	
	self.SuperClass().Preprocess(self, preprocessState)
	
	local line = preprocessState:GetRawLine(self.IfLine)
	
	self.IfContents = line:match(REGEX_MATCH_IF)
	assert(self.IfContents ~= nil,
		preprocessState:MakeError(self.IfLine, "Malformed IF...THEN, could not identify what's between IF and THEN"))
end

function IfParseNode:Execute(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(IfParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	self.IfFunc, err = executionState:LoadLua("return "..self.IfContents, self.IfLine)
	assert(self.IfFunc ~= nil,
		executionState:MakeError(self.IfLine, "Failed to load '"..self.IfContents.."' into a function due to error: "..tostring(err)))
	
	if self.IfFunc() then
		IfParseNode.SuperClass().Execute(self, executionState)
	-- TODO: elseif / else
	end
end

return IfParseNode
