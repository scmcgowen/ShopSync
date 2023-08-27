-- ShopSync is a standard for shops and "sellshops" to broadcast data in order to improve consumer price discovery and user experience.
-- Shops, optionally, can abstain from broadcasting information if they are completely out-of-stock.
-- Note: Broadcasting any false or incorrect data is against Rule 1.5. Shops should not broadcast data if they are not connected to a currency network or are inoperable for any other reason. The intent of ShopSync was not for shops to automatically adjust their own prices based on other shops' prices, considering the current lack of any technical protections against falsified data.
-- This standard is presented as an example table, with comments explaining the fields. Everything that is not specifically "optional" or saying "can be set to nil" is required. Note that "set to nil" can also mean "not set".
-- Shops which support this standard and actively broadcast their information can optionally display "ShopSync supported", "ShopSync-compatible", etc. on monitors
-- Shops should broadcast a Lua table like this on channel 9773 in the situations presented. 
-- The modem return channel should be the computer ID of the shop turtle/computer modulo 65536. This is for backwards compatibility purposes and data receivers should ignore it if the computerID field is present.
-- Any timespans (such as seconds) noted should be governed by os.clock and os.startTimer
-- Situation 1: Shops should broadcast once, `math.random() * 15 + 15` seconds after bootup (so within the range of 15 to 30 seconds)
-- Situation 2: Shops should broadcast after a shop session or purchase is fully completed. Shops should also broadcast after the items for sale or the stocks available are changed. Optionally, shops may opt to not do this broadcast for stock changes if the stock change is part of an automatic process that runs regularly and not a shop owner manually inserting items (for example, a farm supplying a shop). Shops should enforce a 30-second minimum interval between broadcasts while still ensuring that information within broadcasts is up-to-date as of the time at which it is broadcasted. For example, if a shop receives a purchase, sends a broadcast, and then receives another purchase within 5 seconds, it should defer/queue the broadcast to 25 seconds later, unless a broadcast is already queued. The broadcast 25 seconds later should use data gathered at the time of the broadcast being sent, not at the time of it being queued.
-- Data senders using legacy code or outdated practices may also broadcast once every 30 seconds, so data receivers should also be able to handle this situation.
-- The ShopSync standard is currently located at both https://p.sc3.io/7Ae4KxgzAM and https://gist.github.com/Kan18/916e265fe30fac450fa69da1d6c10eec 
-- Version: v1.1, 2023-07-03
{
	type = "ShopSync", -- Keep this the same
	info = { -- Contains general info about the shop
		name = "6_4's Shop", -- Name of shop. This is required.
		description = "Shop focused on selling common materials and items.", -- Optional. Brief description of shop. Try not to include anything already provided in other information fields. Can be generic (e.g. "shop selling items")
		owner = "6_4", -- Optional. Should be Minecraft username or other username that can help users easily identify shop owner
		computerID = 272, -- Should be the ID of the computer or turtle running the shop. If multiple turtles or computers are involved, choose whichever one is calling modem.transmit for ShopSync. Data receivers can differentiate between unique shops using the computerID and multiShop fields. If the computerID field is not set, then data receivers should check the reply channel and use that as the computer ID.
		multiShop = nil, -- If a single computer/turtle is operating multiple shops, it should assign permanent unique integer IDs to each shop. This is so that shops can be differentiated if multiple shops run on the same computer ID. This can also apply if a single computer/turtle is running both a shop and a reverse shop. Shops for which this does not apply should set this to nil.
		software = { -- Optional
			name = "swshop", -- Optional. Name of shop software
			version = "3150525" -- Optional. Can be anything human-readable: compile date, git commit shorthash, version number, etc
		},
		location = { -- Optional
			coordinates = { 138, 75, 248 }, -- Optional table of {x, y, z}. Should be location near shop (where items dispense, or place where monitor is visible from). Can also be automatically determined via modem GPS, if the location is not provided in the shop configuration.
			description = "North of spawn, just outside Immediate Spawn Area.", -- Optional. Description of location
			dimension = "overworld" -- "overworld", "nether", or "end". Optional, but include this if you are including a location.
		},
		otherLocations = { -- If the shop has additional locations, *pulling from the same stock/items*, this table can contain other locations in a similar format to the location table. If not, set this to nil or an empty table.
			{
				coordinates = { 51, 63, -475 },
				description = "Near entrance of town.",
				dimension = "nether"
			}
		}
		
	},
	items = { -- List of items/offers the shop contains. Shops can contain multiple listings for the same item with different prices and stocks, where the item stocks should be separate (e.g. selling 100 diamonds for 10 kst and 200 diamonds for 15 kst). Shops can broadcast out-of-stock listings (where the stock = 0); ideally, they should do so based on whether the listings display on the shop monitor.
		{ -- This shows an example entry for a normal shop listing. Reverse shop listings should follow the format of the next example entry.
			prices = { -- List of tables describing price/currency/address combinations that apply to the listing
				{
					value = 100, -- Price, in specified currency. Price can be 0 if item is for free. In that case, currency can be ignored by data readers and can be set to nil.
					currency = "KST", -- IMPORTANT; ALL DATA READERS SHOULD CHECK THIS! Currency of price. Shops should specify known currencies, such as "KST" (regular Krist, krist.dev) or "TST" (Tenebra, tenebra.lil.gay).
					address = "dia@64.kst", -- Address which shop users should pay to. Shops which require interaction should still set this to the address that users will pay to.
					requiredMeta = "sussy" -- Optional: Metadata which shop users need to include in the transaction. The intent is for it to be something like `/pay <address> <amnt> <requiredMeta>` being the necessary command to execute for shop users on kristpay. This should not include anything that can go in the `address` field.
				} -- Shops which have the same listing in multiple currencies can add more tables to the 'prices' list
			},
			item = { -- Table describing item
				name = "minecraft:diamond", -- name of item as given in list()
				nbt = nil, -- if an item has an NBT hash given in list(), include it here; else, leave this nil
				displayName = "Diamond" -- display name of item; this is recommended to be similar to the displayName given in getItemDetail, but shops can change this if necessary. Ideally it should be the name shown in the shop interface.
			},
			dynamicPrice = false, -- Also applicable to reverse shops: If dynamicPrice is false or nil, then the full stock is available for the specified price. If it is true, then only the first item bought is guaranteed to be available for the specified price, and future items bought/sold may be at a higher or lower price due to slippage.
			stock = 100, -- Availability of this item, as an amount of items. This may be set to `nil` if `madeOnDemand` is true 
			madeOnDemand = false, -- If shops do not dispense the item immediately after payment, and instead produce it on demand, set this to true. If not applicable, set to false or nil.
			requiresInteraction = false -- A shop listing requires interaction if users need to click on a monitor, etc. (or do something OTHER than the /pay command) to get an item. Listings for which this does not apply can have this set to false or nil. To be clear, shops which need monitor clicks to display an address, but would accept payments to the address even if it was not selected through the monitor, can also set this to false or nil. This option only matters for normal shop listings, not "reverse shop" listings.
		},
		{ -- This shows an example entry for a reverse shop ("sellshop"). Shops which give items to the user should see the first example entry.
			shopBuysItem = true, -- ALL DATA READERS MUST CHECK THIS FLAG! "Reverse shop listings" are for shops which accept items from a player and give Krist in exchange. These are also called "sellshops" / "pawnshops". Reverse shop listings should set this to true. Shop listings for which this does not apply can set this to false or nil.
			prices = { -- Table of tables describing price(s) (in different currencies) that the reverse shop will pay for an item
				{
					value = 10,
					currency = "KST"
				}
			},
			item = { -- Table describing item: see above
				name = "minecraft:gold_ingot",
				nbt = nil,
				displayName = "Gold Ingot"
			},
			stock = 100, -- Current limit on amount of this item the reverse shop is willing to accept. If there is no specific item limit, shops should get the current balance, divide by the price, and round down (also see the noLimit option)
			noLimit = false -- If the reverse shop listing has no limit, set this to true. In this case, a shop is willing to accept more items than it can actually pay out for. If not applicable, set to false/nil. This would usually be false/nil when dynamicPrice is true.
		},
	}
}