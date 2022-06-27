LU = require('kengen2.ThirdParty.luaunit.luaunit')
assert(LU ~= nil)

local Parser = require("kengen2.Parser")

local PathUtil = require("kengen2.Util.PathUtil")
local TestUtil = require("kengen2.Util.TestUtil")

TestLexer = {}

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
		[[STARTSCRIPT
		print("Hello, World")
		print("Welcome to kengen!")
		ENDSCRIPT]])
		
	LU.assertEquals(#tokenizedString, 3)
	LU.assertTrue(TestUtil.IsTable(tokenizedString[1]))
	LU.assertTrue(TestUtil.IsTable(tokenizedString[2]))
	LU.assertTrue(TestUtil.IsTable(tokenizedString[3]))
	LU.assertEquals(tokenizedString[1].Type, Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(tokenizedString[2].Type, Parser.TokenTypes.ScriptLine)
	LU.assertEquals(tokenizedString[3].Type, Parser.TokenTypes.ENDSCRIPT)
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
	assert(RunningScriptDir ~= nil)

	Parser.Parser.ParseFile(RunningScriptDir.."/test_complex.kengen")
	
	-- TODO Actually verify the output
end


os.exit( LU.LuaUnit.run() )
