-- Public API for Kengen2
-- 'require' this to get access to the functionality you need!
local Kengen = {
	Framework = require("kengen2.Framework"),
	Parser = require("kengen2.Parser"),
	Settings = require("kengen2.Framework.Settings"),
	Util = require("kengen2.Util")
}

local FileOutputStream = require("kengen2.Execution.FileOutputStream")
local MemoryOutputStream = require("kengen2.Execution.MemoryOutputStream")
local ParsedTemplate = require("kengen2.Execution.ParsedTemplate")

function Kengen.LoadXmlFile(path, settings)
	assert(Kengen.Util.TestUtil.IsString(path))
	assert(settings == nil or (Kengen.Util.TestUtil.IsTable(settings) and settings:IsA(Settings)))
	settings = settings or hidden_KengenSettingsSingleton or Kengen.Settings:New()
	
	assert(settings.ACCESS_STYLE_XML == true)
	return Kengen.Framework.Xml.loadXmlFile(path, settings)
end

-- Translate the kengen file at inputPath to outputPath
-- If outputPath is nil, puts the results in a memory stream instead
function Kengen.TranslateFile(inputPath, outputPath, settings)
	assert(Kengen.Util.TestUtil.IsString(inputPath))
	assert(Kengen.Util.TestUtil.IsString(outputPath) or outputPath == nil)
	assert(settings == nil or (Kengen.Util.TestUtil.IsTable(settings) and settings:IsA(Kengen.Settings)))
	settings = settings or Kengen.Settings:New()
	
	local parsedTemplate = Kengen.Parser.Parser.ParseFile(inputPath, settings)
	assert(parsedTemplate ~= nil)
	assert(parsedTemplate:IsA(ParsedTemplate))
	
	local resultsStream = (outputPath and FileOutputStream:New(outputPath)) or MemoryOutputStream:New()
	parsedTemplate:Execute(resultsStream)
	return resultsStream
end

return Kengen
