require "__DragonIndustries__.arrays"
require "__DragonIndustries__.entities"
require "__DragonIndustries__.boxes"

local function setQuickbarSlotIfEmpty(player, slot, item)
	if player.get_quick_bar_slot(slot) == nil then
		player.set_quick_bar_slot(slot, item)
	end
end

function initPlayer(player)
	player.cheat_mode = true
	player.clear_items_inside()
	player.insert({name = "infinity-chest", count = 1})
	player.insert({name = "infinity-pipe", count = 1})
	player.insert({name = "electric-energy-interface", count = 1})
	player.insert({name = "heat-interface", count = 1})
	
	player.insert({name = "mech-armor", count = 1})
	player.insert({name = "submachine-gun", count = 1})
	player.insert({name = "flamethrower", count = 1})
	player.insert({name = "rocket-launcher", count = 1})

	player.insert({name = "transport-belt", count = 1})
	player.insert({name = "fast-transport-belt", count = 1})
	player.insert({name = "express-transport-belt", count = 1})
	player.insert({name = "turbo-transport-belt", count = 1})
	player.insert({name = "underground-belt", count = 1})
	player.insert({name = "fast-underground-belt", count = 1})
	player.insert({name = "express-underground-belt", count = 1})
	player.insert({name = "turbo-underground-belt", count = 1})
	player.insert({name = "splitter", count = 1})
	player.insert({name = "fast-splitter", count = 1})
	player.insert({name = "express-splitter", count = 1})

	player.insert({name = "inserter", count = 1})
	player.insert({name = "long-handed-inserter", count = 1})
	player.insert({name = "fast-inserter", count = 1})
	player.insert({name = "bulk-inserter", count = 1})
	player.insert({name = "stack-inserter", count = 1})

	player.insert({name = "pipe", count = 1})
	player.insert({name = "pipe-to-ground", count = 1})
	player.insert({name = "storage-tank", count = 1})
	player.insert({name = "pump", count = 1})

	player.insert({name = "assembling-machine-2", count = 1})
	player.insert({name = "assembling-machine-3", count = 1})
	player.insert({name = "chemical-plant", count = 1})
	player.insert({name = "oil-refinery", count = 1})

	player.insert({name = "small-electric-pole", count = 1})
	player.insert({name = "medium-electric-pole", count = 1})

	player.insert({name = "train-stop", count = 1})
	player.insert({name = "rail", count = 1})

	player.insert({name = "wooden-chest", count = 1})	
	player.insert({name = "radar", count = 1})

	player.insert({name = "gun-turret", count = 1})
	player.insert({name = "laser-turret", count = 1})
	player.insert({name = "stone-wall", count = 1})
	
	player.insert({name = "electric-mining-drill", count = 1})
	player.insert({name = "pumpjack", count = 1})
	
	--[[
	player.insert({name = "automation-science-pack", count = 200})
	player.insert({name = "logistic-science-pack", count = 200})
	player.insert({name = "chemical-science-pack", count = 200})
	player.insert({name = "military-science-pack", count = 200})
	player.insert({name = "production-science-pack", count = 200})
	player.insert({name = "utility-science-pack", count = 200})
	player.insert({name = "space-science-pack", count = 200})
	--]]
	
	setQuickbarSlotIfEmpty(player, 1, "transport-belt")
	setQuickbarSlotIfEmpty(player, 2, "underground-belt")
	setQuickbarSlotIfEmpty(player, 3, "splitter")
	setQuickbarSlotIfEmpty(player, 4, "inserter")
	setQuickbarSlotIfEmpty(player, 5, "long-handed-inserter")
	
	setQuickbarSlotIfEmpty(player, 6, "fast-inserter")
	setQuickbarSlotIfEmpty(player, 7, "bulk-inserter")
	setQuickbarSlotIfEmpty(player, 8, "assembling-machine-2")
	setQuickbarSlotIfEmpty(player, 9, "small-electric-pole")
	setQuickbarSlotIfEmpty(player, 10, "medium-electric-pole")
	setQuickbarSlotIfEmpty(player, 11, "steel-furnace")
	
	setQuickbarSlotIfEmpty(player, 11, "pipe")
	setQuickbarSlotIfEmpty(player, 12, "pipe-to-ground")
	setQuickbarSlotIfEmpty(player, 13, "storage-tank")
	setQuickbarSlotIfEmpty(player, 14, "pump")
	setQuickbarSlotIfEmpty(player, 15, "chemical-plant")
	
	setQuickbarSlotIfEmpty(player, 16, "rail")
	setQuickbarSlotIfEmpty(player, 17, "train-stop")
	setQuickbarSlotIfEmpty(player, 18, "gun-turret")
	setQuickbarSlotIfEmpty(player, 19, "laser-turret")
	setQuickbarSlotIfEmpty(player, 20, "stone-wall")
end

function initForce(force, full)
	if full then
		force.research_all_technologies()
		local r = settings.startup["creative-radius"].value
		force.chart(game.surfaces.nauvis, {{-r, -r}, {r, r}})
		force.reset_technology_effects()
	end
	force.manual_crafting_speed_modifier = 100
	force.manual_mining_speed_modifier = 5
	force.character_running_speed_modifier = 5
	force.worker_robots_speed_modifier = 20
	force.character_inventory_slots_bonus = 250
	force.character_reach_distance_bonus = 20
	force.character_build_distance_bonus = 20
	force.character_build_distance_bonus = 20
	force.laboratory_speed_modifier = 100
end