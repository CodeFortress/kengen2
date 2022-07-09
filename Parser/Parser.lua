local ParsedTemplate = require("kengen2.Execution.ParsedTemplate")
local Settings = require("kengen2.Framework.Settings")
local TokenTypes = require("kengen2.Parser.TokenTypes")
local Util = require("kengen2.Util")

local Lexer = require("kengen2.Parser.Lexer")
local ForeachParseNode = require("kengen2.Parser.ForeachParseNode")
local FuncParseNode = require("kengen2.Parser.FuncParseNode")
local IfParseNode = require("kengen2.Parser.IfParseNode")
local ListParseNode = require("kengen2.Parser.ListParseNode")
local StartScriptParseNode = require("kengen2.Parser.StartScriptParseNode")
local StartTemplateParseNode = require("kengen2.Parser.StartTemplateParseNode")
local ScriptChunkParseNode = require("kengen2.Parser.ScriptChunkParseNode")
local TemplateChunkParseNode = require("kengen2.Parser.TemplateChunkParseNode")

local Parser = Util.ClassUtil.CreateClass("Parser", nil)

-- Returns tree of nodes
function Parser.ParseFile(path, settings)
	assert(Util.TestUtil.IsString(path))
    assert(Util.TestUtil.IsTable(settings) and settings:IsA(Settings))
	
	local tokenizedFile = Lexer.Tokenize(path, settings)
	local parser = Parser:New(tokenizedFile)
	return parser:ParseProgram()
end

function Parser:New(tokenizedFile)
    assert(Util.TestUtil.IsTable(self))
    assert(Util.TestUtil.IsTable(tokenizedFile))

    local result = self:Create()
    result.File = tokenizedFile
    return result
end

function Parser:ValidateCursor(cursor, allowBeyondEnd)
	assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
	assert(Util.TestUtil.IsNumber(cursor))
	assert(cursor >= 1)
	assert(cursor <= self.File.Length or allowBeyondEnd)
end

-- Returns the TYPE of the token located at cursor position
function Parser:Peek(cursor)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
	local allowBeyondEnd = true
	self:ValidateCursor(cursor, allowBeyondEnd)
	
	if cursor > self.File.Length then
		return nil
	else
		return self.File.TokensByLine[cursor].Type
	end
end

-- Returns the cursor position moved forward one whole token
function Parser:Advance(cursor)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
	self:ValidateCursor(cursor)

    -- Advance to end of this token, then add one to be at start of next token
    return self.File.TokensByLine[cursor].EndPos + 1
end

-- Returns the actual Token object located at the cursor position
function Parser:CurToken(cursor)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
	self:ValidateCursor(cursor)

    return self.File.TokensByLine[cursor]
end

-- Returns the Token object's type as string for the token located at the cursor position
function Parser:CurTokenString(cursor)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
	self:ValidateCursor(cursor)

    return tostring(TokenTypes.ToString[self.File.TokensByLine[cursor]])
end

-- Root of parser logic
function Parser:ParseProgram()
	local cursor = 1
    local nodesList = {}
    while self:Peek(cursor) ~= nil do
        cursor, nodesList[#nodesList + 1] = self:ParseBlock(cursor)
    end
	local ListNode = ListParseNode:New(nodesList)
    return ParsedTemplate:New(self.File, ListNode)
end

-- Parses a block starting at cursor position; returns a new cursor position and a node
function Parser:ParseBlock(cursor)
	self:ValidateCursor(cursor)
	
    if self:Peek(cursor) == TokenTypes.STARTFUNCTION then
        return self:ParseFuncBlock(cursor)
    else
        return self:ParseExecBlock(cursor)
    end
end

-- Parses a bookended block starting at cursor position; returns a new cursor position and a node
-- Bookended chunk means a chunk that has a specific start and end symbol
function Parser:ParseBookendedBlock(cursor, last, openingSymbol, closingSymbol, nodeClass)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
	self:ValidateCursor(cursor)
    assert(Util.TestUtil.IsNumber(last))
    assert(Util.TestUtil.IsNumber(openingSymbol))
    assert(Util.TestUtil.IsNumber(closingSymbol))
    assert(Util.TestUtil.IsTable(nodeClass))
    assert(self:Peek(cursor) == openingSymbol)

    local last = self:FindClosingSymbol(cursor, openingSymbol, closingSymbol, true)
    local cursor, chain = self:ParseExecChain(cursor + 1, last-1)
    assert(chain ~= nil, "Failed to parse "..tostring(TokenTypes.ToString[openingSymbol]).." block")
    local result = nodeClass:New(chain)
    cursor = self:Advance(cursor) -- skip over the end token!
    return cursor, result
end

-- Parses a function block starting at cursor position; returns a new cursor position and a node
function Parser:ParseFuncBlock(cursor)
	self:ValidateCursor(cursor)
	
    local last = self.File.Length
    return self:ParseBookendedBlock(cursor, last, TokenTypes.STARTFUNCTION, TokenTypes.ENDFUNCTION, FuncParseNode)
end

-- Parses a list of executable nodes starting at cursor position; returns a new cursor position and a list of nodes
function Parser:ParseExecChain(cursor, last)
	self:ValidateCursor(cursor)
	assert(Util.TestUtil.IsNumber(last))
	
    local nodesList = {}
    while self:Peek(cursor) ~= nil and cursor <= last do
        cursor, nodesList[#nodesList + 1] = self:ParseExecBlock(cursor, last)
    end
    return cursor, nodesList
end

-- Parses an executable block starting at cursor position; returns a new cursor position and a node
function Parser:ParseExecBlock(cursor, last)
	self:ValidateCursor(cursor)
	assert(last == nil or Util.TestUtil.IsNumber(last))
	
    last = last or self.File.Length
    if self:Peek(cursor) == TokenTypes.IF then
        return self:ParseIfBlock(cursor, last)
    elseif self:Peek(cursor) == TokenTypes.FOREACH then
        return self:ParseForeachBlock(cursor, last)
    elseif self:Peek(cursor) == TokenTypes.STARTSCRIPT then
        return self:ParseStartScriptBlock(cursor, last)
    elseif self:Peek(cursor) == TokenTypes.STARTTEMPLATE then
        return self:ParseStartTemplateBlock(cursor, last)
    elseif self:Peek(cursor) == TokenTypes.ScriptLine then
        return self:ParseScriptChunk(cursor, last)
    elseif self:Peek(cursor) == TokenTypes.TemplateLine then
        return self:ParseTemplateChunk(cursor, last)
	elseif self:Peek(cursor) == TokenTypes.ENDFOREACH then
		assert(false, "Unexpected ENDFOREACH without a matching FOREACH")
	elseif self:Peek(cursor) == TokenTypes.ELSEIF then
		assert(false, "Unexpected ELSEIF without a matching IF")
	elseif self:Peek(cursor) == TokenTypes.ELSE then
		assert(false, "Unexpected ELSE without a matching IF")
	elseif self:Peek(cursor) == TokenTypes.ENDIF then
		assert(false, "Unexpected ENDIF without a matching IF")
    end

    assert(false, "Unexpected symbol for starting an exec block: "..self:CurTokenString(cursor))
end

-- Parses an IF block starting at cursor position; returns a new cursor position and a node
function Parser:ParseIfBlock(cursor, last)
	self:ValidateCursor(cursor)
	assert(Util.TestUtil.IsNumber(last))
	
    local cursor, ifNode = self:ParseBookendedBlock(last, TokenTypes.IF, TokenTypes.ENDIF, IfParseNode)
	
	return cursor, ifNode
end

-- Parses a FOREACH block starting at cursor position; returns a new cursor position and a node
function Parser:ParseForeachBlock(cursor, last)
	self:ValidateCursor(cursor)
	assert(Util.TestUtil.IsNumber(last))
    return self:ParseBookendedBlock(cursor, last, TokenTypes.FOREACH, TokenTypes.ENDFOREACH, ForeachParseNode)
end

-- Parses a STARTSCRIPT block starting at cursor position; returns a new cursor position and a node
function Parser:ParseStartScriptBlock(cursor, last)
	self:ValidateCursor(cursor)
	assert(Util.TestUtil.IsNumber(last))
    return self:ParseBookendedBlock(cursor, last, TokenTypes.STARTSCRIPT, TokenTypes.ENDSCRIPT, StartScriptParseNode)
end

-- Parses a STARTTEMPLATE block starting at cursor position; returns a new cursor position and a node
function Parser:ParseStartTemplateBlock(cursor, last)
	self:ValidateCursor(cursor)
	assert(Util.TestUtil.IsNumber(last))
    return self:ParseBookendedBlock(cursor, last, TokenTypes.STARTTEMPLATE, TokenTypes.ENDTEMPLATE, StartTemplateParseNode)
end

-- Parses a chunk starting at cursor position; returns a new cursor position and a node
-- Basic chunk just means a sequence of the same symbol of any count
function Parser:ParseBasicChunk(cursor, last, symbol, nodeClass)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
	self:ValidateCursor(cursor)
    assert(Util.TestUtil.IsNumber(last))
    assert(Util.TestUtil.IsNumber(symbol))
    assert(Util.TestUtil.IsTable(nodeClass))
    assert(self:Peek(cursor) == symbol)

    local startPos = cursor
    local endPos = -1
    while (self:Peek(cursor) == symbol and cursor <= last) do
        endPos = self:CurToken(cursor).EndPos
        cursor = self:Advance(cursor)
    end
    assert(endPos >= startPos)
    return cursor, nodeClass:New(startPos, endPos)
end

-- Parses a script chunk starting at cursor position; returns a new cursor position and a node
function Parser:ParseScriptChunk(cursor, last)
	self:ValidateCursor(cursor)
	assert(Util.TestUtil.IsNumber(last))
    return self:ParseBasicChunk(cursor, last, TokenTypes.ScriptLine, ScriptChunkParseNode)
end

-- Parses a template chunk at cursor position; returns a new cursor position and a node
function Parser:ParseTemplateChunk(cursor, last)
	self:ValidateCursor(cursor)
	assert(Util.TestUtil.IsNumber(last))
    return self:ParseBasicChunk(cursor, last, TokenTypes.TemplateLine, TemplateChunkParseNode)
end

-- Returns a string representing the parser's file and provided cursor position
function Parser:ToString(cursor)
	self:ValidateCursor(cursor)
    return self.File.Path..":"..tostring(cursor)
end

-- Find position of a closing symbol while requiring it to be depth-matched with its opening symbol
-- e.g. this will return 5 if run from line 1 with openingSymbol=IF, closingSymbol=ENDIF
--   1: IF foo
--   2:   IF bar
--   3:     print("do work")
--   4:   ENDIF
--   5: ENDIF
function Parser:FindClosingSymbol(cursor, openingSymbol, closingSymbol, assertOnFail)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
	self:ValidateCursor(cursor)
    assert(Util.TestUtil.IsNumber(openingSymbol))
    assert(Util.TestUtil.IsNumber(closingSymbol))

    assert(self:Peek(cursor) == openingSymbol, "Searching for closing symbol when opening symbol didn't even match!")
    cursor = self:Advance(cursor) -- skip the opening symbol

    local result = nil
    local depthCount = 0
    while self:Peek(cursor) ~= nil do
        local symbol = self:Peek(cursor)
        if symbol == openingSymbol then
            depthCount = depthCount + 1
        elseif symbol == closingSymbol and depthCount > 0 then
            depthCount = depthCount - 1
        elseif symbol == closingSymbol then
            result = cursor
            break
        end
        cursor = self:Advance(cursor)
    end

    assert((not assertOnFail) or (result ~= nil), "Mismatched symbol "..TokenTypes.ToString[openingSymbol].." was located at "..self:ToString(cursor))
    
    return result
end

return Parser