--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2020 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Tool
  ]]


-- Used for localization
local S = minetest.get_translator("hardtorch")


-- Turn on torch
-- Acender tocha
hardtorch.turnon_torch = function(itemstack, player)
	local name = player:get_player_name()
	local torchname = itemstack:get_name()
	itemstack:set_name(torchname.."_on")

	-- Check if it is already lit (avoid double loop)
	-- Verifica se ja esta acesa (evitar loop duplo)
	if not hardtorch.in_loop[name] then
		hardtorch.in_loop[name] = {
			lpos = hardtorch.get_lpos(player),
			torchname = torchname,
		}
		
		-- Add HUD element
		hardtorch.add_light_hud(player, torchname)
		
		-- Start torch loop (delay to allow time to update item in inventory)
		-- Inicia loop de tocha (atraso para dar tempo de atualizar item no inventario)
		minetest.after(0.3, hardtorch.torch_loop, name, torchname)
		
		-- Start light loop
		hardtorch.light_loop(name, torchname)
		
		-- Play sound
		hardtorch.turnon_sound(player:getpos(), torchname)
	end

	return itemstack
end


-- Turn off torchs
-- Apagar tochas
hardtorch.turnoff_torch = function(player, torchname)

	-- Remove HUD element
	hardtorch.remove_light_hud(player)

	local loop = hardtorch.in_loop[player:get_player_name()]

	torchname = torchname or loop.torchname
	
	-- Take torch
	local list, i, itemstack = hardtorch.find_and_get_item(player, torchname.."_on")
	if list then
		local inv = player:get_inventory()
		-- Set torch off
		itemstack:set_name(torchname)
		inv:set_stack(list, i, itemstack)
	end
end


-- Start torch loop (for mantain torch working)
-- Inicia loop da tocha (para manter tocha funcionando)
hardtorch.torch_loop = function(name, torchname)
	
	-- Check if it is already lit (avoid double loop)
	-- Verifica se ja esta acesa (evitar loop duplo)
	if not hardtorch.in_loop[name] then return end
	
	-- Check player
	local player = minetest.get_player_by_name(name)
	if not player then end
	
	local def = hardtorch.registered_torchs[torchname]
	local loop = hardtorch.in_loop[name]
	
	
	-- Torch
	-- Tocha
	
	-- Check torch
	local list, i, itemstack = hardtorch.find_and_get_item(player, torchname.."_on")
	if not itemstack then
		-- Finish loop
		hardtorch.turnoff_torch(player, torchname)
		hardtorch.in_loop[name] = nil
		return
	end
	
	-- Check air for torch light
	-- Verifica ar para luz da tocha
	do
		local nn = minetest.get_node(hardtorch.get_lpos(player)).name
		if nn ~= "air" and not string.match(nn, "hardtorch:light_") then
			-- Finish loop
			hardtorch.turnoff_torch(player, torchname)
			hardtorch.in_loop[name] = nil
			return
		end

	end
	
	
	-- Fuel
	-- Combustivel
	
	-- Update fuel wear
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
	
	-- Add wear to fuel item
	-- Consome o Combustivel no inventario
	if loop.fuel then
		local item = inv:get_stack(loop.fuel.list, loop.fuel.i)
		item:add_wear(hardtorch.registered_fuels[loop.fuel.name].loop_wear)
		inv:set_stack(loop.fuel.list, loop.fuel.i, item)
	else
		-- "Without fuel" warning
		-- Aviso de "sem combustivel"
		if torchname ~= def.fuel[1] then
			minetest.chat_send_player(player:get_player_name(), S("Without fuel"))
		end
		
		-- Finish loop
		-- Encerra loop
		hardtorch.turnoff_torch(player, torchname)
		hardtorch.in_loop[name] = nil
		
		return
	end

	-- Checks if fuel runs out during loop
	-- Verifica se acabou o combustivel durante o loop
	if itemstack:is_empty() then
		-- Finish loop
		-- Encerra loop
		hardtorch.turnoff_torch(player, torchname)
		hardtorch.in_loop[name] = nil
		return
	end

	-- Check if HUD element has been added
	-- Verifique se o elemento HUD foi adicionado
	if not loop.hud_id
		or not player:hud_get(loop.hud_id)
	then
		hardtorch.add_light_hud(player, torchname)
	end

	-- Wait for next loop
	-- Aguarda para proximo loop
	minetest.after(2, hardtorch.torch_loop, name, torchname)
end

-- Register tool
-- Registrar ferramenta
hardtorch.register_tool = function(torchname, def)
	
	-- Adjust the created tool
	-- Ajusta a ferramenta criada
	minetest.override_item(torchname, {
		on_use = function(itemstack, user, pointed_thing)
			if itemstack:get_name() ~= torchname then return end

			-- Check if it is already lit (avoid double loop)
			-- Verifica se ja esta acesa (evitar loop duplo)
			if hardtorch.in_loop[user:get_player_name()] then
				return
			end
			
			-- Check if need fire source
			-- Verifica se precisa de fonte de fogo
			if hardtorch.torch_lighter then
				
				-- Check if turn on from fire source node
				-- Verifica se acendeu em bloco de fonte de fogo
				if pointed_thing.under and hardtorch.fire_sources[minetest.get_node(pointed_thing.under).name]
					or pointed_thing.above and hardtorch.fire_sources[minetest.get_node(pointed_thing.above).name]
				then
					return hardtorch.turnon_torch(itemstack, user)
				end
				
				-- Check if turn on with lighter
				-- Verifica se acendeu com acendedor
				for tool,def in pairs(hardtorch.registered_lighters) do
					if hardtorch.find_item(user, tool) then
						local list, i, item = hardtorch.find_and_get_item(user, tool)
						item:add_wear(def.wear_by_use)
						user:get_inventory():set_stack(list, i, item)
						return hardtorch.turnon_torch(itemstack, user)
					end
				end
				minetest.chat_send_player(user:get_player_name(), S("Without heat source or lighter"))
				return itemstack
			end
			return hardtorch.turnon_torch(itemstack, user)
		end,
		
		-- Place torch tool like a torch node
		-- Coloca ferramenta de tocha como nó de tocha
		on_place = function(itemstack, placer, pointed_thing)
			
			-- Check for avoidable nodes
			-- Verifica nodes evitaveis
			if pointed_thing.under and hardtorch.not_place_torch_on[1] then
				local nn = minetest.get_node(pointed_thing.under).name
				for _,n in ipairs(hardtorch.not_place_torch_on) do
					if n == nn then
						return
					end
				end
			end

			if itemstack:get_name() ~= torchname then return end

			if pointed_thing.type ~= "node" then
				return itemstack
			end
			
			-- Check if is right clicking a node
			-- Verifica se esta acessando outro nó
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local defnode = minetest.registered_nodes[node.name]
			if defnode and defnode.on_rightclick and
				((not placer) or (placer and not placer:get_player_control().sneak)) then
				return defnode.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack
			end
			
			-- Check protected area
			-- Verifica se está protegido
			if minetest.is_protected(pointed_thing.above, placer:get_player_name()) == true then
				return itemstack
			end
			
			-- Checks for water in torch sides
			-- Verifica se tem agua nas laterais da tocha
			if def.drop_on_water ~= false and hardtorch.check_node_sides(pointed_thing.above, {"group:water"}) == true then
				return itemstack
			end
			
			-- Check if is a node
			-- Verificar se é um nó
			if not minetest.registered_nodes[torchname] then
				return itemstack
			end
			
			-- Set node according to side placement
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
			
			-- Set turned off torch
			-- Coloca nó de tocha apagado
			if hardtorch.registered_torchs[torchname].nodes_off then
				itemstack:set_name(hardtorch.registered_torchs[torchname].nodes_off.node)
			end
			
			local sucess
			itemstack, sucess = minetest.item_place(itemstack, placer, pointed_thing)
			if sucess == nil or sucess == false then
				return
			end
			
			-- Remove item from inventory
			itemstack:take_item()

			return itemstack

		end,

	})
	
	-- Lit version
	-- Versao acesa
	minetest.override_item(torchname.."_on", {
		wield_image = "hardtorch_torch_tool_on_wield.png",

		on_use = function(itemstack, user, pointed_thing)

			-- Check if is punching another node
			-- Verifica se batendo em outro nó
			local under = pointed_thing.under
			if under then
				local node = minetest.get_node(under)
				local def = minetest.registered_nodes[node.name]
				if def and def.on_punch and
					not (user and user:is_player() and
					user:get_player_control().sneak) then
					itemstack = def.on_punch(under, node, user, itemstack,
						pointed_thing) or itemstack
				end
			end

			if itemstack:get_name() ~= torchname.."_on" then return end

			-- Remove light from player
			hardtorch.turnoff_sound(user:getpos(), torchname)
			hardtorch.apagar_node_luz(user:get_player_name())
			hardtorch.remove_light_hud(user)
			itemstack:set_name(torchname)

			return itemstack
		end,

		on_drop = function(itemstack, dropper, pos)
			if itemstack:get_name() ~= torchname.."_on" then return end

			-- Remove light from player
			hardtorch.apagar_node_luz(dropper:get_player_name())
			hardtorch.remove_light_hud(dropper)
			itemstack:set_name(torchname)
			minetest.item_drop(itemstack, dropper, pos)
			itemstack:clear()

			return itemstack
		end,
		
		-- When place works like a torch with current fuel wear
		-- Ao colocar funciona como tocha com desgaste atual de combustivel
		on_place = function(itemstack, placer, pointed_thing)
			
			-- Check for avoidable nodes
			-- Verifica nodes evitaveis
			if pointed_thing.under and hardtorch.not_place_torch_on[1] then
				local nn = minetest.get_node(pointed_thing.under).name
				for _,n in ipairs(hardtorch.not_place_torch_on) do
					if n == nn then
						return
					end
				end
			end

			if itemstack:get_name() ~= torchname.."_on" then return end

			if pointed_thing.type ~= "node" then
				return itemstack
			end

			-- Check if is right clicking a node
			-- Verifica se esta acessando outro nó
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local defnode = minetest.registered_nodes[node.name]
			if defnode and defnode.on_rightclick and
				((not placer) or (placer and not placer:get_player_control().sneak)) then
				return defnode.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack
			end
			
			-- Check protected area
			-- Verifica se está protegido
			if minetest.is_protected(pointed_thing.above, placer:get_player_name()) == true then
				return itemstack
			end
			
			-- Check if it is already lit (avoid double loop)
			-- Verifica se ja esta acesa (evitar loop duplo)
			local loop = hardtorch.in_loop[placer:get_player_name()]
			if not loop then
				return itemstack
			end
			
			-- Check fuel
			-- Verifica combustivel
			local inv = placer:get_inventory()
			if not loop or not loop.fuel or inv:get_stack(loop.fuel.list, loop.fuel.i):get_name() ~= loop.fuel.name then
				return itemstack
			end
			
			-- Checks for water in torch sides
			-- Verifica se tem agua nas laterais da tocha
			if def.works_in_water ~= true and hardtorch.check_node_sides(pointed_thing.above, {"group:water"}) == true then
				return itemstack
			end

			-- Set node according to side placement
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
			
			local sucess
			itemstack, sucess = minetest.item_place(itemstack, placer, pointed_thing)
			if sucess == nil or sucess == false then
				return
			end
			
			-- Set fuel wear to node
			-- Repassa desgaste de combustivel ao nó
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

			-- Remove item from inventory
			itemstack:take_item()

			-- Remove light from player
			hardtorch.apagar_node_luz(placer:get_player_name())
			hardtorch.remove_light_hud(placer)

			return itemstack
		end,
	})

end


-- Turn off wielded torch when player disconnect
-- Apaga tocha da mão quando o jogador desconecta
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if hardtorch.in_loop[name] then
		hardtorch.turnoff_torch(player, hardtorch.in_loop[name].torchname)
		hardtorch.in_loop[name] = nil
	end
end)

