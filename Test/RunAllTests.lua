local LU = require('kengen2.ThirdParty.luaunit.luaunit')
assert(LU ~= nil)

require("kengen2.Test.Execution.Test_ExecutionState")
require("kengen2.Test.Execution.Test_FileOutputStream")
require("kengen2.Test.Execution.Test_MemoryOutputStream")
require("kengen2.Test.Execution.Test_ParsedTemplate")
require("kengen2.Test.Execution.Test_PreprocessState")

require("kengen2.Test.Framework.Test_Iterator")
require("kengen2.Test.Framework.Test_Json")
require("kengen2.Test.Framework.Test_Settings")
require("kengen2.Test.Framework.Test_Xml")

require("kengen2.Test.Parser.Test_Lexer")
require("kengen2.Test.Parser.Test_Parser")
require("kengen2.Test.Parser.Test_Token")
require("kengen2.Test.Parser.Test_TokenizedFile")
require("kengen2.Test.Parser.Test_TokenTypes")

require("kengen2.Test.Util.Test_ClassUtil")
require("kengen2.Test.Util.Test_FileUtil")
require("kengen2.Test.Util.Test_PathUtil")
require("kengen2.Test.Util.Test_StringUtil")
require("kengen2.Test.Util.Test_TableUtil")
require("kengen2.Test.Util.Test_TestUtil")

require("kengen2.Test.Test_Integration")

--os.exit( LU.LuaUnit.run("Test_Integration.Test_Integration_OnAnimals") )
os.exit( LU.LuaUnit.run() )
