function initPlayer(player)
	player.cheat_mode = true
	player.clear_items_inside()
	player.insert({name = "infinity-chest", count = 1})
	player.insert({name = "electric-energy-interface", count = 1})
	player.insert({name = game.item_prototypes["diamond-axe"] and "diamond-axe" or "steel-axe", count = 10})
	player.insert({name = "power-armor-mk2", count = 1})
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

function convertGhostToRealEntity(player, ghost)
	local modules = ghost.item_requests
	local _,repl = ghost.revive()
	
	if repl and repl.valid then
		for module, amt in pairs(modules) do
			repl.insert({name=module, count = amt})
		end
		
		script.raise_event(defines.events.on_put_item, {position=repl.position, player_index=player.index, shift_build=false, built_by_moving=false, direction=repl.direction, revive=true})
		script.raise_event(defines.events.on_built_entity, {created_entity=repl, player_index=player.index, tick=game.tick, name="on_built_entity", revive=true})
	end
end

function getRefilledItem(entity)
	if entity.fluidbox and #entity.fluidbox > 0 and entity.fluidbox[1] then
		return {type = "fluidbox", name = entity.fluidbox[1].name, display = "fluid: " .. entity.fluidbox[1].name}
	end
	local inv = entity.get_inventory(defines.inventory.cargo_wagon)
	if inv then
		for i = 1,#inv do
			if inv[i] and inv[i].valid_for_read then
				return {type = "item", name = inv[i].name, display = "item: " .. inv[i].name}
			end
		end
	end
	return nil
end