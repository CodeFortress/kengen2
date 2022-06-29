-- Encapsulation of a .kengen file that has been parsed
local Util = require("kengen2.Util")
local Settings = require("kengen2.Framework.Settings")
local TokenizedFile = require("kengen2.Parser.TokenizedFile")

local PreprocessState = Util.ClassUtil.CreateClass("PreprocessState", nil)

function PreprocessState:New(tokenizedFile)
    assert(Util.TestUtil.IsTable(self) and self:IsA(PreprocessState))
	assert(Util.TestUtil.IsTable(tokenizedFile) and tokenizedFile:IsA(TokenizedFile))

    local instance = self:Create()
	instance.TokenizedFile = tokenizedFile
	instance.Settings = tokenizedFile.Settings
    return instance
end

function PreprocessState:GetRawLine(pos)
	assert(Util.TestUtil.IsTable(self) and self:IsA(PreprocessState))
	return self.TokenizedFile:GetRawLine(pos)
end

function PreprocessState:MakeError(lineNum, msg)
	assert(Util.TestUtil.IsTable(self) and self:IsA(PreprocessState))
	return self.TokenizedFile.Path..":"..lineNum.." -- "..msg
end

return PreprocessState
