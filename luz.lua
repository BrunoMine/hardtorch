--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Iluminação
	
  ]]



-- Pegar coordenada de luz
hardtorch.get_lpos = function(player)
	local p = minetest.deserialize(minetest.serialize(player:getpos()))
	p.y = p.y+1
	return minetest.deserialize(minetest.serialize(p))
end


-- Nodes de luz
for _,light in ipairs({"6", "7", "8", "9", "10", "11", "12", "13", "14"}) do
	minetest.register_node("hardtorch:luz_"..light, {
		drawtype = "airlike",
		groups = {not_in_creative_inventory = 1},
		walkable = false,
		paramtype = "light",
		sunlight_propagates = true,
		light_source = tonumber(light),
		pointable = false,
		buildable_to = true,
		drops = {},
		on_timer = function(pos, elapsed)
			local meta = minetest.get_meta(pos)
			-- Verifica se jogador ainda tem luz no local
			if hardtorch.em_loop[meta:get_string("nome")] then
				return true -- Repete loop do timer
			end
			-- remove bloco
			minetest.dig_node(pos)
		end,
	})
end


-- Loop de luz para jogadores (faz a luz acompanhar jogador)
hardtorch.loop_luz = function(name, torchname)
	
	if not hardtorch.em_loop[name] then return end
	
	local player = minetest.get_player_by_name(name)
	if not player then return end
	
	-- Verifica se pos atual tem luz
	local lpa = hardtorch.get_lpos(player) -- coordenada onde deve ter luz atualmente
	local lpos = hardtorch.em_loop[name].lpos
	if not string.match(minetest.get_node(lpa).name, "hardtorch:luz_") then
		
		-- Remove luz do local antigo
		if string.match(minetest.get_node(lpos).name, "hardtorch:luz_") then
			minetest.dig_node(lpos)
		end
		
		-- Coloca no novo local
		if minetest.get_node(lpa).name == "air" then
			minetest.place_node({x=lpa.x,y=lpa.y+1,z=lpa.z}, {name="hardtorch:luz_"..hardtorch.registered_torchs[torchname].light_source})
		end
		local meta = minetest.get_meta(lpa)
		meta:set_string("nome", name)
		minetest.get_node_timer(lpa):start(1)
		
		-- Salva novo local de luz atual do jogador
		hardtorch.em_loop[name].lpos = minetest.deserialize(minetest.serialize(lpa))
		
	end
	minetest.after(0.45, hardtorch.loop_luz, name, torchname)
	
end


-- Forças extinção de luz
hardtorch.apagar_node_luz = function(name)
	if hardtorch.em_loop[name] 
		and hardtorch.em_loop[name].lpos
		and string.match(minetest.get_node(hardtorch.em_loop[name].lpos).name, "hardtorch:luz_") 
	then
		minetest.remove_node(hardtorch.em_loop[name].lpos)
	end
end

