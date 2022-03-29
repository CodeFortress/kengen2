local TokenizedFile = {}
TokenizedFile.__index = TokenizedFile

function TokenizedFile.New(path, stringsByLine, tokens)
    local self = setmetatable({}, TokenizedFile)
    self.Path = path
    self.StringsByLine = stringsByLine
    self.Tokens = tokens
    return self
end

function TokenizedFile:PrintDebug()
    print("--Tokens for File: "..self.Path.."--")
    for index, token in ipairs(self.Tokens) do
        print(TokenTypesToString[token.TokenType]..":"..token.StartLine.."-"..token.EndLine)
        for lineNum = token.StartLine, token.EndLine, 1 do
            print("    "..self.StringsByLine[lineNum])
        end
    end
    print("--End Tokens for File--")
end

return TokenizedFile