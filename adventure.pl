#!/usr/bin/perl

package teste;

###############################################################################
# Programa: adventure - fase 3                                                #
# Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430         #
#          Regis de Abreu Barbosa                 Numero USP: 3135701         #
#          Renato Kosaka Araujo                   Numero USP: 3100737         #
#          Rodrigo Mendes Leme                    Numero USP: 3151151         #
# Curso: computacao                  Data: 15/12/2000                         #
# Professor: Marco Gubitoso                                                   #
# Descricao: arquivo do jogo propriamente dito. Carrega o mesmo e executa-o   #
#            num loop infinito, ate o usuario morrer, vencer ou sair do jogo. #
###############################################################################

use ES;
use Lugar;
use Objeto;
use Leitor;
use Verbo;
use Trad;

my $verbo;
my $direcao;
my $terminou = 0;

Trad::traduz;                # Carrega o jogo
Verbo::mudar_lugar;          # Inicializa a localizacao do aventureiro

while (!$terminou)
{
  print "Jogador: ";
  $cadeia       = <>;
  $_            = &Leitor::filtra_comando($cadeia);
  if ($_ eq "q") {                # Jogador deseja terminar o jogo
    $terminou = 1;
  }
  else
  {
    @comando      = split;        # Quebra a entrada em <verbo> e <complemento>
    $num_palavras = @comando;
    if ($num_palavras == 1)      # Só existe uma palavra que e verbo ou direcao
    {
      if (&Leitor::existe_direcao(@comando)) {       # Foi digitada uma direcao
        &Verbo::mudar_lugar;
      }
      else           # Foi digitado um verbo, executa a acao associada ao mesmo
      {
        $verbo = &Leitor::identifica_verbo(@comando);
        if ($verbo ne "0") {
          &Verbo::executa_acao($verbo,'geral');
        }
        else {
          ES::Erro("Não é possível executar esta ação aqui.");
        }
      }
    } 
    elsif ($num_palavras > 1)         # Trata-se do caso <verbo> <objetos>
    {
      $verbo      = &Leitor::identifica_verbo(@comando);
      $comando[0] = $verbo;    # Substitui o verbo digitado pela forma canonica
      if ($verbo ne "0") {     # Se for um verbo valido, executa a acao
        &Leitor::executa_acao(@comando);
      }
      else {
        ES::Erro("Não é possível executar esta ação aqui.");
      }
    }
  }
}
