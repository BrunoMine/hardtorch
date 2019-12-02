API de Desenvolvimento Lua para mod HardTorch 0.5.0
===================================================

Introdução
---------------------------------------------------
Esse Mod possui alguns metodos para registrar 
tochas e combustiveis compativeis, bem como outros 
recursos para apoiar o desenvolvimento de outras 
modificações afim de manter compatibilidade.

### Registros
Ao registrar uma tocha, nenhum item (node, tool e etc) 
é criado, o registro serve apenas para que a API faça 
com que um determinado item, ou conjunto de itens, funcionem 
de maneira sistematica para funcionarem como uma tocha.

Geralmente uma tocha é composta por varios itens os quais 
a funcionam de forma sistematica para parecerem uma simples 
tocha no jogo. Essa sistematização foi elaborada para permitir 
ao desenvolvedor personalizar o maior número de caracteristicas 
dos itens.

Ao ver os parametros fornecidos ao registrar uma tocha, 
combustivel ou qualquer outra coisa, verifique as mudanças 
que serão realizadas nos itens que serão usados para a formação 
da tocha, combustivel ou outro.

* `hardtorch.register_torch(name, definições da tocha)`: Registra uma ferramenta de iluminação
    * `name`: Itemstring da tocha. Chamadas (Callbacks) `on_use` e `on_place` são alterados pela API.
    * Um item com itemstring igual a `name` com prefixo "_on" precisa estar registrado em Minetest
      e representara a ferramenta acesa. Chamadas (Callbacks) `on_use`, `on_drop` e `on_place` 
      são alterados pela API.
    * Adiciona tocha registrada em `hardtorch.registered_torchs`
    
* `hardtorch.register_fuel(name, definições do combustivel)`: Registra uma combustivel
    * `name`: Nome do item do tipo ferramenta que vai representar o combustivel
    * Adiciona combustivel registrado em `hardtorch.registered_fuels`
    
* `hardtorch.register_lighter(name, definições do acendedor)`: Registra um acendedor
    * `name`: Nome do item do tipo ferramenta que vai representar o acendedor
    * Adiciona combustivel registrado em `hardtorch.registered_lighters`

### Definições do node (`register_torch`)
{
	light_source = 13, --[[
        ^ Intensidade de iluminação da tocha ao ser segurada acesa
	^ Mínimo é 1 e máximo é 14 ]]
        
        nodes = { --[[
        ^ Todos os nodes informados terão as chamadas (callbacks) `on_dig`, `on_use`, `on_timer` 
          e `after_place_node`. Parametro `drop` do node tambem será mudado.]]
        	fire_source = true, --[[
        	^ Registra automaticamente esses nodes como fontes de fogo 
        	^ Se omitido, serão registrados ]] 
		node = "default:torch", -- Node que ilumina quando colocado no mapa
		node_ceiling = "default:torch_ceiling", -- Opcional para nodes wallmounted
		node_wall = "default:torch_wall", -- Opcional para nodes wallmounted
	},
	
	nodes_off = { -- Nodes que representam a tocha esgotada.
		node = "default:torch_off", -- Node apagado quando colocado no mapa
		node_ceiling = "default:torch_off_ceiling", -- Opcional para nodes wallmounted
		node_wall = "default:torch_off_wall", -- Opcional para nodes wallmounted
	},
	
	sounds = {
		turn_on = {name="sound_file", gain=1.0}, -- Som emitido ao acender a tocha
		turn_off = {name="sound_file", gain=1.0}, -- Som emitido apagar a tocha
		water_turn_off = {name="sound_file", gain=1.0}, -- Som emitido ao apagar a tocha quando em contato com agua
	},
	
	fuel = {"mymod:fuel_1", "mymod:fuel_2"}, --[[
	^ Lista de itens consumiveis 
	^ Precisam ser ferramentas desgastaveis ]]
	
	drop_on_water = "", --[[
	^ Itemstring do item dropado quando a tocha é apagada pela agua 
	^ Se omitido, dropa a propria tocha apagada ]]
}

### Definições do combustivel (`register_fuel`)
{
	turns = 1.0,
	^ Noites de duração
}

### Definições do acendedor (`register_lighter`)
{
	wear_by_use = 1000,
	^ Desgaste causado na ferramenta
}




