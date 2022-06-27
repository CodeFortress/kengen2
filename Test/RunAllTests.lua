local Parser = require("kengen2.Parser")
local PathUtil = require("kengen2.Util.PathUtil")

local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
assert(RunningScriptDir ~= nil)

Parser.ParseHelper.ParseFile(RunningScriptDir.."/test.kengen")

print("ALL KENGEN2 TESTS PASSED!!!")