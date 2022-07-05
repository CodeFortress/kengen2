local StringUtil = {}

-- Splits a string based on a provided separator, or whitespace if none is specified
-- Returns list of substrings
-- Adapted from: https://stackoverflow.com/a/40180465
function StringUtil.Split(inputstr, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(inputstr, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end

-- Returns the string contents of the given filepath
function StringUtil.FileToString(filepath)
    local file = assert(io.open(filepath, "rb"), "Failed to open file with filepath: "..tostring(filepath))
    local content = file:read("*all")
    file:close()
    return content
end

-- Returns a version of the string without whitespace at front or back
-- From http://lua-users.org/wiki/StringTrim (it's #5)
 -- warning: has bad performance when string:match'^%s*$' and #string is large
function StringUtil.Trim(string)
    return string:match'^%s*(.*%S)' or ''
end

-- Returns a version of the string without whitespace at front
function StringUtil.TrimStart(string)
    return string:match'^%s*(.*)' or ''
end

-- Returns a version of the string without whitespace at back
function StringUtil.TrimEnd(string)
    return string:match'^(.*%S)' or ''
end

-- Returns whether the string starts with a particular substring
-- From http://lua-users.org/wiki/StringRecipes
function StringUtil.StartsWith(str, start)
    return str:sub(1, #start) == start
end

 -- Returns whether the string ends with a particular substring
-- From http://lua-users.org/wiki/StringRecipes
function StringUtil.EndsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

return StringUtil