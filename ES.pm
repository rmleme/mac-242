package ES;

###############################################################################
# Modulo: ES.pm                                                               #
# Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430         #
#          Regis de Abreu Barbosa                 Numero USP: 3135701         #
#          Renato Kosaka Araujo                   Numero USP: 3100737         #
#          Rodrigo Mendes Leme                    Numero USP: 3151151         #
# Curso: computacao                  Data: 15/12/2000                         #
# Professor: Marco Gubitoso                                                   #
# Descricao: Este modulo contem subrotinas de E/S para o projeto.             #
###############################################################################

use strict;

###############################################################################
# Funcao: Erro                                                                #
# Entrada: uma mensagem de erro do programa.                                  #
# Descricao: imprime uma mensagem de erro na tela.                            #
###############################################################################

sub Erro
{
  my $mensagem = shift;

  print $mensagem."\n";
}

###############################################################################
# Funcao: Exibe                                                               #
# Entrada: uma mensagem do programa.                                          #
# Descricao: imprime uma mensagem qualquer na tela.                           #
###############################################################################

sub Exibe
{
  my $mensagem = shift;

  print $mensagem."\n";
}

###############################################################################
# Funcao: Final                                                               #
# Entrada: a mensagem de finalizacao do programa.                             #
# Descricao: imprime a mensagem de finalizacao do programa na tela.           #
###############################################################################

sub Final
{
  my $mensagem = shift;

  print "$mensagem\n";
  exit;
}

1;
