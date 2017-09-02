--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Registro de Tochas padrao
  ]]


-- Noites de durabilidade da tocha
local torch_nights = math.abs(tonumber(minetest.setting_get("hardtorch_torch_nights") or 0.1)) 
if torch_nights <= 0 then torch_nights = 0.1 end

-- Registra a tocha acessa como um combustivel
hardtorch.register_fuel("hardtorch:torch_on", {
	turns = 0.1,--torch_nights
})

-- Registrar ferramentas
minetest.register_tool("hardtorch:torch", {
	description = "Torch",
	inventory_image = "hardtorch_torch_tool_off.png",
	wield_image = "hardtorch_torch_tool_off.png",
})

-- Versao acessa da ferramenta
minetest.register_tool("hardtorch:torch_on", {
	description = "Torch Lit",
	inventory_image = "hardtorch_torch_tool_on.png",
	wield_image = "hardtorch_torch_tool_on_mao.png",
	groups = {not_in_creative_inventory = 1},
})

-- Registrar tocha
hardtorch.register_torch("hardtorch:torch", {
	night_turns = torch_nights,
	light_source = 10,
	fuel = {"hardtorch:torch_on"},
	nodes = {
		node = "default:torch", 
		node_ceiling = "default:torch_ceiling", 
		node_wall = "default:torch_wall"
	},
	sounds = {
		turn_off = {name="hardtorch_apagando_tocha", gain=0.2},
		water_turn_off = {name="hardtorch_apagando_tocha", gain=0.2},
	},
	drop_on_water = "default:stick",
})


-- Inicia desgaste em tochas antigas
minetest.register_lbm({
	name = "hardtorch:desgaste_tochas_antigas",
	nodenames = {"default:torch", "default:torch_ceiling", "default:torch_wall"},
	action = function(pos, node)
		-- Define desgaste inicial caso necessario
		local meta = minetest.get_meta(pos)
		if not meta:get_string("hardtorch_fuel") then
			meta:set_string("hardtorch_fuel", "hardtorch:torch_on")
			meta:set_int("hardtorch_wear", 0)
		end

		-- Inicia contagem para acabar fogo de acordo com desgaste definido
		minetest.get_node_timer(pos):start(hardtorch.get_node_timeout(pos))
	end,
})

-- Ajuste na tocha padrão
do
	-- Remove receita de nodes de tochas
	minetest.clear_craft({output = 'default:torch'})
	minetest.registered_nodes["default:torch"].groups.not_in_creative_inventory = 1
	minetest.override_item("default:torch", {
		groups = minetest.registered_nodes["default:torch"].groups
	})
end

-- Receita da Tocha
minetest.register_craft({
	output = 'hardtorch:torch 4',
	recipe = {
		{'default:coal_lump'},
		{'group:stick'},
	}
})