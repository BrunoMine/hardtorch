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
	
end
