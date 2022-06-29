-- Encapsulation of a .kengen file that has been parsed
local Util = require("kengen2.Util")
local Settings = require("kengen2.Framework.Settings")
local TokenizedFile = require("kengen2.Parser.TokenizedFile")

local PreprocessParams = Util.ClassUtil.CreateClass("PreprocessParams", nil)

function PreprocessParams:New(tokenizedFile, listNode)
    assert(Util.TestUtil.IsTable(self) and self:IsA(PreprocessParams))
	assert(Util.TestUtil.IsTable(tokenizedFile) and tokenizedFile:IsA(TokenizedFile))

    local instance = self:Create()
	instance.TokenizedFile = tokenizedFile
    return instance
end

function PreprocessParams:GetLine(pos)
	assert(Util.TestUtil.IsTable(self) and self:IsA(PreprocessParams))
	return self.TokenizedFile:GetLine(pos)
end

function PreprocessParams:MakeError(lineNum, msg)
	assert(Util.TestUtil.IsTable(self) and self:IsA(PreprocessParams))
	return self.TokenizedFile.Path..":"..lineNum.." -- "..msg
end

return PreprocessParams
