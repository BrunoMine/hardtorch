--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]


-- Tabela Global
hardtorch = {}


-- Tabela de jogadores em loop de tocha acessa
hardtorch.em_loop = {}

-- Requerer fonte de fogo para acender tocha
hardtorch.torch_lighter = minetest.setting_getbool("hardtorch_torch_lighter") or false

hardtorch.fontes_de_fogo = {
	["default:furnace_active"] = true,
	["default:lava_flowing"] = true,
	["default:lava_source"] = true,
	["fire:basic_flame"] = true,
	["fire:permanent_flame"] = true,
}

hardtorch.acendedores = {
	["fire:flint_and_steel"] = 1000,
}

hardtorch.registered_fuels = {}

hardtorch.registered_torchs = {}


-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[HardTorch]"..msg)
	end
end

-- Modpath
local modpath = minetest.get_modpath("hardtorch")


-- Carregar scripts
notificar("Carregando...")
-- Metodos gerais
dofile(modpath.."/comum.lua")
dofile(modpath.."/luz.lua")
dofile(modpath.."/tool.lua")
dofile(modpath.."/node.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/torch.lua")
dofile(modpath.."/oil.lua")
dofile(modpath.."/lamp.lua")
notificar("[OK]!")
