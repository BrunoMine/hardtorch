--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Registro de Tochas padrao
  ]]

-- Luminosidade da lamparina
local torch_light_source = math.abs(tonumber(minetest.setting_get("hardtorch_torch_light_source") or 11)) 


-- Noites de durabilidade da tocha
local torch_nights = math.abs(tonumber(minetest.setting_get("hardtorch_torch_nights") or 0.1)) 
if torch_nights <= 0 then torch_nights = 0.1 end


-- Ajuste na tocha padrão
do
	minetest.override_item("default:torch", {
		-- Muda imagem para jogador saber que tem que acendela
		inventory_image = "hardtorch_torch_tool_off.png",
		wield_image = "hardtorch_torch_tool_off.png",
		light_source = torch_light_source
	})
end


-- Registra a tocha acessa como um combustivel
hardtorch.register_fuel("hardtorch:torch_on", {
	turns = torch_nights,
})

-- Registrar ferramentas
minetest.register_tool("hardtorch:torch", {
	description = "Torch (used)",
	inventory_image = "hardtorch_torch_tool_off.png",
	wield_image = "hardtorch_torch_tool_off.png",
	groups = {not_in_creative_inventory = 1},
})

-- Versao acessa da ferramenta
minetest.register_tool("hardtorch:torch_on", {
	inventory_image = "hardtorch_torch_tool_on.png",
	wield_image = "hardtorch_torch_tool_on_mao.png",
	groups = {not_in_creative_inventory = 1},
})

-- Registrar tocha
hardtorch.register_torch("hardtorch:torch", {
	light_source = minetest.registered_nodes["default:torch"].light_source,
	fuel = {"hardtorch:torch_on"},
	nodes = {
		node = "default:torch", 
		node_ceiling = "default:torch_ceiling", 
		node_wall = "default:torch_wall"
	},
	sounds = {
		turn_on = {name="hardtorch_acendendo_tocha", gain=0.2},
		turn_off = {name="hardtorch_apagando_tocha", gain=0.2},
		water_turn_off = {name="hardtorch_apagando_tocha", gain=0.2},
	},
})
