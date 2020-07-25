require "config"
require "functions"

function initGlobal(force)
	if not global.creative then
		global.creative = {}
	end
	
	if not global.creative.cachedRefills then
		global.creative.cachedRefills = {}
	end
end

initGlobal(false)

local function prepareTerrain()
	local r = Config.radius
	game.forces.neutral.chart(game.surfaces.nauvis, {{-r, -r}, {r, r}}) --generate the area
	
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
		local r = Config.radius
		force.chart(game.surfaces.nauvis, {{-r, -r}, {r, r}})
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

local function initMap()
	prepareTerrain()
	preparePlayers()
end

local function addCommands()
	commands.add_command("initCreative", {"cmd.init-creative-help"}, function(event)
		if game.players[event.player_index].admin then
			game.print("EasyCreative: Initializing creative mode.")
			initMap()
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
	
	commands.add_command("refill", {"cmd.refill-help"}, function(event)
		if game.players[event.player_index].admin then
			local entity = game.players[event.player_index].selected
			if entity then
				local item = getRefilledItem(entity)
				if item then
					game.print("EasyCreative: Marking entity " .. entity.name .. " @ " .. entity.position.x .. ", " .. entity.position.y .. " for refill with " .. item.display)
					table.insert(global.creative.cachedRefills, {entity = entity, item = item})
				else
					game.print("EasyCreative: Entity is empty!")
				end
			else
				game.print("EasyCreative: No entity selected!")
			end
		end
	end)
	
	commands.add_command("fillTrain", {"cmd.fill-train-help"}, function(event)
		if game.players[event.player_index].admin then
			local entity = game.players[event.player_index].selected
			if entity and (entity.type == "cargo-wagon" or entity.type == "fluid-wagon" or entity.type == "locomotive") then
				local item = event.parameter
				if item and game.item_prototypes[item] then
					game.print("EasyCreative: Filling train with " .. item)
					for _,car in pairs(entity.train.carriages) do
						if car.type == "cargo-wagon" then
							local inv = car.get_inventory(defines.inventory.cargo_wagon)
							inv.insert({name = item, count = 1000000})
						end
					end
				else
					game.print("EasyCreative: No item specified!")
				end
			else
				game.print("EasyCreative: No train entity selected!")
			end
		end
	end)
	
	commands.add_command("emptyTrain", {"cmd.empty-train-help"}, function(event)
		if game.players[event.player_index].admin then
			local entity = game.players[event.player_index].selected
			if entity and (entity.type == "cargo-wagon" or entity.type == "fluid-wagon" or entity.type == "locomotive") then
				game.print("EasyCreative: Clearing train")
				for _,car in pairs(entity.train.carriages) do
					if car.type == "cargo-wagon" then
						local inv = car.get_inventory(defines.inventory.cargo_wagon)
						inv.clear()
						for i,e in ipairs(global.creative.cachedRefills) do
							if e.entity == car then
								table.remove(global.creative.cachedRefills, i)
							end
						end
					end
				end
			else
				game.print("EasyCreative: No train entity selected!")
			end
		end
	end)
end

addCommands()

script.on_load(function()

end)

--[[
script.on_event(defines.events.on_console_command, function(event)
	if event.command == "c" and string.find(event.parameters, "initCreative") then
		game.print("EasyCreative: Initializing creative mode.")
		initMap()
	end
	if event.command == "c" and string.find(event.parameters, "initMap") then
		game.print("EasyCreative: Preparing creative terrain.")
		prepareTerrain()
	end
	if event.command == "c" and event.player_index and string.find(event.parameters, "initPlayer") then
		game.print("EasyCreative: Initializing creative mode for player " .. game.players[event.player_index].name)
		initPlayer(game.players[event.player_index])
		initForce(game.players[event.player_index].force, true)
	end
	if event.command == "c" and string.find(event.parameters, "refill") then
		local entity = game.players[event.player_index].selected
		if entity then
			local item = getRefilledItem(entity)
			if item then
				game.print("EasyCreative: Marking entity " .. entity.name .. " @ " .. entity.position.x .. ", " .. entity.position.y .. " for refill with " .. item.display)
				table.insert(global.creative.cachedRefills, {entity = entity, item = item})
			else
				game.print("EasyCreative: Entity is empty!")
			end
		else
			game.print("EasyCreative: No entity selected!")
		end
	end
end)
--]]

script.on_init(function()
	initGlobal(true)
end)

script.on_configuration_changed(function()
	initGlobal(true)
end)

local function convertGhostsNear(player)
	local ghosts = player.surface.find_entities_filtered{type = {"entity-ghost", "tile-ghost"}, area = box}
	for _,entity in pairs(ghosts) do
		if entity.type == "entity-ghost" then
			convertGhostToRealEntity(player, entity)
		elseif entity.type == "tile-ghost" then
			entity.revive()
		end
	end
end

script.on_event(defines.events.on_tick, function(event)
	if event.tick%20 ~= 0 then return end
	
	local creative = global.creative
	
	if #game.players > 0 then
		local player = game.players[math.random(1, #game.players)]
		if player.cheat_mode then
			convertGhostsNear(player)
		end
	end
	
	if event.tick%120 == 0 and creative.cachedRefills and #creative.cachedRefills > 0 then
		for i,entry in ipairs(creative.cachedRefills) do
			if entry.entity.valid then
				if entry.item.items and entry.item.type ~= "fluidbox" then
					for _,item in pairs(entry.item.items) do
						entry.entity.insert({name = item.name, count = 1000000})
					end
				else
					local item = entry.item
					if item.type == "item" then
						entry.entity.insert({name = item.name, count = 1000000})
					else
						entry.entity.fluidbox[1] = {name = item.name, amount = 1000000}
					end
				end
			else
				table.remove(creative.cachedRefills, i)
			end
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
					if item.type ~= "fluid" and (game.item_prototypes[item.name].place_result or game.item_prototypes[item.name].place_as_tile_result) and player.get_item_count(item.name) == 0 then
						player.insert({name = item.name, count = 1})
					end
				end
				--script.raise_event(defines.events.on_pre_player_mined_item, {entity=entity, player_index=event.player_index, tick=game.tick, name="on_pre_player_mined_item", creative=true, buffer = {}})
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
			local repl = event.target.name
			local pos = entity.position
			local force = entity.force
			local dir = entity.direction
			--entity.destroy()
			local surf = entity.surface
			surf.create_entity{name = repl, position = pos, force = force, direction = dir, player = player, 	fast_replace = true}
		end
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local entity = event.created_entity
	local player = game.players[event.player_index]
	if player.cheat_mode then
		if entity.type == "entity-ghost" then
			convertGhostToRealEntity(player, entity)
		elseif entity.type == "tile-ghost" then
			entity.revive()
		elseif event.stack then --is nil for blueprints
			player.insert({name = event.stack.name, count = 1})
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