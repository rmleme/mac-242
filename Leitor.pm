package Leitor;

###############################################################################
# Modulo: Leitor.pm                                                           #
# Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430         #
#          Regis de Abreu Barbosa                 Numero USP: 3135701         #
#          Renato Kosaka Araujo                   Numero USP: 3100737         #
#          Rodrigo Mendes Leme                    Numero USP: 3151151         #
# Curso: computacao                  Data: 15/12/2000                         #
# Professor: Marco Gubitoso                                                   #
# Descricao: Este modulo contem as subrotinas de leitura, limpeza, identifi-  #
#            cacao e execuacao dos comandos digitados pelo usuario no jogo.   #
###############################################################################

use Verbo;
use Objeto;

###############################################################################
# Funcao: existe_raiz                                                         #
# Entrada: o verbo a ser localizado.                                          #
# Saida: 1 se encontrou a raiz do verbo; 0 caso contrario. Alem disso, retor- #
#        na o verbo encontrado.                                               #
# Descricao: procura nas listas de verbos e de sinonimos a raiz do suposto    #
#            verbo passado como parametro.                                    #
###############################################################################

sub existe_raiz
{
  my $procurado  = shift;
  my $encontrado = shift;
  my $achou      = 0;
  my $verbo;
  
  foreach $verbo (keys %Verbo::verbos)
  {
    if (substr($procurado,0,3) eq substr($verbo,0,3))       # Com isso, compara
    {                                             # apenas as raizes dos verbos
      $achou       = 1;
      $$encontrado = $verbo;
      last;
    }
  }
  if (!$achou)        # Nao encontrou na lista de verbos, tenta na de sinonimos
  {
    foreach $verbo (keys %Verbo::sinonimos)
    {
      if (substr($procurado,0,3) eq substr($verbo,0,3))     # Com isso, compara
      {                                           # apenas as raizes dos verbos
        $achou       = 1;
        $$encontrado = $verbo;
        last;
      }
    }
  }
  return $achou;
}

###############################################################################
# Funcao: extrai_preposicoes                                                  #
# Entrada: uma cadeia de caracteres.                                          #
# Saida: a cadeia modificada.                                                 #
# Descricao: retira todas as preposicoes de uma cadeia de caracteres.         #
###############################################################################

sub extrai_preposicoes
{
  my $cadeia = shift;

  $cadeia =~ s/\bate\b//g;
  $cadeia =~ s/\bapos\b//g;
  $cadeia =~ s/\bante\b//g;
  $cadeia =~ s/\bcom\b//g;
  $cadeia =~ s/\bcontra\b//g;
  $cadeia =~ s/\bd{1}[aeo]{1}s?\b//g;       # Preposicao "de" e suas contracoes
  $cadeia =~ s/\bdesde\b//g;
  $cadeia =~ s/\bem\b//g;
  $cadeia =~ s/\bn{1}[ao]{1}s?\b//g;            # Extrai as contracoes da
  $cadeia =~ s/\bn{1}u{1}[mn]{1}a?s?\b//g;      # preposicao "em"
  $cadeia =~ s/\bentre\b//g;
  $cadeia =~ s/\bpor\b//g;
  $cadeia =~ s/\bpara\b//g;
  $cadeia =~ s/\bsem\b//g;
  $cadeia =~ s/\bsob\b//g;
  $cadeia =~ s/\bsobre\b//g;
  $cadeia =~ s/\bperante\b//g;
  $cadeia =~ s/\bdurante\b//g;
  $cadeia =~ s/\batraves\b//g;
  $cadeia =~ s/\btras\b//g;
  return $cadeia;
}

###############################################################################
# Funcao: filtra_comando                                                      #
# Entrada: uma cadeia de caracteres.                                          #
# Saida: a cadeia modificada.                                                 #
# Descricao: filtra a cadeia de entrada digitado pelo jogador, mudando-a para #
#            letras minusculas e retirando artigos, preposicoes e acentuacoes.#
###############################################################################

sub filtra_comando
{
  my $cadeia = shift;

  # Retira as acentuacoes
  $cadeia =~ tr/¡…Õ”⁄·ÈÌÛ˙¬ Œ‘€‚ÍÓÙ˚«Á√„¿‡‹¸/AEIOUaeiouAEIOUaeiouCcAaAaUu/;
  chomp($cadeia);                 # Tira o new line do final da cadeia
  $cadeia =~ tr/A-Z/a-z/;         # Troca todas as maiusculas por minusculas
  if ($cadeia ne "o")             # Nao e caso especial - direcao oeste
  {
    $cadeia =~ s/\b[ao]{1}s?\b//g;             # Extrai os artigos definidos
    $cadeia =~ s/\bu{1}[mn]{1}a?s?\b//g;       # Extrai os artigos indefinidos
    $cadeia = extrai_preposicoes($cadeia);
  }
  return $cadeia;
}

###############################################################################
# Funcao: identifica_verbo                                                    #
# Entrada: o suposto verbo.                                                   #
# Saida: "0" se o verbo nao eh valido; o verbo identificado, caso contrario.  #
# Descricao: recebe um suposto verbo qualquer e retorna a forma canonica do   #
#            mesmo.                                                           #
###############################################################################

sub identifica_verbo
{
  my $verbo = shift;
  my $encontrado;
  my $referencia;
  my $final;

  if (length($verbo) <= 3)      # Procura nas listas o verbo inteiro
  {
    if (exists($Verbo::verbos{$verbo})) {
      return $verbo;
    }
    elsif (exists($Verbo::sinonimos{$verbo})) {
      return $Verbo::sinonimos{$verbo};
    }
    else {
      return "0";
    }
  }
  else          # Procura nas listas apenas a raiz do verbo
  {
    $referencia = \$encontrado;
    if (existe_raiz($verbo,$referencia))        # Procura nas listas de verbos
    {                                           # e sinonimos a raiz do verbo
      $encontrado = $$referencia;
      $final      = chop($verbo);
      if ($final eq "a" || $final eq "e" || $final eq "i" || $final eq "o" ||
          $final eq "u" || $final eq "r")     # Esta no infinito ou imperativo
      {
        if ($final eq "r")       # Nao esta no imperativo
        {
          $final = chop($verbo) . $final;
          if ($final eq "ar" || $final eq "er" || $final eq "ir" ||
              $final eq "or")          # Esta no infinitivo (pela conjugacao)
          {
            if (exists($Verbo::verbos{$encontrado})) {      # Achou na lista
              return $encontrado;                           # de verbos
            }
            else {                              # Achou na lista de sinonimos
              return $Verbo::sinonimos{$encontrado};
            }
          }
          else {
            return "0";
          }
        }
        else
        {
          if (exists($Verbo::verbos{$encontrado})) {        # Achou na lista
            return $encontrado;                             # de verbos
          }
          else {                               # Achou na lista de sinonimos
            return $Verbo::sinonimos{$encontrado};
          }
        }
      }
      else {
        return "0";
      }
    }
    else {
      return "0";
    }
  }
}

###############################################################################
# Funcao: existe_direcao                                                      #
# Entrada: a direcao a ser localizada.                                        #
# Saida: 1 se encontrou a direcao; 0 caso contrario.                          #
# Descricao: ve se a direcao digitada pelo usuario eh valida; caso seja, alte-#
#            a localizacao do aventureiro.                                    #
###############################################################################

sub existe_direcao
{
  my $direcao = shift;
  my $lugar_atual;               # A atual localizacao do aventureiro
  my $novo_lugar;                # Para onde o aventureiro foi apos se mover

  $lugar_atual = $Lugar::lugares->{&Objeto::devolve_aventureiro
                                   ->devolve("local")};
  if (exists($lugar_atual->{SAIDAS}{$direcao}))
  {
    $novo_lugar = $Lugar::lugares->{$lugar_atual->{SAIDAS}{$direcao}}
                  ->devolve("nome");
    &Objeto::devolve_aventureiro->altera("local",$novo_lugar);
    return 1;
  }
  elsif (exists($Verbo::sinonimos{$direcao}))
  {
    $direcao = $Verbo::sinonimos{$direcao};
    if (exists($lugar_atual->{SAIDAS}{$direcao}))
    {
      $novo_lugar = $Lugar::lugares->{$lugar_atual->{SAIDAS}{$direcao}}
                                      ->devolve("nome");
      &Objeto::devolve_aventureiro->altera("local",$novo_lugar);
      return 1;
    }
    else {
      return 0;
    }
  }
  else {
    return 0;
  }
}

###############################################################################
# Funcao: existe_objeto                                                       #
# Entrada: o objeto a ser localizado.                                         #
# Saida: o objeto se o encontrou; 0 caso contrario.                           #
# Descricao: procura nas listas de objetos e de sinonimos o nome do objeto    #
#            procurado. Se ele tiver alguma caracteristica especial, tambem a #
#            procura.                                                         #
###############################################################################

sub existe_objeto
{
  my $procurado = shift;
  my $caracteristica;
  my $objeto;

  if (exists ($Objeto::objetos->{$procurado})) {
    return $procurado;
  }
  elsif (exists ($Verbo::sinonimos{$procurado})) {
    $objeto = $Verbo::sinonimos{$procurado};
    return $objeto;
  }
  if (scalar(@_)) {
    $caracteristica = shift;  
    $procurado      = $procurado.$caracteristica;
    if (exists ($Objeto::objetos->{$procurado})) {
      return $procurado;
    }
    elsif (exists ($Verbo::sinonimos{$procurado})) {
      $objeto = $Verbo::sinonimos{procurado};
      return $objeto;
    }    
  }
  return "0";
}

###############################################################################
# Funcao: existe_lugar                                                        #
# Entrada: o lugar a ser localizado.                                          #
# Saida: o lugar se o encontrou; 0 caso contrario.                            #
# Descricao: procura nas listas de lugares e de sinonimos o nome do lugar     #
#            procurado.                                                       #
###############################################################################

sub existe_lugar
{
  my $procurado = shift;
  my $lugar;

  if (exists ($Lugar::lugares->{$procurado})) {
    return $procurado;
  }
  elsif (exists ($Verbo::sinonimos{$procurado})) {
    $lugar = $Verbo::sinonimos{$procurado};
    return $lugar;
  }
  return "0";
}

###############################################################################
# Funcao: executa_acao                                                        #
# Entrada: o verbo a ser executado e o complemento associado ao verbo.        #
# Descricao: executa a acao associada a um verbo, primeiro tentando o caso    #
#            mais especifico e, em nao conseguindo, o mais geral.             #
###############################################################################

sub executa_acao
{
  my $verbo     = shift;
  my $procurado = shift;
  my $direcao;
  my $obj;
  my $objblessed;
  my $lg;
  my $lgblessed;

  if (existe_direcao ($procurado)) {    # A direcao digitada e valida
    if ($verbo eq 'ir') {               # Trata-se do caso <verbo> <direcao>
        &Verbo::mudar_lugar;
    }
  }
  else
  {
    $obj = existe_objeto ($procurado, @_);
    if ($obj ne "0") {
      $objblessed = $Objeto::objetos->{$obj};
      if ($objblessed->devolve('local') ne               # O objeto nao esta no
              &Objeto::devolve_aventureiro->devolve('local')) {         # mesmo
	  ES::Erro ("Este objeto n„o existe aqui.\n");             # lugar onde
	  return;                                          # esta o aventureiro
      }
      if (exists ($objblessed->{ACOES}{$verbo})) {       # O verbo e especifico
	&Verbo::executa_acao ($verbo, $objblessed);      # daquele objeto
      }
      else {                                             # Executa o caso geral
        &Verbo::executa_acao ($verbo, 'geral', $objblessed);
      }
    }
    else         # O objeto esta no mesmo lugar onde esta o aventureiro
    {
      $lg = existe_lugar ($procurado, @_);
      if ($lg ne "0") {
	  $lgblessed = $Lugar::lugares->{$lg};
	  if ($lgblessed->devolve('nome') ne
                  &Objeto::devolve_aventureiro->devolve('local')) {
	      ES::Erro ("Chegue l· primeiro.\n");
	      return;
	  }
	  if (exists ($lgblessed->{ACOES}{$verbo})) {
	      &Verbo::executa_acao ($verbo, $lgblessed);    
	  }
	  else {
	      &Verbo::executa_acao ($verbo, "geral", $lgblessed); 
	  }
      } 
      else {
	  &Verbo::executa_acao ($verbo, "geral");     # Executa o caso mais
      }                                               # geral do verbo
    }
  }
} 

1;
