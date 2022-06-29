-- Takes the results of the json parser and converts it into the format preferred by kengen
-- This file was used in CoGS for CA, but was part of kengen first
-- Changes have been made for kengen2
local Json = {}

local JsonParser = require("kengen2.ThirdParty.jsonparser")

-- actual API function for loading a json string into kengen
function Json.LoadJsonString(string)
	return JsonParser.Parse(string)
end

-- actual API function for loading a json file into kengen
function Json.LoadJsonFile(path)
	io.input(path)
	local jsonRaw = io.read("*all")
	return json.LoadJsonString(jsonRaw)
end

-- actual API function for loading a json string or file, determined on the fly
function Json.LoadJsonAutomatic(filepathOrRawString)
	if string.find(filepathOrRawString, ":") then
		return Json.LoadJsonString(filepathOrRawString)
	else
		return Json.LoadJsonFile(filepathOrRawString)
	end
end

return Json