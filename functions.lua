require "__DragonIndustries__.arrays"
require "__DragonIndustries__.entities"
require "__DragonIndustries__.boxes"

function initPlayer(player)
	player.cheat_mode = true
	player.clear_items_inside()
	player.insert({name = "infinity-chest", count = 1})
	player.insert({name = "electric-energy-interface", count = 1})
	--player.insert({name = game.item_prototypes["diamond-axe"] and "diamond-axe" or "steel-axe", count = 10})
	player.insert({name = "power-armor-mk2", count = 1})
	player.insert({name = "transport-belt", count = 1})
	player.insert({name = "fast-transport-belt", count = 1})
	player.insert({name = "underground-belt", count = 1})
	player.insert({name = "splitter", count = 1})
	player.insert({name = "assembling-machine-2", count = 1})
	player.insert({name = "inserter", count = 1})
	player.insert({name = "long-handed-inserter", count = 1})
	player.insert({name = "fast-inserter", count = 1})
	player.insert({name = "small-electric-pole", count = 1})
	player.insert({name = "medium-electric-pole", count = 1})
	player.insert({name = "steel-furnace", count = 1})
	player.insert({name = "train-stop", count = 1})
	player.insert({name = "rail", count = 1})
	player.insert({name = "wooden-chest", count = 1})
	player.insert({name = "pipe", count = 1})
	player.insert({name = "pipe-to-ground", count = 1})
	player.insert({name = "storage-tank", count = 1})
	player.insert({name = "pump", count = 1})
	player.insert({name = "chemical-plant", count = 1})
	player.insert({name = "gun-turret", count = 1})
	player.insert({name = "laser-turret", count = 1})
	player.insert({name = "stone-wall", count = 1})
	
	player.insert({name = "electric-mining-drill", count = 1})
	player.insert({name = "pumpjack", count = 1})
	player.insert({name = "boiler", count = 1})
	player.insert({name = "steam-engine", count = 1})
	player.insert({name = "solar-panel", count = 1})
	player.insert({name = "lab", count = 1})
	player.insert({name = "oil-refinery", count = 1})
	player.insert({name = "radar", count = 1})
	
	player.insert({name = "red-wire", count = 200})
	player.insert({name = "green-wire", count = 200})
	player.insert({name = "automation-science-pack", count = 200})
	player.insert({name = "logistic-science-pack", count = 200})
	player.insert({name = "chemical-science-pack", count = 200})
	player.insert({name = "military-science-pack", count = 200})
	player.insert({name = "production-science-pack", count = 200})
	player.insert({name = "utility-science-pack", count = 200})
	player.insert({name = "space-science-pack", count = 200})
	
	
	player.set_quick_bar_slot(1, "transport-belt")
	player.set_quick_bar_slot(2, "fast-transport-belt")
	player.set_quick_bar_slot(3, "underground-belt")
	player.set_quick_bar_slot(4, "splitter")
	player.set_quick_bar_slot(5, "inserter")
	
	player.set_quick_bar_slot(6, game.active_mods["boblogistics"] and "fast-inserter" or "long-handed-inserter")
	player.set_quick_bar_slot(7, "assembling-machine-2")
	player.set_quick_bar_slot(8, "small-electric-pole")
	player.set_quick_bar_slot(9, "medium-electric-pole")
	player.set_quick_bar_slot(10, "steel-furnace")
	
	player.set_quick_bar_slot(11, "pipe")
	player.set_quick_bar_slot(12, "pipe-to-ground")
	player.set_quick_bar_slot(13, "storage-tank")
	player.set_quick_bar_slot(14, "pump")
	player.set_quick_bar_slot(15, "chemical-plant")
	
	player.set_quick_bar_slot(16, "rail")
	player.set_quick_bar_slot(17, "train-stop")
	player.set_quick_bar_slot(18, "gun-turret")
	player.set_quick_bar_slot(19, "laser-turret")
	player.set_quick_bar_slot(20, "stone-wall")
end

function initForce(force, full)
	if full then
		force.research_all_technologies()
		local r = Config.radius
		force.chart(game.surfaces.nauvis, {{-r, -r}, {r, r}})
		force.reset_technology_effects()
	end
	force.manual_crafting_speed_modifier = force.manual_crafting_speed_modifier+100
	force.manual_mining_speed_modifier = force.manual_mining_speed_modifier+2.5
	force.character_running_speed_modifier = force.character_running_speed_modifier+2
	force.worker_robots_speed_modifier = force.worker_robots_speed_modifier+2
	force.character_inventory_slots_bonus = force.character_inventory_slots_bonus+250
	force.character_reach_distance_bonus = force.character_reach_distance_bonus+20
	force.character_build_distance_bonus = force.character_build_distance_bonus+20
	force.character_build_distance_bonus = force.character_build_distance_bonus+20
	force.laboratory_speed_modifier = force.laboratory_speed_modifier*10
end

function getRefilledItem(entity)
	if entity.fluidbox and #entity.fluidbox > 0 and entity.fluidbox[1] then
		return {type = "fluidbox", name = entity.fluidbox[1].name, display = "fluid: " .. entity.fluidbox[1].name}
	end
	local inv = entity.get_inventory(defines.inventory.cargo_wagon)
	local items = {}
	local keys = {}
	local disp = ""
	if inv then
		for i = 1,#inv do
			local filter = inv.supports_filters() and inv.get_filter(i) or nil
			local add = nil
			if filter then
				add = filter
			elseif inv[i] and inv[i].valid_for_read then
				add = inv[i].name
			end
			if add and not listHasValue(keys, add) then
				table.insert(items, {name = add})
				table.insert(keys, add)
				disp = disp .. " & item: " .. add
			end
		end
	end
	return {type = "item", items = items, display = disp}
end