package Trad;

###############################################################################
# Modulo: Trad.pm                                                             #
# Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430         #
#          Regis de Abreu Barbosa                 Numero USP: 3135701         #
#          Renato Kosaka Araujo                   Numero USP: 3100737         #
#          Rodrigo Mendes Leme                    Numero USP: 3151151         #
# Curso: computacao                  Data: 15/12/2000                         #
# Professor: Marco Gubitoso                                                   #
# Descricao: tradutor do arquivo de entrada do jogo em codigo Perl.           #
###############################################################################

################################################################
# O arquivo de entrada � uma sequ�ncia de blocos, ligados por um

# separador (':::').  O formato de cada bloco �:
# -------------------------------------------------------------- 
# [TIPO] [NOME] 
# [Conte�do]
# -------------------------------------------------------------- 
# [TIPO] � um de (lugar, objeto, altera, acao)
# [NOME] � um identificador
# [Conte�do] depende do tipo.  Em geral � uma seq��ncia de pares
# do tipo propriedade, valor, da seguinte forma:
# --------------------------------------------------------------
# [propriedade] = [valor]
# --------------------------------------------------------------
# ou
# --------------------------------------------------------------
# [propriedade] = {
#   [valor]
# }
# --------------------------------------------------------------
# Neste segundo caso, [valor] pode ocupar v�rias linhas
#
# Para a��o, o [Conte�do] � um c�digo de uma rotina, que ser� traduzida 
# para PERL.

use Lugar;
use Objeto;
use Verbo;

# chave: string com o nome do lugar em letras min�sculas
# valor: refer�ncia pro lugar
# � utilizado para guardar todos os lugares j� criados.
my $lugares = {};

# chave: string com o nome do objeto em letras min�sculas
# valor: refer�ncia pro objeto
# � utilizado para guardar todos os objetos j� criados.
my $objetos = {};

# chave: string com o nome da subrotina
# � utilizado para saber se a a��o j� foi criada ou n�o.
my $acoes = {};

# chave: string com o nome da subrotina
# valor: 'geral' ou 'especifica'
# � utilizado para saber se uma a��o se restringe a um lugar/objeto ou se � geral.
my $tipo_acao = {};

# chave: string com o nome da a��o, objeto ou lugar que n�o foi encontrado
# valor: 'acao', 'objeto' ou 'lugar'
# � utilizado para saber se ficou faltando alguma coisa no arquivo do jogo.
my $falta = {};

# Indica se ocorreram erros na tradu��o do arquivo
my $erros = 0;


# Coordena toda a tradu��o do arquivo
# Retorna: refer�ncia pra um hash com todos os lugares do jogo, chave � o nome do lugar
#          refer�ncia pra um hash com todos os objetos do jogo, chave � o nome do objeto
sub traduz {
  # Separador dos blocos
  my $salvo = $/;  # salva o valor de $/
  $/="\n:::\n";

  # Tipos de blocos
  my %Tipos = (
	    lugar  => \&Lugar,
	    objeto => \&Objeto,
	    altera => \&Altera,
	    acao   => \&Acao
	   );

  # Leitura dos blocos
  while(<>) {
    chomp;			# Arranca o separador

    # o bloco come�a com o tipo
    do {
      Erro("Tipo indefinido");
      next;
    } unless (s/^(\w+)\s*//);

    # pega o nome
    my $tipo = lc $1;
    s/^(\w+)\s*\n?//;
    my $nome  = lc $1;

    # inicializa o aventureiro
    $objetos->{'aventureiro'} = Objeto::devolve_aventureiro;

    # chama a rotina de tratamento correspondente
    if (exists $Tipos{$tipo}) {
      next unless &{$Tipos{$tipo}}($nome,\$_)
    }
    else {
      Erro("Tipo inv�lido");
      next;
    }
  }

  # verifica se est� faltando alguma coisa no arquivo
  my $i;
  foreach $i (keys %$falta) {
    print "Erro: Est� faltando $falta->{$i} $i no arquivo.\n";
  }
  exit if (keys %$falta); # se estiver faltando sai do programa

  exit if ($erros);       # se ocorreram erros sai do programa

  # define $objetos como o hash de objetos a ser utilizado
  Objeto::hash_de_objetos ($objetos);

  # define $lugares como o hash de lugares a ser utilizado
  Lugar::hash_de_lugares ($lugares);

  # devolve valor de $/ de antes do traduz() ser chamado
  $/ = $salvo;
}

# Pega um valor
sub Valor {
  my $val;
  $val = $1 if s/^\s*\{\n?(.*?)\}\s*//s || s/^\s*(.*)\n?//;
  return $val;
}

# Pega um campo
sub Campo {
  my ($campo,$valor);

  $campo=$1 if s/^\s*(\w+)\s*=//s;
  Erro ("Campo sem nome") if $campo eq "";
  
  $valor = Valor;
  return ($campo,$valor);
}

# Define um lugar
sub Define_Lugar {
  my $nome = shift;
  my $lugar = shift;
  my ($c, $v);

  while ($_) {
    if (s/^saida\s*//i) {
      ($c, $v) = Campo;
      $v = lc $v;
      $lugar->cria_saida ($c, $v);
      unless (exists $lugares->{$v}) {
	$falta->{$v} = 'lugar';
      }
    }
    elsif (s/^verbo\s*//i) {
      ($c, $v) = Campo;
      $v = lc $v;
      $lugar->nova_acao ($c, $v);
      unless (exists $acoes->{$v}) {
	$falta->{$v} = 'acao';
      }
      # agora � uma a��o espec�fica
      $tipo_acao->{$v} = 'especifica';
      # caso o verbo for utilizado de modo geral usa a rotina default
      Verbo::inclui_verbo ($c, 'acao_default');
    }
    elsif (s/^inclui\s*(\w+)\s*//i) {
      $v = lc $1;
      $lugar->inclui_objeto ($v);
      if (exists $objetos->{$v}) {
	$objetos->{$v}->altera('local', $nome);
      }
      else {
	  Erro ("$v j� tem que ter sido criado para ser incluido em $nome.");
      }
    }
    elsif (s/^sinonimos\s*//i) {
      ($c, $v) = Campo;
      Verbo::inclui_sinonimo ($c, $v);
    }
    else {
      ($c, $v) = Campo;
      if ($c eq 'desc') {
	$lugar->descricao ($v);
      }
      else {
	$lugar->propriedade ($c, $v);
      }
    }
  }
}

# Define um objeto
sub Define_Objeto {
  my $nome = shift;
  my $obj = shift;
  my ($c, $v);

  while ($_) {
    if (s/^verbo\s*//i) {
      ($c, $v) = Campo;
      $v = lc $v;
      $obj->nova_acao ($c, $v);
      unless (exists $acoes->{$v}) {
	$falta->{$v} = 'acao';
      }
      # agora � uma a��o espec�fica
      $tipo_acao->{$v} = 'especifica';
      # caso o verbo for utilizado de modo geral usa a rotina default
      Verbo::inclui_verbo ($c, 'acao_default');
    }
    elsif (s/^inclui\s*(\w+)\s*//i) {
      $v = lc $1;
      if (exists $objetos->{$v}) {
	my $objeto_interior = $objetos->{$v};
	$objeto_interior->inserir ($obj);
      }
      else {
	Erro ("N�o posso incluir $v em $nome.\n  S� posso inserir objetos que j� foram definidos.");
      }
    }
    elsif (s/^animado\s*//i) {
	($c, $v) = Campo;
        Objeto::inclui_objanim ($nome, $v);
	$obj->altera ('propriedade', 'animado', $c);
    }
    elsif (s/^sinonimos\s*//i) {
	($c, $v) = Campo;
        Verbo::inclui_sinonimo ($c, $v);
    } 
    else {
	($c, $v) = Campo;
	if ($c eq 'desc') {
	    $obj->altera ('descricao', $v);
	}
	else {
	    $obj->altera ('propriedade', $c, $v);
	}
    }
  }
}

# Cria um lugar
sub Lugar {
  my $nome = shift;
  my $lugar;

  if (!(exists $lugares->{$nome})) {
    $lugar = Lugar::new;
    $lugar->nome ($nome);
    $lugares->{$nome} = $lugar;
    if (exists $falta->{$nome}) {
      delete $falta->{$nome};
    }
  }
  else {
    Erro ("$nome ja existe, use Altera");
    return 0;
  }

  Define_Lugar ($nome, $lugar);
}

# Cria um objeto
sub Objeto {
  my $nome = shift;
  my $obj;

  if (!(exists $objetos->{$nome})) {
    $obj = Objeto::new;
    $obj->altera ('nome', $nome);
    $objetos->{$nome} = $obj;
    if (exists $falta->{$nome}) {
      delete $falta->{$nome};
    }
  }
  else {
    Erro ("$nome ja existe, use Altera");
    return 0;
  }

  Define_Objeto ($nome, $obj);
}

# Altera um objeto ou lugar
sub Altera {
  my $nome = shift;

  if (exists $objetos->{$nome}) {
    Define_Objeto ($nome, $objetos->{$nome});
  }
  elsif (exists $lugares->{$nome}) {
    Define_Lugar ($nome, $lugares->{$nome});
  }
  else {
    Erro ("N�o posso alterar $nome. N�o foi criado ainda.");
  }
}

# Define uma fun��o
# Acao [nome] [argumentos]
sub Acao {
  my $nome = shift;		# nome da fun��o
  my $code;			# c�digo traduzido

  if (exists $acoes->{$nome}) {
    Erro ("A a��o $nome j� existe. N�o � poss�vel cri�-la de novo.");
    return 0;
  }

  # indica que a a��o j� foi criada
  $acoes->{$nome} = 'T';

  # s� � geral se n�o for especifica de algum objeto ou lugar
  unless ($tipo_acao->{$nome} eq 'especifica') {
    Verbo::inclui_verbo ($nome, $nome);
    $tipo_acao->{$nome} = 'geral';
  }

  # se esta a��o estava faltando, agora n�o est� mais
  if (exists $falta->{$nome}) {
    delete $falta->{$nome};
  }

  # pega os argumentos
  my @args;
  if (s/^[(]([^)]*)[)]//){	# args entre ()s
    @args = split(/\s+/,$1);	# lista dos argumentos
  } 
  unshift(@args, '$this');

  # cabe�alho
  my $args = join(', ', @args);	# lista de argumentos

  $code = <<FIM;
sub $nome {
  my ($args) = \@\_;
FIM

  $code .= &Parser("  ") . "}\n";

  Verbo::acao2perl ($code);
}

sub tradcampo {
  my $c = shift;
  $c =~ s/
	    ^\s*           # lixo
	    (\w+) 	   # nome 
	    \s*\[\s*
	    (\w+)	   # campo
	    \s*\]\s*
	    /'$'."Objeto::objetos->{'$1'}->devolve('propriedade', '$2')"/sgex;
  return $c;
} 

sub tradfunc {
  my $c = shift;
  $c =~ s/
	    ^\s*           # lixo
	    (\w+) 	   # nome 
	    [.]		   # separador
	    (\w+)	   # funcao
	    (\(?)	   # pode ter argumentos ou n�o
	    /"\$$2(\$$1" . ($3 ? ', ' : ')')/sgex;
  return $c;
}

sub Parser {
  my ($code, $tab);
  my ($campo, $valor);

  $tab = shift;
  while ($_) {
    return $code if s/^\s*fim//s;
    return $code if /^\s*$/s;

    # condicional
    if (s/^\s*se\s*//) {
      my $cond  = &Condicao;
      $code .= $tab ."if ($cond) {\n";
      $code .= &Parser($tab . '  ') . "$tab}\n";
    }
    # atribui��o
    elsif (s/^\s*(\w+\s*\[\s*\w+\s*\]?)\s*=//s) {
	$campo = $1;
	$campo =~ s/
	    ^\s*           # lixo
	    (\w+) 	   # nome 
	    \s*\[\s*
	    (\w+)	   # campo
	    \s*\]\s*
	    /'$'."Objeto::objetos->{'$1'}->altera('propriedade', '$2',"/sgex;
      $valor = Valor;
      $valor = tradcampo($valor);
      $code .= "$tab$campo \"$valor\");\n";
    }
    # chamada de fun��o de objeto, () obrigat�rios
    elsif (s/^\s*(\w+[.]\w+\s*\()([^)]*\))//si) {
      $campo = tradfunc($1);
      $code .= "$tab$campo$2;\n";
    }
    # fun��es especiais
    elsif (s/^\s*(final|exibe)\s*\(([^)]+?\))//si) {
      $campo = $1;
      $code .= "$tab$campo($2;\n";
    }
    else {
      Erro("instru��o desconhecida: $_");
      return $code;
    }
  }
  return $code;
}

sub Condicao {
  my ($nome, $campo, $valor,$cond);

  if (s/^rand\s*([<>]=?|=)\s*(\d+)//s) {
    return "rand $1 $2";
  }

  if (s/^(\w+)\[(\w+)\]\s*\n//) {
    return"exists \$" . $1 . "->{" . "'$2'}";
  }

  $valor = Valor;
  $valor = tradcampo($valor);
  $valor = tradfunc($valor);

  return $valor;
}

sub Erro {
  print STDERR <<ERR;
Erro no bloco $.
  $_[0]
ERR
  $erros = 1;
}

1;
