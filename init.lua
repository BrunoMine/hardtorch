--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
  ]]


-- Global Tables

-- API Table
-- Tabela da API
hardtorch = {}

-- Players in loop to lit torch
-- Jogadores em loop de tocha acesa
hardtorch.in_loop = {}

-- Fire sources (nodes that act as fire sources to light torches)
-- Fontes de fogo (nodes que funcionam como fontes de fogo para acender tochas)
hardtorch.fire_sources = {}

-- Nodes to avoid when placing torches
-- Nodes para evitar ao colocar tochas
hardtorch.not_place_torch_on = {}



-- Load settings

-- Require fire source to light torch
-- Requerer fonte de fogo para acender tocha
hardtorch.torch_lighter = (minetest.settings:get("hardtorch_torch_lighter") == "true") or false

-- Fixed time for a night
-- Tempo fixo de duração de uma noite
hardtorch.night_time = tonumber(minetest.settings:get("hardtorch_fixed_night_time") or 0)
if hardtorch.night_time == 0 then
	local time_speed = tonumber(minetest.setting_get("time_speed") or 72)
	if time_speed == 0 then
		time_speed = 72
	end
	hardtorch.night_time = (12*60*60)/time_speed
end



-- Load scripts

-- Notify load
-- Notificador de Inicializador
local notify = function(msg)
	if minetest.settings:get("log_mods") then
		minetest.debug("[HardTorch] "..msg)
	end
end

-- Modpath
local modpath = minetest.get_modpath("hardtorch")

notify("Loading...")
-- API features
dofile(modpath.."/features/common.lua")
dofile(modpath.."/features/light.lua")
dofile(modpath.."/features/tool.lua")
dofile(modpath.."/features/node.lua")
dofile(modpath.."/features/fuel.lua")
dofile(modpath.."/features/api.lua")
-- Content
dofile(modpath.."/content/oil.lua")
dofile(modpath.."/content/torch.lua")
dofile(modpath.."/content/lamp.lua")
dofile(modpath.."/content/xdecor_candle.lua")
notify("OK!")



-- Presets
-- Pré ajustes

-- Lighter Flint and Steel
-- Acendedor de pederneira
hardtorch.register_lighter("fire:flint_and_steel", {
	wear_by_use = 1000
})

-- Fire source nodes
-- Nodes fonte de fogo
hardtorch.fire_sources["default:furnace_active"] = true
hardtorch.fire_sources["default:lava_flowing"] = true
hardtorch.fire_sources["default:lava_source"] = true
hardtorch.fire_sources["fire:basic_flame"] = true
hardtorch.fire_sources["fire:permanent_flame"] = true

-- Campfire mod
if minetest.get_modpath("campfire") then
	hardtorch.fire_sources["campfire:campfire_active"] = true
end

-- Anvil mod
if minetest.get_modpath("anvil") then
	table.insert(hardtorch.not_place_torch_on, "anvil:anvil")
end
