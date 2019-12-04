API de Desenvolvimento Lua para o mod HardTorch
===============================================

Introdução
----------
Esse mod possui alguns métodos para registrar tochas, combustíveis e acendedores, bem como outros 
recursos para apoiar o desenvolvimento de outras modificações afim de manter compatibilidade.

### Tochas
Ao registrar uma tocha, nenhum item (nó ou ferramenta) é criado. A API modificara os itens já 
registrados em Minetest para funcionarem como um único item que é a tocha. Portanto, toda a 
arte e aspectos físicos de tais itens não são realizados pela API e devem ser previamente criados, 
isso permite mais personalização de cada tocha. 
Os itens que devem ser previamente criados, e que serão usados para registrar a tocha são:

* Tocha: Item do tipo ferramenta que será usado como tocha apagada no inventario.
  * Parâmetros ´on_use´ e ´on_place´ são redefinidos pela API.
* Tocha acesa: Item do tipo ferramenta que será usado como tocha acesa no invenario.
  * Esse item deve possuir o mesmo itemstring da tocha apagada com a adição do sufixo "_on".
  * Parâmetros ´wield_image´, ´on_use´, ´on_drop´ e ´on_place´ são redefinidos pela API.
* Bloco de tocha: Item do tipo nó/bloco que será colocado como uma tocha apagada.
* Bloco de tocha acesa: Item do tipo nó/bloco que será colocado como uma tocha acesa.
  * Parâmetros ´drop´, ´on_dig´, ´on_use´, ´after_place_node´, ´on_timer´ e ´on_place´ são redefinidos pela API.
* Combustível: Item do tipo ferramenta que será desgastado enquanto a tocha estiver acesa.

### Combustíveis
O combustível é um item do tipo ferramenta que será consumido enquanto o jogador estiver com uma 
tocha acesa ou repassado para a tocha acesa que for colocada como bloco. Todos os combustíveis 
precisam ser previamente registrados como tal através do método correspondente.

### Acendedores
O acendedor é um item do tipo ferramenta usado para acender uma tocha no inventario. Todos os 
acendedores precisam ser previamente registrados como tal através do método correspondente. 
A necessidade do acendedor é desabilitada por padrão nas configurações de jogo.

### Fontes de calor
As fontes de calor são blocos que podem ser usados para acender uma tocha. Os nodes que podem ser 
usados como fonte de calor precisar ser inseridos na tabela correspondente.
A necessidade da fonte de calor para acender tochas é desabilitada por padrão nas configurações de jogo.

Exemplos:
```lua
hardtorch.fire_sources["default:furnace_active"] = true
hardtorch.fire_sources["default:lava_flowing"] = true
hardtorch.fire_sources["fire:permanent_flame"] = true
```

### Métodos
* `hardtorch.register_torch(itemstring, {definições da tocha})`: Registra uma tocha.
* `hardtorch.register_fuel(itemstring, {definições do combustível})`: Registra uma combustível.
* `hardtorch.register_lighter(itemstring, {definições do acendedor})`: Registra um acendedor.

### Tabelas globais
* `hardtorch.registered_torchs`: Definições de tochas registradas, indexado por itemstring.
* `hardtorch.registered_fuels`: Definições de combustíveis registrados, indexado por itemstring.
* `hardtorch.registered_lighters`: Definições de acendedores registrados, indexado por itemstring.
* `hardtorch.registered_nodes`: Definições de nós/blocos de tocha registrados, indexado por itemstring.
* `hardtorch.fire_sources`: Lista de fontes de calor, indexado por itemstring.
* `hardtorch.not_place_torch_on`: Lista de nós/blocos evitaveis para colocação de tochas, não indexado.

#### Definições da tocha (`register_torch`)

    {
        light_source = 13, 	-- Intensidade de iluminação da tocha (máximo é 14)
        
        fuel = {"combust1", "combust2"}, 	-- Lista de combustíveis
        
        works_in_water = false, 		-- Tocha funciona na agua (se `true`, ignora o parametro `drop_in_water`) <opicional>
        
        drop_on_water = "item_dropado", 	-- Item caido se molhar a tocha (se `false`, a tocha não cairá) <opicional>
        
        nodes = { 				-- Blocos de tocha acesa
            node = "bloco_padrao", 		-- Bloco aceso
            node_ceiling = "bloco_no_teto", -- Bloco colocado no teto <opicional>
            node_wall = "bloco_na_parede", 	-- Bloco colocado na parede <opicional>
            fire_source = true, 		-- Registra como fonte de fogo (padrão é `true`) <opicional>
        },
        
        nodes_off = { 			-- Blocos de tocha apagada
            node = "bloco_padrao_apagado", 	-- Bloco apagado quando colocado no mapa
            node_ceiling = "bloco_no_teto", -- Bloco colocado no teto <opicional>
            node_wall = "bloco_na_parede", 	-- Bloco colocado na parede <opicional>
        },
        
        sounds = { 				-- Sons
            turn_on = {definições de som}, 	-- Som de acender tocha
            turn_off = {definições de som}, -- Som de apagar tocha de forma generica
            water_turn_off = {definições de som}, -- Som de apagar tocha com agua
        },
        
    }

#### Definições do combustível (`register_fuel`)

    {
        turns = 1.0, 	-- Noites de duração
    }

#### Definições do acendedor (`register_lighter`)

    {
        wear_by_use = 100, 	-- Desgaste causado na ferramenta
    }

#### Definições de som

    {
        name = "nome_do_som", 	-- Nome do som (nome do arquivo sem o sufixo ".ogg")
        gain = 1.0, 		-- Ganho de volume
    }




