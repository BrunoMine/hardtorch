--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Acendedores
	
  ]]

-- Tabela global
hardtorch.registered_lighters = {}

-- Registrar Acendedor
hardtorch.register_lighter = function(name, def)
	hardtorch.registered_lighters[name] = def
end

