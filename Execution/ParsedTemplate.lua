-- Encapsulation of a .kengen file that has been parsed
local Util = require("kengen2.Util")
local PreprocessState = require("kengen2.Execution.PreprocessState")
local ExecutionState = require("kengen2.Execution.ExecutionState")
local Settings = require("kengen2.Framework.Settings")
local ListParseNode = require("kengen2.Parser.ListParseNode")
local TokenizedFile = require("kengen2.Parser.TokenizedFile")
local IOutputStream = require("kengen2.Execution.IOutputStream")

local ParsedTemplate = Util.ClassUtil.CreateClass("ParsedTemplate", nil)

function ParsedTemplate:New(tokenizedFile, listNode)
    assert(Util.TestUtil.IsTable(self) and self:IsA(ParsedTemplate))
	assert(Util.TestUtil.IsTable(tokenizedFile) and tokenizedFile:IsA(TokenizedFile))
	assert(Util.TestUtil.IsTable(listNode) and listNode:IsA(ListParseNode))

    local instance = self:Create()
	instance.TokenizedFile = tokenizedFile
	instance.RootNode = listNode
	instance.RootNode:Preprocess(PreprocessState:New(tokenizedFile))
    return instance
end

function ParsedTemplate:Execute(outputStream)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ParsedTemplate))
	assert(Util.TestUtil.IsTable(outputStream) and outputStream:IsA(IOutputStream))
	
	assert(Util.TestUtil.IsTable(self.TokenizedFile) and
		Util.TestUtil.IsTable(self.TokenizedFile.Settings) and
		self.TokenizedFile.Settings:IsA(Settings))
	
	local executionState = ExecutionState:New(self.TokenizedFile, outputStream)
	self.RootNode:Execute(executionState)
	outputStream:Close()
end

return ParsedTemplate
