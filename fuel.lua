--[[
	Mod HardTorch para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Combustiveis
	
  ]]

-- Tabela Global
hardtorch.registered_fuels = {}

-- Registrar Combustivel
hardtorch.register_fuel = function(name, def)
	
	hardtorch.registered_fuels[name] = {}
	local registro = hardtorch.registered_fuels[name]
	
	registro.turns = def.turns
	registro.time = def.turns * hardtorch.night_time
	registro.loop_wear = (65535/registro.time)*2
	
	-- Sobreescreve on_place para evitar reparos no combustivel em ferramentas
	if minetest.registered_tools[name] then
		hardtorch.registered_fuels[name].old_on_place = minetest.registered_tools[name].on_place
		hardtorch.registered_fuels[name].on_place = function(itemstack, placer, pointed_thing)
			
			-- Verifica nodes evitaveis
			if pointed_thing.under and hardtorch.evitar_tool_on_place[1] then
				
				local nn = minetest.get_node(pointed_thing.under).name
				for _,n in ipairs(hardtorch.evitar_tool_on_place) do
					if n == nn then
						return
					end
				end
			end
			
			if hardtorch.registered_fuels[name].old_on_place ~= nil then
				return hardtorch.registered_fuels[name].old_on_place(itemstack, placer, pointed_thing)
			end
		end
		
		minetest.override_item(name, {
			on_place = hardtorch.registered_fuels[name].on_place,
		})
	end
end
