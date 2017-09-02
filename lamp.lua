--[[
	Mod HardTorch para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Registro de Lamparina
  ]]


-- Noites de durabilidade da tocha
local torch_nights = math.abs(tonumber(minetest.setting_get("hardtorch_lamp_nights") or 1)) 
if torch_nights <= 0 then torch_nights = 1 end

local tile_anim = {
	name = "hardtorch_lamp_lado_active.png",
	animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
}

-- Register node de lamparina
local def_lamp = {
	description = "Lamparina",
	tiles = {
		"hardtorch_lamp_cima.png",
		"hardtorch_lamp_baixo.png",
		"hardtorch_lamp_lado.png",
		"hardtorch_lamp_lado.png",
		"hardtorch_lamp_lado.png",
		"hardtorch_lamp_lado.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
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
	selection_box = {
		type = "fixed",
		fixed = {-4.5/16, -8/16, -4.5/16, 4.5/16, 2.5/16, 4.5/16},
	},
	sunlight_propagates = true,
	walkable = false,
	liquids_pointable = false,
	light_source = 12,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1},
	sounds = default.node_sound_wood_defaults(),
}

-- Node-ferramenta
minetest.register_node("hardtorch:lamp", minetest.deserialize(minetest.serialize(def_lamp)))

-- Node-ferramenta ativo
minetest.register_node("hardtorch:lamp_on", minetest.deserialize(minetest.serialize(def_lamp)))
minetest.override_item("hardtorch:lamp_on", {
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory = 1},
	tiles = {
		"hardtorch_lamp_cima.png",
		"hardtorch_lamp_baixo.png",
		tile_anim,
		tile_anim,
		tile_anim,
		tile_anim
	},
})

-- Node ativo
minetest.register_node("hardtorch:lamp_active", minetest.deserialize(minetest.serialize(def_lamp)))
minetest.override_item("hardtorch:lamp_active", {
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory = 1},
	tiles = {
		"hardtorch_lamp_cima.png",
		"hardtorch_lamp_baixo.png",
		tile_anim,
		tile_anim,
		tile_anim,
		tile_anim
	},
})


-- Registrar Lamparina
hardtorch.register_torch("hardtorch:lamp", {
	description = "Lamparina",
	night_turns = torch_nights,
	light_source = 14,
	nodes = {
		node = "hardtorch:lamp_active",
	},
	fuel = {"hardtorch:oil"},
})

-- Oleo de lamparina
minetest.register_tool("hardtorch:oil", {
	description = "Oleo de Lamparina",
	inventory_image = "hardtorch_oil.png",
	stack_max = 1,
})

hardtorch.register_fuel("hardtorch:oil", {
	turns = 3,
})

-- Receitas

minetest.register_craft({
	output = 'hardtorch:oil',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'group:leaves', 'group:leaves'},
	}
})

minetest.register_craft({
	output = 'hardtorch:lamp',
	recipe = {
		{'group:stick', 'default:torch', 'group:stick'},
		{'default:steel_ingot', 'default:coal_lump', 'default:steel_ingot'},
		{'group:stick', 'default:steel_ingot', 'group:stick'},
	}
})
