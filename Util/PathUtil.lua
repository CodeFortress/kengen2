local PathUtil = {}

function PathUtil.GetRunningScriptDirectoryPath()
	local str = debug.getinfo(2, "S").source:sub(2)
	local result = str:match("(.*/)")
	
	-- If not found, assume we're on Windows
	if (result == nil) then
		result = str:match("(.*[/\\])")
	end
	
	return result
end

return PathUtil