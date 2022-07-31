local TestUtil = require("kengen2.Util.TestUtil")

local StringUtil = {}

-- Splits a string based on a provided separator, or whitespace if none is specified
-- Returns list of substrings
-- Adapted from: https://stackoverflow.com/a/40180465
function StringUtil.SplitOnCharacters(inputstr, sep)
	assert(TestUtil.IsString(inputstr))
	assert(sep ~= nil and TestUtil.IsString(sep))
	
    local fields = {}
    
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(inputstr, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end

function StringUtil.SplitOnSpacebarOnly(inputstr)
	assert(TestUtil.IsString(inputstr))
	return StringUtil.SplitOnCharacters(inputstr, " ")
end

-- Returns a version of the string without whitespace at front or back
-- From http://lua-users.org/wiki/StringTrim (it's #5)
 -- warning: has bad performance when string:match'^%s*$' and #string is large
function StringUtil.Trim(string)
	assert(TestUtil.IsString(string))
	
    return string:match'^%s*(.*%S)' or ''
end

-- Returns a version of the string without whitespace at front
function StringUtil.TrimStart(string)
	assert(TestUtil.IsString(string))
	
    return string:match'^%s*(.*)' or ''
end

-- Returns a version of the string without whitespace at back
function StringUtil.TrimEnd(string)
	assert(TestUtil.IsString(string))
	
    return string:match'^(.*%S)' or ''
end

-- Returns whether the string starts with a particular substring
-- From http://lua-users.org/wiki/StringRecipes
function StringUtil.StartsWith(str, start)
	assert(TestUtil.IsString(str))
	assert(TestUtil.IsString(start))
	
    return str:sub(1, #start) == start
end

 -- Returns whether the string ends with a particular substring
-- From http://lua-users.org/wiki/StringRecipes
function StringUtil.EndsWith(str, ending)
	assert(TestUtil.IsString(str))
	assert(TestUtil.IsString(ending))
	
    return ending == "" or str:sub(-#ending) == ending
end

return StringUtil