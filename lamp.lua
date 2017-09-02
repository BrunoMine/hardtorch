--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Registro de Lamparina
  ]]


local tile_anim = {
	name = "hardtorch_lamp_lado_active.png",
	animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
}



-- Register node de lamparina
local def_lamp = {
	description = "Lamparina",
	stack_max = 1,
	tiles = {
		"hardtorch_lamp_wield_cima.png",
		"hardtorch_lamp_wield_baixo.png",
		"hardtorch_lamp_wield_lado.png",
		"hardtorch_lamp_wield_lado.png",
		"hardtorch_lamp_wield_lado.png",
		"hardtorch_lamp_wield_lado.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}, -- NodeBox1
			{-0.375, -0.5, -0.375, 0.375, 0, 0.375}, -- NodeBox2
			{0.25, -0.375, 0.25, 0.375, 0.5, 0.375}, -- NodeBox3
			{0.25, -0.375, -0.375, 0.375, 0.5, -0.25}, -- NodeBox4
			{-0.375, -0.375, -0.375, -0.25, 0.5, -0.25}, -- NodeBox5
			{-0.375, -0.375, 0.25, -0.25, 0.5, 0.375}, -- NodeBox6
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, -- Vela
			{-0.5, -0.5+1, -0.5, 0.5, -0.375+1, 0.5}, -- NodeBox1
			{-0.25, -0.375+1, -0.25, 0.25, -0.25+1, 0.25}, -- NodeBox2
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-4.5/16, -8/16, -4.5/16, 4.5/16, 2.5/16, 4.5/16},
	},
	sunlight_propagates = true,
	walkable = false,
	liquids_pointable = false,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1},
	sounds = default.node_sound_wood_defaults(),
}

-- Node-ferramenta
minetest.register_node("hardtorch:lamp", minetest.deserialize(minetest.serialize(def_lamp)))
minetest.override_item("hardtorch:lamp", {
	on_place = function(itemstack, placer, pointed_thing)
		
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		
		itemstack:set_name("hardtorch:lamp_node")

		if not minetest.item_place(itemstack, placer, pointed_thing) then
			return itemstack
		end
		
		-- Remove item do inventario
		itemstack:take_item()

		return itemstack
		
	end,
})


-- Node-ferramenta ativo
minetest.register_node("hardtorch:lamp_on", minetest.deserialize(minetest.serialize(def_lamp)))
minetest.override_item("hardtorch:lamp_on", {
	description = "Lamparina Acessa",
	paramtype = "light",
	paramtype = nil,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory = 1},
	tiles = {
		"hardtorch_lamp_wield_cima.png",
		"hardtorch_lamp_wield_baixo.png",
		"hardtorch_lamp_wield_lado_on.png",
		"hardtorch_lamp_wield_lado_on.png",
		"hardtorch_lamp_wield_lado_on.png",
		"hardtorch_lamp_wield_lado_on.png"
	},
})

-- Node 
minetest.register_node("hardtorch:lamp_node", minetest.deserialize(minetest.serialize(def_lamp)))
minetest.override_item("hardtorch:lamp_node", {
	drop = "hardtorch:lamp",
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory = 1},
	tiles = {
		"hardtorch_lamp_cima.png",
		"hardtorch_lamp_baixo.png",
		"hardtorch_lamp_lado.png",
		"hardtorch_lamp_lado.png",
		"hardtorch_lamp_lado.png",
		"hardtorch_lamp_lado.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.25, 0.1875}, -- Tanque
			{-0.1875, -0.5, 0.125, -0.125, 0, 0.1875}, -- Haste1
			{0.125, -0.5, 0.125, 0.1875, 0, 0.1875}, -- Haste2
			{-0.1875, -0.5, -0.1875, -0.125, 0, -0.125}, -- Haste3
			{0.125, -0.5, -0.1875, 0.1875, 0, -0.125}, -- Haste4
			{-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25}, -- Base
			{-0.25, 0, -0.25, 0.25, 0.0625, 0.25}, -- Tampa
			{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125}, -- Tampa2
			{-0.0625, -0.25, -0.0625, 0.0625, 0, 0.0625}, -- Vela
		}
	},
})

-- Node ativo
minetest.register_node("hardtorch:lamp_node_active", minetest.deserialize(minetest.serialize(def_lamp)))
minetest.override_item("hardtorch:lamp_node_active", {
	light_source = 12,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory = 1},
	tiles = {
		"hardtorch_lamp_cima.png",
		"hardtorch_lamp_baixo.png",
		tile_anim,
		tile_anim,
		tile_anim,
		tile_anim
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.25, 0.1875}, -- Tanque
			{-0.1875, -0.5, 0.125, -0.125, 0, 0.1875}, -- Haste1
			{0.125, -0.5, 0.125, 0.1875, 0, 0.1875}, -- Haste2
			{-0.1875, -0.5, -0.1875, -0.125, 0, -0.125}, -- Haste3
			{0.125, -0.5, -0.1875, 0.1875, 0, -0.125}, -- Haste4
			{-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25}, -- Base
			{-0.25, 0, -0.25, 0.25, 0.0625, 0.25}, -- Tampa
			{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125}, -- Tampa2
			{-0.0625, -0.25, -0.0625, 0.0625, 0, 0.0625}, -- Vela
		}
	},
})


-- Registrar Lamparina
hardtorch.register_torch("hardtorch:lamp", {
	description = "Lamparina",
	light_source = 12,
	nodes = {
		node = "hardtorch:lamp_node_active",
	},
	nodes_off = {
		node = "hardtorch:lamp_node",
	},
	fuel = {"hardtorch:oil"},
})


-- Receita da Lamparina
minetest.register_craft({
	output = 'hardtorch:lamp',
	recipe = {
		{'group:stick', 'default:torch', 'group:stick'},
		{'default:steel_ingot', 'default:coal_lump', 'default:steel_ingot'},
		{'group:stick', 'default:steel_ingot', 'group:stick'},
	}
})
