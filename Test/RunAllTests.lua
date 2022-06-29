LU = require('kengen2.ThirdParty.luaunit.luaunit')
assert(LU ~= nil)

local Lexer = require("kengen2.Parser.Lexer")
local Parser = require("kengen2.Parser")

local ParsedTemplate = require("kengen2.Execution.ParsedTemplate")

local PathUtil = require("kengen2.Util.PathUtil")
local TestUtil = require("kengen2.Util.TestUtil")

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

	local tokenizedFile = Parser.Lexer.Tokenize(RunningScriptDir.."/test_simple.kengen")
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
	LU.assertEquals(tokenizedFile.Tokens[2].Type, Parser.TokenTypes.ScriptLine)
	LU.assertEquals(tokenizedFile.Tokens[3].Type, Parser.TokenTypes.ENDSCRIPT)
	
	LU.assertEquals(#tokenizedFile.TokensByLine, 4)
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[3]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[4]))
	LU.assertEquals(tokenizedFile.TokensByLine[1].Type, Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedFile.TokensByLine[2].Type, Parser.TokenTypes.ScriptLine)
	LU.assertEquals(tokenizedFile.TokensByLine[3].Type, Parser.TokenTypes.ScriptLine)
	LU.assertEquals(tokenizedFile.TokensByLine[4].Type, Parser.TokenTypes.ENDSCRIPT)
end

function TestLexer:TestLexerOnSimpleString()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local tokenizedString = Parser.Lexer.TokenizeString(
		[[.STARTSCRIPT
		print("Hello, World")
		print("Welcome to kengen!")
		.ENDSCRIPT]])
		
	LU.assertEquals(#tokenizedString, 3)
	LU.assertTrue(TestUtil.IsTable(tokenizedString[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedString[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedString[3]))
	LU.assertEquals(tokenizedString[1].Type, Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedString[2].Type, Parser.TokenTypes.ScriptLine)
	LU.assertEquals(tokenizedString[3].Type, Parser.TokenTypes.ENDSCRIPT)
end

-- this is currently assuming that easyDirectives is false
function TestLexer:TestLexerOnSimpleStringButForgotPeriods()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local tokenizedString = Parser.Lexer.TokenizeString(
		[[STARTSCRIPT
		print("Hello, World")
		print("Welcome to kengen!")
		ENDSCRIPT]])
		
	LU.assertEquals(#tokenizedString, 1)
	LU.assertTrue(TestUtil.IsTable(tokenizedString[1]))
	LU.assertEquals(tokenizedString[1].Type, Parser.TokenTypes.TemplateLine)
end

function TestLexer:TestLexerOnComplexFile()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local tokenizedFile = Parser.Lexer.Tokenize(RunningScriptDir.."/test_complex.kengen")
	LU.assertTrue(TestUtil.IsTable(tokenizedFile))
	LU.assertEquals(tokenizedFile.Length, 22)
	LU.assertEquals(tokenizedFile.Path, RunningScriptDir.."/test_complex.kengen")
	
	LU.assertEquals(#tokenizedFile.Tokens, 19)
	LU.assertEquals(#tokenizedFile.TokensByLine, 22)
	
	-- TODO Expand the existing test to cover more cases; test every token here
	
end

TestParser = {}

function TestParser:TestParserNoCrash()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local Result = Parser.Parser.ParseFile(RunningScriptDir.."/test_complex.kengen")
	LU.assertTrue(Result ~= nil)
	LU.assertTrue(Result:IsA(ParsedTemplate))
	
	-- TODO Actually verify the output
end

function TestParser:TestParserOnCockatrice()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local Result = Parser.Parser.ParseFile(RunningScriptDir.."/cockatrice-to-mse/main.kengen")
	LU.assertTrue(Result ~= nil)
	LU.assertTrue(Result:IsA(ParsedTemplate))
	
	-- TODO Actually verify the output
end


os.exit( LU.LuaUnit.run() )
