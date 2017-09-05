--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Ferramentas
	
  ]]


-- Acender tocha
hardtorch.acender_tocha = function(itemstack, player)
	local name = player:get_player_name()
	local torchname = itemstack:get_name()
	itemstack:set_name(torchname.."_on")
	
	-- Verifica se ja esta acessa (evitar loop duplo)
	if not hardtorch.em_loop[name] then 
		hardtorch.em_loop[name] = {lpos=hardtorch.get_lpos(player)}
		-- Adiciona luz no hud
		hardtorch.adicionar_luz_hud(player, torchname)
		-- Inicia loop de tocha (atraso para dar tempo de atualizar item no inventario)
		minetest.after(0.3, hardtorch.loop_tocha, name, torchname)
		-- Inicia loop de luz
		hardtorch.loop_luz(name, torchname)
		-- Som
		hardtorch.som_acender(player:getpos(), torchname)
	end
	
	return itemstack
end


-- Apaga todas as tochas que um jogador possui
hardtorch.apagar_tocha = function(player, torchname)
	-- Remover luz do hud
	hardtorch.remover_luz_hud(player)
	
	-- Pega a tocha
	local list, i, itemstack = hardtorch.find_and_get_item(player, torchname.."_on")
	if list then
		local inv = player:get_inventory()
		-- Coloca no lugar 
		itemstack:set_name(torchname)
		inv:set_stack(list, i, itemstack)
	end
end


-- Inicia loop de verificação apos acender tocha
hardtorch.loop_tocha = function(name, torchname)
	-- Verifica se ja iniciou loop
	if not hardtorch.em_loop[name] then return end
	-- Verifica jogador
	local player = minetest.get_player_by_name(name)
	if not player then return end
	
	local def = hardtorch.registered_torchs[torchname]
	local loop = hardtorch.em_loop[name]
	
	-- Verifica tocha
	local list, i, itemstack = hardtorch.find_and_get_item(player, torchname.."_on")
	if not itemstack then
		-- Encerra loop
		hardtorch.apagar_tocha(player, torchname)
		hardtorch.em_loop[name] = nil
		return
	end
	
	-- Verifica se tem lugar para a luz
	do 
		local nn = minetest.get_node(hardtorch.get_lpos(player)).name
		if nn ~= "air" and not string.match(nn, "hardtorch:luz_") then
			-- Encerra loop
			hardtorch.apagar_tocha(player, torchname)
			hardtorch.em_loop[name] = nil
			return
		end 
		
	end
	
	-- Combustivel
	-- Atualiza combustivel em uso
	local inv = player:get_inventory()
	if not loop.fuel or inv:get_stack(loop.fuel.list, loop.fuel.i):get_name() ~= loop.fuel.name then
		local listfuel, indexfuel, itemfuel = hardtorch.get_fuel_stack(player, torchname)
		if not listfuel then
			loop.fuel = nil
		else
			loop.fuel = {list=listfuel, i=indexfuel, name=itemfuel:get_name()}
		end	
	end
	-- Consome o Combustivel
	if loop.fuel then
		local item = inv:get_stack(loop.fuel.list, loop.fuel.i)
		item:add_wear(hardtorch.registered_fuels[loop.fuel.name].loop_wear)
		inv:set_stack(loop.fuel.list, loop.fuel.i, item)
	else
		-- Encerra loop
		hardtorch.apagar_tocha(player, torchname)
		hardtorch.em_loop[name] = nil
		return
	end
	
	
	-- Verifica se acabou a tocha durante o loop
	if itemstack:is_empty() then
		-- Encerra loop
		hardtorch.apagar_tocha(player, torchname)
		hardtorch.em_loop[name] = nil
		return
	end
	
	
	-- Verifica se luz do hud foi criada
	if not loop.hud_id 
		or not player:hud_get(loop.hud_id)
	then
		hardtorch.adicionar_luz_hud(player, torchname)
	end
	
	
	-- Prepara para proximo loop
	minetest.after(2, hardtorch.loop_tocha, name, torchname)
end


-- Registra as ferramentas
hardtorch.register_tool = function(torchname, def)
	
	-- Ajusta a ferramenta criada
	minetest.override_item(torchname, {
		on_use = function(itemstack, user, pointed_thing)
			if itemstack:get_name() ~= torchname then return end
			
			-- Verifica se ja tem uma tocha acessa
			if hardtorch.em_loop[user:get_player_name()] then
				return
			end
			
			-- Verifica se tem fonte de fogo
			if hardtorch.torch_lighter then
				if pointed_thing.under and hardtorch.fontes_de_fogo[minetest.get_node(pointed_thing.under).name] 
					or pointed_thing.above and hardtorch.fontes_de_fogo[minetest.get_node(pointed_thing.above).name] 
				then
					return hardtorch.acender_tocha(itemstack, user)
				end
				for tool,def in pairs(hardtorch.registered_lighters) do
					if hardtorch.find_item(user, tool) then
						local list, i, item = hardtorch.find_and_get_item(user, tool)
						item:add_wear(def.wear_by_use)
						user:get_inventory():set_stack(list, i, item)
						return hardtorch.acender_tocha(itemstack, user)
					end
				end
				return itemstack
			end
			return hardtorch.acender_tocha(itemstack, user)
		end,

		-- Ao colocar funciona como tocha normal apenas repassando o desgaste
		on_place = function(itemstack, placer, pointed_thing)
			if itemstack:get_name() ~= torchname then return end
			
			if pointed_thing.type ~= "node" then
				return itemstack
			end
			
			-- Verifica se esta acessando outro node
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local defnode = minetest.registered_nodes[node.name]
			if defnode and defnode.on_rightclick and
				((not placer) or (placer and not placer:get_player_control().sneak)) then
				return defnode.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack
			end
			
			-- Verifica se tem algum impedimento no local
			if hardtorch.check_torch_area(pointed_thing.above) == false then
				return itemstack
			end
			
			-- Verificar se é um node
			if not minetest.registered_nodes[torchname] then
				return itemstack
			end
			
			-- Definir node de acordo com posicionamento
			local above = pointed_thing.above
			local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
			if wdir == 0 then
				itemstack:set_name(def.nodes.node_ceiling or def.nodes.node)
			elseif wdir == 1 then
				itemstack:set_name(def.nodes.node)
			else
				itemstack:set_name(def.nodes.node_wall or def.nodes.node)
			end
			
			-- Coloca node apagado
			if hardtorch.registered_torchs[torchname].nodes_off then
				itemstack:set_name(hardtorch.registered_torchs[torchname].nodes_off.node)
			end
			if not minetest.item_place(itemstack, placer, pointed_thing) then
				return itemstack
			end
			
			-- Remove item do inventario
			itemstack:take_item()

			return itemstack
			
		end,
		
	})
	
	-- Versao acessa
	minetest.override_item(torchname.."_on", {
		wield_image = "hardtorch_torch_tool_on_mao.png",
		
		on_use = function(itemstack, user, pointed_thing)
			if itemstack:get_name() ~= torchname.."_on" then return end
			
			-- Remover luz
			hardtorch.som_apagar(user:getpos(), torchname)
			hardtorch.apagar_node_luz(user:get_player_name())
			hardtorch.remover_luz_hud(user)
			itemstack:set_name(torchname)
			return itemstack
		end,

		on_drop = function(itemstack, dropper, pos)
			if itemstack:get_name() ~= torchname.."_on" then return end
			
			-- Remover luz
			hardtorch.apagar_node_luz(dropper:get_player_name())
			hardtorch.remover_luz_hud(dropper)
			itemstack:set_name(torchname)
			minetest.item_drop(itemstack, dropper, pos)
			itemstack:clear()
	
			return itemstack
		end,

		-- Ao colocar funciona como tocha normal apenas repassando o desgaste
		on_place = function(itemstack, placer, pointed_thing)
			if itemstack:get_name() ~= torchname.."_on" then return end
			
			if pointed_thing.type ~= "node" then
				return itemstack
			end
			
			-- Verifica se esta acessando outro node
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local defnode = minetest.registered_nodes[node.name]
			if defnode and defnode.on_rightclick and
				((not placer) or (placer and not placer:get_player_control().sneak)) then
				return defnode.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack
			end
			
			-- Verifica se ja iniciou loop
			local loop = hardtorch.em_loop[placer:get_player_name()]
			if not loop then
				return itemstack
			end
			
			-- Verifica se tem combustivel
			local inv = placer:get_inventory()
			if not loop or not loop.fuel or inv:get_stack(loop.fuel.list, loop.fuel.i):get_name() ~= loop.fuel.name then
				return itemstack
			end
			
			-- Verifica se tem algum impedimento no local
			if hardtorch.check_torch_area(pointed_thing.above) == false then
				return itemstack
			end
			
			
			-- Definir node de acordo com posicionamento
			local above = pointed_thing.above
			local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
			if wdir == 0 then
				itemstack:set_name(def.nodes.node_ceiling or def.nodes.node)
			elseif wdir == 1 then
				itemstack:set_name(def.nodes.node)
			else
				itemstack:set_name(def.nodes.node_wall or def.nodes.node)
			end

			itemstack = minetest.item_place(itemstack, placer, pointed_thing, wdir)
	
			if not itemstack then
				return
			end
	
			-- Repassa desgaste de combustivel
			local fuelname, fuelwear
			fuelname = loop.fuel.name
			fuelwear = inv:get_stack(loop.fuel.list, loop.fuel.i):get_wear()
			if inv:get_stack(loop.fuel.list, loop.fuel.i):get_name() ~= itemstack:get_name() then
				local fuelstack = inv:get_stack(loop.fuel.list, loop.fuel.i)
				fuelstack:take_item()
				hardtorch.update_inv(placer, loop.fuel.list, loop.fuel.i, fuelstack)
			end
			local meta = minetest.get_meta(pointed_thing.above)
			meta:set_string("hardtorch_fuel", fuelname)
			meta:set_int("hardtorch_wear", fuelwear)
			minetest.get_node_timer(pointed_thing.above):start(hardtorch.get_node_timeout(pointed_thing.above))
			
			-- Remove item do inventario
			itemstack:take_item()
	
			-- Remover luz
			hardtorch.apagar_node_luz(placer:get_player_name())
			hardtorch.remover_luz_hud(placer)
	
			return itemstack
		end,
	})
	
end

