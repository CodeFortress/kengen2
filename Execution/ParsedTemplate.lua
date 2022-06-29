-- Encapsulation of a .kengen file that has been parsed
local Util = require("kengen2.Util")
local PreprocessParams = require("kengen2.Execution.PreprocessParams")
local Settings = require("kengen2.Framework.Settings")
local ListParseNode = require("kengen2.Parser.ListParseNode")
local TokenizedFile = require("kengen2.Parser.TokenizedFile")

local ParsedTemplate = Util.ClassUtil.CreateClass("ParsedTemplate", nil)

function ParsedTemplate:New(tokenizedFile, listNode)
    assert(Util.TestUtil.IsTable(self) and self:IsA(ParsedTemplate))
	assert(Util.TestUtil.IsTable(tokenizedFile) and tokenizedFile:IsA(TokenizedFile))
	assert(Util.TestUtil.IsTable(listNode) and listNode:IsA(ListParseNode))

    local instance = self:Create()
	instance.TokenizedFile = tokenizedFile
	instance.RootNode = listNode
	instance.RootNode:Preprocess(PreprocessParams:New(tokenizedFile))
    return instance
end

function ParsedTemplate:Execute(settings)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ParsedTemplate))
	assert(Util.TestUtil.IsTable(settings) and settings:IsA(Settings))
	
	self.RootNode:Execute(settings)
end

return ParsedTemplate
