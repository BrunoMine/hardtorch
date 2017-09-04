--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodos comuns
	
  ]]


-- Tocar som de acender tocha
hardtorch.som_acender = function(pos, torchname)
	if hardtorch.registered_torchs[torchname].sounds.turn_on then
		minetest.sound_play(hardtorch.registered_torchs[torchname].sounds.turn_on.name, {
			pos = pos,
			max_hear_distance = 7,
			gain = hardtorch.registered_torchs[torchname].sounds.turn_on.gain,
		})
	end
end


-- Tocar som de apagar tocha
hardtorch.som_apagar = function(pos, torchname)
	if hardtorch.registered_torchs[torchname].sounds.turn_off then
		minetest.sound_play(hardtorch.registered_torchs[torchname].sounds.turn_off.name, {
			pos = pos,
			max_hear_distance = 7,
			gain = hardtorch.registered_torchs[torchname].sounds.turn_off.gain,
		})
	end
end


-- Tocar som de apagar tocha pela agua
hardtorch.som_apagar_por_agua = function(pos, torchname)
	if hardtorch.registered_torchs[torchname].sounds.water_turn_off then
		minetest.sound_play(hardtorch.registered_torchs[torchname].sounds.water_turn_off.name, {
			pos = pos,
			max_hear_distance = 7,
			gain = hardtorch.registered_torchs[torchname].sounds.water_turn_off.gain,
		})
	end
end


-- Calcular tempo restante de um node
hardtorch.get_node_timeout = function(pos)
	local meta = minetest.get_meta(pos)
	local torchname = hardtorch.registered_nodes[minetest.get_node(pos).name]
	local fuel = meta:get_string("hardtorch_fuel")
	-- Verifica combustivel
	if fuel == "" then fuel = hardtorch.registered_torchs[torchname].fuel[1] end
	local wear = meta:get_int("hardtorch_wear")
	local fulltime = hardtorch.registered_fuels[fuel].time
	local time = (fulltime/65535)*wear
	return fulltime-math.floor(time)
end

-- Calcular desgaste de um node
hardtorch.get_node_wear = function(pos)
	local meta = minetest.get_meta(pos)
	local fuel = meta:get_string("hardtorch_fuel")
	local torchname = hardtorch.registered_nodes[minetest.get_node(pos).name]
	-- Verifica combustivel
	if fuel == "" then fuel = hardtorch.registered_torchs[torchname].fuel[1] end
	local fulltime = hardtorch.registered_fuels[fuel].time
	local timer = minetest.get_node_timer(pos)
	local time_rem = timer:get_timeout() - timer:get_elapsed()
	local wear_rem = (65535/fulltime)*time_rem
	return 65535-math.floor(wear_rem)
end


-- Atualizar um itemstack no inventario do jogador 
-- (metodo padrão set_stack() não consegue atualizar com stack vazio)
hardtorch.update_inv = function(player, list, i, stack)
	local inv = player:get_inventory()
	local itemlist = inv:get_list(list)
	itemlist[i] = stack or "empty"
	inv:set_list(list, itemlist)
end


-- Verificar impedimento no local proximo da tocha
hardtorch.check_torch_area = function(pos)
	for _,p in ipairs({
		{x=pos.x+1, y=pos.y, z=pos.z},
		{x=pos.x, y=pos.y+1, z=pos.z},
		{x=pos.x, y=pos.y, z=pos.z+1},
		{x=pos.x-1, y=pos.y, z=pos.z},
		{x=pos.x, y=pos.y-1, z=pos.z},
		{x=pos.x, y=pos.y, z=pos.z-1},
	}) do
		if minetest.find_nodes_in_area(p, p, {"group:water"})[1] then
			return false
		end
	end
	return true
end


-- Encontrar tocha acessa no inventario
hardtorch.find_and_get_item = function(player, itemname)
	local inv = player:get_inventory()
	-- Verifica cada um dos itens
	for list_name,list in pairs(inv:get_lists()) do
		for i,item in ipairs(list) do
			-- Troca pela tocha apagada
			if item:get_name() == itemname then
				return list_name, i, item
			end
		end
	end
end


-- Encontrar tocha acessa no inventario
hardtorch.find_item = function(player, itemname)
	local inv = player:get_inventory()
	-- Verifica em todas listas de inventario
	for listname,list in pairs(inv:get_lists()) do
		if inv:contains_item(listname, itemname) then
			return true
		end
	end
	return false
end


-- Pegar combustivel no inventario de um jogador
hardtorch.get_fuel_stack = function(player, torchname)
	for _,fuelname in ipairs(hardtorch.registered_torchs[torchname].fuel) do
		if hardtorch.find_item(player, fuelname) then
			return hardtorch.find_and_get_item(player, fuelname)
		end
	end
end


-- Elemento HUD luz padrao
hardtorch.hud_element = {
	hud_elem_type = "image",
	position = {x=0.1, y=1.1},
	name = "hardtorch_luz",
	scale = {x=4, y=4},
	text = "hardtorch_luz.png",
	number = 2,
	item = 3,
	direction = 0,
	alignment = {x=0, y=0},
	offset = {x=0, y=0},
	size = { x=100, y=100 },
}


-- Adicionar luz do hud
hardtorch.adicionar_luz_hud = function(player, torchname)
	hardtorch.em_loop[player:get_player_name()].hud_id = player:hud_add(hardtorch.hud_element)
end


-- Remover luz do hud
hardtorch.remover_luz_hud = function(player)
	local name = player:get_player_name()
	if hardtorch.em_loop[name] and hardtorch.em_loop[name].hud_id then
		player:hud_remove(hardtorch.em_loop[name].hud_id)
	end
end





