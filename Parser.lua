local TokenTypes = require("TokenTypes")
local Util = require("Util")

local Parser = Util.CreateClass("Parser", nil)

function Parser:New(tokenizedFile)
    assert(Util.IsTable(self))
    assert(Util.IsTable(tokenizedFile))

    local result = self:Create()
    result.CurPos = 1
    result.File = tokenizedFile
    return result
end

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

function Parser:ParseFuncBlock()
    local last = FindClosingSymbol(TokenTypes.STARTFUNCTION, TokenTypes.ENDFUNCTION, true)
    local chain = self:ParseExecChain(last-1)
    assert(chain ~= nil, "Failed to parse STARTFUNCTION block")
    return FuncParseNode:New(chain)
end

function Parser:ParseExecChain(last)
    local nodesList = {}
    while self:Peek() ~= nil do
        nodesList[#nodesList + 1] = self:ParseExecBlock(last)
    end
    return ExecChainParseNode:New(nodesList)
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
        return self:ParseScriptBlock(last)
    elseif self:Peek() == TokenTypes.TemplateLine then
        return self:ParseTemplateBlock(last)
    end

    assert(false, "Unexpected symbol for starting an exec block: "..tostring(TokenTypes.ToString[self:Peek()]))
end

-- Returns the TYPE of the token being looked at
function Parser:Peek()
    assert(Util.IsTable(self) and self:IsA(Parser))

    if self.CurPos > self.File.Length then
        return nil
    end

    return self.File.TokensByLine[self.CurPos].Type
end

function Parser:Advance()
    assert(Util.IsTable(self) and self:IsA(Parser))

    -- Advance to end of this token, then add one to be at start of next token
    self.CurPos = self.File.TokensByLine[self.CurPos].EndPos + 1
    return self.CurPos
end

-- Find position of a closing symbol while requiring it to be depth-matched with its opening symbol
-- e.g. this will return 5 if run from line 1 with openingSymbol=IF, closingSymbol=ENDIF
--   1: IF foo
--   2:   IF bar
--   3:     print("do work")
--   4:   ENDIF
--   5: ENDIF
function Parser:FindClosingSymbol(openingSymbol, closingSymbol, assertOnFail)
    assert(Util.IsTable(self) and self:IsA(Parser))
    assert(Util.IsNumber(openingSymbol))
    assert(Util.IsNumber(closingSymbol))

    assert(Peek() == openingSymbol, "Searching for closing symbol when opening symbol didn't even match!")
    self:Advance() -- skip the opening symbol
    local originalPos = CurPos

    local result = nil
    local depthCount = 0
    while self:Peek() ~= nil do
        local symbol = self:Peek()
        if symbol == openingSymbol then
            depthCount = depthCount + 1
        elseif symbol == closingSymbol and depthCount > 0 then
            depthCount = depthCount + 1
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