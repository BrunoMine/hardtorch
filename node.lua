--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nodes
  ]]

-- Nodes registrados
hardtorch.registered_nodes = {}


-- Registrar Node de tocha
hardtorch.register_node = function(torchname, def)
	
	for nt,nn in pairs(def.nodes) do
		hardtorch.registered_nodes[nn] = torchname
		if def.nodes.fire_source ~= false then
			hardtorch.fontes_de_fogo[nn] = true
		end
	end
	
	-- Recuperar o desgaste apos coletado
	local on_dig = function(pos, node, digger)
		if not hardtorch.registered_nodes[node.name] then return end
		local meta = minetest.get_meta(pos)
		local inv = digger:get_inventory()
	
		-- Calcula desgaste
		local wear = hardtorch.get_node_wear(pos)
		local itemstack = {name=torchname, count=1}
		
		-- Caso o combustivel seja o proprio item, repassa desgaste
		if torchname.."_on" == meta:get_string("hardtorch_fuel") then
			itemstack.wear = wear
		end
		
		-- Torna acessa caso ainda nao tenha nenhuma (sem loop)
		if not hardtorch.em_loop[digger:get_player_name()] then
			itemstack.name = torchname.."_on"
		end
		
		-- Verifica se tocha cabe no inventario
		if inv:room_for_item("main", itemstack) then
						
			-- Coloca no inventario
			inv:add_item("main", itemstack)
			
			-- Acende com loop caso adicinou acesa anteriormente
			if not hardtorch.em_loop[digger:get_player_name()] then
				local list, i, itemstack = hardtorch.find_and_get_item(digger, torchname.."_on")
				itemstack:set_name(torchname)
				itemstack = hardtorch.acender_tocha(itemstack, digger)
				inv:set_stack(list, i, itemstack)
			end
			
			
		else
			-- Dropa no local
			minetest.add_item(pos, itemstack)
		end
		
		-- Verifica se combustivel cabe no inventario
		if torchname.."_on" ~= meta:get_string("hardtorch_fuel") then
			local fuelstack = {name=meta:get_string("hardtorch_fuel"), count=1, wear=wear}
			
			if inv:room_for_item("main", fuelstack) then
						
				-- Coloca no inventario
				inv:add_item("main", fuelstack)
			else
				-- Dropa no local
				minetest.add_item(pos, fuelstack)
			end
		end
	
		minetest.remove_node(pos)
	end

	
	-- Adiciona uso para node de tochas ser substituindo por ferramenta de tocha (que será acessa)
	local on_use = function(itemstack, player, pointed_thing)
		if not hardtorch.registered_nodes[itemstack:get_name()] then return end
		local sobra = itemstack:get_count() - 1
		local inv = player:get_inventory()
		
		-- Localiza o item no iventario
		local list, i = player:get_wield_list(), player:get_wield_index()
		local itemstack2 = inv:get_stack(list, i)
		if itemstack:to_string() ~= itemstack2:to_string() then
			return
		end

		-- Troca o item pela ferramenta
		itemstack:replace({name=torchname, count=1, wear=0, metadata=""})
		inv:set_stack(list, i, itemstack)

		-- Caso tenha sobra tenta colocar no inventario, ou joga no chão (com aviso sonoro e textual)
		if sobra > 0 then
			if inv:room_for_item("main", def.nodes.node.." "..sobra) then
				-- Coloca no inventario
				inv:add_item("main", def.nodes.node.." "..sobra)
			else
				-- Coloca a tocha no inventario para poder dropa-la
				inv:set_stack(list, i, def.nodes.node.." "..sobra)
				minetest.item_drop(inv:get_stack(list, i), player, player:getpos())
				-- Recoloca tocha
				inv:set_stack(list, i, itemstack)
			end
		end
	
		itemstack:set_name(torchname) -- restaura nome da tocha	
		
		return itemstack
	end


	-- Atualiza as tocha apos colocar
	local after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not hardtorch.registered_nodes[minetest.get_node(pos).name] then return end
		
		-- Certifica de que iniciou contagem
		local timer = minetest.get_node_timer(pos)
		if timer:is_started() ~= true then
			-- Define desgaste inicial caso necessario
			local meta = minetest.get_meta(pos)
			if meta:get_string("hardtorch_fuel") == "" then
				meta:set_string("hardtorch_fuel", def.fuel[1])
				meta:set_int("hardtorch_wear", 0)
			end
		
			-- Inicia contagem para acabar fogo de acordo com desgaste definido
			timer:start(hardtorch.get_node_timeout(pos))
		end
	
	end

	-- Remove tocha quando fogo acabar
	local on_timer = function(pos, elapsed)
		if not hardtorch.registered_nodes[minetest.get_node(pos).name] then return end
		
		if def.nodes_off then
			local node = minetest.get_node(pos)
			
			if node.name == def.nodes.node then
				node.name=def.nodes_off.node
			elseif node.name == def.nodes.node_ceiling then
				node.name=def.nodes_off.node_ceiling
			elseif node.name == def.nodes.node_wall then
				node.name=def.nodes_off.node_wall
			end
			minetest.set_node(pos, node)
		else
			minetest.remove_node(pos)
		end
	end
	
	local node_torch_def = {
		drop="", 
		on_dig=on_dig, 
		on_use=on_use, 
		after_place_node=after_place_node, 
		on_timer=on_timer,
	}
	
	-- Impedir colocação normal em casos especiais
	if hardtorch.torch_lighter then
		node_torch_def.on_place = function(itemstack, placer, pointed_thing)
			return itemstack
		end
	end
	
	-- Atualiza tochas com novas funcões de chamadas
	minetest.override_item(def.nodes.node, node_torch_def)
	minetest.override_item(def.nodes.node_ceiling or def.nodes.node, node_torch_def)
	minetest.override_item(def.nodes.node_wall or def.nodes.node, node_torch_def)


	-- Apagar tochas em contato com agua
	minetest.register_abm({
		label = "Esfriamento de tochas molhadas",
		nodenames = {def.nodes.node, def.nodes.node_ceiling, def.nodes.node_wall},
		neighbors = {"group:water"},
		interval = 1,
		chance = 3,
		catch_up = false,
		action = function(pos, node)
			if hardtorch.check_torch_area(pos) == false then
				local wear = hardtorch.get_node_wear(pos)
				hardtorch.som_apagar_por_agua(pos, torchname)
				minetest.remove_node(pos)
				minetest.add_item(pos, def.drop_on_water or {name=torchname, wear=wear})
			end
		end,
	})

end
