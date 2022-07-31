local LU = require('kengen2.ThirdParty.luaunit.luaunit')

local Settings = require("kengen2.Framework.Settings")

local Lexer = require("kengen2.Parser.Lexer")
local Parser = require("kengen2.Parser.Parser")
local TokenTypes = require("kengen2.Parser.TokenTypes")

local FuncParseNode = require("kengen2.Parser.FuncParseNode")
local ListParseNode = require("kengen2.Parser.ListParseNode")
local ScriptChunkParseNode = require("kengen2.Parser.ScriptChunkParseNode")

local StringUtil = require("kengen2.Util.StringUtil")

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

return Test_Parser