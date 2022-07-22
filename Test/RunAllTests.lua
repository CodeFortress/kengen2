LU = require('kengen2.ThirdParty.luaunit.luaunit')
assert(LU ~= nil)

local Kengen = require("kengen2")

local Iterator = require("kengen2.Framework.Iterator")
local Settings = require("kengen2.Framework.Settings")

local Lexer = require("kengen2.Parser.Lexer")
local Parser = require("kengen2.Parser.Parser")
local TokenTypes = require("kengen2.Parser.TokenTypes")

local FuncParseNode = require("kengen2.Parser.FuncParseNode")
local ListParseNode = require("kengen2.Parser.ListParseNode")
local ScriptChunkParseNode = require("kengen2.Parser.ScriptChunkParseNode")

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

Test_ClassUtil = {}

function Test_ClassUtil:Test_Unit_IsAFailsOnNil()
	local function funcToFail()
		local settings = Settings:New()
		settings:IsA(nil)
	end
	LU.assertErrorMsgContains("Passed a nil class to an IsA check", funcToFail)
end

Test_StringUtil = {}

function Test_StringUtil:Test_Unit_StartsWith()
	LU.assertTrue(StringUtil.StartsWith("foo", ""))
	LU.assertTrue(StringUtil.StartsWith("foo", "f"))
	LU.assertTrue(StringUtil.StartsWith("foo", "fo"))
	LU.assertTrue(StringUtil.StartsWith("foo", "foo"))
	
	LU.assertFalse(StringUtil.StartsWith("foo", "o"))
	LU.assertFalse(StringUtil.StartsWith("foo", " "))
	LU.assertFalse(StringUtil.StartsWith("foo", ".")) -- make sure it is not treated as regex
	
	LU.assertError(function()
		StringUtil.StartsWith("foo", nil)
	end)
	LU.assertError(function()
		StringUtil.StartsWith("foo", 1)
	end)
	LU.assertError(function()
		StringUtil.StartsWith("foo", {"f"})
	end)

	LU.assertError(function()
		StringUtil.StartsWith(nil, "f")
	end)
	LU.assertError(function()
		StringUtil.StartsWith(1, "f")
	end)
	LU.assertError(function()
		StringUtil.StartsWith({"foo"}, "f")
	end)
end

function Test_StringUtil:Test_Unit_Trim()
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

	LU.assertError(function()
		StringUtil.Trim(nil)
	end)
	LU.assertError(function()
		StringUtil.Trim(1)
	end)
	LU.assertError(function()
		StringUtil.Trim({"foo"})
	end)
end

function Test_StringUtil:Test_Unit_TrimStart()
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
	
	LU.assertError(function()
		StringUtil.TrimStart(nil)
	end)
	LU.assertError(function()
		StringUtil.TrimStart(1)
	end)
	LU.assertError(function()
		StringUtil.TrimStart({"foo"})
	end)
end

function Test_StringUtil:Test_Unit_End()
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
	
	LU.assertError(function()
		StringUtil.TrimEnd(nil)
	end)
	LU.assertError(function()
		StringUtil.TrimEnd(1)
	end)
	LU.assertError(function()
		StringUtil.TrimEnd({"foo"})
	end)
end

Test_Iterator = {}

function Test_Iterator:Test_Class_Make()
	local iterator = Iterator:New(BasicDatabase.cards, nil, nil)
	local n = 1
	for card in iterator:Make_Iterator() do
		LU.assertEquals(card.Name, BasicDatabase.cards[n].Name)
		n = n + 1
	end
end

function Test_Iterator:Test_Class_Filtering()
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

function Test_Iterator:Test_Class_Sorting()
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

	local tokenizedFile = Lexer.Tokenize(RunningScriptDir.."/test_simple.kengen", Settings:New())
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
	local tokenizedFile = Lexer.Tokenize(RunningScriptDir.."/test_complex.kengen", settings)
	LU.assertTrue(TestUtil.IsTable(tokenizedFile))
	LU.assertEquals(tokenizedFile.Length, 22)
	LU.assertEquals(tokenizedFile.Path, RunningScriptDir.."/test_complex.kengen")
	
	LU.assertEquals(#tokenizedFile.Tokens, 19)
	LU.assertEquals(#tokenizedFile.TokensByLine, 22)
	
	-- TODO Expand the existing test to cover more cases; test every token here
	
end

Test_Parser = {}

function Test_Parser:setUp()
	local sampleFile = [[
		STARTSCRIPT -- Hello World
		print("Hello, World")
		print("Welcome to kengen!")
		ENDSCRIPT -- Hello World
		
		STARTFUNCTION PrintHelloWorld()
			print("Hello again, World")
		ENDFUNCTION -- PrintHelloWorld
		
		.print("This is an ExecBlock")
		.print("It's embedded right into the file")
		
		IF doEmbeddedIf THEN
			FOREACH item IN items DO
				IF item.Type == "A" THEN
					.print(item.Name.." is Type A")
				ELSEIF item.Type == "B" THEN
					.print(item.Name.." is Type B")
				ELSEIF item.Type == "C" THEN
					.print(item.Name.." is Type C")
				ELSE
					IF printErrors THEN
						.print("Item with unknown item type: "..item.Name)
					ENDIF
				ENDIF
			ENDFOREACH
		ELSE -- not doEmbeddedIf
			.print("Skipping embedded if")
		ENDIF -- doEmbeddedIf
		]]
	local sampleFileLines = StringUtil.Split(sampleFile, "\n")
	local findLineNumber = function(lines, substring)
		for index, value in ipairs(sampleFileLines) do
			if value:find(substring, 1, true --[[disable regex]]) ~= nil then
				return index
			end
		end
		error("Could not find a line with expected string: "..substring)
		return nil
	end
	
	self.TestLineNumbers = {}
	self.TestLineNumbers.StartScriptHelloWorld = findLineNumber(sampleFileLines, "STARTSCRIPT -- Hello World")
	self.TestLineNumbers.EndScriptHelloWorld = findLineNumber(sampleFileLines, "ENDSCRIPT -- Hello World")
	self.TestLineNumbers.StartFunctionPrintHelloWorld = findLineNumber(sampleFileLines, "STARTFUNCTION PrintHelloWorld")
	self.TestLineNumbers.EndFunctionPrintHelloWorld = findLineNumber(sampleFileLines, "ENDFUNCTION -- PrintHelloWorld")
	self.TestLineNumbers.ExecBlock = findLineNumber(sampleFileLines, "This is an ExecBlock")
	self.TestLineNumbers.StartDoEmbeddedIf = findLineNumber(sampleFileLines, "doEmbeddedIf")
	self.TestLineNumbers.ElseNotDoEmbeddedIf = findLineNumber(sampleFileLines, "ELSE -- not doEmbeddedIf")
	self.TestLineNumbers.EndDoEmbeddedIf = findLineNumber(sampleFileLines, "ENDIF -- doEmbeddedIf")
	
	local tokenizedFile = Lexer.TokenizeStringToFile(sampleFile, Settings:New())
	self.SampleParser = Parser:New(tokenizedFile)
end

function Test_Parser:Test_Unit_ValidateCursor()
	LU.assertError(function()
		self.SampleParser:ValidateCursor(0)
	end)
	LU.assertError(function()
		self.SampleParser:ValidateCursor(9999)
	end)
	LU.assertError(function()
		self.SampleParser:ValidateCursor("1")
	end)

	self.SampleParser:ValidateCursor(1)
	self.SampleParser:ValidateCursor(4)
end

function Test_Parser:Test_Unit_CursorLookups()
	LU.assertEquals(self.SampleParser:Peek(self.TestLineNumbers.StartScriptHelloWorld), TokenTypes.STARTSCRIPT)
	LU.assertEquals(self.SampleParser:Peek(self.TestLineNumbers.StartScriptHelloWorld + 1), TokenTypes.ScriptLine)
	LU.assertEquals(self.SampleParser:Peek(self.TestLineNumbers.StartScriptHelloWorld + 2), TokenTypes.ScriptLine)
	LU.assertEquals(self.SampleParser:Peek(self.TestLineNumbers.EndScriptHelloWorld), TokenTypes.ENDSCRIPT)
	
	LU.assertEquals(self.SampleParser:Advance(self.TestLineNumbers.StartScriptHelloWorld), self.TestLineNumbers.StartScriptHelloWorld + 1)
	LU.assertEquals(self.SampleParser:Advance(self.TestLineNumbers.StartScriptHelloWorld + 1), self.TestLineNumbers.EndScriptHelloWorld)
	LU.assertEquals(self.SampleParser:Advance(self.TestLineNumbers.StartScriptHelloWorld + 2), self.TestLineNumbers.EndScriptHelloWorld)
	LU.assertEquals(self.SampleParser:Advance(self.TestLineNumbers.EndScriptHelloWorld), self.TestLineNumbers.EndScriptHelloWorld + 1)
	
	LU.assertEquals(self.SampleParser:CurToken(self.TestLineNumbers.StartScriptHelloWorld).Type, TokenTypes.STARTSCRIPT)
	LU.assertEquals(self.SampleParser:CurToken(self.TestLineNumbers.StartScriptHelloWorld + 1).Type, TokenTypes.ScriptLine)
	LU.assertEquals(self.SampleParser:CurToken(self.TestLineNumbers.StartScriptHelloWorld + 2).Type, TokenTypes.ScriptLine)
	LU.assertEquals(self.SampleParser:CurToken(self.TestLineNumbers.EndScriptHelloWorld).Type, TokenTypes.ENDSCRIPT)
	
	LU.assertEquals(
		self.SampleParser:CurTokenString(self.TestLineNumbers.StartScriptHelloWorld),
		TokenTypes.ToString[TokenTypes.STARTSCRIPT])
	LU.assertEquals(
		self.SampleParser:CurTokenString(self.TestLineNumbers.StartScriptHelloWorld + 1),
		TokenTypes.ToString[TokenTypes.ScriptLine])
	LU.assertEquals(
		self.SampleParser:CurTokenString(self.TestLineNumbers.StartScriptHelloWorld + 2),
		TokenTypes.ToString[TokenTypes.ScriptLine])
	LU.assertEquals(
		self.SampleParser:CurTokenString(self.TestLineNumbers.EndScriptHelloWorld),
		TokenTypes.ToString[TokenTypes.ENDSCRIPT])
end

function Test_Parser:Test_Unit_ParseBlock()
	local cursor, node = self.SampleParser:ParseBlock(self.TestLineNumbers.StartFunctionPrintHelloWorld)
	LU.assertEquals(cursor, self.TestLineNumbers.StartFunctionPrintHelloWorld + 3)
	LU.assertTrue(node:IsA(FuncParseNode))
	
	local cursor, node = self.SampleParser:ParseBlock(self.TestLineNumbers.ExecBlock)
	LU.assertTrue(node:IsA(ScriptChunkParseNode))
end

function Test_Parser:Test_Unit_FindSymbolAtDepth()
	LU.assertEquals(
		self.SampleParser:FindSymbolAtDepth(
			self.TestLineNumbers.StartFunctionPrintHelloWorld,
			TokenTypes.STARTFUNCTION,
			{ TokenTypes.ENDFUNCTION },
			Parser.SymbolPairs),
		self.TestLineNumbers.EndFunctionPrintHelloWorld)
	
	LU.assertEquals(
		self.SampleParser:FindSymbolAtDepth(
			self.TestLineNumbers.StartScriptHelloWorld,
			TokenTypes.STARTSCRIPT,
			{ TokenTypes.ENDSCRIPT },
			Parser.SymbolPairs),
		self.TestLineNumbers.EndScriptHelloWorld)
	
	LU.assertEquals(
		self.SampleParser:FindSymbolAtDepth(
			self.TestLineNumbers.StartDoEmbeddedIf,
			TokenTypes.IF,
			{ TokenTypes.ENDIF },
			Parser.SymbolPairs),
		self.TestLineNumbers.EndDoEmbeddedIf)
	
	LU.assertEquals(
		self.SampleParser:FindSymbolAtDepth(
			self.TestLineNumbers.StartDoEmbeddedIf,
			TokenTypes.IF,
			{ TokenTypes.ELSEIF, TokenTypes.ELSE, TokenTypes.ENDIF },
			Parser.SymbolPairs),
		self.TestLineNumbers.ElseNotDoEmbeddedIf)
	
	LU.assertEquals(
		self.SampleParser:FindSymbolAtDepth(
			self.TestLineNumbers.ElseNotDoEmbeddedIf,
			TokenTypes.ELSE,
			{ TokenTypes.ELSEIF, TokenTypes.ELSE, TokenTypes.ENDIF },
			Parser.SymbolPairs),
		self.TestLineNumbers.EndDoEmbeddedIf)
end

-- TODO: Test_Parser should have some unit/class level tests which validate actual parsed node trees

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
	local ResultsToMatchFile = io.open("Test/animals/test_animals.h", "r")
	local ResultsToMatch = ResultsToMatchFile:read("*a")
	ResultsToMatchFile:close()
	
	-- TODO this feels a little flimsy. It breaks if switched to "rb" open mode here OR in StringUtil.FileToString,
	--	since loading the kengen files uses that function and apparently produces different results.
	--  Probably should come up with something more newline-agnostic, or understand the expected differences
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

--os.exit( LU.LuaUnit.run("Test_Integration.Test_Integration_OnAnimals") )
os.exit( LU.LuaUnit.run() )
