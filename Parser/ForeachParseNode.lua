local ListParseNode = require("kengen2.Parser.ListParseNode")
local PreprocessParams = require("kengen2.Execution.PreprocessParams")
local Util = require("kengen2.Util")

local ForeachParseNode = Util.ClassUtil.CreateClass("ForeachParseNode", ListParseNode)

-- possible preceding . or >, whitespace, FOREACH keyword, whitespace, clause, whitespace, IN keyword, whitespace
local REGEX_MATCH_FOREACH = "^%.?%s*FOREACH%s+(.*)%s+IN%s+"

-- a regex just to get the correct amount of white space in front of FOREACH for genned code
local REGEX_MATCH_FOREACH_SPACE = "^(%s*)FOREACH"

local REGEX_MATCH_IN = "IN%s+(.*)%s+"
local REGEX_MATCH_AS = "AS%s+(.*)%s"
local REGEX_MATCH_WHERE = "WHERE%s+(.*)%s"
local REGEX_MATCH_BY = "BY%s+(.*)%s"
local REGEX_MATCH_SUFFIX_AS = "AS%s+"
local REGEX_MATCH_SUFFIX_WHERE = "WHERE%s+"
local REGEX_MATCH_SUFFIX_BY = "BY%s+"
local REGEX_MATCH_SUFFIX_DO = "DO%s*$"

function ForeachParseNode:New(nodesList)
    assert(Util.TestUtil.IsTable(self) and self:IsA(ForeachParseNode))
    -- parent class will validate the nodesList

    local instance = ForeachParseNode.SuperClass().New(self, nodesList)
	instance.ForeachLine = instance.StartPos - 1
    return instance
end

function ForeachParseNode:Preprocess(preprocessParams)
	assert(Util.TestUtil.IsTable(preprocessParams) and preprocessParams:IsA(PreprocessParams))
	
	local line = preprocessParams:GetLine(self.ForeachLine)
	
	local foreachContents = line:match(REGEX_MATCH_FOREACH)
	assert(foreachContents ~= nil,
		preprocessParams:MakeError(self.ForeachLine, "Malformed FOREACH, could not identify what's between FOREACH and IN"))
	assert(line:find(REGEX_MATCH_SUFFIX_DO) ~= nil,
		preprocessParams:MakeError(self.ForeachLine, "FOREACH loop without a DO on the same line; this is not supported yet"))
	
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
	assert(inContents ~= nil,
		preprocessParams:MakeError(self.ForeachLine, "Malformed FOREACH, does not have a valid IN clause"))
	
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
	
	--[[
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
	--]]
	
	self.SuperClass().Preprocess(self, preprocessParams)
end

return ForeachParseNode
