API de Desenvolvimento Lua para o mod HardTorch
===============================================

Introdução
----------
Esse mod possui alguns métodos para registrar tochas, combustiveis e acendedores, bem como outros 
recursos para apoiar o desenvolvimento de outras modificações afim de manter compatibilidade.

### Tochas
Ao registrar uma tocha, nenhum item (nó ou ferramenta) é criado. A API modificara os itens já 
registrados em Minetest para funcionarem como um único item que é a tocha. Portanto, toda a 
arte e aspectos físicos de tais itens não são realizados pela API e devem ser previamente criados, 
isso permite mais personalização de cada tocha. 
Os itens que devem ser previamente criados, e que serão usados para registrar a tocha são:

* Tocha: Item do tipo ferramenta que será usado como tocha apagada no inventario.
* Tocha acesa: Item do tipo ferramenta que será usado como tocha acesa no invenario.
  * Esse item deve possuir o mesmo itemstring da tocha apagada com a adição do sufixo "_on".
* Bloco de tocha: Item do tipo nó/bloco que será colocado no chão como uma tocha apagada.
* Bloco de tocha acesa: Item do tipo nó/bloco que será colocado no chão como uma tocha acesa.
* Combustivel: Item do tipo ferramenta que será desgastado enquanto a tocha estiver acesa.

### Combustiveis
O combustivel é um item do tipo ferramenta que será consumido enquanto o jogador estiver com uma 
tocha acesa ou repassado para a tocha acesa que for colocada como bloco. Todos os combustiveis 
precisam ser previamente registrados como tal atravez do método correspondente.

### Acendedores
O acendedor é um item do tipo ferramenta usado para acender uma tocha no inventario. Todos os 
acendedores precisam ser previamente registrados como tal atravez do método correspondente. 
A necessidade do acendedor é desabilitada por padrão nas configurações de jogo.

### Fontes de calor
As fontes de calor são blocos que podem ser usados para acender uma tocha. Os nodes que podem ser 
usados como fonte de calor precisar ser inseridos na tabela correspondente.
A necessidade da fonte de calor para acender tochas é desabilitada por padrão nas configurações de jogo.

### Métodos
* `hardtorch.register_torch(itemstring, {definições da tocha})`: Registra uma tocha.
* `hardtorch.register_fuel(itemstring, {definições do combustivel})`: Registra uma combustivel.
* `hardtorch.register_lighter(itemstring, {definições do acendedor})`: Registra um acendedor.

### Tabelas globais
* `hardtorch.registered_torchs`: Definições de tochas registradas, indexado por itemstring.
* `hardtorch.registered_fuels`: Definições de combustiveis registrados, indexado por itemstring.
* `hardtorch.registered_lighters`: Definições de acendedores registrados, indexado por itemstring.
* `hardtorch.registered_nodes`: Definições de nós/blocos de tocha registrados, indexado por itemstring.
* `hardtorch.fire_sources`: Lista de fontes de calor, indexado por itemstring.
* `hardtorch.not_place_torch_on`: Lista de nós/blocos evitaveis para colocação de tochas, não indexado.

#### Definições da tocha (`register_torch`)

    {
        light_source = 13, 	-- Intensidade de iluminação da tocha (máximo é 14)
        
        nodes = { 				-- Blocos de tocha acesa
            node = "bloco_padrao", 		-- Bloco padrão padrão
            node_ceiling = "bloco_no_teto", -- Blocos colocados no teto <opicional>
            node_wall = "bloco_na_parede", 	-- Blocos colocados na parede <opicional>
            fire_source = true, 		-- Registra como fonte de fogo (padrão é `true`) <opicional>
        },
        
        nodes_off = { 			-- Bloco de tocha apagada
            node = "bloco_padrao_apagado", 	-- Bloco apagado quando colocado no mapa
            node_ceiling = "bloco_no_teto", -- Opcional para nodes wallmounted
            node_wall = "bloco_na_parede", 	-- Opcional para nodes wallmounted
        },
        
        sounds = { 				        -- Sons
            turn_on = {name="som", gain=1.0}, 	-- Som de acender tocha
            turn_off = {name="som", gain=1.0}, 	-- Som de apagar tocha de forma generica
            water_turn_off = {name="som", gain=1.0}, -- Som de apagar tocha com agua
        },
        
        fuel = {"combustivel1", "combustivel2"}, -- Lista de combustiveis
        
        drop_on_water = "item_dropado", 	-- Item caido se molhar a tocha (por padrão é a tocha) <opicional>
    }

#### Definições do combustivel (`register_fuel`)

    {
        turns = 1.0, 	-- Noites de duração
    }

#### Definições do acendedor (`register_lighter`)

    {
        wear_by_use = 1000, 	-- Desgaste causado na ferramenta
    }




