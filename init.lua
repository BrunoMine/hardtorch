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
hardtorch.tempo_tocha = tonumber(minetest.setting_get("hardtorch_tempo_tocha") or 300)


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
