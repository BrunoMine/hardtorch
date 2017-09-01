--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Registro de Tochas padrao
  ]]


-- Noites de durabilidade da tocha
local torch_nights = math.abs(tonumber(minetest.setting_get("hardtorch_torch_nights") or 1)) 
if torch_nights <= 0 then torch_nights = 1 end


hardtorch.register_torch("hardtorch:torch_tool", {
	description = "Tocha",
	night_turns = torch_nights,
	light_source = 11,
	inventory_image = {
		on = "hardtorch_torch_tool_on.png",
		off = "hardtorch_torch_tool_off.png",
	},
	wield_image = "hardtorch_torch_tool_off.png",
	nodes = {
		node = "default:torch", 
		node_ceiling = "default:torch_ceiling", 
		node_wall = "default:torch_wall"
	},
	sounds = {
		turn_off = {name="hardtorch_apagando_tocha", gain=0.2},
	}
})


-- Inicia desgaste em tochas antigas
minetest.register_lbm({
	name = "hardtorch:desgaste_tochas_antigas",
	nodenames = {"default:torch", "default:torch_ceiling", "default:torch_wall"},
	action = function(pos, node)
		-- Define desgaste inicial caso necessario
		local meta = minetest.get_meta(pos)
		if not meta:get_int("hardtorch_wear") then
			meta:set_int("hardtorch_wear", 0)
		end

		-- Inicia contagem para acabar fogo de acordo com desgaste definido
		local timeout = (hardtorch.registered_torches[torchname].torch_time/65535)*(65535-meta:get_int("hardtorch_wear"))
		minetest.get_node_timer(pos):start(timeout)
	end,
})


minetest.override_item("default:torch", {
	inventory_image = "hardtorch_torch_tool_off.png",
	wield_image = "hardtorch_torch_tool_off.png",
})
