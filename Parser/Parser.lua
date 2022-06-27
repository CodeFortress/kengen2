local TokenTypes = require("kengen2.Parser.TokenTypes")
local Util = require("kengen2.Util")

local ForeachParseNode = require("kengen2.Parser.ForeachParseNode")
local FuncParseNode = require("kengen2.Parser.FuncParseNode")
local IfParseNode = require("kengen2.Parser.IfParseNode")
local StartScriptParseNode = require("kengen2.Parser.StartScriptParseNode")
local StartTemplateParseNode = require("kengen2.Parser.StartTemplateParseNode")
local ScriptChunkParseNode = require("kengen2.Parser.ScriptChunkParseNode")
local TemplateChunkParseNode = require("kengen2.Parser.TemplateChunkParseNode")

local Parser = Util.ClassUtil.CreateClass("Parser", nil)

function Parser:New(tokenizedFile)
    assert(Util.TestUtil.IsTable(self))
    assert(Util.TestUtil.IsTable(tokenizedFile))

    local result = self:Create()
    result.CurPos = 1
    result.File = tokenizedFile
    return result
end

-- Returns the TYPE of the token being looked at
function Parser:Peek()
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))

    if self.CurPos > self.File.Length then
        return nil
    end

    return self.File.TokensByLine[self.CurPos].Type
end

-- Moves the current position forward one whole token
function Parser:Advance()
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))

    -- Advance to end of this token, then add one to be at start of next token
    self.CurPos = self.File.TokensByLine[self.CurPos].EndPos + 1
    return self.CurPos
end

-- Returns the current Token object
function Parser:CurToken()
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))

    return self.File.TokensByLine[self.CurPos]
end

-- Returns the current Token object's type as string
function Parser:CurTokenString()
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))

    return tostring(TokenTypes.ToString[self.File.TokensByLine[self.CurPos]])
end

-- Root of parser logic
function Parser:ParseProgram()
    local nodesList = {}
    while self:Peek() ~= nil do
        nodesList[#nodesList + 1] = self:ParseBlock()
    end
    return nodesList
end

function Parser:ParseBlock()
    if self:Peek() == TokenTypes.STARTFUNCTION then
        return self:ParseFuncBlock()
    else
        return self:ParseExecBlock()
    end
end

-- Bookended chunk means a chunk that has a specific start and end symbol
function Parser:ParseBookendedBlock(last, openingSymbol, closingSymbol, nodeClass)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
    assert(Util.TestUtil.IsNumber(last))
    assert(Util.TestUtil.IsNumber(openingSymbol))
    assert(Util.TestUtil.IsNumber(closingSymbol))
    assert(Util.TestUtil.IsTable(nodeClass))
    assert(self:Peek() == openingSymbol)

    local last = self:FindClosingSymbol(openingSymbol, closingSymbol, true)
    local chain = self:ParseExecChain(last-1)
    assert(chain ~= nil, "Failed to parse "..tostring(TokenTypes.ToString[openingSymbol]).." block")
    local result = nodeClass:New(chain)
    self:Advance() -- skip over the end token!
    return result
end

function Parser:ParseFuncBlock()
    local last = self.File.Length
    return self:ParseBookendedBlock(last, TokenTypes.STARTFUNCTION, TokenTypes.ENDFUNCTION, FuncParseNode)
end

function Parser:ParseExecChain(last)
    local nodesList = {}
    while self:Peek() ~= nil and self.CurPos <= last do
        nodesList[#nodesList + 1] = self:ParseExecBlock(last)
    end
    return nodesList
end

function Parser:ParseExecBlock(last)
    last = last or self.File.Length
    if self:Peek() == TokenTypes.IF then
        return self:ParseIfBlock(last)
    elseif self:Peek() == TokenTypes.FOREACH then
        return self:ParseForeachBlock(last)
    elseif self:Peek() == TokenTypes.STARTSCRIPT then
        return self:ParseStartScriptBlock(last)
    elseif self:Peek() == TokenTypes.STARTTEMPLATE then
        return self:ParseStartTemplateBlock(last)
    elseif self:Peek() == TokenTypes.ScriptLine then
        return self:ParseScriptChunk(last)
    elseif self:Peek() == TokenTypes.TemplateLine then
        return self:ParseTemplateChunk(last)
    end

    assert(false, "Unexpected symbol for starting an exec block: "..self:CurTokenString())
end

function Parser:ParseIfBlock(last)
    assert(not_implemented)
end

function Parser:ParseForEachBlock(last)
    return self:ParseBookendedBlock(last, TokenTypes.FOREACH, TokenTypes.ENDFOREACH, ForeachParseNode)
end

function Parser:ParseStartScriptBlock(last)
    return self:ParseBookendedBlock(last, TokenTypes.STARTSCRIPT, TokenTypes.ENDSCRIPT, StartScriptParseNode)
end

function Parser:ParseStartTemplateBlock(last)
    return self:ParseBookendedBlock(last, TokenTypes.STARTTEMPLATE, TokenTypes.ENDTEMPLATE, StartTemplateParseNode)
end

-- Basic chunk just means a sequence of the same symbol of any count
function Parser:ParseBasicChunk(last, symbol, nodeClass)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
    assert(Util.TestUtil.IsNumber(last))
    assert(Util.TestUtil.IsNumber(symbol))
    assert(Util.TestUtil.IsTable(nodeClass))
    assert(self:Peek() == symbol)

    local startPos = self.CurPos
    local endPos = -1
    while (self:Peek() == symbol and self.CurPos <= last) do
        endPos = self:CurToken().EndPos
        self:Advance()
    end
    assert(endPos >= startPos)
    return nodeClass:New(startPos, endPos)
end

function Parser:ParseScriptChunk(last)
    return self:ParseBasicChunk(last, TokenTypes.ScriptLine, ScriptChunkParseNode)
end

function Parser:ParseTemplateChunk(last)
    return self:ParseBasicChunk(last, TokenTypes.TemplateLine, TemplateChunkParseNode)
end

function Parser:ToString()
    return self.File.Path..":"..tostring(self.CurPos)
end

-- Find position of a closing symbol while requiring it to be depth-matched with its opening symbol
-- e.g. this will return 5 if run from line 1 with openingSymbol=IF, closingSymbol=ENDIF
--   1: IF foo
--   2:   IF bar
--   3:     print("do work")
--   4:   ENDIF
--   5: ENDIF
function Parser:FindClosingSymbol(openingSymbol, closingSymbol, assertOnFail)
    assert(Util.TestUtil.IsTable(self) and self:IsA(Parser))
    assert(Util.TestUtil.IsNumber(openingSymbol))
    assert(Util.TestUtil.IsNumber(closingSymbol))

    assert(self:Peek() == openingSymbol, "Searching for closing symbol when opening symbol didn't even match!")
    self:Advance() -- skip the opening symbol
    local originalPos = self.CurPos

    local result = nil
    local depthCount = 0
    while self:Peek() ~= nil do
        local symbol = self:Peek()
        if symbol == openingSymbol then
            depthCount = depthCount + 1
        elseif symbol == closingSymbol and depthCount > 0 then
            depthCount = depthCount - 1
        elseif symbol == closingSymbol then
            result = self.CurPos
            break
        end
        self:Advance()
    end

    self.CurPos = originalPos

    assert((not assertOnFail) or (result ~= nil), "Mismatched symbol "..TokenTypes.ToString[openingSymbol].." was located at "..tostring(self))
    
    return result
end

return Parser