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
# cont�m todos os nomes das fun��es de a��es n�o-espec�ficas a nenhum objeto ou
# lugar
%verbos;

# hash global de sin�nimos de verbos, lugares e objetos
# cont�m um sin�nimo do verbo, lugar ou objeto dado como chave
%sinonimos;

# Fun��o: incluir um verbo no hash global
# Recebe: string com o nome do verbo
#         string com o nome da subrotina correspondente ao verbo
sub inclui_verbo {
    my $novo = shift;

    # as rotinas pr�-definidas n�o podem ser alteradas
    unless ($novo eq 'pegar' || $novo eq 'examinar' || $novo eq 'largar') {
	$verbos{$novo} = shift;
    }
}

# Fun��o: remover um verbo do hash global
# Recebe: string com o nome do verbo
sub remove_verbo {
    my $acao = shift;

    delete $verbos{$acao};
}

# Fun��o: incluir um verbo no hash de sin�nimos
# Recebe: string com o verbo
#         string com o sin�nimo
sub inclui_sinonimo {
    my $sinonimo = shift;
    my $i;

    # string com a lista de verbos separados por espa�o
    my $lista = shift;
    my @verbos = split ' ', $lista;
    
    foreach $i (@verbos) {
	if (exists $sinonimos{$i}) {
	    ES::Erro ("Verbo $i j� tem sin�nimo.");
	}
	else {
	    $sinonimos{$i} = $sinonimo;
	}
    }
}

# Fun��o : devolver um sin�nimo correspondente
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

# Fun��o: executar a subrotina correspondente ao verbo dado
# Recebe: - string com o nome do verbo a ser executado
#         - refer�ncia para um lugar ou objeto caso seja uma a��o espec�fica,
#           ou a string 'geral' se � uma a��o geral
#         - argumentos da a��o
sub executa_acao {
    my $acao = shift;
    my $coisa = shift;

    # caso o verbo exista no lugar ou objeto ele ser� executado
    # caso contr�rio tentar� executar a subrotina geral
    if ($coisa eq 'geral') {  # se foi passado a refer�ncia pra lugar ou objeto
        if (existe_acao ($acao)) {
	    my $sub = $verbos{$acao};
	    &$sub (@_);
	    &Objeto::atualiza_objanim;
        }
	else {
	  ES::Exibe ("N�o sei como $acao.");
        }
    }
    else {
        if ($coisa->devolve ('acao', $acao)) {
	    my $sub = $coisa->devolve ('acao', $acao);
	    &$sub (@_);            # $sub � a string com o nome da subrotina
	    &Objeto::atualiza_objanim;              # correspondente � $acao
	}
    }
}
	
# Fun��o: transformar uma string em c�digo perl
#         o c�digo fica neste package
# Recebe: string com o c�digo
sub acao2perl {
    my $code = shift;

    eval $code;
}

# Fun��o : indicar se a a��o est� especificada no hash global
# Recebe : string com o nome da a��o
# Devolve: 1 - se a a��o existe no hash global
#          0 - se a a��o n�o existe no hash global
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

# Fun��o: mostrar mensagem padr�o de verbos que n�o s�o gerais
sub acao_default {
    ES::Exibe ("N�o posso fazer isso.");
}

# Alguns verbos j� pr�-definidos #

# Fun��o: exibir a descri��o do local ou objeto
# Recebe: refer�ncia para o lugar ou objeto
sub examinar {
    my $coisa = shift;

    if ($coisa) {
	exibe ($coisa->devolve ('descricao'));
    }
    else {
	exibe ("Examinar o que?");
    }
}

# Fun��o: tirar o objeto do lugar e dar para o aventureiro
# Recebe: refer�ncia para o objeto
sub pegar {
    my $objeto = shift;
    my $aventureiro = &Objeto::devolve_aventureiro;

    unless ($objeto) {
        ES::Exibe ("N�o d�.");
	return;
    }

    if (exists $objeto->{SAIDAS}) {
        ES::Exibe ("Como vou pegar um lugar?");
	return;
    }

    if ($objeto->devolve('nome') eq $aventureiro->devolve('nome')) {
        ES::Exibe ("N�o posso pegar a mim mesmo.");
	return;
    }
    
    # o objeto deve estar no mesmo local em que o aventureiro est�
    my $local_obj = $objeto->devolve ('local');
    my $local_avt = $aventureiro->devolve ('local');
    if ($Lugar::lugares->{$local_obj}->devolve ('nome') eq
                $Lugar::lugares->{$local_obj}->devolve ('nome')) {
	&Objeto::inserir ($objeto, $aventureiro);
	$Lugar::lugares->{$local_obj}->exclui_objeto($objeto->devolve('nome'));
    }
    else {
        ES::Exibe ("N�o existe esse objeto aqui!\n");
    }
}

# Fun��o: tirar o objeto do aventureiro e deixar no local onde ele est�
# Recebe: refer�ncia para o objeto
sub largar {
    my $objeto = shift;
    my $aventureiro = Objeto::devolve ('aventureiro');
    my $contem_obj = $objeto->devolve ('propriedade', 'incluido');

    # este if verifica se o objeto est� "incluido" no aventureiro
    if ($contem_obj == $aventureiro) {
	$objeto->remover ($aventureiro);
    }
    else {
        exibe ("Voc� n�o tem esse objeto.\n");
    }
}

# Funcao : ir
# Devolve: uma mensagem de erro quando o aventureiro nao pode ir numa direcao

sub ir {
    ES::Erro("Nao � poss�vel ir nessa dire��o.");
    return;
}


# Inclus�o no hash global
$verbos{'examinar'} = 'examinar';
$verbos{'pegar'}    = 'pegar';
$verbos{'largar'}   = 'largar';
$verbos{'ir'}       = 'ir';


# Sinonimos
inclui_sinonimo('examinar','ver');
inclui_sinonimo('examinar','olhar');
inclui_sinonimo('ir','va');
inclui_sinonimo('ir','vai');

# Comandos especiais para o criador da hist�ria

# Fun��o: mostrar uma mensagem
# Recebe: string com a mensagem
sub exibe {
    my $mensagem = shift;

    ES::Exibe ($mensagem);
}

# Fun��o: mostrar final
# Recebe: string com a mensagem de finaliza��o
sub final {
    my $mensagem = shift;

    ES::Final ($mensagem);
}

1;
