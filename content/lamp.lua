--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Oil Lamp
  ]]


-- Used for localization
local S = minetest.get_translator("hardtorch")

-- Oil Lamp light
-- Luminosidade da Lamparina
local lamp_light_source = hardtorch.check_light_number(minetest.settings:get("hardtorch_lamp_light_source") or 13)

local tile_anim = {
	name = "hardtorch_lamp_side_active.png",
	animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
}

-- Tool nodebox
local tool_nodebox = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}, -- NodeBox1
		{-0.125, 0, -0.125, 0.125, 0.5, 0.125}, -- Base1
		{-0.375, -0.375, -0.375, 0.375, 0, -0.125}, -- Base2
		{-0.375, -0.375, 0.125, 0.375, 0, 0.375}, -- Base3
		{-0.375, -0.375, -0.125, -0.125, 0, 0.125}, -- Base4
		{0.125, -0.375, -0.125, 0.375, 0, 0.125}, -- NodeBox5
		{0.25, -0.375, 0.25, 0.375, 0.5, 0.375}, -- NodeBox3
		{0.25, -0.375, -0.375, 0.375, 0.5, -0.25}, -- NodeBox4
		{-0.375, -0.375, -0.375, -0.25, 0.5, -0.25}, -- NodeBox5
		{-0.375, -0.375, 0.25, -0.25, 0.5, 0.375}, -- NodeBox6
		{-0.125, 0, -0.125, 0.125, 0.5, 0.125}, -- Candle
		{-0.5, -0.5+1, -0.5, 0.5, -0.375+1, 0.5}, -- NodeBox1
		{-0.25, -0.375+1, -0.25, 0.25, -0.25+1, 0.25}, -- NodeBox2
	}
}

-- Node nodebox
local node_nodebox = {
	type = "fixed",
	fixed = {
		{-0.1875, -0.4375, 0.0625, 0.1875, -0.25, 0.1875}, -- Tank 1
		{-0.1875, -0.4375, -0.1875, 0.1875, -0.25, -0.0625}, -- Tank 2
		{-0.1875, -0.4375, -0.0625, -0.0625, -0.25, 0.0625}, -- Tank 3
		{0.0625, -0.4375, -0.0625, 0.1875, -0.25, 0.0625}, -- Tank 4
		{-0.1875, -0.5, 0.125, -0.125, 0, 0.1875}, -- Stem 1
		{0.125, -0.5, 0.125, 0.1875, 0, 0.1875}, -- Stem 2
		{-0.1875, -0.5, -0.1875, -0.125, 0, -0.125}, -- Stem 3
		{0.125, -0.5, -0.1875, 0.1875, 0, -0.125}, -- Stem 4
		{-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25}, -- Base
		{-0.25, 0, -0.25, 0.25, 0.0625, 0.25}, -- Cover
		{-0.125, 0.0625, -0.125, 0.125, 0.125, 0.125}, -- Cover 2
		{-0.0625, -0.25, -0.0625, 0.0625, 0, 0.0625}, -- Torch
	}
}

-- Register node
-- Register node de lamparina
local def_lamp = minetest.serialize({
	description = S("Oil Lamp"),
	stack_max = 1,
	tiles = {
		"hardtorch_lamp_wield_top.png",
		"hardtorch_lamp_wield_bottom.png",
		"hardtorch_lamp_wield_side.png",
		"hardtorch_lamp_wield_side.png",
		"hardtorch_lamp_wield_side.png",
		"hardtorch_lamp_wield_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = tool_nodebox,
	selection_box = {
		type = "fixed",
		fixed = {-4.5/16, -8/16, -4.5/16, 4.5/16, 2.5/16, 4.5/16},
	},
	sunlight_propagates = true,
	liquids_pointable = false,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1},
	sounds = default.node_sound_wood_defaults(),
})

-- Oil Lamp node
-- Nó da lamparina
minetest.register_node("hardtorch:lamp", minetest.deserialize(def_lamp))
minetest.override_item("hardtorch:lamp", {
	on_place = function(itemstack, placer, pointed_thing)

		if pointed_thing.type ~= "node" then
			return itemstack
		end

		itemstack:set_name("hardtorch:lamp_node")

		if not minetest.item_place(itemstack, placer, pointed_thing) then
			return itemstack
		end
		
		-- Remove from inventory
		itemstack:take_item()

		return itemstack

	end,
})


-- Oil Lamp lit node
-- Nó da lamparina acesa
minetest.register_node("hardtorch:lamp_on", minetest.deserialize(def_lamp))
minetest.override_item("hardtorch:lamp_on", {
	description = S("Oil Lamp Lit"),
	paramtype = "light",
	paramtype = nil,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory = 1},
	tiles = {
		"hardtorch_lamp_wield_top.png",
		"hardtorch_lamp_wield_bottom.png",
		"hardtorch_lamp_wield_side_on.png",
		"hardtorch_lamp_wield_side_on.png",
		"hardtorch_lamp_wield_side_on.png",
		"hardtorch_lamp_wield_side_on.png"
	},
})

-- Node
minetest.register_node("hardtorch:lamp_node", minetest.deserialize(def_lamp))
minetest.override_item("hardtorch:lamp_node", {
	drop = "hardtorch:lamp",
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory = 1},
	tiles = {
		"hardtorch_lamp_top.png",
		"hardtorch_lamp_bottom.png",
		"hardtorch_lamp_side.png",
		"hardtorch_lamp_side.png",
		"hardtorch_lamp_side.png",
		"hardtorch_lamp_side.png"
	},
	node_box = node_nodebox,
})

-- Active node
minetest.register_node("hardtorch:lamp_node_active", minetest.deserialize(def_lamp))
minetest.override_item("hardtorch:lamp_node_active", {
	light_source = lamp_light_source,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1, not_in_creative_inventory = 1},
	tiles = {
		"hardtorch_lamp_top.png",
		"hardtorch_lamp_bottom.png",
		tile_anim,
		tile_anim,
		tile_anim,
		tile_anim
	},
	node_box = node_nodebox,
})


-- Register Oil Lamp
-- Registrar Lamparina
hardtorch.register_torch("hardtorch:lamp", {
	light_source = lamp_light_source,
	drop_on_water = false,
	nodes = {
		node = "hardtorch:lamp_node_active",
	},
	nodes_off = {
		node = "hardtorch:lamp_node",
	},
	sounds = {
		turn_on = {name="hardtorch_click_oil_lamp", gain=0.2},
		turn_off = {name="hardtorch_click_oil_lamp", gain=0.2},
		water_turn_off = {name="hardtorch_turnoff_torch", gain=0.2},
	},
	fuel = {"hardtorch:oil"},
})


-- Oil Lamp recipe
-- Receita da Lamparina
minetest.register_craft({
	output = 'hardtorch:lamp',
	recipe = {
		{'group:stick', 'default:coal_lump', 'group:stick'},
		{'default:steel_ingot', 'default:coal_lump', 'default:steel_ingot'},
		{'group:stick', 'default:steel_ingot', 'group:stick'},
	}
})

