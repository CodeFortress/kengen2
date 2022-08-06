local LU = require('kengen2.ThirdParty.luaunit.luaunit')
assert(LU ~= nil)

local Kengen = require("kengen2")

local Iterator = require("kengen2.Framework.Iterator")
local Settings = require("kengen2.Framework.Settings")

local Lexer = require("kengen2.Parser.Lexer")
local Parser = require("kengen2.Parser.Parser")
local TokenTypes = require("kengen2.Parser.TokenTypes")

local ParsedTemplate = require("kengen2.Execution.ParsedTemplate")
local MemoryOutputStream = require("kengen2.Execution.MemoryOutputStream")

local FileUtil = require("kengen2.Util.FileUtil")
local PathUtil = require("kengen2.Util.PathUtil")
local StringUtil = require("kengen2.Util.StringUtil")
local TestUtil = require("kengen2.Util.TestUtil")

Test_Integration = {}

function Test_Integration:Test_Integration_OnSimple()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local parsedTemplate = Parser.ParseFile(RunningScriptDir.."/test_simple.kengen", Settings:New())
	LU.assertTrue(parsedTemplate ~= nil)
	LU.assertTrue(parsedTemplate:IsA(ParsedTemplate))
	
	local resultsStream = MemoryOutputStream:New()
	parsedTemplate:Execute(resultsStream)
	
	LU.assertEquals(resultsStream.FinalizedData, "Hello, World\nWelcome to Kengen!\n")
end

function Test_Integration:Test_Integration_OnIfs()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local parsedTemplate = Parser.ParseFile(RunningScriptDir.."/test_ifs.kengen", Settings:New())
	LU.assertTrue(parsedTemplate ~= nil)
	LU.assertTrue(parsedTemplate:IsA(ParsedTemplate))
	
	local resultsStream = MemoryOutputStream:New()
	parsedTemplate:Execute(resultsStream)
	
	LU.assertEquals(resultsStream.FinalizedData, "ABCDEFGHIJ\n")
end

function Test_Integration:Test_Integration_OnCardsSample()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local settings = Settings:New()
	settings.XML_STYLE_ACCESS = false
	
	local parsedTemplate = Parser.ParseFile(RunningScriptDir.."/test_cards_sample.kengen", settings)
	LU.assertTrue(parsedTemplate ~= nil)
	LU.assertTrue(parsedTemplate:IsA(ParsedTemplate))
	
	local resultsStream = MemoryOutputStream:New()
	parsedTemplate:Execute(resultsStream)
	
	local expectedResult =
	[[// GENERATED, DO NOT MODIFY
Cards with CMC 2 or more, sorted by CMC:
	Grizzly Bears (2) 2/2
	Lightning Strike (2)
	Divination (3)
	Gray Ogre (3) 2/2
	Hill Giant (4) 3/3
	Control Magic (4)
]]
	
	LU.assertEquals(resultsStream.FinalizedData, expectedResult)
end

function Test_Integration:Test_Integration_OnComplex()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local Result = Parser.ParseFile(RunningScriptDir.."/test_complex.kengen", Settings:New())
	LU.assertTrue(Result ~= nil)
	LU.assertTrue(Result:IsA(ParsedTemplate))
	
	-- TODO Actually verify the output... really though this test may not be an Integration test
	--	because currently the test_complex won't execute, the script lines aren't valid Lua
end

function Test_Integration:Test_Integration_OnAnimals()
	local MySettings = Settings:New()
	MySettings.ACCESS_STYLE_XML = false
	LU.assertError(function()
		Kengen.TranslateFile("Test/animals/test_animals.kengen", nil, MySettings)
	end)

	MySettings.ACCESS_STYLE_XML = true
	local ResultsStream = Kengen.TranslateFile("Test/animals/test_animals.kengen", nil, MySettings)
	local ResultsToMatch = FileUtil.FileToString("Test/animals/test_animals.h")
	
	LU.assertEquals(ResultsStream.FinalizedData, ResultsToMatch)
end

function Test_Integration:DISABLED_Test_Class_OnCockatrice()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local settings = Settings:New()
	settings.XML_STYLE_ACCESS = true
	
	local parsedTemplate = Parser.ParseFile(RunningScriptDir.."/cockatrice-to-mse/main.kengen", settings)
	LU.assertTrue(parsedTemplate ~= nil)
	LU.assertTrue(parsedTemplate:IsA(ParsedTemplate))
	
	local resultsStream = MemoryOutputStream:New()
	parsedTemplate:Execute(resultsStream)
	
	-- Don't perform any validation -- this test is to make sure that the system can churn through a huge
	-- XML file and execute a ton of logic without hitting any crashes or asserts.
	--print(resultsStream.FinalizedData)
end