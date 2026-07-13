require "functions"

require "__DragonIndustries__.boxes"

local function prepareTerrain(surface)
	local r = math.floor(settings.startup["creative-radius"].value)
	game.forces.neutral.chart(surface, {{-r, -r}, {r, r}}) --generate the area
	
	for _,e in pairs(game.surfaces[1].find_entities_filtered{type = {"turret", "resource", "unit", "unit-spawner", "optimized-decorative", "simple-entity", "tree", "cliff"}}) do
		e.destroy()
	end
	
	local tiles = {}
	for x = -r,r do
		for y=-r,r do
			table.insert(tiles, {name="grass-1", position={x, y}})
		end
	end
	game.surfaces[1].set_tiles(tiles)
	
	for _,force in pairs(game.forces) do
		force.chart(surface, {{-r, -r}, {r, r}})
	end
end

local function preparePlayers()	
	for _,player in pairs(game.players) do
		initPlayer(player)
	end
	for _,force in pairs(game.forces) do
		initForce(force, true)
	end
end

local function initMap(surface)
	prepareTerrain(surface)
	preparePlayers()
end

local function addCommands()
	commands.add_command("initCreative", {"cmd.init-creative-help"}, function(event)
		if game.players[event.player_index].admin then
			game.print("EasyCreative: Initializing creative mode.")
			initMap(game.players[event.player_index].surface)
		end
	end)
	
	commands.add_command("initMap", {"cmd.init-map-help"}, function(event)
		if game.players[event.player_index].admin then
			game.print("EasyCreative: Preparing creative terrain.")
			prepareTerrain()
		end
	end)
	
	commands.add_command("initPlayer", {"cmd.init-player-help"}, function(event)
		if game.players[event.player_index].admin then
			game.print("EasyCreative: Initializing creative mode for player " .. game.players[event.player_index].name)
			initPlayer(game.players[event.player_index])
			initForce(game.players[event.player_index].force, true)
		end
	end)
end

addCommands()

script.on_load(function()

end)

script.on_nth_tick(20, function(data)	
	if #game.players > 0 then
		local player = game.players[math.random(1, #game.players)]
		if player.cheat_mode and player.character and player.character.valid then
			convertGhostsNear(player, 100)
		end
	end
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local entity = event.entity
	if event.player_index then
		local player = game.players[event.player_index]
		if player.cheat_mode then
			if entity.type ~= "item-entity" then
				local items = entity.prototype.mineable_properties.products and entity.prototype.mineable_properties.products or {}
				for _,item in pairs(items) do
					if item.type ~= "fluid" and (prototypes.item[item.name].place_result or prototypes.item[item.name].place_as_tile_result) and player.get_item_count(item.name) == 0 then
						player.insert({name = item.name, count = 1})
					end
				end
			end
			entity.destroy()
		end
	end
end)

script.on_event(defines.events.on_marked_for_upgrade, function(event)
	local entity = event.entity
	if event.player_index then
		local player = game.players[event.player_index]
		if player.cheat_mode then
			upgradeEntity(entity, player, event.target.name)
		end
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local entity = event.entity
	local player = game.players[event.player_index]
	if player.cheat_mode then
		if entity.type == "entity-ghost" then
			convertGhostToRealEntity(entity)
		elseif entity.type == "tile-ghost" then
			entity.revive()
		end
	end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
	local entity = event.entity
	local player = event.player_index and game.players[event.player_index] or nil
	if player and player.cheat_mode then
		for i = 1,#event.buffer do
			local item = event.buffer[i]
			if player.get_item_count(item.name) > 0 or not(item.prototype.place_result or item.prototype.place_as_tile_result) then
				event.buffer.remove({name = item.name, count = item.count})
			end
		end
	end
end)

script.on_event(defines.events.on_technology_effects_reset, function(event)
	local flag = false
	for _,player in pairs(event.force.players) do
		if player.cheat_mode then
			flag = true
			break
		end
	end
	if flag then
		initForce(event.force)
	end
end)

script.on_event(defines.events.on_player_selected_area, function(event)
	if event.item == "inventory-emptier" then
		local player = game.players[event.player_index]
		for _,entity in pairs(event.entities) do
			if entity.valid and entity.prototype.type ~= "character" then
				entity.clear_items_inside()
				if entity.fluidbox then
					for i = 1,#entity.fluidbox do
						entity.fluidbox[i] = nil
					end
				end
			else
				player.print("Found an invalid entity!")
			end
		end
	end
end)