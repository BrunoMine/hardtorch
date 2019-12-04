--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Default Torchs
  ]]


-- Used for localization
local S = minetest.get_translator("hardtorch")


-- Torch light
-- Luminosidade da Tocha
local torch_light_source = hardtorch.check_light_number(minetest.settings:get("hardtorch_torch_light_source") or 11)

-- Torch durability (in nights)
-- Durabilidade da Tocha (em nights)
local torch_nights = math.abs(tonumber(minetest.settings:get("hardtorch_torch_nights") or 0.1))
if torch_nights <= 0 then torch_nights = 0.1 end


-- Default torch adjustment
-- Ajuste na tocha padrão
do
	minetest.override_item("default:torch", {
		-- Change image to player know that need to light it
		-- Muda imagem para jogador saber que tem que acendela
		inventory_image = "hardtorch_torch_tool_off.png",
		wield_image = "hardtorch_torch_tool_off.png",
		light_source = torch_light_source
	})
end


-- Register the lit torch like fuel
-- Registra a tocha acessa como um combustivel
hardtorch.register_fuel("hardtorch:torch_on", {
	turns = torch_nights,
})

-- Register tool
-- Registrar ferramenta
minetest.register_tool("hardtorch:torch", {
	description = S("Torch (used)"),
	inventory_image = "hardtorch_torch_tool_off.png",
	wield_image = "hardtorch_torch_tool_off.png",
	groups = {not_in_creative_inventory = 1},
})

-- Lit version tool
-- Versao acessa da ferramenta
minetest.register_tool("hardtorch:torch_on", {
	inventory_image = "hardtorch_torch_tool_on.png",
	wield_image = "hardtorch_torch_tool_on_wield.png",
	groups = {not_in_creative_inventory = 1},
})

-- Register torch
hardtorch.register_torch("hardtorch:torch", {
	light_source = minetest.registered_nodes["default:torch"].light_source,
	fuel = {"hardtorch:torch_on"},
	nodes = {
		node = "default:torch",
		node_ceiling = "default:torch_ceiling",
		node_wall = "default:torch_wall"
	},
	sounds = {
		turn_on = {name="hardtorch_turnon_torch", gain=0.2},
		turn_off = {name="hardtorch_turnoff_torch", gain=0.2},
		water_turn_off = {name="hardtorch_turnoff_torch", gain=0.2},
	},
})
