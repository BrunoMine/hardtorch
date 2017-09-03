--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	API
	
  ]]

-- Tabela Global
hardtorch.registered_torchs = {}

-- Registrar tocha
hardtorch.register_torch = function(name, def)
	
	hardtorch.registered_torchs[name] = def
	
	-- Consolidar dados
	hardtorch.registered_torchs[name].sounds = def.sounds or {}
	
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


