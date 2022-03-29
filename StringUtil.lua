local StringUtil = {}

-- Splits a string based on a provided separator, or whitespace if none is specified
-- Returns list of substrings
-- Adapted from: https://stackoverflow.com/a/7615129
function StringUtil.Split(inputstr, sep)
    sep = sep or '%s'
    local t={}
    for field, s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do
        table.insert(t,field) 
        if s=="" then
            return t
        end
    end
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