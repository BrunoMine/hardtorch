--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Light
  ]]


-- Get light position
-- Pegar coordenada de luz
hardtorch.get_lpos = function(player)
	local p = table.copy(player:get_pos())
	p.y = p.y + 1
	
	return table.copy(p)
end


-- Check light
-- Verificar luz
local check_light_node = function(pos)
	local meta = minetest.get_meta(pos)
	if meta:get_string("name") == "" then
		minetest.add_node(pos, {name="hardtorch:light_0"})
		minetest.remove_node(pos)
	end
end


-- Light nodes
-- Nodes de luz
local light_nodes = {}
for _,light in ipairs({"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"}) do
	table.insert(light_nodes, "hardtorch:light_"..light)
	minetest.register_node("hardtorch:light_"..light, {
		drawtype = "airlike",
		groups = {not_in_creative_inventory = 1},
		walkable = false,
		paramtype = "light",
		sunlight_propagates = true,
		light_source = tonumber(light),
		pointable = false,
		buildable_to = true,
		drop = {},
		on_place = function(itemstack, placer, pointed_thing)
			itemstack:clear()
			minetest.after(1, check_light_node, pointed_thing.above)
			return itemstack
		end,
		on_timer = function(pos, elapsed)
			local meta = minetest.get_meta(pos)
			
			-- Check if player still has light
			-- Verifica se jogador ainda tem luz no local
			if hardtorch.in_loop[meta:get_string("name")] 
				and vector.equals(hardtorch.in_loop[meta:get_string("name")].lpos, pos) == true
			then
				-- Continue to the next timer
				-- Repete loop do timer
				return true 
			end
			
			-- Remove node
			minetest.remove_node(pos)
		end,
		on_drop = function(itemstack, dropper, pos)
			itemstack:clear()
			return itemstack
		end,
	})
	
	-- Convert old light nodes
	minetest.register_alias(
		"hardtorch:luz_"..light, 
		"hardtorch:light_"..light
	)
end


-- Light loop for players (makes light follow player)
-- Loop de luz para jogadores (faz a luz acompanhar jogador)
hardtorch.light_loop = function(name, torchname)
	
	if not hardtorch.in_loop[name] then return end
	
	local player = minetest.get_player_by_name(name)
	if not player then return end
	
	-- Checks if current pos has light
	-- Verifica se pos atual tem luz
	local current_light_pos = hardtorch.get_lpos(player)
	local last_light_pos = hardtorch.in_loop[name].lpos
	if not string.match(minetest.get_node(current_light_pos).name, "hardtorch:light_") then
		
		-- Remove light from last position
		-- Remove luz do local antigo
		if string.match(minetest.get_node(last_light_pos).name, "hardtorch:light_") then
			minetest.remove_node(last_light_pos)
		end
		
		-- Set light on new position
		-- Coloca luz no novo local
		if minetest.get_node(current_light_pos).name == "air" then
			minetest.add_node(current_light_pos, {name="hardtorch:light_"..hardtorch.registered_torchs[torchname].light_source})
		end
		local meta = minetest.get_meta(current_light_pos)
		
		meta:set_string("name", name)
		minetest.get_node_timer(current_light_pos):start(1)
		
		-- Save new light position for this player
		-- Salva novo local de luz desse jogar
		hardtorch.in_loop[name].lpos = hardtorch.round_pos(current_light_pos)
	end
	minetest.after(0.45, hardtorch.light_loop, name, torchname)
	
end


-- Force light extinction
-- Força extinção de luz
hardtorch.apagar_node_luz = function(name)
	if hardtorch.in_loop[name] 
		and hardtorch.in_loop[name].lpos
		and string.match(minetest.get_node(hardtorch.in_loop[name].lpos).name, "hardtorch:light_") 
	then
		minetest.remove_node(hardtorch.in_loop[name].lpos)
	end
end


-- Remove residual light
-- Remove luz residual indevida
minetest.register_lbm({
	label = "Remove residual light",
	name = "hardtorch:remove_light",
	nodenames = light_nodes,
	run_at_every_load = true,
	action = function(pos, node)
		minetest.remove_node(pos)
	end,
})
