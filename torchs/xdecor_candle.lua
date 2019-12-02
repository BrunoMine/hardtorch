--[[
	Mod HardTorch para Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)

	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>.

	Registro de Vela (candle) do mod xdecor
  ]]

if minetest.registered_nodes["xdecor:candle"] == nil then return end

-- Used for localization

local S = minetest.get_translator("hardtorch")

-- Luminosidade da lamparina
local candle_light_source = hardtorch.check_light_number(minetest.settings:get("hardtorch_xdecor_candle_light_source") or 7)

-- Noites de durabilidade da tocha
local candle_nights = math.abs(tonumber(minetest.settings:get("hardtorch_xdecor_candle_nights") or 0.8))
if candle_nights <= 0 then candle_nights = 0.8 end


-- Ajuste na vela (candle) do mod xdecor
do
	minetest.override_item("xdecor:candle", {
		-- Muda imagem para jogador saber que tem que acendela
		inventory_image = "xdecor_candle_wield.png",
		wield_image = "xdecor_candle_wield.png",
		light_source = candle_light_source
	})
end


-- Registra a tocha acessa como um combustivel
hardtorch.register_fuel("hardtorch:xdecor_candle_on", {
	turns = candle_nights,
})

-- Registrar ferramentas
minetest.register_tool("hardtorch:xdecor_candle", {
	description = S("Candle (used)"),
	inventory_image = "xdecor_candle_wield.png",
	wield_image = "xdecor_candle_wield.png",
	groups = {not_in_creative_inventory = 1},
})

-- Versao acessa da ferramenta
minetest.register_tool("hardtorch:xdecor_candle_on", {
	inventory_image = "xdecor_candle_inv.png",
	wield_image = "xdecor_candle_inv.png",
	groups = {not_in_creative_inventory = 1},
})

-- Registrar tocha
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
