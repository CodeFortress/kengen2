local LU = require('kengen2.ThirdParty.luaunit.luaunit')
local FileOutputStream = require("kengen2.Execution.FileOutputStream")

local FileUtil = require("kengen2.Util.FileUtil")
local PathUtil = require("kengen2.Util.PathUtil")

Test_FileOutputStream = {}

function Test_FileOutputStream:Test_Class()
	
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)
	
	local Path = RunningScriptDir.."/../file_output_stream_test.txt"
	
	local Stream = FileOutputStream:New(Path)
	Stream:WriteLine("Hello, World")
	Stream:WriteLine("Welcome to Kengen!")
	Stream:Close()
	
	local Result = FileUtil.FileToString(Path)
	
	LU.assertEquals(Result, "Hello, World\nWelcome to Kengen!\n")
	
	LU.assertTrue(os.remove(Path))
end

return Test_FileOutputStream