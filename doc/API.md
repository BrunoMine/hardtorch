HardTorch API Reference
=======================

Introduction
------------
This mod has some methods for registering torches, fuels and lighters as well as other resources 
to support the development of other modifications to maintain compatibility.

### Torchs
When registering a torch, no item (node ​​or tool) is created. The API will modify items already 
registered in Minetest to work as a single item which is the torch. Therefore, all art and 
physical aspects of such items are not performed by the API and must be pre-created, this allows 
for further customization of each torch.
The items that must be previously created and that will be used to register the torch are:

* Torch: Tool type item that will be used as an unlit torch in the inventory.
  * ´on_use´ and ´on_place´ params are reset by the API.
* Lit torch: Tool type item that will be used as an lit torch in the inventory.
  * This item must have the same itemstring as the unlit torch with the addition of the suffix "_on".
  * ´wield_image´, ´on_use´, ´on_drop´ and ´on_place´ param are reset by the API.
* Torch node: Node type item that will be placed as an unlit torch.
* Lit torch node: Node type item that will be placed as an lit torch.
  * ´drop´, ´on_dig´, ´on_use´, ´after_place_node´, ´on_timer´ and ´on_place´ params are reset by the API.
* Fuel: Tool type item that will be worn while the torch is lit.

### Fuels
Fuel is a tool item that will be consumed while the player has a torch lit or passed on to 
the lit torch that is placed as a block. All fuels need to be previously registered as such 
by the corresponding method.

### Lighters
The igniter is a tool-type item used to light a torch in the inventory. All lighters need to be 
previously registered as such by the corresponding method. The need for the igniter is disabled 
by default in the game settings.

### Fire sources
Fire sources are blocks that can be used to light a torch. Nodes that can be used as a fire source 
need to be inserted in the corresponding table.
The need for the fire source to light torches is disabled by default in the game settings.

Examples:
```lua
hardtorch.fire_sources["default:furnace_active"] = true
hardtorch.fire_sources["default:lava_flowing"] = true
hardtorch.fire_sources["fire:permanent_flame"] = true
```

### Methods
* `hardtorch.register_torch(itemstring, {torch definition})`: Register a torch.
* `hardtorch.register_fuel(itemstring, {fuel definition})`: Register a fuel.
* `hardtorch.register_lighter(itemstring, {lighter definition})`: Register a lighter.

### Global table
* `hardtorch.registered_torchs`: Registered torch definitions, indexed by torch name.
* `hardtorch.registered_fuels`: Registered fuel definitions, indexed by fuel name.
* `hardtorch.registered_lighters`: Registered lighter definitions, indexed by lighter name.
* `hardtorch.registered_nodes`: Registered node torch definitions, indexed by node name.
* `hardtorch.fire_sources`: List of fire sources, indexed by node name.
* `hardtorch.not_place_torch_on`: List of avoidable nodes to place torch nodes, not indexed.

#### Torch definition (`register_torch`)

    {
        light_source = 13, 	-- Torch illumination intensity (maximum is 14)
        
        fuel = {"itemfuel1", "itemfuel_2"}, -- List of fuels
        
        works_in_water = false, 		-- Torch works in water (if `true` ignores `drop_in_water` param) <optional>
        
        drop_on_water = "dropped_item", 	-- Dropped item if wet torch (if `false`, the torch will not drop) <optional>
        
        nodes = { 				-- Nodes for lit torch
            node = "default_node", 		-- Lit torch node
            node_ceiling = "node_ceiling", 	-- Node ceiling <optional>
            node_wall = "node_wall", 	-- Node on wall <optional>
            fire_source = true, 		-- Register nodes like a fire source (default is `true`) <optional>
        } 
        
        nodes_off = { 			-- Nodes for unlit torch
            node = "unlit_torch_node", 	-- Unlit torch node
            node_ceiling = "node_ceiling", 	-- Node ceiling <optional>
            node_wall = "node_wall", 	-- Node on wall <optional>
        },
        
        sounds = { 				-- Sounds
            turn_on = {sound definition}, 	-- Turn on torch sound
            turn_off = {sound definition}, 	-- Turn off (generically) torch sound
            water_turn_off = {sound definition}, -- Turn off torch by water sound
        },
        
    }

#### Fuel definition (`register_fuel`)

    {
        turns = 1.0, 	-- Durability (in nights)
    }

#### Lighter definition (`register_lighter`)

    {
        wear_by_use = 100, 	-- Lighter wear by use
    }

#### Sound definition

    {
        name = "sound_name", 	-- Sound name (filename without suffix ".ogg")
        gain = 1.0, 		-- Volume gain
    }




