local Settings = require("kengen2.Framework.Settings")
local Token = require("kengen2.Parser.Token")
local TokenTypes = require("kengen2.Parser.TokenTypes")
local Util = require("kengen2.Util")

local TokenizedFile = Util.ClassUtil.CreateClass("TokenizedFile", nil)

function TokenizedFile:New(path, stringsByLine, cleanStringsByLine, tokens, settings)
    assert(Util.TestUtil.IsTable(self) and self:IsA(TokenizedFile))
    assert(Util.TestUtil.IsString(path))
    assert(Util.TestUtil.IsTable(stringsByLine))
	assert(Util.TestUtil.IsTable(cleanStringsByLine))
	assert(#stringsByLine == #cleanStringsByLine)
    assert(Util.TestUtil.IsTable(tokens))
	assert(Util.TestUtil.IsTable(settings) and settings:IsA(Settings))

    local result = self:Create()
    result.Length = #stringsByLine
    result.Path = path
    result.StringsByLine = stringsByLine
	result.CleanStringsByLine = cleanStringsByLine
    result.Tokens = tokens
	result.Settings = settings
	
    result.TokensByLine = TokenizedFile.MakeTokensByLine(result.Tokens)
	
    return result
end

-- intentionally static helper
function TokenizedFile.MakeTokensByLine(tokens)
	local tokensByLine = {}
	for _, token in ipairs(tokens) do
		assert(Util.TestUtil.IsTable(token) and token:IsA(Token))
        for pos = token.StartPos, token.EndPos, 1 do
            tokensByLine[pos] = token
        end
    end
	return tokensByLine
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

function TokenizedFile:GetRawLine(pos)
	assert(Util.TestUtil.IsNumber(pos))
	assert(pos >= 1 and pos <= self.Length)
	return self.StringsByLine[pos]
end

function TokenizedFile:GetCleanLine(pos)
	assert(Util.TestUtil.IsNumber(pos))
	assert(pos >= 1 and pos <= self.Length)
	return self.CleanStringsByLine[pos]
end

return TokenizedFile