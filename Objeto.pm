package Objeto;

###############################################################################
# Modulo: Objeto.pm                                                           #
# Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430         #
#          Regis de Abreu Barbosa                 Numero USP: 3135701         #
#          Renato Kosaka Araujo                   Numero USP: 3100737         #
#          Rodrigo Mendes Leme                    Numero USP: 3151151         #
# Curso: computacao                  Data: 11/12/2000                         #
# Professor: Marco Gubitoso                                                   #
# Descricao: Este modulo contem subrotinas para a manipulacao dos objetos.    #
###############################################################################

use Lugar;
use Verbo;

# Objeto Aventureiro
# Suas especificacoes devem ser mudadas pelo usuario.
my $aventureiro = &new;

# Hash com todos os objetos do jogo
# chave: string com nome do objeto
# valor: referência do objeto
$objetos = {};

# Hash de objetos animados
# chave: string com nome do objeto
# valor: string com nome da função que será executada quando acabar a animação
# OBS.: cada objeto pode ter só uma propriedade animada
my $objetos_animados ={};

### Construtor do objeto ###
sub new {
    my $objeto       = {};
    $objeto->{NOME}  = undef;   # string com o nome do objeto
    $objeto->{DESC}  = undef;   # string com a descricao do objeto
    $objeto->{LOCAL} = undef;   # referencia para o local em que o
                                # objeto se encontra
    $objeto->{PROP}  = {};      # propriedades especiais do objeto
    $objeto->{OBJS}  = {};      # referencias para outros objetos que
                                # ele carrega
    $objeto->{ACOES} = {};      # strings com os nomes das rotinas de acoes
                                # que podem ser feitas com esse objeto
    return bless $objeto;
}

# Diz qual o hash de objetos
# Recebe: referência para um hash com objetos
sub hash_de_objetos {
    my $ref_hash = shift;
    $objetos = $ref_hash;
}

# Retorna o valor da caracteristica do objeto dada como argumento
# A caracteristica pode ser: nome, local, descricao, objetos, propriedade ou
# acao
sub devolve {
    my $objeto = shift;
    my $campo = shift;

    if ($campo eq "nome") {
	return $objeto->{NOME};
    }
    elsif ($campo eq "local") {
	return $objeto->{LOCAL};
    }
    elsif ($campo eq "descricao") {
	return $objeto->{DESC};
    }
    elsif ($campo eq "objetos") {
	return $objeto->{OBJS};
    }
    elsif ($campo eq "propriedade") {
	my $prop = shift;               # Para propriedade tambem eh necessario
        return $objeto->{PROP}{$prop};           # passar o nome da propriedade
    }
    elsif ($campo eq "acao") {
        my $acao = shift;                    # Para acao tambem eh necessario
        return $objeto->{ACOES}{$acao};      # passar a acao desejada
    }
}

# Devolve a referência para o aventureiro
sub devolve_aventureiro {
    return $aventureiro;
}

# Altera uma caracteristica do objeto
# A caracteristica eh passada como primeiro parametro e o valor como segundo
# Podem ser alterados: nome, descricao, local
sub altera {
    my $objeto = shift;
    my $campo = shift;

    if ($campo eq "nome") {
	$objeto->{NOME} = shift;
    }
    elsif ($campo eq "descricao") {
	$objeto->{DESC} = shift;
    }
    elsif ($campo eq "local") {
	$objeto->{LOCAL} = shift;
    }
    elsif ($campo eq "propriedade") {
	my $prop = shift;
	$objeto->{PROP}{$prop} = shift;
    }
}

# Apaga uma propriedade de um objeto.
# O primeiro argumento eh o objeto.
# O segundo argumento eh o nome da propriedade que sera apagada
sub apaga_prop {
    my $objeto = shift;
    my $prop   = shift;

    delete $objeto->{PROP}{$prop};
}

# Inclui uma acao nova para o objeto.
# O primeiro argumento eh o objeto.
# O segundo argumento eh o nome da acao, usado como chave,
# e o terceiro a string com o nome da subrotina correspondente.
sub nova_acao {
    my $objeto = shift;
    my $acao   = shift;

    $objeto->{ACOES}{$acao} = shift;
}

# Inclui um objeto no hash de objetos animados
# Recebe: string com nome do objeto
#         string com o nome da rotina a ser executada
sub inclui_objanim {
    my $nome   = shift;
    my $rotina = shift;

    $objetos_animados->{$nome} = $rotina;
}

# Atualiza todos os objetos animados
sub atualiza_objanim {
    my $i;

    foreach $i (keys %$objetos_animados) {
	my $obj   = $objetos->{$i};
	my $prop  = $obj->devolve ('propriedade', 'animado');
	my $valor = $obj->devolve ('propriedade', $prop);
	
	$valor--;
	if ($valor <= 0) {          # Executa a animacao
	    my $rot = $objetos_animados->{$i};
	    &Verbo::executa_acao ($rot, 'geral');
	}
	$obj->altera ('propriedade', $prop, $valor);
    }
}

# Coloca um objeto dentro do outro
# O primeiro argumento eh a referencia para o objeto que sera inserido
# O segundo argumento eh a referencia para o objeto que recebera o outro
sub inserir {
    my $objeto1 = shift;
    my $objeto2 = shift;
    
    # se o objeto esta inserido em algum outro, ele eh retirado deste
    if (exists $objeto1->{PROP}{"incluido"}) {
	my $contem1 = $objeto1->{PROP}{"incluido"};
	delete $contem1->{OBJS}{$objeto1->{NOME}};
    }
	
    # Cria uma propriedade que indica que ele esta incluido e tem como valor
    # o nome do objeto2.
    $objeto1->altera("propriedade", "incluido", $objeto2);
    $objeto2->{OBJS}{$objeto1->{NOME}} = $objeto1;        # A referencia para o
                      # objeto1 entra na lista dos objetos contidos no objeto2.
                      # A chave eh o nome do objeto1
}

# Retira um objeto do outro
# O primeiro argumento eh a referencia para o objeto a ser retirado.
# O segundo argumento eh a referencia para o objeto de onde esta sendo
# retirado.
sub remover {
    my $objeto1 = shift;
    my $objeto2 = shift;

    delete $objeto2->{OBJS}{$objeto1->{NOME}};   # Tira o objeto1 da lista
                                                 # do objeto 2
    if (exists $objeto2->{PROP}{"incluido"}) {
	$objeto1->altera("propriedade", "incluido",
                         $objeto2->{PROP}{"incluido"});
	$objeto1->inserir($objeto2->{PROP}{"incluido"});
    } else {
	$objeto1->apaga_prop("incluido");
	$objeto1->{LOCAL} = $objeto2->{LOCAL};
	($objeto1->{LOCAL})->inclui_objeto($objeto1);
    }
}

1;
