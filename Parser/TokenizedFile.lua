local TokenTypes = require("kengen2.Parser.TokenTypes")
local Util = require("kengen2.Util")

local TokenizedFile = Util.ClassUtil.CreateClass("TokenizedFile", nil)

function TokenizedFile:New(path, stringsByLine, tokens)
    assert(Util.TestUtil.IsTable(self) and self:IsA(TokenizedFile))
    assert(Util.TestUtil.IsString(path))
    assert(Util.TestUtil.IsTable(stringsByLine))
    assert(Util.TestUtil.IsTable(tokens))

    local result = self:Create()
    result.Length = #stringsByLine
    result.Path = path
    result.StringsByLine = stringsByLine
    result.Tokens = tokens
    result.TokensByLine = {}
    for _, token in ipairs(result.Tokens) do
        for pos = token.StartPos, token.EndPos, 1 do
            result.TokensByLine[pos] = token
        end
    end
    return result
end

function TokenizedFile:__tostring()
    assert(Util.TestUtil.IsTable(self) and self:IsA(TokenizedFile))
    return self.Path
end

function TokenizedFile:PrintDebug()
    print("--Tokens for File: "..self.Path.."--")
    for index, token in ipairs(self.Tokens) do
        print(TokenTypes.ToString[token.Type]..":"..token.StartPos.."-"..token.EndPos)
        for lineNum = token.StartPos, token.EndPos, 1 do
            print("    "..self.StringsByLine[lineNum])
        end
    end
    print("--End Tokens for File--")
    print("--Tokens by Pos: "..self.Path.."--")
    for lineNum, token in ipairs(self.TokensByLine) do
        print ("    "..lineNum..":"..TokenTypes.ToString[token.Type])
    end
    print("--End Tokens by Pos--")
end

return TokenizedFile