local LU = require('kengen2.ThirdParty.luaunit.luaunit')
assert(LU ~= nil)

require("kengen2.Test.Framework.Test_Iterator")
require("kengen2.Test.Parser.Test_Lexer")
require("kengen2.Test.Parser.Test_Parser")
require("kengen2.Test.Util.Test_ClassUtil")
require("kengen2.Test.Util.Test_PathUtil")
require("kengen2.Test.Util.Test_StringUtil")

require("kengen2.Test.Test_Integration")

--os.exit( LU.LuaUnit.run("Test_Integration.Test_Integration_OnAnimals") )
os.exit( LU.LuaUnit.run() )
