local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local PathUtil = require("kengen2.Util.PathUtil")
local StringUtil = require("kengen2.Util.StringUtil")
local TestUtil = require("kengen2.Util.TestUtil")

Test_PathUtil = {}

function Test_PathUtil:Test_Unit_GetRunningScriptDirectoryPath()
	local Path = PathUtil.GetRunningScriptDirectoryPath()
	LU.assertTrue(
		StringUtil.EndsWith(Path, "kengen2\\Test\\Util\\") or
		StringUtil.EndsWith(Path, "kengen2/Test/Util/"))
end

return Test_PathUtil