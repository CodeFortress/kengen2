Kengen = require("kengen2")
settings = Kengen.Settings:New()
settings.ACCESS_STYLE_XML = false
Kengen.TranslateFile("Test/test_animals.kengen", "Test/test_animals.h", settings)