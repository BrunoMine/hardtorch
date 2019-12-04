--[[
	Mod HardTorch for Minetest
	Copyright (C) 2017-2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
	
	API
  ]]

-- Torchs table
-- Tabela de tochas
hardtorch.registered_torchs = {}

-- Register torch
-- Registrar tocha
hardtorch.register_torch = function(name, def)
	
	-- Consolidate data
	-- Consolidar dados
	def.sounds = def.sounds or {}
	def.drop_on_water = def.drop_on_water or true
	
	hardtorch.registered_torchs[name] = def
	
	-- Register tools (off and on)
	-- Registrar ferramentas (apagada e acesa)
	hardtorch.register_tool(name, def)
	
	-- Register node
	-- Registrar node
	hardtorch.register_node(name, def)
	
	-- Turn off the torch on joining the server
	-- Desligue a tocha ao ingressar no servidor
	minetest.register_on_joinplayer(function(player)
		if hardtorch.find_item(player, name.."_on") == true then
			hardtorch.turnoff_torch(player, name)
		end
	end)
end


-- Lighters table
-- Tabela de acendedores
hardtorch.registered_lighters = {}

-- Register lighter
-- Registrar Acendedor
hardtorch.register_lighter = function(name, def)
	hardtorch.registered_lighters[name] = def
end
