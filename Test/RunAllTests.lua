LU = require('kengen2.ThirdParty.luaunit.luaunit')
assert(LU ~= nil)

local Iterator = require("kengen2.Framework.Iterator")
local Settings = require("kengen2.Framework.Settings")

local Lexer = require("kengen2.Parser.Lexer")
local Parser = require("kengen2.Parser")

local ParsedTemplate = require("kengen2.Execution.ParsedTemplate")
local FileOutputStream = require("kengen2.Execution.FileOutputStream")
local MemoryOutputStream = require("kengen2.Execution.MemoryOutputStream")

local PathUtil = require("kengen2.Util.PathUtil")
local StringUtil = require("kengen2.Util.StringUtil")
local TestUtil = require("kengen2.Util.TestUtil")

local BasicDatabase = {}
BasicDatabase["cards"] = {}
BasicDatabase["cards"][1] = { Name = "Lightning Bolt", CMC = 1 }
BasicDatabase["cards"][2] = { Name = "Giant Growth", CMC = 1 }
BasicDatabase["cards"][3] = { Name = "Divination", CMC = 3 }
BasicDatabase["cards"][4] = { Name = "Grizzly Bears", CMC = 2 }
BasicDatabase["cards"][5] = { Name = "Hill Giant", CMC = 4 }
BasicDatabase["cards"][6] = { Name = "Gray Ogre", CMC = 3 }
BasicDatabase["cards"][7] = { Name = "Lightning Strike", CMC = 2 }
BasicDatabase["cards"][8] = { Name = "Control Magic", CMC = 4 }

TestClassUtil = {}

function TestClassUtil:TestIsAFailsOnNil()
	local function funcToFail()
		local settings = Settings:New()
		settings:IsA(nil)
	end
	LU.assertErrorMsgContains("Passed a nil class to an IsA check", funcToFail)
end

TestStringUtil = {}

function TestStringUtil:TestTrim()
	LU.assertEquals(StringUtil.Trim(""), "")
	LU.assertEquals(StringUtil.Trim(" "), "")
	LU.assertEquals(StringUtil.Trim("	"), "")
	LU.assertEquals(StringUtil.Trim("  "), "")
	
	-- content in middle with spaces or tabs on outside
	LU.assertEquals(StringUtil.Trim(" a"), "a")
	LU.assertEquals(StringUtil.Trim("a "), "a")
	LU.assertEquals(StringUtil.Trim("a  "), "a")
	LU.assertEquals(StringUtil.Trim("  a"), "a")
	LU.assertEquals(StringUtil.Trim(" a "), "a")
	LU.assertEquals(StringUtil.Trim("	a"), "a")
	LU.assertEquals(StringUtil.Trim("a	"), "a")
	LU.assertEquals(StringUtil.Trim("	a	"), "a")
	
	-- spaces in middle
	LU.assertEquals(StringUtil.Trim(" a b"), "a b")
	LU.assertEquals(StringUtil.Trim("a b "), "a b")
	LU.assertEquals(StringUtil.Trim("a b  "), "a b")
	LU.assertEquals(StringUtil.Trim("  a b"), "a b")
	LU.assertEquals(StringUtil.Trim(" a b "), "a b")
	LU.assertEquals(StringUtil.Trim("	a b"), "a b")
	LU.assertEquals(StringUtil.Trim("a b	"), "a b")
	LU.assertEquals(StringUtil.Trim("	a b	"), "a b")
	
	-- tabs in middle (a tab b)
	LU.assertEquals(StringUtil.Trim(" a	b"), "a	b")
	LU.assertEquals(StringUtil.Trim("a	b "), "a	b")
	LU.assertEquals(StringUtil.Trim("a	b  "), "a	b")
	LU.assertEquals(StringUtil.Trim("  a	b"), "a	b")
	LU.assertEquals(StringUtil.Trim(" a	b "), "a	b")
	LU.assertEquals(StringUtil.Trim("	a	b"), "a	b")
	LU.assertEquals(StringUtil.Trim("a	b	"), "a	b")
	LU.assertEquals(StringUtil.Trim("	a	b	"), "a	b")
	
	-- newlines
	LU.assertEquals(StringUtil.Trim("\na	b"), "a	b")
	LU.assertEquals(StringUtil.Trim("\r\na	b"), "a	b")
	LU.assertEquals(StringUtil.Trim("a	b\n"), "a	b")
	LU.assertEquals(StringUtil.Trim("a	b\r\n"), "a	b")
	LU.assertEquals(StringUtil.Trim("\na	b"), "a	b")
	LU.assertEquals(StringUtil.Trim("\na	b\n"), "a	b")
	LU.assertEquals(StringUtil.Trim("\na	b\r"), "a	b")
	LU.assertEquals(StringUtil.Trim("a	b\n"), "a	b")
	LU.assertEquals(StringUtil.Trim("\na	b\n"), "a	b")
end

function TestStringUtil:TestTrimStart()
	LU.assertEquals(StringUtil.TrimStart(""), "")
	LU.assertEquals(StringUtil.TrimStart(" "), "")
	LU.assertEquals(StringUtil.TrimStart("	"), "")
	LU.assertEquals(StringUtil.TrimStart("  "), "")
	
	-- content in middle with spaces or tabs on outside
	LU.assertEquals(StringUtil.TrimStart(" a"), "a")
	LU.assertEquals(StringUtil.TrimStart("a "), "a ")
	LU.assertEquals(StringUtil.TrimStart("a  "), "a  ")
	LU.assertEquals(StringUtil.TrimStart("  a"), "a")
	LU.assertEquals(StringUtil.TrimStart(" a "), "a ")
	LU.assertEquals(StringUtil.TrimStart("	a"), "a")
	LU.assertEquals(StringUtil.TrimStart("a	"), "a	")
	LU.assertEquals(StringUtil.TrimStart("	a	"), "a	")
	
	-- spaces in middle
	LU.assertEquals(StringUtil.TrimStart(" a b"), "a b")
	LU.assertEquals(StringUtil.TrimStart("a b "), "a b ")
	LU.assertEquals(StringUtil.TrimStart("a b  "), "a b  ")
	LU.assertEquals(StringUtil.TrimStart("  a b"), "a b")
	LU.assertEquals(StringUtil.TrimStart(" a b "), "a b ")
	LU.assertEquals(StringUtil.TrimStart("	a b"), "a b")
	LU.assertEquals(StringUtil.TrimStart("a b	"), "a b	")
	LU.assertEquals(StringUtil.TrimStart("	a b	"), "a b	")
	
	-- tabs in middle (a tab b)
	LU.assertEquals(StringUtil.TrimStart(" a	b"), "a	b")
	LU.assertEquals(StringUtil.TrimStart("a	b "), "a	b ")
	LU.assertEquals(StringUtil.TrimStart("a	b  "), "a	b  ")
	LU.assertEquals(StringUtil.TrimStart("  a	b"), "a	b")
	LU.assertEquals(StringUtil.TrimStart(" a	b "), "a	b ")
	LU.assertEquals(StringUtil.TrimStart("	a	b"), "a	b")
	LU.assertEquals(StringUtil.TrimStart("a	b	"), "a	b	")
	LU.assertEquals(StringUtil.TrimStart("	a	b	"), "a	b	")
	
	-- newlines
	LU.assertEquals(StringUtil.TrimStart("\na	b"), "a	b")
	LU.assertEquals(StringUtil.TrimStart("\r\na	b"), "a	b")
	LU.assertEquals(StringUtil.TrimStart("a	b\n"), "a	b\n")
	LU.assertEquals(StringUtil.TrimStart("a	b\r\n"), "a	b\r\n")
	LU.assertEquals(StringUtil.TrimStart("\na	b"), "a	b")
	LU.assertEquals(StringUtil.TrimStart("\na	b\n"), "a	b\n")
	LU.assertEquals(StringUtil.TrimStart("\na	b\r"), "a	b\r")
	LU.assertEquals(StringUtil.TrimStart("a	b\n"), "a	b\n")
	LU.assertEquals(StringUtil.TrimStart("\na	b\n"), "a	b\n")
end

function TestStringUtil:TestTrimEnd()
	LU.assertEquals(StringUtil.TrimEnd(""), "")
	LU.assertEquals(StringUtil.TrimEnd(" "), "")
	LU.assertEquals(StringUtil.TrimEnd("	"), "")
	LU.assertEquals(StringUtil.TrimEnd("  "), "")
	
	-- content in middle with spaces or tabs on outside
	LU.assertEquals(StringUtil.TrimEnd(" a"), " a")
	LU.assertEquals(StringUtil.TrimEnd("a "), "a")
	LU.assertEquals(StringUtil.TrimEnd("a  "), "a")
	LU.assertEquals(StringUtil.TrimEnd("  a"), "  a")
	LU.assertEquals(StringUtil.TrimEnd(" a "), " a")
	LU.assertEquals(StringUtil.TrimEnd("	a"), "	a")
	LU.assertEquals(StringUtil.TrimEnd("a	"), "a")
	LU.assertEquals(StringUtil.TrimEnd("	a	"), "	a")
	
	-- spaces in middle
	LU.assertEquals(StringUtil.TrimEnd(" a b"), " a b")
	LU.assertEquals(StringUtil.TrimEnd("a b "), "a b")
	LU.assertEquals(StringUtil.TrimEnd("a b  "), "a b")
	LU.assertEquals(StringUtil.TrimEnd("  a b"), "  a b")
	LU.assertEquals(StringUtil.TrimEnd(" a b "), " a b")
	LU.assertEquals(StringUtil.TrimEnd("	a b"), "	a b")
	LU.assertEquals(StringUtil.TrimEnd("a b	"), "a b")
	LU.assertEquals(StringUtil.TrimEnd("	a b	"), "	a b")
	
	-- tabs in middle (a tab b)
	LU.assertEquals(StringUtil.TrimEnd(" a	b"), " a	b")
	LU.assertEquals(StringUtil.TrimEnd("a	b "), "a	b")
	LU.assertEquals(StringUtil.TrimEnd("a	b  "), "a	b")
	LU.assertEquals(StringUtil.TrimEnd("  a	b"), "  a	b")
	LU.assertEquals(StringUtil.TrimEnd(" a	b "), " a	b")
	LU.assertEquals(StringUtil.TrimEnd("	a	b"), "	a	b")
	LU.assertEquals(StringUtil.TrimEnd("a	b	"), "a	b")
	LU.assertEquals(StringUtil.TrimEnd("	a	b	"), "	a	b")
	
	-- newlines
	LU.assertEquals(StringUtil.TrimEnd("\na	b"), "\na	b")
	LU.assertEquals(StringUtil.TrimEnd("\r\na	b"), "\r\na	b")
	LU.assertEquals(StringUtil.TrimEnd("a	b\n"), "a	b")
	LU.assertEquals(StringUtil.TrimEnd("a	b\r\n"), "a	b")
	LU.assertEquals(StringUtil.TrimEnd("\na	b"), "\na	b")
	LU.assertEquals(StringUtil.TrimEnd("\na	b\n"), "\na	b")
	LU.assertEquals(StringUtil.TrimEnd("\na	b\r"), "\na	b")
	LU.assertEquals(StringUtil.TrimEnd("a	b\n"), "a	b")
	LU.assertEquals(StringUtil.TrimEnd("\na	b\n"), "\na	b")
end

TestIterator = {}

function TestIterator:TestBasicIterator()
	local iterator = Iterator:New(BasicDatabase.cards, nil, nil)
	local n = 1
	for card in iterator:Make_Iterator() do
		LU.assertEquals(card.Name, BasicDatabase.cards[n].Name)
		n = n + 1
	end
end

function TestIterator:TestIteratorFiltering()
	local function SampleFilterFunc(card)
		return card.CMC > 2
	end

	local iterator = Iterator:New(BasicDatabase.cards, SampleFilterFunc, nil)
	local count = 0
	for card in iterator:Make_Iterator() do
		LU.assertTrue(card.CMC > 2)
		count = count + 1
	end
	LU.assertEquals(count, 4)
end

function TestIterator:TestIteratorSorting()
	local function SampleSortFunc(card1, card2)
		if card1.CMC < card2.CMC then
			return true
		elseif card1.CMC > card2.CMC then
			return false
		end
		return card1.Name < card2.Name
	end

	local iterator = Iterator:New(BasicDatabase.cards, nil, SampleSortFunc)
	local index = 0
	for card in iterator:Make_Iterator() do
		index = index + 1
		if index == 1 then
			LU.assertEquals(card.Name, "Giant Growth")
		elseif index == 2 then
			LU.assertEquals(card.Name, "Lightning Bolt")
		elseif index == 3 then
			LU.assertEquals(card.Name, "Grizzly Bears")
		elseif index == 4 then
			LU.assertEquals(card.Name, "Lightning Strike")
		elseif index == 5 then
			LU.assertEquals(card.Name, "Divination")
		elseif index == 6 then
			LU.assertEquals(card.Name, "Gray Ogre")
		elseif index == 7 then
			LU.assertEquals(card.Name, "Control Magic")
		elseif index == 8 then
			LU.assertEquals(card.Name, "Hill Giant")
		end
	end
	LU.assertEquals(index, 8)
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
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    STARTSCRIPT", false, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    STARTSCRIPT", false, true), Parser.TokenTypes.STARTSCRIPT)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    STARTSCRIPT", true, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    STARTSCRIPT", true, true), Parser.TokenTypes.STARTSCRIPT)
	
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
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("local foo = true", false, false), Parser.TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("local foo = true", false, true), Parser.TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("local foo = true", true, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("local foo = true", true, true), Parser.TokenTypes.TemplateLine)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine("		local foo = true", false, false), Parser.TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("		local foo = true", false, true), Parser.TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("		local foo = true", true, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine("		local foo = true", true, true), Parser.TokenTypes.TemplateLine)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    local foo = true", false, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    local foo = true", false, true), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    local foo = true", true, false), Parser.TokenTypes.TemplateLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(">	    local foo = true", true, true), Parser.TokenTypes.TemplateLine)
	
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    local foo = true", false, false), Parser.TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    local foo = true", false, true), Parser.TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    local foo = true", true, false), Parser.TokenTypes.ScriptLine)
	LU.assertEquals(Lexer.ExtractTokenFromLine(".	    local foo = true", true, true), Parser.TokenTypes.ScriptLine)
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

function TestParser:DISABLED_TestParserOnCockatrice()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local settings = Settings:New()
	settings.XML_STYLE_ACCESS = true
	
	local parsedTemplate = Parser.Parser.ParseFile(RunningScriptDir.."/cockatrice-to-mse/main.kengen", settings)
	LU.assertTrue(parsedTemplate ~= nil)
	LU.assertTrue(parsedTemplate:IsA(ParsedTemplate))
	
	local resultsStream = MemoryOutputStream:New()
	parsedTemplate:Execute(resultsStream)
	
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

function TestParser:TestGeneratorOnCardsSample()
	local RunningScriptDir = PathUtil.GetRunningScriptDirectoryPath();
	LU.assertTrue(RunningScriptDir ~= nil)

	local settings = Settings:New()
	settings.XML_STYLE_ACCESS = false
	
	local parsedTemplate = Parser.Parser.ParseFile(RunningScriptDir.."/cockatrice-to-mse/test_cards_sample.kengen", settings)
	LU.assertTrue(parsedTemplate ~= nil)
	LU.assertTrue(parsedTemplate:IsA(ParsedTemplate))
	
	local resultsStream = MemoryOutputStream:New()
	parsedTemplate:Execute(resultsStream)
	
	-- TODO Actually verify the output
end

os.exit( LU.LuaUnit.run() )
