local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local FileUtil = require("kengen2.Util.FileUtil")
local PathUtil = require("kengen2.Util.PathUtil")

Test_FileUtil = {}

function Test_FileUtil:Test_Unit_FileToString()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)
	
	local Path = RunningScriptDir.."/../sample_file.txt"
	local Result = FileUtil.FileToString(Path)
	LU.assertEquals(Result,
		[[to be, or not to be?
that is the question
for whether tis nobler to suffer the
slings and arrows of outrageous fortune]])
end

return Test_FileUtil