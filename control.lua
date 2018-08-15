require "config"
require "functions"

function initGlobal(force)
	if not global.creative then
		global.creative = {}
	end
end

initGlobal(false)

script.on_load(function()
	
end)

script.on_init(function()
	initGlobal(true)
end)

script.on_configuration_changed(function()
	initGlobal(true)
end)

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
end

local function preparePlayers()	
	for _,player in pairs(game.players) do
		initPlayer(player)
	end
	for _,force in pairs(game.forces) do
		initForce(force)
	end
end

local function initMap()
	prepareTerrain()
	preparePlayers()
end

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
	
	if #game.players > 0 then
		local player = game.players[math.random(1, #game.players)]
		if player.cheat_mode then
			convertGhostsNear(player)
		end
	end
end)

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
		initForce(game.players[event.player_index].force)
	end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	initPlayer(game.players[event.player_index])
	initForce(game.players[event.player_index].force)
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local entity = event.entity
	if event.player_index then
		local player = game.players[event.player_index]
		if player.cheat_mode then
			local items = entity.prototype.mineable_properties.products and entity.prototype.mineable_properties.products or {}
			for _,item in pairs(items) do
				if item.type ~= "fluid" and player.get_item_count(item.name) == 0 then
					player.insert({name = item.name, count = 1})
				end
			end
		end
	end
	entity.destroy()
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
	local player = game.players[event.player_index]
	if player.cheat_mode then
		for i = 1,#event.buffer do
			local item = event.buffer[i]
			if player.get_item_count(item.name) > 0 then
				event.buffer.remove({name = item.name, count = item.count})
			end
		end
	end
end)