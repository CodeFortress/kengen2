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
	
	-- Create a sub-environment of _G that has access to everything in _G
	-- This way, called Lua can't screw up our environment, but can still call things in it (e.g. "require")
	instance.LuaLoadEnv = {}
	setmetatable(instance.LuaLoadEnv, {__index = _G})

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
	assert(Util.TestUtil.IsString(msg))
	return self.TokenizedFile.Path..":"..tostring(lineNum).." -- "..msg
end

function ExecutionState:WriteLine(line)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ExecutionState))
	assert(Util.TestUtil.IsString(line))
	return self.OutputStream:WriteLine(line)
end

function ExecutionState:SetVar(var, value)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ExecutionState))
	assert(var ~= nil)
	
	self.LuaLoadEnv[var] = value
end

function ExecutionState:LoadLua(textChunk, lineNumStart, lineNumEnd)
	assert(Util.TestUtil.IsTable(self) and self:IsA(ExecutionState))
	assert(Util.TestUtil.IsString(textChunk))
	
	local chunkName = "Chunkname_TODO"
	local result, err = load(textChunk, chunkName, "t", self.LuaLoadEnv)
	assert(result ~= nil,
		self:MakeError(lineNumStart, "Failed to load '"..textChunk.."' due to error: "..tostring(err)))
	return result, err
end

return ExecutionState
