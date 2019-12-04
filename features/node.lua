--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Nodes
  ]]

-- Registered nodes
-- Nodes registrados
hardtorch.registered_nodes = {}

-- Turn off torch node
local turn_off_torch_node = function(pos, def)
	local node = minetest.get_node(pos)
	
	if node.name == def.nodes.node then
		node.name=def.nodes_off.node
	elseif node.name == def.nodes.node_ceiling then
		node.name=def.nodes_off.node_ceiling
	elseif node.name == def.nodes.node_wall then
		node.name=def.nodes_off.node_wall
	end
	
	minetest.set_node(pos, node)
end

-- Register torch node
-- Registrar Node de tocha
hardtorch.register_node = function(torchname, def)
	
	for nt,nn in pairs(def.nodes) do
		hardtorch.registered_nodes[nn] = torchname
		if def.nodes.fire_source ~= false then
			hardtorch.fire_sources[nn] = true
		end
	end
	
	-- Take torch and fuel with wear
	-- Pega tocha e combustivel com desgaste
	local on_dig = function(pos, node, digger)
		if not hardtorch.registered_nodes[node.name] then return end
		local meta = minetest.get_meta(pos)
		local inv = digger:get_inventory()
	
		-- Calculate wear
		local wear = hardtorch.get_node_wear(pos)
		local itemstack = {name=torchname, count=1}
		
		-- If torch is the fuel
		-- Se a tocha é o próprio cosbustivel
		local torch_is_fuel = false
		if torchname.."_on" == meta:get_string("hardtorch_fuel") then
			itemstack.wear = wear
			torch_is_fuel = true
		end
		
		-- Keep torch lit if possible
		-- Deixa tocha acesa se possivel
		if not hardtorch.in_loop[digger:get_player_name()] then
			itemstack.name = torchname.."_on"
		end
		
		-- Checks if torch fits in inventory
		-- Verifica se tocha cabe no inventario
		if inv:room_for_item("main", itemstack) then
			
			inv:add_item("main", itemstack)
			
			-- Lights with loop if added previously lit
			-- Acende com loop caso adicinou acesa anteriormente
			if not hardtorch.in_loop[digger:get_player_name()] then
				local list, i, itemstack = hardtorch.find_and_get_item(digger, torchname.."_on")
				itemstack:set_name(torchname)
				itemstack = hardtorch.turnon_torch(itemstack, digger)
				inv:set_stack(list, i, itemstack)
			end
			
		else
			-- Drop torch
			minetest.add_item(pos, itemstack)
		end
		
		-- Checks if fuel fits in inventory
		-- Verifica se combustivel cabe no inventario
		if torch_is_fuel == false then 
			local fuelstack = {name=meta:get_string("hardtorch_fuel"), count=1, wear=wear}
			
			if inv:room_for_item("main", fuelstack) then
						
				-- Coloca no inventario
				inv:add_item("main", fuelstack)
			else
				-- Drop fuel
				minetest.add_item(pos, fuelstack)
			end
		end
		
		minetest.remove_node(pos)
	end
	
	
	-- Replaces craftitem/node in a tool (to be lit)
	-- Troca craftitem/nó em ferramenta (para ser acesa)
	local on_use = function(itemstack, player, pointed_thing)
		if not hardtorch.registered_nodes[itemstack:get_name()] then return end
		local leftover = itemstack:get_count() - 1
		local inv = player:get_inventory()
		
		-- Localize the item on inventory
		-- Localiza o item no iventario
		local list, i = player:get_wield_list(), player:get_wield_index()
		local itemstack2 = inv:get_stack(list, i)
		if itemstack:to_string() ~= itemstack2:to_string() then
			return
		end
		
		-- Replace item
		itemstack:replace({name=torchname, count=1, wear=0, metadata=""})
		inv:set_stack(list, i, itemstack)
		
		-- If has left over, try put on inventory or drop (with audible and textual warning)
		-- Caso tenha sobra tenta colocar no inventario, ou joga no chão (com aviso sonoro e textual)
		if leftover > 0 then
		
			-- Put in inventory
			if inv:room_for_item("main", def.nodes.node.." "..leftover) then
				inv:add_item("main", def.nodes.node.." "..leftover)
				
			-- Drop
			else
				-- Set torchs in inveotory to drop
				-- Coloca a tocha no inventario para dropar
				inv:set_stack(list, i, def.nodes.node.." "..leftover)
				minetest.item_drop(inv:get_stack(list, i), player, player:getpos())
				
				-- Restore to the torch tool
				-- Restaura para a ferramenta tocha
				inv:set_stack(list, i, itemstack)
			end
		end
		
		-- Restore torch name
		-- Restaura nome da tocha	
		itemstack:set_name(torchname) 
		
		return itemstack
	end

	
	-- Update the torch after place it
	-- Atualiza a tocha apos coloca-la
	local after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not hardtorch.registered_nodes[minetest.get_node(pos).name] then return end
		
		-- Starts wear time count
		-- Inicia contagem de tempo de desgaste
		local timer = minetest.get_node_timer(pos)
		if timer:is_started() ~= true then
			
			-- Set initial wear if necessary
			-- Define desgaste inicial caso necessario
			local meta = minetest.get_meta(pos)
			if meta:get_string("hardtorch_fuel") == "" then
				meta:set_string("hardtorch_fuel", def.fuel[1])
				meta:set_int("hardtorch_wear", 0)
			end
			
			-- Starts counting to end fire according to set wear 
			-- Inicia contagem para acabar fogo de acordo com desgaste definido
			timer:start(hardtorch.get_node_timeout(pos))
		end
	
	end
	
	-- Remove torch when fire end
	-- Remove tocha quando fogo acabar
	local on_timer = function(pos, elapsed)
		if not hardtorch.registered_nodes[minetest.get_node(pos).name] then return end
		
		if def.nodes_off then
			turn_off_torch_node(pos, def)
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
	
	-- Prevent normal placement in special cases
	-- Impedir colocação normal em casos especiais
	if hardtorch.torch_lighter then
		node_torch_def.on_place = function(itemstack, placer, pointed_thing)
			return itemstack
		end
	end
	
	-- Upgrades torches with new calling features
	-- Atualiza tochas com novas funções de chamadas
	minetest.override_item(def.nodes.node, node_torch_def)
	if def.nodes.node_ceiling then minetest.override_item(def.nodes.node_ceiling, node_torch_def) end
	if def.nodes.node_wall then minetest.override_item(def.nodes.node_wall, node_torch_def) end

	-- Turn off torches in contact with water
	-- Apagar tochas em contato com agua
	minetest.register_abm({
		label = "Turn off wet torch",
		nodenames = {def.nodes.node, def.nodes.node_ceiling, def.nodes.node_wall},
		neighbors = {"group:water"},
		interval = 1,
		chance = 3,
		catch_up = false,
		action = function(pos, node)
			if def.works_in_water == true then return end
			
			if hardtorch.check_node_sides(pos, {"group:water"}) == false then return end
			
			hardtorch.turnoff_by_water_sound(pos, torchname)
			
			local force_drop = false
			
			-- Try turn off
			if def.nodes_off then
				turn_off_torch_node(pos, def)
			else
				force_drop = true
			end
			
			-- Drop
			if force_drop == true or def.drop_on_water ~= false then
				minetest.remove_node(pos)
				if type(def.drop_on_water) == "string" then
					minetest.add_item(pos, {name=def.drop_on_water, wear=wear})
				else
					minetest.add_item(pos, {name=torchname, wear=wear})
				end
			end
		end,
	})

end
