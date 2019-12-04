--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	Fuel
  ]]

-- Global Table
-- Tabela Global
hardtorch.registered_fuels = {}

-- Register Fuel
-- Registrar Combustivel
hardtorch.register_fuel = function(name, def)
	
	hardtorch.registered_fuels[name] = {}
	local registro = hardtorch.registered_fuels[name]
	
	registro.turns = def.turns
	registro.time = def.turns * hardtorch.night_time
	registro.loop_wear = (65535/registro.time)*2
	
	-- Override on_place to avoid tool fuel repairs
	-- Sobreescreve on_place para evitar reparos no combustivel em ferramentas
	if minetest.registered_tools[name] then
		hardtorch.registered_fuels[name].old_on_place = minetest.registered_tools[name].on_place
		hardtorch.registered_fuels[name].on_place = function(itemstack, placer, pointed_thing)
			
			-- Check for avoidable nodes
			-- Verifica nodes evitaveis
			if pointed_thing.under and hardtorch.not_place_torch_on[1] then
				
				local nn = minetest.get_node(pointed_thing.under).name
				for _,n in ipairs(hardtorch.not_place_torch_on) do
					if n == nn then
						return
					end
				end
			end
			
			if hardtorch.registered_fuels[name].old_on_place ~= nil then
				return hardtorch.registered_fuels[name].old_on_place(itemstack, placer, pointed_thing)
			end
		end
		
		minetest.override_item(name, {
			on_place = hardtorch.registered_fuels[name].on_place,
		})
	end
end
