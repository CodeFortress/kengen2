local ExecutionState = require("kengen2.Execution.ExecutionState")
local Iterator = require("kengen2.Framework.Iterator")
local ListParseNode = require("kengen2.Parser.Nodes.ListParseNode")
local PreprocessState = require("kengen2.Execution.PreprocessState")
local Util = require("kengen2.Util")

local ForeachParseNode = Util.ClassUtil.CreateClass("ForeachParseNode", ListParseNode)

-- possible preceding . or >, whitespace, FOREACH keyword, whitespace, clause, whitespace, IN keyword, whitespace
local REGEX_MATCH_FOREACH = "^%s*%.?%s*FOREACH%s+(.*)%s+IN%s+"

-- a regex just to get the correct amount of white space in front of FOREACH for genned code
local REGEX_MATCH_FOREACH_SPACE = "^(%s*)FOREACH"

local REGEX_MATCH_IN = "IN%s+(.*)%s+"
local REGEX_MATCH_AS = "AS%s+(.*)%s"
local REGEX_MATCH_WHERE = "WHERE%s+(.*)%s"
local REGEX_MATCH_BY = "BY%s+(.*)%s"
local REGEX_MATCH_SUFFIX_AS = "AS%s+"
local REGEX_MATCH_SUFFIX_WHERE = "WHERE%s+"
local REGEX_MATCH_SUFFIX_BY = "BY%s+"
local REGEX_MATCH_SUFFIX_DO = "DO%s*$"

function ForeachParseNode:New(nodesList)
    assert(Util.TestUtil.IsTable(self) and self:IsA(ForeachParseNode))
    -- parent class will validate the nodesList

    local instance = ForeachParseNode.SuperClass().New(self, nodesList)
	instance.ForeachLineNum = instance.StartPos - 1
    return instance
end

function ForeachParseNode:Preprocess(preprocessState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ForeachParseNode))
	assert(Util.TestUtil.IsTable(preprocessState) and preprocessState:IsA(PreprocessState))
	
	self.SuperClass().Preprocess(self, preprocessState)
	
	local line = preprocessState:GetRawLine(self.ForeachLineNum)
	
	local foreachContents = line:match(REGEX_MATCH_FOREACH)
	assert(foreachContents ~= nil,
		preprocessState:MakeError(self.ForeachLineNum, "Malformed FOREACH, could not identify what's between FOREACH and IN"))
	assert(line:find(REGEX_MATCH_SUFFIX_DO) ~= nil,
		preprocessState:MakeError(self.ForeachLineNum, "FOREACH loop without a DO on the same line; this is not supported yet"))
	
	local inContents = line:match(REGEX_MATCH_IN..REGEX_MATCH_SUFFIX_AS)
	if inContents == nil then
		inContents = line:match(REGEX_MATCH_IN..REGEX_MATCH_SUFFIX_WHERE)
	end
	if inContents == nil then
		inContents = line:match(REGEX_MATCH_IN..REGEX_MATCH_SUFFIX_BY)
	end
	if inContents == nil then
		inContents = line:match(REGEX_MATCH_IN..REGEX_MATCH_SUFFIX_DO)
	end
	assert(inContents ~= nil,
		preprocessState:MakeError(self.ForeachLineNum, "Malformed FOREACH, does not have a valid IN clause"))
	
	local asContents = line:match(REGEX_MATCH_AS..REGEX_MATCH_SUFFIX_WHERE)
	if asContents == nil then
		asContents = line:match(REGEX_MATCH_AS..REGEX_MATCH_SUFFIX_BY)
	end
	if asContents == nil then
		asContents = line:match(REGEX_MATCH_AS..REGEX_MATCH_SUFFIX_DO)
	end
	
	local whereContents = line:match(REGEX_MATCH_WHERE..REGEX_MATCH_SUFFIX_BY)
	if whereContents == nil then
		whereContents = line:match(REGEX_MATCH_WHERE..REGEX_MATCH_SUFFIX_DO)
	end
	
	local byContents = line:match(REGEX_MATCH_BY..REGEX_MATCH_SUFFIX_DO)
	
	self.ForeachContents = foreachContents
	self.InContents = inContents
	self.AsContents = asContents
	self.WhereContents = whereContents
	self.ByContents = byContents
end

function ForeachParseNode:Execute(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ForeachParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	self:PrepareIteration(executionState)
	
	local function executeChildNodes()
		ForeachParseNode.SuperClass().Execute(self, executionState)
	end
	
	assert(self.VarName ~= nil)
	
	local iterator = self.Iterator:Make_Iterator()
	for currentItem in iterator do
		--GLOBAL_FOREACH_ITERATION_VAR = currentItem
		executionState:SetVar(self.VarName, currentItem)
		--executionState:LoadLua(self.VarName.." = GLOBAL_FOREACH_ITERATION_VAR")()
		
		executeChildNodes()
	end
end

function ForeachParseNode:PrepareIteration(executionState)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ForeachParseNode))
	assert(Util.TestUtil.IsTable(executionState) and executionState:IsA(ExecutionState))
	
	local varName
	local foreachFuncLoader
	if asContents ~= nil then
		assert(executionState.Settings.ACCESS_STYLE_XML, "Line #"..tostring(self.ForeachLineNum).." of ".._filePath.." -- The 'AS' clause is only supported in XML style")
		varName = self.AsContents
		foreachFuncLoader = executionState:LoadLua("return "..self.InContents.."."..self.ForeachContents, self.ForeachLineNum)
	elseif executionState.Settings.ACCESS_STYLE_XML then
		varName = self.ForeachContents
		foreachFuncLoader = executionState:LoadLua("return "..self.InContents.."."..self.ForeachContents, self.ForeachLineNum)
	else
		varName = self.ForeachContents
		foreachFuncLoader = executionState:LoadLua("return "..self.InContents, self.ForeachLineNum)
	end
	assert(varName ~= nil and varName:len() > 0,
		executionState:MakeError(self.ForeachLineNum, "Malformed FOREACH, got an empty var name"))
	
	local whereFuncLoader = nil
	if self.WhereContents ~= nil then
		whereFuncLoader = executionState:LoadLua("return function ("..varName..") return "..self.WhereContents.." end", self.ForeachLineNum)
	end
	
	local byFuncLoader = nil
	if self.ByContents ~= nil then
		local comparePhrase1 = self.ByContents:gsub(varName, varName.."1")
		local comparePhrase2 = self.ByContents:gsub(varName, varName.."2")
		byFuncLoader = executionState:LoadLua(
			"return function ("..varName.."1, "..varName.."2) return "..comparePhrase1.." < "..comparePhrase2.." end",
			self.ForeachLineNum)
	end
	
	local foreachFunc = foreachFuncLoader()
	local whereFunc = (whereFuncLoader and whereFuncLoader()) or nil
	local byFunc = (byFuncLoader and byFuncLoader()) or nil
	
	self.VarName = varName
	self.Iterator = Iterator:New(foreachFunc, whereFunc, byFunc)
end

return ForeachParseNode
