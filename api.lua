--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	API
	
  ]]

-- Registrar Combustivel
hardtorch.register_fuel = function(name, def)
	
	hardtorch.registered_fuels[name] = {}
	local registro = hardtorch.registered_fuels[name]
	
	registro.turns = def.turns
	registro.time = (def.turns*(12*60*60))/tonumber(minetest.setting_get("time_speed") or 72)
	registro.loop_wear = (65535/registro.time)*2
	
end


-- Registrar tocha
hardtorch.register_torch = function(name, def)
	
	hardtorch.registered_torchs[name] = def
	
	-- Consolidar dados
	hardtorch.registered_torchs[name].sounds = def.sounds or {}
	
	-- Tempo de durabilidade em segundos
	hardtorch.registered_torchs[name].torch_time = (def.night_turns*(12*60*60))/tonumber(minetest.setting_get("time_speed") or 72)
	hardtorch.registered_torchs[name].loop_wear = (65535/hardtorch.registered_torchs[name].torch_time)*2
	
	-- Cria as ferramentas
	hardtorch.register_tool(name, def)
	
	-- Registrar node
	hardtorch.register_node(name, def)
	
	-- Certifica que jogador que acabou de entrar esteja com tocha acessa, caso contrario apaga ela
	minetest.register_on_joinplayer(function(player)
		if hardtorch.find_item(player, name.."_on") == true then
			hardtorch.apagar_tocha(player, name)
		end
	
	end)
end
