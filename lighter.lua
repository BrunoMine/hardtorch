--[[
	Mod HardTorch for Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>5.
	
	Lighter
  ]]

-- Global Table
-- Tabela global
hardtorch.registered_lighters = {}

-- Register lighter
-- Registrar Acendedor
hardtorch.register_lighter = function(name, def)
	hardtorch.registered_lighters[name] = def
end

