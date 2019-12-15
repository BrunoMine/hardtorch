--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Common Methods
  ]]


-- Play turn on torch sound
-- Tocar som de acender tocha
hardtorch.turnon_sound = function(pos, torchname)
	if hardtorch.registered_torchs[torchname].sounds.turn_on then
		minetest.sound_play(hardtorch.registered_torchs[torchname].sounds.turn_on.name, {
			pos = pos,
			max_hear_distance = 7,
			gain = hardtorch.registered_torchs[torchname].sounds.turn_on.gain,
		})
	end
end


-- Play turn off torch sound
-- Tocar som de apagar tocha
hardtorch.turnoff_sound = function(pos, torchname)
	if hardtorch.registered_torchs[torchname].sounds.turn_off then
		minetest.sound_play(hardtorch.registered_torchs[torchname].sounds.turn_off.name, {
			pos = pos,
			max_hear_distance = 7,
			gain = hardtorch.registered_torchs[torchname].sounds.turn_off.gain,
		})
	end
end


-- Play turn off torch by water sound
-- Tocar som de apagar tocha pela agua
hardtorch.turnoff_by_water_sound = function(pos, torchname)
	if hardtorch.registered_torchs[torchname].sounds.water_turn_off then
		minetest.sound_play(hardtorch.registered_torchs[torchname].sounds.water_turn_off.name, {
			pos = pos,
			max_hear_distance = 7,
			gain = hardtorch.registered_torchs[torchname].sounds.water_turn_off.gain,
		})
	end
end


-- Calculate remaining time of a node
-- Calcular tempo restante de um node
hardtorch.get_node_timeout = function(pos)
	local meta = minetest.get_meta(pos)
	local torchname = hardtorch.registered_nodes[minetest.get_node(pos).name]
	local fuel = meta:get_string("hardtorch_fuel")
	
	-- Check fuel
	if fuel == "" then fuel = hardtorch.registered_torchs[torchname].fuel[1] end
	local wear = meta:get_int("hardtorch_wear")
	local fulltime = hardtorch.registered_fuels[fuel].time
	local time = (fulltime/65535)*wear
	return fulltime-math.floor(time)
end


-- Calculate wear on a node
-- Calcular desgaste de um node
hardtorch.get_node_wear = function(pos)
	local meta = minetest.get_meta(pos)
	local fuel = meta:get_string("hardtorch_fuel")
	local torchname = hardtorch.registered_nodes[minetest.get_node(pos).name]
	
	-- Check fuel
	if fuel == "" then fuel = hardtorch.registered_torchs[torchname].fuel[1] end
	local fulltime = hardtorch.registered_fuels[fuel].time
	local timer = minetest.get_node_timer(pos)
	local time_rem = timer:get_timeout() - timer:get_elapsed()
	local wear_rem = (65535/fulltime)*time_rem
	return 65535-math.floor(wear_rem)
end


-- Update itemstack (default method 'set_stack' cannot update with an empty stack)
-- Atualiza itemstack (metodo padrão 'set_stack' não consegue atualizar com stack vazio)
hardtorch.update_inv = function(player, list, i, stack)
	local inv = player:get_inventory()
	local itemlist = inv:get_list(list)
	itemlist[i] = stack or "empty"
	inv:set_list(list, itemlist)
end


-- Check nodes near torch
-- Verificar blocos perto da tocha
hardtorch.check_node_sides = function(pos, nodes)
	for _,p in ipairs({
		{x=pos.x+1, y=pos.y, z=pos.z},
		{x=pos.x, y=pos.y+1, z=pos.z},
		{x=pos.x, y=pos.y, z=pos.z+1},
		{x=pos.x-1, y=pos.y, z=pos.z},
		{x=pos.x, y=pos.y-1, z=pos.z},
		{x=pos.x, y=pos.y, z=pos.z-1},
	}) do
		if minetest.find_nodes_in_area(p, p, nodes)[1] then
			return true
		end
	end
	return false
end


-- Find and get item on inventory
-- Busca e pega item no inventario
hardtorch.find_and_get_item = function(player, itemname)
	local inv = player:get_inventory()
	
	-- Check each list name
	for list_name,list in pairs(inv:get_lists()) do
		
		-- Check each item
		for i,item in ipairs(list) do
			if item:get_name() == itemname then
				return list_name, i, item
			end
		end
	end
end


-- Find item on inventory
-- Busca item no inventario
hardtorch.find_item = function(player, itemname)
	local inv = player:get_inventory()
	
	-- Check each list name
	for listname,list in pairs(inv:get_lists()) do
		if inv:contains_item(listname, itemname) then
			return true
		end
	end
	return false
end


-- Get torch fuel from inventory
-- Pegar combustivel de tocha no inventario
hardtorch.get_fuel_stack = function(player, torchname)
	for _,fuelname in ipairs(hardtorch.registered_torchs[torchname].fuel) do
		if hardtorch.find_item(player, fuelname) then
			return hardtorch.find_and_get_item(player, fuelname)
		end
	end
end


-- HUD element default light
-- Elemento HUD luz padrao
hardtorch.hud_element = {
	hud_elem_type = "image",
	position = {x=0.1, y=1.1},
	name = "hardtorch_light",
	scale = {x=4, y=4},
	text = "hardtorch_light.png",
	number = 2,
	item = 3,
	direction = 0,
	alignment = {x=0, y=0},
	offset = {x=0, y=0},
	size = { x=100, y=100 },
}


-- Add light on HUD
-- Adicionar luz no HUD
hardtorch.add_light_hud = function(player, torchname)
	hardtorch.in_loop[player:get_player_name()].hud_id = player:hud_add(hardtorch.hud_element)
end


-- Remove light from HUD
-- Remover luz do HUD
hardtorch.remove_light_hud = function(player)
	local name = player:get_player_name()
	if hardtorch.in_loop[name] and hardtorch.in_loop[name].hud_id then
		player:hud_remove(hardtorch.in_loop[name].hud_id)
	end
end


-- Check and correct light power
-- Verifica e corrige potencia de luz
hardtorch.check_light_number = function(n)
	if not n then
		return 1
	end
	
	if not tonumber(n) then
		return 1
	end
	
	n = math.abs(tonumber(n))
	
	if n > 14 then
		return 14
	elseif n < 1 then
		return 1
	end

	return n
end

-- Round pos
local world_limit = 100000
hardtorch.round_pos = function(pos)
	local n = { -- Negatives
		x = pos.x < 0,
		y = pos.y < 0,
		z = pos.z < 0,
	}
	local npos = vector.round(pos)
	if n.x == true and math.abs(npos.x - pos.x) == 0.5 then npos.x = npos.x - 1 end
	if n.y == true and math.abs(npos.y - pos.y) == 0.5 then npos.y = npos.y - 1 end
	if n.z == true and math.abs(npos.z - pos.z) == 0.5 then npos.z = npos.z - 1 end
	return npos
end


