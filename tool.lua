--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Ferramenta para desgaste
	
  ]]


-- Encontrar tocha acessa no inventario
local find_torch_inv = function(player)
	local inv = player:get_inventory()
	-- Verifica cada um dos itens
	for list_name,list in pairs(inv:get_lists()) do
		for i,item in ipairs(list) do
			-- Troca pela tocha apagada
			if item:get_name() == "hardtorch:torch_tool_on" then
				return list_name, i, item
			end
		end
	end
end

-- Apaga todas as tochas que um jogador possui
hardtorch.apagar_tocha = function(player)
	-- Remover luz do hud
	if hardtorch.em_loop[player:get_player_name()] and hardtorch.em_loop[player:get_player_name()].hud_id then
		player:hud_remove(hardtorch.em_loop[player:get_player_name()].hud_id)
	end
	local inv = player:get_inventory()
	-- Verifica cada um dos itens
	for _,list in pairs(inv:get_lists()) do
		for i,item in ipairs(list) do
			-- Troca pela tocha apagada
			if item:get_name() == "hardtorch:torch_tool_on" then
				item:set_name("hardtorch:torch_tool")
				inv:set_stack("main", i, item)
			end
		end
	end
end


-- Elemento HUD luz
local hud_element = {
	hud_elem_type = "image",
	position = {x=0.1, y=1.1},
	name = "<name>",
	scale = {x=4, y=4},
	text = "hardtorch_luz.png",
	number = 2,
	item = 3,
	direction = 0,
	alignment = {x=0, y=0},
	offset = {x=0, y=0},
	size = { x=100, y=100 },
}


-- Inicia loop de verificação apos acender tocha
local desgaste_loop = (65535/hardtorch.tempo_tocha)*2
hardtorch.loop_tocha = function(name)
	-- Verifica se ja iniciou loop
	if not hardtorch.em_loop[name] then return end
	-- Verifica jogador
	local player = minetest.get_player_by_name(name)
	if not player then return end
	
	-- Verifica tocha
	local list, i, itemstack = find_torch_inv(player)
	if not itemstack then
		-- Encerra loop
		hardtorch.apagar_tocha(player)
		hardtorch.em_loop[name] = nil
		return
	end
	-- Adiciona desgaste
	itemstack:add_wear(desgaste_loop)
	player:get_inventory():set_stack(list, i, itemstack)
	
	-- Verifica se acabou a tocha
	if itemstack:is_empty() then
		-- Encerra loop
		hardtorch.apagar_tocha(player)
		hardtorch.em_loop[name] = nil
		return
	end
	
	-- Verifica se luz do hud foi criada
	if not hardtorch.em_loop[name].hud_id 
		or not player:hud_get(hardtorch.em_loop[name].hud_id)
	then
		hardtorch.em_loop[name].hud_id = player:hud_add(hud_element)
	end
	
	
	-- Prepara para proximo loop
	minetest.after(2, hardtorch.loop_tocha, name)
end


-- Acender tocha
hardtorch.acender_tocha = function(itemstack, player)
	local name = player:get_player_name()
	itemstack:set_name("hardtorch:torch_tool_on")
	itemstack:add_wear(100)
	
	-- Verifica se ja esta acessa (evitar loop duplo)
	if not hardtorch.em_loop[name] then 
		hardtorch.em_loop[name] = {lpos=hardtorch.get_lpos(player)}
		-- Adiciona luz no hud
		hardtorch.em_loop[name].hud_id = player:hud_add(hud_element)
		-- Inicia loop de tocha (atraso para dar tempo de atualizar item no inventario)
		minetest.after(0.3, hardtorch.loop_tocha, name)
		-- Inicia loop de luz
		hardtorch.loop_luz(name)
	end
	
	return itemstack
end


-- Ferramenta de tocha para desgaste
minetest.register_tool("hardtorch:torch_tool", {
	description = "Tocha",
	inventory_image = "hardtorch_torch_tool_off.png",
	groups = {not_in_creative_inventory = 1},
	
	on_use = function(itemstack, user, pointed_thing)
		return hardtorch.acender_tocha(itemstack, user)
	end,
	
	-- Ao colocar funciona como tocha normal apenas repassando o desgaste
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		
		local under = pointed_thing.under
		local above = pointed_thing.above
		local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
		local fakestack = itemstack
		local wear = itemstack:get_wear()
		
		if wdir == 0 then
			fakestack:set_name("default:torch_ceiling")
		elseif wdir == 1 then
			fakestack:set_name("default:torch")
		else
			fakestack:set_name("default:torch_wall")
		end
		
		itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		
		-- Repassa desgaste
		local meta = minetest.get_meta(pointed_thing.above)
		meta:set_int("wear", wear)
		
		-- Remove item do inventario
		itemstack:clear()
		
		return itemstack
	end,
})

-- Versao acessa
minetest.register_tool("hardtorch:torch_tool_on", {
	description = "Tocha",
	inventory_image = "default_torch_on_floor.png",
	wield_image = "hardtorch_torch_tool_on_mao.png",
	groups = {not_in_creative_inventory = 1},
	
	on_use = function(itemstack, user, pointed_thing)
		-- Remover luz
		hardtorch.apagar_node_luz(user:get_player_name())
		if hardtorch.em_loop[user:get_player_name()].hud_id then
			user:hud_remove(hardtorch.em_loop[user:get_player_name()].hud_id)
		end
		itemstack:set_name("hardtorch:torch_tool")
		return itemstack
	end,
	
	on_drop = function(itemstack, dropper, pos)
		-- Remover luz
		hardtorch.apagar_node_luz(dropper:get_player_name())
		if hardtorch.em_loop[dropper:get_player_name()].hud_id then
			dropper:hud_remove(hardtorch.em_loop[dropper:get_player_name()].hud_id)
		end
		itemstack:set_name("hardtorch:torch_tool")
		minetest.item_drop(itemstack, dropper, pos)
		itemstack:clear()
		return itemstack
	end,
	
	-- Ao colocar funciona como tocha normal apenas repassando o desgaste
	on_place = minetest.registered_tools["hardtorch:torch_tool"].on_place
	
})



-- Certifica que jogador que acabou de entrar esteja com tocha acessa, caso contrario apaga ela
minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	
	-- Verifica se tem tocha acessa
	if inv:contains_item("main", "hardtorch:torch_tool_on") 
		or inv:contains_item("craft", "hardtorch:torch_tool_on") 
	then 
		hardtorch.apagar_tocha(player)
	end
	
	
end)
