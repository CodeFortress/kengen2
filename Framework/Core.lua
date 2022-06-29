-- Converts kengen code into lua.
-- This file was used in CoGS for CA, but was part of kengen first
-- Changes have been made for kengen2
-- This was originally command-line driven in kengen v0.1

local lfs =			require("lfs")
local getopt_alt =	require("kengen.thirdparty.getopt_alt")
local utilities =	require("kengen.framework.utilities")

------------- COMMAND LINE PARAMS -------------
local commandLineHelp = [[
Kengen v0.1 Command Line Options
Kengen is a code-generation tool which uses a Lua-based syntax to make code
	generation easy and more fun

core
  -e              :    (requires -g) erase all generated files if the gofile
                           ran successfully
  --g=(filename)  :    if set, executes the generated file (the gofile) after
                           translations are complete; this is relative to any
						   path included using --p
  -h              :    print the help prompt and do nothing else  
  --k=(ext)       :    use ext as the file extension for kengen files;
                           defaults to "kengen"
  --p=(path)      :    if set, run kengen conversion on the provided path
                           instead of current working directory
  -r              :    if enabled, recursively convert all kengen files in
                           folders and subfolders 

xml
  -x          :    if enabled, prioritize syntax for input formats which
                        don't intrinsically support arrays such as XML
  -f          :    (requires -x) if enabled, flatten XML elements which have
                        only text and no children or attributes
  --i=(word)  :    (requires -x) XML elements will have their text placed
                        into this attribute; defaults to InnerText
  
example
   -xfr --g=main : Translate .kengen in the current working dir and subdirs
                   using XML and flattening, then run the "main.kengen" file
]]

------------- SETTINGS -------------
local argsWhichTakeStrings = "pkig"
local settings = getopt_alt.getopt(arg, argsWhichTakeStrings)
if settings["h"] or utilities.table_length(settings) == 0 then
	print(commandLineHelp)
	return
end

-- path to the folder where we want to convert kengen files into Lua
local TARGET_PATH = "."
if settings["p"] then TARGET_PATH = settings["p"] end

-- if true, convert kengen in child folders of the target directory, not just the directory itself
local DIRECTORY_RECURSION = false
if settings["r"] then DIRECTORY_RECURSION = true end

-- file extension to use for kengen files
local KENGEN_FILE_EXTENSION = "kengen"
if settings["k"] then KENGEN_FILE_EXTENSION = settings["k"] end

-- file name to execute after completing translation
local GO_FILENAME = nil
if settings["g"] then GO_FILENAME = settings["g"] end

-- handles input formats which don't intrinsically support arrays, such as XML (in XML, an array is just child nodes with the same identifier)
-- if true, "FOREACH card IN deck DO" is translated as "for card in deck.card do" because <deck><card/><card/><card/></deck>
-- if false, "FOREACH card IN deck DO" is translated as "for card in deck do" e.g. because "deck = { [ card1data ], [ card2data ] }
local ACCESS_STYLE_XML = false
if settings["x"] then ACCESS_STYLE_XML = true end

-- TODO: Autoswitch for ACCESS_STYLE_XML based on XML/JSON load functions called

-- if true, an XML element which has no attributes, just text, will be "flattened" so that the element maps directly to the string text
--	for xml of "<item>this is my text</item>", the "item" variable will have the value "this is my text"
--  for xml of "<item someAttribute="true">this is my text</item>", the "item" variable will still be a table
--		whose text can be accessed with the XML_ELEMENT_TEXT_KEY key
-- if false, element text must always be accessed through the XML_ELEMENT_TEXT_KEY set below
local XML_FLATTEN_ELEMENT_TEXT = false
if settings["f"] then XML_FLATTEN_ELEMENT_TEXT = true end

-- this is the table key which is store to put XML elements' text if XML_FLATTEN_ELEMENT_TEXT is false or the element has attributes
--  for xml of "<item someAttribute="true">this is my text</item>", the "item" variable will be a table with keys "someAttribute" and
--		whatever this variable is set to
local XML_ELEMENT_TEXT_KEY = "InnerText"
if settings["i"] then XML_ELEMENT_TEXT_KEY = settings["i"] end

------------- ENDSETTINGS -------------

local GO_FILEPATH = nil -- if settings specify a go file, store its path here once we've seen it

local REGEX_KENGEN_FILE_EXTENSION = "%."..KENGEN_FILE_EXTENSION
local KENGEN_DOTTED_FILE_EXTENSION = "."..KENGEN_FILE_EXTENSION

local REGEX_STARTTEMPLATE = "^[%.]?%s*STARTTEMPLATE%s*"		-- optional . to start line, any amount of white space, keyword, white space
local REGEX_ENDTEMPLATE = "^[%.]?%s*ENDTEMPLATE%s*"			-- optional . to start line, any amount of white space, keyword, white space
local REGEX_MATCH_FOREACH = "^%s*FOREACH%s+(.*)%s+IN%s+"	-- any preceding . is already removed, so just check whitespace, FOREACH keyword, whitespace, clause, whitespace, IN keyword, whitespace
local REGEX_MATCH_FOREACH_SPACE = "^(%s*)FOREACH"			-- a regex just to get the correct amount of white space in front of FOREACH for genned code
local REGEX_MATCH_IN = "IN%s+(.*)%s+"
local REGEX_MATCH_AS = "AS%s+(.*)%s"
local REGEX_MATCH_WHERE = "WHERE%s+(.*)%s"
local REGEX_MATCH_BY = "BY%s+(.*)%s"
local REGEX_MATCH_SUFFIX_AS = "AS%s+"
local REGEX_MATCH_SUFFIX_WHERE = "WHERE%s+"
local REGEX_MATCH_SUFFIX_BY = "BY%s+"
local REGEX_MATCH_SUFFIX_DO = "DO%s*$"
local REGEX_MATCH_END = "^(%s*)END(%s*)$"

local FUNCTION_KEYWORDS = {
	["COUNT"] = "kengen.iterator.count",
	["INDEX"] = "kengen.iterator.index",
	["ORIGINAL_INDEX"] = "kengen.iterator.originalIndex",
	["IS_FIRST"] = "kengen.iterator.isFirst",
	["IS_LAST"] = "kengen.iterator.isLast",
	["OUTPUT"] = "kengen.fileio.setOutputFile",
	["APPEND"] = "kengen.fileio.setAppendFile",
	["CLOSE"] = "kengen.fileio.closeOutputFile",
	["LOAD_XML"] = "kengen.xml.loadXmlAutomatic",
	["LOAD_XML_STRING"] = "kengen.xml.loadXmlString",
	["LOAD_XML_FILE"] = "kengen.xml.loadXmlFile",
	["LOAD_JSON"] = "kengen.json.loadJsonAutomatic",
	["LOAD_JSON_STRING"] = "kengen.json.loadJsonString",
	["LOAD_JSON_FILE"] = "kengen.json.loadJsonFile",
}

-- sort these by longest to shortest in case any are substrings of others
local FUNCTION_KEYWORDS_SORTED = {}
for keyword, target in pairs(FUNCTION_KEYWORDS) do
	FUNCTION_KEYWORDS_SORTED[#FUNCTION_KEYWORDS_SORTED + 1] = { ["Keyword"] = keyword, ["Target"] = target }
end
table.sort(FUNCTION_KEYWORDS_SORTED, function(v1,v2) return #v1.Keyword > #v2.Keyword end)

local CHAR_TEMPLATE_LINE = ">"
local CHAR_SCRIPT_LINE = "."

local function TranslateKeywordFunctions(_line)
	for _, pair in pairs(FUNCTION_KEYWORDS_SORTED) do
		_line = _line:gsub(pair.Keyword.."%s*%(", pair.Target.."(")
	end
	return _line
end

local files_translated_from_kengen = {}

local function TranslateKengenToLua(_filePath)
	
	local writePath = _filePath:gsub(REGEX_KENGEN_FILE_EXTENSION, ".lua")
	files_translated_from_kengen[#files_translated_from_kengen + 1] = writePath
	
	local readHandle, err = io.open(_filePath, "r")
	assert(readHandle ~= nil, "TranslateKengenToLua :: Failed to open input file: " .. tostring(_filePath) .. " err: " .. tostring(err))
	
	local writeHandle, err = io.open(writePath, "w")
	assert(writeHandle ~= nil, "TranslateKengenToLua :: Failed to open output file: " .. tostring(writePath) .. " err: " .. tostring(err))
	
	print("Translating file from kengen to lua: ".._filePath.."  =>  "..writePath)
	
	-- include settings the generated file will use
	writeHandle:write("local kengen = require(\"kengen\")\n")
	writeHandle:write("kengen.settings.XML_FLATTEN_ELEMENT_TEXT = "..tostring(XML_FLATTEN_ELEMENT_TEXT).."\n")
	writeHandle:write("kengen.settings.XML_ELEMENT_TEXT_KEY = \""..XML_ELEMENT_TEXT_KEY.."\"\n")
	writeHandle:write("\n")
	
	local isTemplateMode = false
	
	local line = readHandle:read("*line")
	local lineNum = 1
	while line do
		local startsWithTemplateOperator = StringUtil.StringStartsWith(line, CHAR_TEMPLATE_LINE)
		local isTemplateLine = (isTemplateMode and StringUtil.StringStartsWith(line, CHAR_SCRIPT_LINE) == false) or startsWithTemplateOperator
		if line:find(REGEX_STARTTEMPLATE) ~= nil then
			assert(not isTemplateMode, "Line #"..tostring(lineNum).." of ".._filePath.." has a STARTTEMPLATE when already in template mode")
			writeHandle:write("--"..line)
			isTemplateMode = true
		elseif line:find(REGEX_ENDTEMPLATE) ~= nil then
			assert(isTemplateMode, "Line #"..tostring(lineNum).." of ".._filePath.." has an ENDTEMPLATE when not in template mode")
			writeHandle:write("--"..line)
			isTemplateMode = false
		elseif isTemplateLine then
			-- in template mode, output goes straight to the lua file as text to send to output file
			-- we use the [=== and ===] to ignore escape characters included in the source text
			assert(line:find("%[===") == nil,
				"Line #"..tostring(lineNum).." of ".._filePath.." -- The '[===' operator is reserved by Kengen and cannot be output")
			assert(line:find("===%]") == nil,
				"Line #"..tostring(lineNum).." of ".._filePath.." -- The '===]' operator is reserved by Kengen and cannot be output")
			
			-- remove leading template operator
			if startsWithTemplateOperator then
				line = line:sub(2)
			end
			
			-- replace variable expressions with actual values instead of text
			-- TODO need to support function keywords used inside of variable expressions
			line = line:gsub("%$(%b())", "]===]..tostring(%1)..[===[")
			
			writeHandle:write("kengen.fileio.outputLine( [===["..line.."]===] )")
		else
			-- this line is script
			
			-- remove leading script operator
			if StringUtil.StringStartsWith(line, CHAR_SCRIPT_LINE) then
				line = line:sub(2) -- remove . character
			end
			
			-- translate all keyword functions
			line = TranslateKeywordFunctions(line)
			
			-- translate FOREACH expressions
			if line:find(REGEX_MATCH_FOREACH) ~= nil then
				local foreachContents = line:match(REGEX_MATCH_FOREACH)
				assert(line:find(REGEX_MATCH_SUFFIX_DO) ~= nil,
					"Line #"..tostring(lineNum).." of ".._filePath.." has a FOREACH loop without a DO on the same line; this is not supported yet")
				
				local inContents = line:match(REGEX_MATCH_IN..REGEX_MATCH_SUFFIX_AS)
				if inContents == nil then
					inContents = line:match(REGEX_MATCH_IN..REGEX_MATCH_SUFFIX_WHERE)
				end
				if inContents == nil then
					inContents = line:match(REGEX_MATCH_IN..REGEX_MATCH_SUFFIX_BY)
				end
				if inContents == nil then
					inContents = line:match(REGEX_MATCH_IN..REGEX_MATCH_SUFFIX_DO)
				end
				assert(inContents ~= nil, "Line #"..tostring(lineNum).." of ".._filePath.." has a FOREACH loop without a valid IN clause")
				
				local asContents = line:match(REGEX_MATCH_AS..REGEX_MATCH_SUFFIX_WHERE)
				if asContents == nil then
					asContents = line:match(REGEX_MATCH_AS..REGEX_MATCH_SUFFIX_BY)
				end
				if asContents == nil then
					asContents = line:match(REGEX_MATCH_AS..REGEX_MATCH_SUFFIX_DO)
				end
				
				local whereContents = line:match(REGEX_MATCH_WHERE..REGEX_MATCH_SUFFIX_BY)
				if whereContents == nil then
					whereContents = line:match(REGEX_MATCH_WHERE..REGEX_MATCH_SUFFIX_DO)
				end
				
				local byContents = line:match(REGEX_MATCH_BY..REGEX_MATCH_SUFFIX_DO)
				
				line = line:match(REGEX_MATCH_FOREACH_SPACE)
				line = line.."for "
				local varName
				if asContents ~= nil then
					assert(ACCESS_STYLE_XML, "Line #"..tostring(lineNum).." of ".._filePath.." -- The 'AS' clause is only supported in XML style")
					varName = asContents
					line = line..varName.." in kengen.iterator.iterate("..inContents.."."..foreachContents..", "
				elseif ACCESS_STYLE_XML then
					varName = foreachContents
					line = line..varName.." in kengen.iterator.iterate("..inContents.."."..foreachContents..", "
				else
					varName = foreachContents
					line = line..foreachContents.." in kengen.iterator.iterate("..inContents..", "
				end
				assert(varName ~= nil and varName:len() > 0, "Line #"..tostring(lineNum).." of ".._filePath.." -- has a nil/empty var name")
				
				if whereContents ~= nil then
					line = line.."function ("..varName..") return "..whereContents.." end, "
				else
					line = line.."nil, "
				end
				
				if byContents ~= nil then
					local comparePhrase1 = byContents:gsub(varName, varName.."1")
					local comparePhrase2 = byContents:gsub(varName, varName.."2")
					line = line.."function ("..varName.."1, "..varName.."2) return "..comparePhrase1.." < "..comparePhrase2.." end) do"
				else
					line = line.."nil) do"
				end
			elseif line:find(REGEX_MATCH_END) ~= nil then
				line = line:gsub("END", "end")
			end
			
			-- finally, push the line to file
			writeHandle:write(line)
		end
		
		writeHandle:write("\n")
		line = readHandle:read("*line")
		lineNum = lineNum + 1
	end
	
	writeHandle:flush()

	readHandle:close()
	writeHandle:close()
	
	if GO_FILENAME ~= nil and StringUtil.StringEndsWith(_filePath, GO_FILENAME..KENGEN_DOTTED_FILE_EXTENSION) then
		GO_FILEPATH = writePath
	end
end

function TranslateKengenToOutput(fullPath, settings)
	assert(TestUtil.IsString(fullPath))
	assert(TestUtil.IsTable(settings) and settings:IsA(Settings))
	
	local parsedTemplate = Parser.ParseFile(fullPath)
	
	parsedTemplate.Execute(outputStream)
end

function TranslateFilesInPath (_path, _settings)
	print ("Translating files in directory: ".._path)
    for file in lfs.dir(_path) do
		-- skip current directory, up directory, and dot-syntax hidden files/folders
		-- TODO support an option/setting for not skipping hidden files/folders
        if not StringUtil.StringStartsWith(file,".") then
            local fullPath = _path..'/'..file
            local attr = lfs.attributes (fullPath)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
				if _settings.DIRECTORY_RECURSION then
					TranslateFilesInPath (fullPath)
				else
					print ("Ignoring folder '"..fullPath.."', use the -r option to change this")
				end
            else
                if StringUtil.StringEndsWith(fullPath, KENGEN_DOTTED_FILE_EXTENSION) then
					TranslateKengenToOutput(fullPath, _settings)
				end
            end
        end
    end
end
