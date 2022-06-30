-- Takes the results of the XmlParser and converts it into the format preferred by kengen
-- This file was used in CoGS for CA, but was part of kengen first
-- Changes have been made for kengen2
local xml = {}

local TableUtil = require("kengen2.Util.TableUtil")
local Settings = require("kengen2.Framework.Settings")
require("kengen2.ThirdParty.xmlparser")

-- this is intended as a meta function so that if someone accesses an element
-- 	 item.id
-- but the element ("id" in this case) is an array according to XmlParser, e.g.
--   <item><id>there_is_only_ever_one_of_these</id></item>
-- so they needed to do item[1].id,
-- then it automatically checks if the array is exactly length 1, and if so,
-- provides the behavior they "intended"
-- this is because XmlParser has no way to identify that the above XML could or couldn't have multiple "id" child elements
local function index_access_first(t, k)
	if #t == 1 then
		return t[1][k]
	else
		-- TODO should this error?
		return nil
	end
end

-- metatable with the above method replacing __index
local index_access_first_metatable = {__index = index_access_first}

-- forward declare local so we can call it recursively
local xml_to_tables_impl 

-- converter which takes output of XmlParser as _source and fills out a result variable with kengen-formatted tables
-- strips out things we don't want code to care about like ".ChildNodes"
local function xml_to_tables(_source, _settings)
	local result = {}
	xml_to_tables_impl(_source, result, _settings)
	return result
end

-- actual implementation using recursion
xml_to_tables_impl = function (_source, _target, _settings)
	
	-- set the value for the text key if the source data had any text in the element
	if _source.Value ~= nil then
		_target[_settings.XML_ELEMENT_TEXT_KEY] = _source.Value
	else
		_target[_settings.XML_ELEMENT_TEXT_KEY] = ""
	end
	
	-- map attributes from source data to output 1:1
	for attributeKey, attributeValue in pairs(_source.Attributes) do
		_target[attributeKey] = attributeValue
	end
	
	-- walk children in source data and map them to output in arrays based on element name
	for _, childNode in ipairs(_source.ChildNodes) do
		local childName = childNode.Name
		
		-- if this is the first time we've seen this type of child node, make the array for it
		if _target[childName] == nil then
			local targetTable = {}
			_target[childName] = targetTable
			 
			-- here's the secret sauce to get around ambiguity of xml elements 
			setmetatable(targetTable, index_access_first_metatable)
		end
		
		-- recursively do this work on the child
		local array = _target[childName]
		array[#array + 1] = {}
		childArray = array[#array]
		xml_to_tables_impl(childNode, childArray, _settings)
	end
	
	-- if a child element is absolutely empty except for its value, we just want to use that directly
	-- e.g. <item><id>01234</id></item>
	-- should be accessible as just item.id, not item.id[1].InnerText or any of that
	-- however, this is only works if there is 1 of that child and that child has no attributes
	-- so, we check our settings and flatten as appropriate
	if _settings.XML_FLATTEN_ELEMENT_TEXT then
		for _, childNode in ipairs(_source.ChildNodes) do
			local childName = childNode.Name
			local correspondingTable = _target[childName]
			if #correspondingTable == 1 and TableUtil.CalcLength(correspondingTable[1]) <= 1 then
				_target[childName] = correspondingTable[1][_settings.XML_ELEMENT_TEXT_KEY]
			end
		end
	end
end

-- actual API function for loading an xml string into kengen
function xml.loadXmlString(_string, _settings)
	local xmlTree=XmlParser:ParseXmlText(_string)
	return xml_to_tables(xmlTree, _settings)
end

-- actual API function for loading an xml file into kengen
function xml.loadXmlFile(_path, _settings)
	io.input(_path)
	local xmlRaw = io.read("*all")
	return xml.loadXmlString(xmlRaw, _settings)
end

-- actual API function for loading an xml string or file, determined on the fly
function xml.loadXmlAutomatic(_filepathOrRawString, _settings)
	if string.find(_filepathOrRawString, "<") then
		return xml.loadXmlString(_filepathOrRawString, _settings)
	else
		return xml.loadXmlFile(_filepathOrRawString, _settings)
	end
end

return xml