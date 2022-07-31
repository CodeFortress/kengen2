local LU = require('kengen2.ThirdParty.luaunit.luaunit')
local Iterator = require("kengen2.Framework.Iterator")

local BasicDatabase = {}
BasicDatabase["cards"] = {}
BasicDatabase["cards"][1] = { Name = "Lightning Bolt", CMC = 1 }
BasicDatabase["cards"][2] = { Name = "Giant Growth", CMC = 1 }
BasicDatabase["cards"][3] = { Name = "Divination", CMC = 3 }
BasicDatabase["cards"][4] = { Name = "Grizzly Bears", CMC = 2 }
BasicDatabase["cards"][5] = { Name = "Hill Giant", CMC = 4 }
BasicDatabase["cards"][6] = { Name = "Gray Ogre", CMC = 3 }
BasicDatabase["cards"][7] = { Name = "Lightning Strike", CMC = 2 }
BasicDatabase["cards"][8] = { Name = "Control Magic", CMC = 4 }

Test_Iterator = {}

function Test_Iterator:Test_Class_Make()
	local iterator = Iterator:New(BasicDatabase.cards, nil, nil)
	local n = 1
	for card in iterator:Make_Iterator() do
		LU.assertEquals(card.Name, BasicDatabase.cards[n].Name)
		n = n + 1
	end
end

function Test_Iterator:Test_Class_Filtering()
	local function SampleFilterFunc(card)
		return card.CMC > 2
	end

	local iterator = Iterator:New(BasicDatabase.cards, SampleFilterFunc, nil)
	local count = 0
	for card in iterator:Make_Iterator() do
		LU.assertTrue(card.CMC > 2)
		count = count + 1
	end
	LU.assertEquals(count, 4)
end

function Test_Iterator:Test_Class_Sorting()
	local function SampleSortFunc(card1, card2)
		if card1.CMC < card2.CMC then
			return true
		elseif card1.CMC > card2.CMC then
			return false
		end
		return card1.Name < card2.Name
	end

	local iterator = Iterator:New(BasicDatabase.cards, nil, SampleSortFunc)
	local index = 0
	for card in iterator:Make_Iterator() do
		index = index + 1
		if index == 1 then
			LU.assertEquals(card.Name, "Giant Growth")
		elseif index == 2 then
			LU.assertEquals(card.Name, "Lightning Bolt")
		elseif index == 3 then
			LU.assertEquals(card.Name, "Grizzly Bears")
		elseif index == 4 then
			LU.assertEquals(card.Name, "Lightning Strike")
		elseif index == 5 then
			LU.assertEquals(card.Name, "Divination")
		elseif index == 6 then
			LU.assertEquals(card.Name, "Gray Ogre")
		elseif index == 7 then
			LU.assertEquals(card.Name, "Control Magic")
		elseif index == 8 then
			LU.assertEquals(card.Name, "Hill Giant")
		end
	end
	LU.assertEquals(index, 8)
end

return Test_Iterator