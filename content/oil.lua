--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Oil
  ]]


-- Used for localization
local S = minetest.get_translator("hardtorch")

-- Durability of oil (in nights)
-- Durabilidade do oleo (em noites)
local oil_nights = math.abs(tonumber(minetest.settings:get("hardtorch_oil_nights") or 1.2))
if oil_nights <= 0 then oil_nights = 1.2 end

-- Oil
-- Oleo
minetest.register_tool("hardtorch:oil", {
	description = S("Oil"),
	inventory_image = "hardtorch_oil.png",

})

-- Register fuel
-- Registrar combustivel
hardtorch.register_fuel("hardtorch:oil", {
	turns = oil_nights,
})

-- Oil recipes
-- Receitas para oleo
minetest.register_craft({
	output = 'hardtorch:oil',
	recipe = {
		{'default:coal_lump'},
		{'default:coal_lump'},
		{'default:coal_lump'},
	}
})
