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
	end
	
	-- Recuperar o desgaste apos coletado
	local on_dig = function(pos, node, digger)
		local meta = minetest.get_meta(pos)
		local inv = digger:get_inventory()
	
		-- Calcula desgaste
		local timer = minetest.get_node_timer(pos)
		local t_rest = timer:get_timeout() - timer:get_elapsed()
		local w_rest = (65535/hardtorch.registered_torchs[torchname].torch_time)*t_rest
		local itemstack = {name=torchname, count=1, wear=65535-w_rest, metadata=""}
	
		-- Verifica se cabe no inventario
		if inv:room_for_item("main", itemstack) then
			
			-- Mantem ferramenta ativa (sem loop) para identificar depois
			if not hardtorch.em_loop[digger:get_player_name()] then
				itemstack.name = torchname.."_on"
			end
			
			-- Coloca no inventario
			inv:add_item("main", itemstack)
			
			-- Acende tocha caso jogador nao tenha uma acessa ainda
			if not hardtorch.em_loop[digger:get_player_name()] then
				local list, i, itemstack = hardtorch.find_and_get_item(digger, torchname.."_on")
				itemstack:set_name(torchname) -- restaura o nome para acender em definitivo (com loop)
				itemstack = hardtorch.acender_tocha(itemstack, digger)
				inv:set_stack(list, i, itemstack)
			end
			
		else
			-- Dropa no local
			minetest.add_item(pos, itemstack)
		end
	
		minetest.remove_node(pos)
	end


	-- Adiciona uso para node de tochas ser substituindo por ferramenta de tocha (que será acessa)
	local on_use = function(itemstack, player, pointed_thing)
		local sobra = itemstack:get_count() - 1
		local inv = player:get_inventory()
	
		-- Localiza o item no iventario
		local list, i = player:get_wield_list(), player:get_wield_index()
		local itemstack2 = inv:get_stack(list, i)
		if itemstack:to_string() ~= itemstack2:to_string() then
			return
		end
	
		-- Troca o item por uma tocha acessa
		itemstack:replace({name=torchname.."_on", count=1, wear=0, metadata=""})
		inv:set_stack(list, i, itemstack)
	
		-- Caso tenha sobra tenta colocar no inventario, ou joga no chão (com aviso sonoro e textual)
		if sobra > 0 then
			if inv:room_for_item("main", nodes.node.." "..sobra) then
				-- Coloca no inventario
				inv:add_item("main", nodes.node.." "..sobra)
			else
				-- Coloca a tocha no inventario para poder dropa-la
				inv:set_stack(list, i, nodes.node" "..sobra)
				minetest.item_drop(inv:get_stack(list, i), player, player:getpos())
				-- Recoloca tocha
				inv:set_stack(list, i, itemstack)
			end
		end
		
		itemstack:set_name(torchname) -- restaura nome da tocha		
		return hardtorch.acender_tocha(itemstack, player)
	end


	-- Atualiza as tocha apos colocar
	local after_place_node = function(pos, placer, itemstack, pointed_thing)
	
		-- Define desgaste inicial caso necessario
		local meta = minetest.get_meta(pos)
		if not meta:get_int("hardtorch_wear") then
			meta:set_int("hardtorch_wear", 0)
		end
		
		-- Inicia contagem para acabar fogo de acordo com desgaste definido
		local timeout = (hardtorch.registered_torchs[torchname].torch_time/65535)*(65535-meta:get_int("hardtorch_wear"))
		minetest.get_node_timer(pos):start(timeout)
	
	end

	-- Remove tocha quando fogo acabar
	local on_timer = function(pos, elapsed)
		-- remove bloco
		minetest.remove_node(pos)
	end

	local node_torch_def = {
		drop="", 
		on_dig=on_dig, 
		on_use=on_use, 
		after_place_node=after_place_node, 
		on_timer=on_timer,
	}
	
	
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
				hardtorch.som_apagar(pos, torchname)
				minetest.remove_node(pos)
			end
		end,
	})

end
