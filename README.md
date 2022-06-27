# kengen2
kengen is a framework for generating code using Lua, that supports a gsl-like syntax.

Installation:
* Download kengen2 and put it wherever is convenient
* Add the following to your LUA_PATH environment variable:
** Linux:
*** /one/level/above/kengen2/?.lua
*** /one/level/above/kengen2/?/init.lua
** Windows:
*** C:\one\level\above\kengen2\?.lua
*** C:\one\level\above\kengen2\?\init.lua
* Make sure you did one level ABOVE kengen2! "kengen2" should not actually appear in your LUA_PATH

Installation Verification:
* Navigate into your kengen2 directory and then run Test/RunAllTests.lua
** For example, if you're using Windows + ZeroBraneStudio + gitbash:
*** cd ~/Workspace/lua/kengen2
*** ~/Downloads/ZeroBraneStudio/bin/lua.exe Test/RunAllTests.lua