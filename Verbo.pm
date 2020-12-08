package Verbo;

###############################################################################
# Modulo: Verbo.pm                                                            #
# Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430         #
#          Regis de Abreu Barbosa                 Numero USP: 3135701         #
#          Renato Kosaka Araujo                   Numero USP: 3100737         #
#          Rodrigo Mendes Leme                    Numero USP: 3151151         #
# Curso: computacao                  Data: 15/12/2000                         #
# Professor: Marco Gubitoso                                                   #
# Descricao: contem todas as rotinas de manipulacao de verbos (acoes) e seus  #
#            sinonimos. Tambem contem algumas definicoes de verbos obrigato-  #
#            rios no jogo.                                                    #
###############################################################################

use Objeto;
use Lugar;
use ES;

# hash global de verbos
# contém todos os nomes das funções de ações não-específicas a nenhum objeto ou
# lugar
%verbos;

# hash global de sinônimos de verbos, lugares e objetos
# contém um sinônimo do verbo, lugar ou objeto dado como chave
%sinonimos;

# Função: incluir um verbo no hash global
# Recebe: string com o nome do verbo
#         string com o nome da subrotina correspondente ao verbo
sub inclui_verbo {
    my $novo = shift;

    # as rotinas pré-definidas não podem ser alteradas
    unless ($novo eq 'pegar' || $novo eq 'examinar' || $novo eq 'largar') {
	$verbos{$novo} = shift;
    }
}

# Função: remover um verbo do hash global
# Recebe: string com o nome do verbo
sub remove_verbo {
    my $acao = shift;

    delete $verbos{$acao};
}

# Função: incluir um verbo no hash de sinônimos
# Recebe: string com o verbo
#         string com o sinônimo
sub inclui_sinonimo {
    my $sinonimo = shift;
    my $i;

    # string com a lista de verbos separados por espaço
    my $lista = shift;
    my @verbos = split ' ', $lista;
    
    foreach $i (@verbos) {
	if (exists $sinonimos{$i}) {
	    ES::Erro ("Verbo $i já tem sinônimo.");
	}
	else {
	    $sinonimos{$i} = $sinonimo;
	}
    }
}

# Função : devolver um sinônimo correspondente
# Recebe : string com o verbo
# Devolve: string com o sinonimo
sub qual_sinonimo {
    my $verbo = shift;

    return $sinonimos{$verbo};
}

# Funcao : devolver um verbo correspondente
# Recebe : string com o verbo
# Devolve: o proprio verbo
sub qual_verbo {
    my $chave = shift;

    return $verbos{$chave};
}

# Função: executar a subrotina correspondente ao verbo dado
# Recebe: - string com o nome do verbo a ser executado
#         - referência para um lugar ou objeto caso seja uma ação específica,
#           ou a string 'geral' se é uma ação geral
#         - argumentos da ação
sub executa_acao {
    my $acao = shift;
    my $coisa = shift;

    # caso o verbo exista no lugar ou objeto ele será executado
    # caso contrário tentará executar a subrotina geral
    if ($coisa eq 'geral') {  # se foi passado a referência pra lugar ou objeto
        if (existe_acao ($acao)) {
	    my $sub = $verbos{$acao};
	    &$sub (@_);
	    &Objeto::atualiza_objanim;
        }
	else {
	  ES::Exibe ("Não sei como $acao.");
        }
    }
    else {
        if ($coisa->devolve ('acao', $acao)) {
	    my $sub = $coisa->devolve ('acao', $acao);
	    &$sub (@_);            # $sub é a string com o nome da subrotina
	    &Objeto::atualiza_objanim;              # correspondente à $acao
	}
    }
}
	
# Função: transformar uma string em código perl
#         o código fica neste package
# Recebe: string com o código
sub acao2perl {
    my $code = shift;

    eval $code;
}

# Função : indicar se a ação está especificada no hash global
# Recebe : string com o nome da ação
# Devolve: 1 - se a ação existe no hash global
#          0 - se a ação não existe no hash global
sub existe_acao {
    my $acao = shift;
    if (exists $verbos{$acao}) {
	return 1;
    }
    else {
	return 0;
    }
}

# Funcao : mudar_lugar
# Recebe : o novo lugar para o qual o aventureiro se dirige.
# Devolve: imprime uma descricao do novo lugar do aventureiro.
sub mudar_lugar
{
  my $novo_lugar = $Lugar::lugares->{&Objeto::devolve_aventureiro
                                     ->devolve("local")};
  my @lista  = $novo_lugar->devolve("objetos");
  my $coisas = &Objeto::devolve_aventureiro->devolve('objetos');
  my $i;

  ES::Exibe($novo_lugar->devolve("descricao"));
  print "Objetos: ";
  foreach $i (@lista) {
      print $i." " unless ($i eq 'aventureiro');
  }
  print "\nSuas coisas: ";
  foreach $i (keys %$coisas) {
      print $i." ";
  }
  print "\n";
}

# Função: mostrar mensagem padrão de verbos que não são gerais
sub acao_default {
    ES::Exibe ("Não posso fazer isso.");
}

# Alguns verbos já pré-definidos #

# Função: exibir a descrição do local ou objeto
# Recebe: referência para o lugar ou objeto
sub examinar {
    my $coisa = shift;

    if ($coisa) {
	exibe ($coisa->devolve ('descricao'));
    }
    else {
	exibe ("Examinar o que?");
    }
}

# Função: tirar o objeto do lugar e dar para o aventureiro
# Recebe: referência para o objeto
sub pegar {
    my $objeto = shift;
    my $aventureiro = &Objeto::devolve_aventureiro;

    unless ($objeto) {
        ES::Exibe ("Não dá.");
	return;
    }

    if (exists $objeto->{SAIDAS}) {
        ES::Exibe ("Como vou pegar um lugar?");
	return;
    }

    if ($objeto->devolve('nome') eq $aventureiro->devolve('nome')) {
        ES::Exibe ("Não posso pegar a mim mesmo.");
	return;
    }
    
    # o objeto deve estar no mesmo local em que o aventureiro está
    my $local_obj = $objeto->devolve ('local');
    my $local_avt = $aventureiro->devolve ('local');
    if ($Lugar::lugares->{$local_obj}->devolve ('nome') eq
                $Lugar::lugares->{$local_obj}->devolve ('nome')) {
	&Objeto::inserir ($objeto, $aventureiro);
	$Lugar::lugares->{$local_obj}->exclui_objeto($objeto->devolve('nome'));
    }
    else {
        ES::Exibe ("Não existe esse objeto aqui!\n");
    }
}

# Função: tirar o objeto do aventureiro e deixar no local onde ele está
# Recebe: referência para o objeto
sub largar {
    my $objeto = shift;
    my $aventureiro = Objeto::devolve ('aventureiro');
    my $contem_obj = $objeto->devolve ('propriedade', 'incluido');

    # este if verifica se o objeto está "incluido" no aventureiro
    if ($contem_obj == $aventureiro) {
	$objeto->remover ($aventureiro);
    }
    else {
        exibe ("Você não tem esse objeto.\n");
    }
}

# Funcao : ir
# Devolve: uma mensagem de erro quando o aventureiro nao pode ir numa direcao

sub ir {
    ES::Erro("Nao é possível ir nessa direção.");
    return;
}


# Inclusão no hash global
$verbos{'examinar'} = 'examinar';
$verbos{'pegar'}    = 'pegar';
$verbos{'largar'}   = 'largar';
$verbos{'ir'}       = 'ir';


# Sinonimos
inclui_sinonimo('examinar','ver');
inclui_sinonimo('examinar','olhar');
inclui_sinonimo('ir','va');
inclui_sinonimo('ir','vai');

# Comandos especiais para o criador da história

# Função: mostrar uma mensagem
# Recebe: string com a mensagem
sub exibe {
    my $mensagem = shift;

    ES::Exibe ($mensagem);
}

# Função: mostrar final
# Recebe: string com a mensagem de finalização
sub final {
    my $mensagem = shift;

    ES::Final ($mensagem);
}

1;
