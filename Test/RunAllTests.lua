LU = require('kengen2.ThirdParty.luaunit.luaunit')
assert(LU ~= nil)

local Settings = require("kengen2.Framework.Settings")

local Lexer = require("kengen2.Parser.Lexer")
local Parser = require("kengen2.Parser")

local ParsedTemplate = require("kengen2.Execution.ParsedTemplate")
local FileOutputStream = require("kengen2.Execution.FileOutputStream")
local MemoryOutputStream = require("kengen2.Execution.MemoryOutputStream")

local PathUtil = require("kengen2.Util.PathUtil")
local TestUtil = require("kengen2.Util.TestUtil")

TestClassUtil = {}

function TestClassUtil:TestIsAFailsOnNil()
	local function funcToFail()
		local settings = Settings:New()
		settings:IsA(nil)
	end
	LU.assertErrorMsgContains("Passed a nil class to an IsA check", funcToFail)
end

TestLexer = {}

function TestLexer:TestLexerExtractTokenFromLine()
	
	-- First bool parameter is whether we're in template mode currently
	-- Second bool parameter is whether "easyDirectives" is enabled
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTSCRIPT", false, false), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTSCRIPT", false, true), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTSCRIPT", true, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTSCRIPT", true, true), Parser.TokenTypes.STARTSCRIPT)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTSCRIPT", false, false), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTSCRIPT", false, true), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTSCRIPT", true, false), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTSCRIPT", true, true), Parser.TokenTypes.STARTSCRIPT)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTSCRIPT", false, false), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTSCRIPT", false, true), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTSCRIPT", true, false), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTSCRIPT", true, true), Parser.TokenTypes.STARTSCRIPT)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTTEMPLATE", false, false), Parser.TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTTEMPLATE", false, true), Parser.TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTTEMPLATE", true, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTTEMPLATE", true, true), Parser.TokenTypes.STARTTEMPLATE)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTTEMPLATE", false, false), Parser.TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTTEMPLATE", false, true), Parser.TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTTEMPLATE", true, false), Parser.TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTTEMPLATE", true, true), Parser.TokenTypes.STARTTEMPLATE)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTTEMPLATE", false, false), Parser.TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTTEMPLATE", false, true), Parser.TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTTEMPLATE", true, false), Parser.TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTTEMPLATE", true, true), Parser.TokenTypes.STARTTEMPLATE)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("FOREACH foo IN bar DO", false, false), Parser.TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine("FOREACH foo IN bar DO", false, true), Parser.TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine("FOREACH foo IN bar DO", true, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("FOREACH foo IN bar DO", true, true), Parser.TokenTypes.FOREACH)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".FOREACH foo IN bar DO", false, false), Parser.TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".FOREACH foo IN bar DO", false, true), Parser.TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".FOREACH foo IN bar DO", true, false), Parser.TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".FOREACH foo IN bar DO", true, true), Parser.TokenTypes.FOREACH)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    FOREACH foo IN bar DO", false, false), Parser.TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    FOREACH foo IN bar DO", false, true), Parser.TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    FOREACH foo IN bar DO", true, false), Parser.TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    FOREACH foo IN bar DO", true, true), Parser.TokenTypes.FOREACH)
end

function TestLexer:TestLexerExtractContentFromLine()
	
	-- First bool parameter is whether we're in template mode currently
	-- Second bool parameter is whether "easyDirectives" is enabled
	-- In theory, these parameters have no effect on what's considered the contents -- only the token
	
	LU.assertEquals(Lexer.ExtractContentFromLine("STARTSCRIPT", false, false), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine("STARTSCRIPT", false, true), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine("STARTSCRIPT", true, false), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine("STARTSCRIPT", true, true), "STARTSCRIPT")
	
	LU.assertEquals(Lexer.ExtractContentFromLine(".STARTSCRIPT", false, false), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(".STARTSCRIPT", false, true), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(".STARTSCRIPT", true, false), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(".STARTSCRIPT", true, true), "STARTSCRIPT")
	
	LU.assertEquals(Lexer.ExtractContentFromLine(".	    STARTSCRIPT", false, false), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(".	    STARTSCRIPT", false, true), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(".	    STARTSCRIPT", true, false), "STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(".	    STARTSCRIPT", true, true), "STARTSCRIPT")
	
	LU.assertEquals(Lexer.ExtractContentFromLine("FOREACH foo IN bar DO", false, false), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine("FOREACH foo IN bar DO", false, true), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine("FOREACH foo IN bar DO", true, false), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine("FOREACH foo IN bar DO", true, true), "FOREACH foo IN bar DO")
	
	LU.assertEquals(Lexer.ExtractContentFromLine(".FOREACH foo IN bar DO", false, false), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine(".FOREACH foo IN bar DO", false, true), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine(".FOREACH foo IN bar DO", true, false), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine(".FOREACH foo IN bar DO", true, true), "FOREACH foo IN bar DO")
	
	LU.assertEquals(Lexer.ExtractContentFromLine(".	    FOREACH foo IN bar DO", false, false), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine(".	    FOREACH foo IN bar DO", false, true), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine(".	    FOREACH foo IN bar DO", true, false), "FOREACH foo IN bar DO")
	LU.assertEquals(Lexer.ExtractContentFromLine(".	    FOREACH foo IN bar DO", true, true), "FOREACH foo IN bar DO")
end

function TestLexer:TestLexerOnSimpleFile()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local tokenizedFile = Parser.Lexer.Tokenize(RunningScriptDir.."/test_simple.kengen", Settings:New())
	LU.assertTrue(TestUtil.IsTable(tokenizedFile))
	LU.assertEquals(tokenizedFile.Length, 4)
	LU.assertEquals(tokenizedFile.Path, RunningScriptDir.."/test_simple.kengen")
	
	LU.assertEquals(#tokenizedFile.StringsByLine, 4)
	LU.assertTrue(TestUtil.IsString(tokenizedFile.StringsByLine[1]))
	LU.assertTrue(TestUtil.IsString(tokenizedFile.StringsByLine[2]))
	LU.assertTrue(TestUtil.IsString(tokenizedFile.StringsByLine[3]))
	LU.assertTrue(TestUtil.IsString(tokenizedFile.StringsByLine[4]))
	
	LU.assertEquals(#tokenizedFile.Tokens, 3)
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.Tokens[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.Tokens[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.Tokens[3]))
	LU.assertEquals(tokenizedFile.Tokens[1].Type, Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedFile.Tokens[2].Type, Parser.TokenTypes.TemplateLine)
	LU.assertEquals(tokenizedFile.Tokens[3].Type, Parser.TokenTypes.ENDSCRIPT)
	
	LU.assertEquals(#tokenizedFile.TokensByLine, 4)
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[3]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[4]))
	LU.assertEquals(tokenizedFile.TokensByLine[1].Type, Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedFile.TokensByLine[2].Type, Parser.TokenTypes.TemplateLine)
	LU.assertEquals(tokenizedFile.TokensByLine[3].Type, Parser.TokenTypes.TemplateLine)
	LU.assertEquals(tokenizedFile.TokensByLine[4].Type, Parser.TokenTypes.ENDSCRIPT)
end

function TestLexer:TestLexerOnSimpleString()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local tokenizedString = Parser.Lexer.TokenizeString(
		[[.STARTSCRIPT
		print("Hello, World")
		print("Welcome to kengen!")
		.ENDSCRIPT]],
		Settings:New())
		
	LU.assertEquals(#tokenizedString, 3)
	LU.assertTrue(TestUtil.IsTable(tokenizedString[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedString[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedString[3]))
	LU.assertEquals(tokenizedString[1].Type, Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedString[2].Type, Parser.TokenTypes.ScriptLine)
	LU.assertEquals(tokenizedString[3].Type, Parser.TokenTypes.ENDSCRIPT)
end

function TestLexer:TestLexerOnSimpleStringButForgotPeriodsAndNoEasyDirectives()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local settings = Settings:New()
	settings.EASY_DIRECTIVES = false
	
	local tokenizedString = Parser.Lexer.TokenizeString(
		[[STARTSCRIPT
		print("Hello, World")
		print("Welcome to kengen!")
		ENDSCRIPT]],
		settings)
		
	LU.assertEquals(#tokenizedString, 1)
	LU.assertTrue(TestUtil.IsTable(tokenizedString[1]))
	LU.assertEquals(tokenizedString[1].Type, Parser.TokenTypes.TemplateLine)
end

function TestLexer:TestLexerOnComplexFile()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local settings = Settings:New()
	local tokenizedFile = Parser.Lexer.Tokenize(RunningScriptDir.."/test_complex.kengen", settings)
	LU.assertTrue(TestUtil.IsTable(tokenizedFile))
	LU.assertEquals(tokenizedFile.Length, 22)
	LU.assertEquals(tokenizedFile.Path, RunningScriptDir.."/test_complex.kengen")
	
	LU.assertEquals(#tokenizedFile.Tokens, 19)
	LU.assertEquals(#tokenizedFile.TokensByLine, 22)
	
	-- TODO Expand the existing test to cover more cases; test every token here
	
end

TestParser = {}

function TestParser:TestParserOnSimple()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local Result = Parser.Parser.ParseFile(RunningScriptDir.."/test_simple.kengen", Settings:New())
	LU.assertTrue(Result ~= nil)
	LU.assertTrue(Result:IsA(ParsedTemplate))
	
	-- TODO Actually verify the output
end

function TestParser:TestParserOnComplex()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local Result = Parser.Parser.ParseFile(RunningScriptDir.."/test_complex.kengen", Settings:New())
	LU.assertTrue(Result ~= nil)
	LU.assertTrue(Result:IsA(ParsedTemplate))
	
	-- TODO Actually verify the output
end

function TestParser:TestParserOnCockatrice()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local Result = Parser.Parser.ParseFile(RunningScriptDir.."/cockatrice-to-mse/main.kengen", Settings:New())
	LU.assertTrue(Result ~= nil)
	LU.assertTrue(Result:IsA(ParsedTemplate))
	
	-- TODO Actually verify the output
end

TestGenerator = {}

function TestGenerator:TestGeneratorOnSimple()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local parsedTemplate = Parser.Parser.ParseFile(RunningScriptDir.."/test_simple.kengen", Settings:New())
	LU.assertTrue(parsedTemplate ~= nil)
	LU.assertTrue(parsedTemplate:IsA(ParsedTemplate))
	
	local resultsStream = MemoryOutputStream:New()
	parsedTemplate:Execute(resultsStream)
	
	LU.assertEquals(resultsStream.FinalizedData, "Hello, World\nWelcome to Kengen!\n")
end

os.exit( LU.LuaUnit.run() )
