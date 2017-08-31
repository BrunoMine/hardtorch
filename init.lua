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


-- Tempo de permanencia da tocha acessa (em segundos)
local velocidade_tempo = tonumber(minetest.setting_get("time_speed") or 72)
local torch_nights = math.abs(tonumber(minetest.setting_get("hardtorch_torch_nights") or 1)) -- Noites de durabilidade da tocha
if torch_nights < 0.1 then torch_nights = 1 end
hardtorch.tempo_tocha = (torch_nights*(12*60*60))/velocidade_tempo
-- Tempo fixo (sobreescreve caso definido)
if tonumber(minetest.setting_get("hardtorch_torch_time") or 0) > 10 then
	hardtorch.tempo_tocha = tonumber(minetest.setting_get("hardtorch_torch_time") or hardtorch.tempo_tocha)
end

-- Requerer fonte de fogo para acender tocha
hardtorch.torch_lighter = minetest.setting_getbool("hardtorch_torch_lighter") or false

hardtorch.fontes_de_fogo = {
	["default:furnace_active"] = true,
	["default:lava_flowing"] = true,
	["default:lava_source"] = true,
	["fire:basic_flame"] = true,
	["fire:permanent_flame"] = true,
	["default:torch"] = true,
	["default:torch_ceiling"] = true,
	["default:torch_wall"] = true,
}

hardtorch.acendedores = {
	["fire:flint_and_steel"] = 1000,
}



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
dofile(modpath.."/luz.lua")
dofile(modpath.."/tool.lua")
dofile(modpath.."/node_torch.lua")
notificar("[OK]!")
