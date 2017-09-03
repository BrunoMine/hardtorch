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

-- Nodes que funcionam como fontes de fogo para acender tochas
hardtorch.fontes_de_fogo = {}

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
dofile(modpath.."/lighter.lua")
dofile(modpath.."/fuel.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/torch.lua")
dofile(modpath.."/oil.lua")
dofile(modpath.."/lamp.lua")
notificar("[OK]!")


-- Pré ajustes

-- Acendedor de pederneira
hardtorch.register_lighter("fire:flint_and_steel", {
	wear_by_use = 1000
})

-- Nodes fonte de fogo
hardtorch.fontes_de_fogo["default:furnace_active"] = true
hardtorch.fontes_de_fogo["default:lava_flowing"] = true
hardtorch.fontes_de_fogo["default:lava_source"] = true
hardtorch.fontes_de_fogo["fire:basic_flame"] = true
hardtorch.fontes_de_fogo["fire:permanent_flame"] = true
	
	
