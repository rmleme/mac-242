package Lugar;

###############################################################################
# Modulo: Lugar.pm                                                            #
# Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430         #
#          Regis de Abreu Barbosa                 Numero USP: 3135701         #
#          Renato Kosaka Araujo                   Numero USP: 3100737         #
#          Rodrigo Mendes Leme                    Numero USP: 3151151         #
# Curso: computacao                  Data: 15/12/2000                         #
# Professor: Marco Gubitoso                                                   #
# Descricao: Este modulo contem subrotinas para a manipulacao de lugares.     #
###############################################################################

use ES;

# Hash com todos os lugares do jogo
# chave: string com nome do lugar
# valor: referência do lugar
$lugares = {};

###############################################################################
# Metodo: new (construtor)                                                    #
# Saida: um objeto da classe Lugar.                                           #
# Descricao: cria um novo objeto da classe Lugar.                             #
###############################################################################

sub new
{
  my $self = {};

  $self->{NOME}         = undef;      # Nome do Lugar
  $self->{DESCRICAO}    = undef;      # Uma breve descricao sobre o Lugar
  $self->{SAIDAS}       = {};         # As possiveis direcoes de saida do Lugar
  $self->{OBJETOS}      = [];         # Objetos existentes no Lugar
  $self->{PROPRIEDADES} = {};         # Propriedades adicionais do Lugar
  $self->{ACOES}        = {};         # Acoes factiveis naquele Lugar
  return bless $self;
}

###############################################################################
# Metodo: devolve                                                             #
# Entrada: um objeto Lugar e o atributo do qual deseja-se o valor atual.      #
# Saida: o valor atual do atributo passado na entrada.                        #
# Descricao: devolve o valor atual do atributo passado na entrada.            #
###############################################################################

sub devolve
{
  my $self     = shift;
  my $atributo = shift;
  my $i;
  my @vetor_saida;

  if ($atributo eq "nome")
  {
    return $self->{NOME};
  }
  elsif ($atributo eq "descricao")
  {
    return $self->{DESCRICAO};
  }
  elsif ($atributo eq "saidas")
  {
    return $self->{SAIDAS};
  }
  elsif ($atributo eq "objetos")
  {
    foreach $i (@{$self->{OBJETOS}})      # Enumero todos os Objetos
    {                                     # existentes no Lugar
      push(@vetor_saida,$i);
    }
    return @vetor_saida;
  }
  elsif ($atributo eq "propriedades")
  {
    foreach $i (keys %{$self->{PROPRIEDADES}})       # Enumera todas as
    {                                                # propriedades de um Lugar
      push(@vetor_saida,$i);
    }
    return @vetor_saida;
  }
  elsif ($atributo eq "acao")
  {
      my $acao = shift;
      return $self->{ACOES}{$acao};
  }
}

###############################################################################
# Metodo: nome                                                                #
# Entrada: um objeto Lugar e o novo valor do atributo NOME.                   #
# Descricao: altera o valor do atributo NOME.                                 #
###############################################################################

sub nome
{
  my $self = shift;

  if (@_)
  {
    $self->{NOME} = shift;
  }
}

###############################################################################
# Metodo: descricao                                                           #
# Entrada: um objeto Lugar e o novo valor do atributo DESCRICAO.              #
# Descricao: altera o valor do atributo DESCRICAO.                            #
###############################################################################

sub descricao
{
  my $self = shift;

  if (@_)
  {
    $self->{DESCRICAO} = shift;
  }
}

###############################################################################
# Metodo: propriedade                                                         #
# Entrada: um objeto Lugar e um novo valor para alguma alguma das proprieda-  #
#          des do Lugar.                                                      #
# Descricao: altera o estado de alguma das propriedades do Lugar.             #
###############################################################################

sub propriedade
{
  my $self        = shift;
  my $propriedade = shift;

  if (@_)
  {
    $self->{PROPRIEDADES}{$propriedade} = shift;
  }
}

###############################################################################
# Metodo: estado prop                                                         #
# Entrada: um objeto Lugar e uma propriedade adicional do mesmo.              #
# Descricao: devolve o estado de uma das propriedades adicionais do Lugar.    #
###############################################################################

sub estado_prop
{
  my $self = shift;
  my $propriedade = shift;

  return $self->{PROPRIEDADES}{$propriedade};
}

###############################################################################
# Metodo: cria_saida                                                          #
# Entrada: um objeto Lugar, uma nova direcao de saida e a referencia para o   #
#          outro Lugar.                                                       #
# Descricao: cria uma nova direcao de saida do Lugar.                         #
###############################################################################

sub cria_saida
{
  my $self    = shift;
  my $direcao = shift;

  if (@_)
  {
    $self->{SAIDAS}{$direcao} = shift;
  }
}

###############################################################################
# Metodo: tira_saida                                                          #
# Entrada: um objeto Lugar e uma direcao de saida.                            #
# Descricao: cancela alguma das saidas existentes no Lugar.                   #
###############################################################################

sub tira_saida
{
  my $self = shift;
  my $direcao = shift;

  delete ($self->{SAIDAS}{$direcao});
}

###############################################################################
# Metodo: inclui_objeto                                                       #
# Entrada: um objeto Lugar e um objeto Objeto.                                #
# Descricao: inclui um novo Objeto no Lugar.                                  #
###############################################################################

sub inclui_objeto
{
  my $self = shift;

  if (@_)
  {
    push(@{$self->{OBJETOS}},shift);
  }
}

###############################################################################
# Metodo: exclui_objeto                                                       #
# Entrada: o Objeto a ser excluido.                                           #
# Descricao: retira um Objeto do Lugar.                                       #
###############################################################################

sub exclui_objeto
{
  my $self = shift;
  my $obj  = shift;
  my $tam  = @{$self->{OBJETOS}};
  my $i;

  while ($tam > 0)
  {
    $i = shift(@{$self->{OBJETOS}});
    if ($i eq $obj)
    {
      return 1;
    }
    else
    {
      push(@{$self->{OBJETOS}},$i)
    }
    $tam--;
  }
  return 0;
}

###############################################################################
# Rotina: nova_acao                                                           #
# Entrada:   O primeiro argumento eh o objeto.                                #
#            O segundo argumento eh o nome da acao, usado como chave,         #
#            e o terceiro a string com o nome da subrotina correspondente.    #
# Descricao: inclui uma nova acao para o lugar.                               #
###############################################################################

sub nova_acao
{
  my $lugar = shift;
  my $novo  = shift;
    
  if ($lugar->devolve('acao', $novo))
  {
    ES::Erro("Verbo $novo já foi definido para ".$lugar->devolve('nome'));
  }
  else
  {
    $lugar->{ACOES}{$novo} = shift;
  }
}

###############################################################################
# Rotina: hash_de_lugares                                                     #
# Entrada: referencia para um hash de lugares.                                #
# Descricao: diz qual e o hash de lugares.                                    #
###############################################################################

sub hash_de_lugares
{
  my $ref_hash = shift;

  $lugares = $ref_hash;
}

1;
