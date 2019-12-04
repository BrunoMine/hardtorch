--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Candle from xdecor mod
  ]]

if minetest.registered_nodes["xdecor:candle"] == nil then return end


-- Used for localization
local S = minetest.get_translator("hardtorch")

-- Candle light
local candle_light_source = hardtorch.check_light_number(minetest.settings:get("hardtorch_xdecor_candle_light_source") or 7)

-- Candle durability (in nights)
local candle_nights = math.abs(tonumber(minetest.settings:get("hardtorch_xdecor_candle_nights") or 0.8))
if candle_nights <= 0 then candle_nights = 0.8 end


-- Candle adjustment
do
	minetest.override_item("xdecor:candle", {
		-- Change image to player know that need to light it
		inventory_image = "xdecor_candle_wield.png",
		wield_image = "xdecor_candle_wield.png",
		light_source = candle_light_source
	})
end


-- Register the lit torch like fuel
hardtorch.register_fuel("hardtorch:xdecor_candle_on", {
	turns = candle_nights,
})

-- Register tool
minetest.register_tool("hardtorch:xdecor_candle", {
	description = S("Candle (used)"),
	inventory_image = "xdecor_candle_wield.png",
	wield_image = "xdecor_candle_wield.png",
	groups = {not_in_creative_inventory = 1},
})

-- Lit version tool
minetest.register_tool("hardtorch:xdecor_candle_on", {
	inventory_image = "xdecor_candle_inv.png",
	wield_image = "xdecor_candle_inv.png",
	groups = {not_in_creative_inventory = 1},
})

-- Register Candle
hardtorch.register_torch("hardtorch:xdecor_candle", {
	light_source = minetest.registered_nodes["xdecor:candle"].light_source,
	fuel = {"hardtorch:xdecor_candle_on"},
	nodes = {
		node = "xdecor:candle",
		node_ceiling = "xdecor:candle",
		node_wall = "xdecor:candle"
	},
	sounds = {
		turn_on = {name="hardtorch_acendendo_tocha", gain=0.2},
		turn_off = {name="hardtorch_apagando_tocha", gain=0.2},
		water_turn_off = {name="hardtorch_apagando_tocha", gain=0.2},
	},
})
