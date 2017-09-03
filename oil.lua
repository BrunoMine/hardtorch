--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Registro de Oleo
  ]]


-- Noites de durabilidade da tocha da lamparina
local oil_nights = math.abs(tonumber(minetest.setting_get("hardtorch_oil_nights") or 1.2)) 
if oil_nights <= 0 then oil_nights = 1.2 end


-- Oleo de lamparina
minetest.register_tool("hardtorch:oil", {
	description = "Oil",
	inventory_image = "hardtorch_oil.png",
})


-- Registrar combustivel
hardtorch.register_fuel("hardtorch:oil", {
	turns = oil_nights,
})


-- Receitas para oleo
minetest.register_craft({
	output = 'hardtorch:oil',
	recipe = {
		{'default:coal_lump'},
		{'default:coal_lump'},
		{'default:coal_lump'},
	}
})
