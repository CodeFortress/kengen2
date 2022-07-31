local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local Settings = require("kengen2.Framework.Settings")

local Lexer = require("kengen2.Parser.Lexer")
local TokenTypes = require("kengen2.Parser.TokenTypes")

local PathUtil = require("kengen2.Util.PathUtil")
local TestUtil = require("kengen2.Util.TestUtil")

Test_Lexer = {}

function Test_Lexer:Test_Unit_ExtractTokenFromLine()
	
	-- First bool parameter is whether we're in template mode currently
	-- Second bool parameter is whether "easyDirectives" is enabled
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTSCRIPT", false, false), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTSCRIPT", false, true), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTSCRIPT", true, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTSCRIPT", true, true), TokenTypes.STARTSCRIPT)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTSCRIPT", false, false), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTSCRIPT", false, true), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTSCRIPT", true, false), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTSCRIPT", true, true), TokenTypes.STARTSCRIPT)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTSCRIPT", false, false), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTSCRIPT", false, true), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTSCRIPT", true, false), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTSCRIPT", true, true), TokenTypes.STARTSCRIPT)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    STARTSCRIPT", false, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    STARTSCRIPT", false, true), TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    STARTSCRIPT", true, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    STARTSCRIPT", true, true), TokenTypes.STARTSCRIPT)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTTEMPLATE", false, false), TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTTEMPLATE", false, true), TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTTEMPLATE", true, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("STARTTEMPLATE", true, true), TokenTypes.STARTTEMPLATE)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTTEMPLATE", false, false), TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTTEMPLATE", false, true), TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTTEMPLATE", true, false), TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".STARTTEMPLATE", true, true), TokenTypes.STARTTEMPLATE)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTTEMPLATE", false, false), TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTTEMPLATE", false, true), TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTTEMPLATE", true, false), TokenTypes.STARTTEMPLATE)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    STARTTEMPLATE", true, true), TokenTypes.STARTTEMPLATE)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("FOREACH foo IN bar DO", false, false), TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine("FOREACH foo IN bar DO", false, true), TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine("FOREACH foo IN bar DO", true, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("FOREACH foo IN bar DO", true, true), TokenTypes.FOREACH)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".FOREACH foo IN bar DO", false, false), TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".FOREACH foo IN bar DO", false, true), TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".FOREACH foo IN bar DO", true, false), TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".FOREACH foo IN bar DO", true, true), TokenTypes.FOREACH)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    FOREACH foo IN bar DO", false, false), TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    FOREACH foo IN bar DO", false, true), TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    FOREACH foo IN bar DO", true, false), TokenTypes.FOREACH)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    FOREACH foo IN bar DO", true, true), TokenTypes.FOREACH)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("local foo = true", false, false), TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("local foo = true", false, true), TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("local foo = true", true, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("local foo = true", true, true), TokenTypes.TemplateLine)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("		local foo = true", false, false), TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("		local foo = true", false, true), TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("		local foo = true", true, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("		local foo = true", true, true), TokenTypes.TemplateLine)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    local foo = true", false, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    local foo = true", false, true), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    local foo = true", true, false), TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    local foo = true", true, true), TokenTypes.TemplateLine)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    local foo = true", false, false), TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    local foo = true", false, true), TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    local foo = true", true, false), TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    local foo = true", true, true), TokenTypes.ScriptLine)
end

function Test_Lexer:Test_Unit_ExtractContentFromLine()
	
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
	
	LU.assertEquals(Lexer.ExtractContentFromLine(">	    STARTSCRIPT", false, false), " 	    STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(">	    STARTSCRIPT", false, true), " 	    STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(">	    STARTSCRIPT", true, false), " 	    STARTSCRIPT")
	LU.assertEquals(Lexer.ExtractContentFromLine(">	    STARTSCRIPT", true, true), " 	    STARTSCRIPT")
	
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

function Test_Lexer:Test_Class_OnSimpleFile()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local tokenizedFile = Lexer.Tokenize(RunningScriptDir.."/../test_simple.kengen", Settings:New())
	LU.assertTrue(TestUtil.IsTable(tokenizedFile))
	LU.assertEquals(tokenizedFile.Length, 4)
	LU.assertEquals(tokenizedFile.Path, RunningScriptDir.."/../test_simple.kengen")
	
	LU.assertEquals(#tokenizedFile.StringsByLine, 4)
	LU.assertTrue(TestUtil.IsString(tokenizedFile.StringsByLine[1]))
	LU.assertTrue(TestUtil.IsString(tokenizedFile.StringsByLine[2]))
	LU.assertTrue(TestUtil.IsString(tokenizedFile.StringsByLine[3]))
	LU.assertTrue(TestUtil.IsString(tokenizedFile.StringsByLine[4]))
	
	LU.assertEquals(#tokenizedFile.Tokens, 3)
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.Tokens[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.Tokens[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.Tokens[3]))
	LU.assertEquals(tokenizedFile.Tokens[1].Type, TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedFile.Tokens[2].Type, TokenTypes.TemplateLine)
	LU.assertEquals(tokenizedFile.Tokens[3].Type, TokenTypes.ENDSCRIPT)
	
	LU.assertEquals(#tokenizedFile.TokensByLine, 4)
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[3]))
	LU.assertTrue(TestUtil.IsTable(tokenizedFile.TokensByLine[4]))
	LU.assertEquals(tokenizedFile.TokensByLine[1].Type, TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedFile.TokensByLine[2].Type, TokenTypes.TemplateLine)
	LU.assertEquals(tokenizedFile.TokensByLine[3].Type, TokenTypes.TemplateLine)
	LU.assertEquals(tokenizedFile.TokensByLine[4].Type, TokenTypes.ENDSCRIPT)
end

function Test_Lexer:Test_Class_OnSimpleString()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local tokenizedString = Lexer.TokenizeString(
		[[.STARTSCRIPT
		print("Hello, World")
		print("Welcome to kengen!")
		.ENDSCRIPT]],
		Settings:New())
		
	LU.assertEquals(#tokenizedString, 3)
	LU.assertTrue(TestUtil.IsTable(tokenizedString[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedString[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedString[3]))
	LU.assertEquals(tokenizedString[1].Type, TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedString[2].Type, TokenTypes.ScriptLine)
	LU.assertEquals(tokenizedString[3].Type, TokenTypes.ENDSCRIPT)
end

function Test_Lexer:Test_Class_OnSimpleStringButForgotPeriodsAndNoEasyDirectives()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local settings = Settings:New()
	settings.EASY_DIRECTIVES = false
	
	local tokenizedString = Lexer.TokenizeString(
		[[STARTSCRIPT
		print("Hello, World")
		print("Welcome to kengen!")
		ENDSCRIPT]],
		settings)
		
	LU.assertEquals(#tokenizedString, 1)
	LU.assertTrue(TestUtil.IsTable(tokenizedString[1]))
	LU.assertEquals(tokenizedString[1].Type, TokenTypes.TemplateLine)
end

function Test_Lexer:Test_Class_OnComplexFile()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	assert(RunningScriptDir ~= nil)

	local settings = Settings:New()
	local tokenizedFile = Lexer.Tokenize(RunningScriptDir.."/../test_complex.kengen", settings)
	LU.assertTrue(TestUtil.IsTable(tokenizedFile))
	LU.assertEquals(tokenizedFile.Length, 22)
	LU.assertEquals(tokenizedFile.Path, RunningScriptDir.."/../test_complex.kengen")
	
	LU.assertEquals(#tokenizedFile.Tokens, 19)
	LU.assertEquals(#tokenizedFile.TokensByLine, 22)
	
	-- TODO Expand the existing test to cover more cases; test every token here
	
end

return Test_Lexer