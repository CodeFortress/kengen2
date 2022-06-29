-- Encapsulation of a .kengen file that has been parsed
local Util = require("kengen2.Util")
local Settings = require("kengen2.Framework.Settings")
local TokenizedFile = require("kengen2.Parser.TokenizedFile")
local IOutputStream = require("kengen2.Execution.IOutputStream")

local ExecutionState = Util.ClassUtil.CreateClass("ExecutionState", nil)

function ExecutionState:New(tokenizedFile, outputStream)
    assert(Util.TestUtil.IsTable(self) and self:IsA(ExecutionState))
	assert(Util.TestUtil.IsTable(tokenizedFile) and tokenizedFile:IsA(TokenizedFile))
	assert(Util.TestUtil.IsTable(outputStream) and outputStream:IsA(IOutputStream))

    local instance = self:Create()
	instance.TokenizedFile = tokenizedFile
	instance.Settings = tokenizedFile.Settings
	instance.OutputStream = outputStream
    return instance
end

function ExecutionState:GetRawLine(pos)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ExecutionState))
	return self.TokenizedFile:GetRawLine(pos)
end

function ExecutionState:GetCleanLine(pos)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ExecutionState))
	return self.TokenizedFile:GetCleanLine(pos)
end

function ExecutionState:MakeError(lineNum, msg)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ExecutionState))
	return self.TokenizedFile.Path..":"..lineNum.." -- "..msg
end

function ExecutionState:WriteLine(line)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ExecutionState))
	return self.OutputStream:WriteLine(line)
end

return ExecutionState
