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
# O arquivo de entrada é uma sequência de blocos, ligados por um

# separador (':::').  O formato de cada bloco é:
# -------------------------------------------------------------- 
# [TIPO] [NOME] 
# [Conteúdo]
# -------------------------------------------------------------- 
# [TIPO] é um de (lugar, objeto, altera, acao)
# [NOME] é um identificador
# [Conteúdo] depende do tipo.  Em geral é uma seqüência de pares
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
# Neste segundo caso, [valor] pode ocupar várias linhas
#
# Para ação, o [Conteúdo] é um código de uma rotina, que será traduzida 
# para PERL.

use Lugar;
use Objeto;
use Verbo;

# chave: string com o nome do lugar em letras minúsculas
# valor: referência pro lugar
# É utilizado para guardar todos os lugares já criados.
my $lugares = {};

# chave: string com o nome do objeto em letras minúsculas
# valor: referência pro objeto
# É utilizado para guardar todos os objetos já criados.
my $objetos = {};

# chave: string com o nome da subrotina
# É utilizado para saber se a ação já foi criada ou não.
my $acoes = {};

# chave: string com o nome da subrotina
# valor: 'geral' ou 'especifica'
# É utilizado para saber se uma ação se restringe a um lugar/objeto ou se é geral.
my $tipo_acao = {};

# chave: string com o nome da ação, objeto ou lugar que não foi encontrado
# valor: 'acao', 'objeto' ou 'lugar'
# É utilizado para saber se ficou faltando alguma coisa no arquivo do jogo.
my $falta = {};

# Indica se ocorreram erros na tradução do arquivo
my $erros = 0;


# Coordena toda a tradução do arquivo
# Retorna: referência pra um hash com todos os lugares do jogo, chave é o nome do lugar
#          referência pra um hash com todos os objetos do jogo, chave é o nome do objeto
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

    # o bloco começa com o tipo
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
      Erro("Tipo inválido");
      next;
    }
  }

  # verifica se está faltando alguma coisa no arquivo
  my $i;
  foreach $i (keys %$falta) {
    print "Erro: Está faltando $falta->{$i} $i no arquivo.\n";
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
      # agora é uma ação específica
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
	  Erro ("$v já tem que ter sido criado para ser incluido em $nome.");
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
      # agora é uma ação específica
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
	Erro ("Não posso incluir $v em $nome.\n  Só posso inserir objetos que já foram definidos.");
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
    Erro ("Não posso alterar $nome. Não foi criado ainda.");
  }
}

# Define uma função
# Acao [nome] [argumentos]
sub Acao {
  my $nome = shift;		# nome da função
  my $code;			# código traduzido

  if (exists $acoes->{$nome}) {
    Erro ("A ação $nome já existe. Não é possível criá-la de novo.");
    return 0;
  }

  # indica que a ação já foi criada
  $acoes->{$nome} = 'T';

  # só é geral se não for especifica de algum objeto ou lugar
  unless ($tipo_acao->{$nome} eq 'especifica') {
    Verbo::inclui_verbo ($nome, $nome);
    $tipo_acao->{$nome} = 'geral';
  }

  # se esta ação estava faltando, agora não está mais
  if (exists $falta->{$nome}) {
    delete $falta->{$nome};
  }

  # pega os argumentos
  my @args;
  if (s/^[(]([^)]*)[)]//){	# args entre ()s
    @args = split(/\s+/,$1);	# lista dos argumentos
  } 
  unshift(@args, '$this');

  # cabeçalho
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
	    (\(?)	   # pode ter argumentos ou não
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
    # atribuição
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
    # chamada de função de objeto, () obrigatórios
    elsif (s/^\s*(\w+[.]\w+\s*\()([^)]*\))//si) {
      $campo = tradfunc($1);
      $code .= "$tab$campo$2;\n";
    }
    # funções especiais
    elsif (s/^\s*(final|exibe)\s*\(([^)]+?\))//si) {
      $campo = $1;
      $code .= "$tab$campo($2;\n";
    }
    else {
      Erro("instrução desconhecida: $_");
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
