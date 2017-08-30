--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Modificações nos nodes de tocha
  ]]


-- Recuperar o desgaste apos coletado
local on_dig = function(pos, node, digger)
	local meta = minetest.get_meta(pos)
	local inv = digger:get_inventory()
	
	-- Calcula desgaste
	local timer = minetest.get_node_timer(pos)
	local t_rest = timer:get_timeout() - timer:get_elapsed()
	local w_rest = (65535/hardtorch.tempo_tocha)*t_rest
	local itemstack = {name="hardtorch:torch_tool", count=1, wear=65535-w_rest, metadata=""}
	
	-- Verifica se cabe no inventario
	if inv:room_for_item("main", itemstack) then
		-- Coloca no inventario acessa
		inv:add_item("main", itemstack)
	else
		-- Dropa no local
		minetest.add_item(pos, itemstack)
	end
	
	minetest.remove_node(pos)
end


-- Repor sobra de tochas
local repor_sobra = function(pos, player, sobra)
	-- Caso o jogador desconecte deixa tudo no dropado
	if not player then
		minetest.add_item(minetest.deserialize(pos), "default:torch "..sobra)
	end
	
	local inv = player:get_inventory()
	
	-- Verifica se cabe no inventario
	if inv:room_for_item("main", "default:torch "..sobra) then
		-- Coloca no inventario
		inv:add_item("main", "default:torch "..sobra)
	else
		-- Aviso textual
		minetest.chat_send_player(player:get_player_name(), "Tochas restantes cairam do inventario")
		-- Aviso sonoro [NÃO IMPLEMENTADO AINDA]
		
		-- Dropa no chão
		minetest.add_item(minetest.deserialize(pos), "default:torch "..sobra)
	end
end


-- Adiciona uso para tochas substituindo por tocha ferramenta (que será acessa)
local on_use = function(itemstack, player, pointed_thing)
	local sobra = itemstack:get_count() - 1
	
	-- Troca o item por uma tocha acessa
	itemstack:replace({name="hardtorch:torch_tool_on", count=1, wear=0, metadata=""})
	player:set_wielded_item(itemstack)
	
	-- Caso tenha sobra tenta colocar no inventario, ou joga no chão (com aviso sonoro e textual)
	if sobra > 0 then
		repor_sobra(minetest.serialize(player:getpos()), player, sobra)
	end
	
	return hardtorch.acender_tocha(itemstack, player)
end


-- Atualiza as tocha apos colocar
local after_place_node = function(pos, placer, itemstack, pointed_thing)
	
	-- Define desgaste inicial caso necessario
	local meta = minetest.get_meta(pos)
	if not meta:get_int("wear") then
		meta:set_int("wear", 0)
	end
	
	-- Inicia contagem para acabar fogo de acordo com desgaste definido
	minetest.get_node_timer(pos):start((hardtorch.tempo_tocha/65535)*(65535-meta:get_int("wear")))
	
end


-- Remove tocha quando fogo acabar
local on_timer = function(pos, elapsed)
	-- remove bloco
	minetest.remove_node(pos)
end


-- Atualiza tochas com novas funcões de chamadas
minetest.override_item("default:torch", {drop="", on_dig=on_dig, on_use=on_use, after_place_node=after_place_node, on_timer=on_timer})
minetest.override_item("default:torch_ceiling", {drop="", on_dig=on_dig, on_use=on_use, after_place_node=after_place_node, on_timer=on_timer})
minetest.override_item("default:torch_wall", {drop="", on_dig=on_dig, on_use=on_use, after_place_node=after_place_node, on_timer=on_timer})


-- Inicia desgaste em tochas antigas
minetest.register_lbm({
	name = "hardtorch:desgaste_tochas_antigas",
	nodenames = {"default:torch", "default:torch_ceiling", "default:torch_wall"},
	action = function(pos, node)
		-- Define desgaste inicial caso necessario
		local meta = minetest.get_meta(pos)
		if not meta:get_int("wear") then
			meta:set_int("wear", 0)
		end
	
		-- Inicia contagem para acabar fogo de acordo com desgaste definido
		minetest.get_node_timer(pos):start((hardtorch.tempo_tocha/65535)*(65535-meta:get_int("wear")))
	end,
})

