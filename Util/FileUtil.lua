local TestUtil = require("kengen2.Util.TestUtil")

local FileUtil = {}

-- Returns the string contents of the given filepath
function FileUtil.FileToString(filepath)
	assert(TestUtil.IsString(filepath))
	
    local file = assert(io.open(filepath, "r"), "Failed to open file with filepath: "..tostring(filepath))
    local content = file:read("*all")
    file:close()
    return content
end

return FileUtil