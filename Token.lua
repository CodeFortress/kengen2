local Token = {}
Token.__index = Token

function Token.New(tokenType, startLine, endLine)
    local self = setmetatable({}, Token)
    self.TokenType = tokenType
    self.StartLine = startLine
    self.EndLine = endLine
    return self
end

return Token