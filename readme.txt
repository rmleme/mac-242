===============================================================================
                 RELAT�RIO - PROJETO DE MAC 242 - FASES 2 e 3
===============================================================================

Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430
         R�gis de Abreu Barbosa                 Numero USP: 3135701
         Renato Kosaka Ara�jo                   Numero USP: 3100737
         Rodrigo Mendes Leme                    Numero USP: 3151151
Curso: computa��o
Professor: Marco Dimas Gubitoso



- M�DULOS DO PROGRAMA:

Trad: "traduz" o arquivo de entrada, gerando o ambiente do jogo.

Verbo.pm: cont�m todas as a��es que podem ser executadas pelo jogador, bem como
          suas implementa��es.

Leitor.pm: faz a leitura, limpeza, identifica��o e execu��o dos comandos 
           passados pelo jogador na entrada do jogo.

ES.pm: cont�m todas as rotinas de entrada/sa�da do jogo.

   A esses pacotes, somam-se os da primeira fase, devidamente corrigidos:

Objeto.pm: rotinas de manipula��o dos objetos do jogo.

Lugar.pm: rotinas de manipula��o dos lugares do jogo.



- EXECU��O DO PROGRAMA:

   Para execu��o do programa, basta rod�-lo com um arquivo de descri��o, nos 
moldes estabelecidos pelo professor. Ex.: adventure.pl <arquivo de descri��o>



- EXEMPLO DE EXECU��O:

Este � o quintal de sua casa. � esquerda esta a entrada para a casa
Luzes estranhas movimentam-se de um lado pro outro.
Voc� olha pra cima e v� uma nave espacial.

Objetos: revolver nave
Suas coisas:
Jogador: pegar revolver
Jogador: va para a esquerda
No meio da sala tem uma pilha gigante de coisas. Que bagunca, hein!
Tamb�m tem um bot�o na parede.
� direita est� o quintal da sua casa.

Objetos: pilha botao
Suas coisas: revolver
Jogador: atirar na pilha
N�o � poss�vel executar esta a��o aqui.
Jogador: pegue a pilha
N�o consigo pegar isso.
Jogador: mova a pilha
N�o � poss�vel executar esta a��o aqui.
Jogador: olhe a pilha
Tem tantas coisas aqui, mas nada parece ser �til.
Jogador: ver o botao
Por que voc� n�o experimenta apertar pra ver o que acontece?
Jogador: direita
Este � o quintal de sua casa. � esquerda esta a entrada para a casa
Luzes estranhas movimentam-se de um lado pro outro.
Voc� olha pra cima e v� uma nave espacial.

Objetos: nave
Suas coisas: revolver
Jogador: pegue a nave
N�o consigo pegar isso.
Jogador: atire na nave
N�o � poss�vel executar esta a��o aqui.
Jogador: ir para a esquerda
No meio da sala tem uma pilha gigante de coisas. Que bagunca, hein!
Tamb�m tem um bot�o na parede.
� direita est� o quintal da sua casa.

Objetos: pilha botao
Suas coisas: revolver
Jogador: aperte o botao
Ao apertar o bot�o uma arma super poderosa � acionada e ela destr�i a nave
espacial.
Agora voc� pode voltar a dormir sem aquelas luzes te perturbando.
FIM