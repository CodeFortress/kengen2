local AbstractParseNode = require("kengen2.Parser.AbstractParseNode")
local ExecutionState = require("kengen2.Execution.ExecutionState")
local ListParseNode = require("kengen2.Parser.ListParseNode")
local PreprocessState = require("kengen2.Execution.PreprocessState")
local Util = require("kengen2.Util")

local REGEX_MATCH_IF = "^%s*%.?%s*IF%s+(.*)%s+THEN%s*$"
local REGEX_MATCH_ELSEIF = "^%s*%.?%s*ELSEIF%s+(.*)%s+THEN%s*$"

local IfParseNode = Util.ClassUtil.CreateClass("IfParseNode", AbstractParseNode)

function IfParseNode:New(startPos, endPos, ifNode, elseIfNodeList, elseNode)
    assert(Util.TestUtil.IsTable(self) and self:IsA(IfParseNode))
	assert(Util.TestUtil.IsNumber(startPos))
	assert(Util.TestUtil.IsNumber(endPos))
    assert(Util.TestUtil.IsTable(ifNode) and ifNode:IsA(AbstractParseNode))
	assert(Util.TestUtil.IsTable(elseIfNodeList))
	local previousLineNum = 0
	for _, elseIfNode in pairs(elseIfNodeList) do
		assert(Util.TestUtil.IsTable(elseIfNode))
		assert(Util.TestUtil.IsTable(elseIfNode) and elseIfNode:IsA(AbstractParseNode))
		assert(elseIfNode.StartPos > previousLineNum)
		previousLineNum = elseIfNode.StartPos
	end
	assert((elseNode == nil) or (Util.TestUtil.IsTable(elseNode) and elseNode:IsA(AbstractParseNode)))

    local instance = IfParseNode.SuperClass().New(self, startPos, endPos)
	instance.IfNode = ifNode
	instance.IfContents = nil
	instance.IfFunc = nil
	instance.ElseIfList = elseIfNodeList
	instance.ElseIfListContents = nil
	instance.ElseLineNum = elseLineNum
	instance.ElseNode = elseNode
    return instance
end

-- This is kind of gross, but the ElseIf nodes are all whatever type is contained BETWEEN the ELSEIF
--	and whatever the next delimiter is. So their start pos is the line AFTER the ELSEIF.
local function GetElseIfLineNum(node)
	return node.StartPos - 1
end

function IfParseNode:Preprocess(preprocessState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(IfParseNode))
	assert(Util.TestUtil.IsTable(preprocessState) and preprocessState:IsA(PreprocessState))
	
	local line = preprocessState:GetRawLine(self.StartPos)
	
	self.IfNode:Preprocess(preprocessState)
	self.IfContents = line:match(REGEX_MATCH_IF)
	assert(self.IfContents ~= nil,
		preprocessState:MakeError(self.StartPos, "Malformed IF...THEN, could not identify what's between IF and THEN"))
	
	self.ElseIfListContents = {}
	for _, elseIfNode in pairs(self.ElseIfList) do
		-- Validate that we can properly parse ElseIfList lines
		local elseIfLineNum = GetElseIfLineNum(elseIfNode)
		line = preprocessState:GetRawLine(elseIfLineNum)
		elseIfNode:Preprocess(preprocessState)
		local contents = line:match(REGEX_MATCH_ELSEIF)
		assert(contents ~= nil,
			preprocessState:MakeError(elseIfLineNum, "Malformed ELSEIF...THEN, could not identify what's between ELSEIF and THEN"))
		self.ElseIfListContents[elseIfLineNum] = contents
	end
end

function IfParseNode:Execute(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(IfParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	self.IfFunc, err = executionState:LoadLua("return "..self.IfContents, self.StartPos)
	assert(self.IfFunc ~= nil,
		executionState:MakeError(self.IfLine, "Failed to load '"..self.IfContents.."' into a function due to error: "..tostring(err)))
	
	if self.IfFunc() then
		self.IfNode:Execute(executionState)
	else
		local executedABlock = false
		for _, elseIfNode in ipairs(self.ElseIfList) do
			local elseIfLineNum = GetElseIfLineNum(elseIfNode)
			local elseIfLineContents = self.ElseIfListContents[elseIfLineNum]
			assert(elseIfLineContents ~= nil, "Coding error, expected elseIfLineContents to be cached")
			
			local elseIfFunc, err = executionState:LoadLua("return "..elseIfLineContents, elseIfLineNum) 
			assert(elseIfFunc ~= nil,
				executionState:MakeError(elseIfLineNum, "Failed to load '"..elseIfLineContents.."' into a function due to error: "..tostring(err)))
			
			if elseIfFunc() then
				executedABlock = true
				elseIfNode:Execute(executionState)
				break
			end
		end
		if not executedABlock then
			if self.ElseNode then
				self.ElseNode:Execute(executionState)
			end
		end
	end
end

return IfParseNode
