===============================================================================
                 RELATÓRIO - PROJETO DE MAC 242 - FASES 2 e 3
===============================================================================

Autores: Paulo Marcel Caldeira Yokosawa         Numero USP: 3095430
         Régis de Abreu Barbosa                 Numero USP: 3135701
         Renato Kosaka Araújo                   Numero USP: 3100737
         Rodrigo Mendes Leme                    Numero USP: 3151151
Curso: computação
Professor: Marco Dimas Gubitoso



- MÓDULOS DO PROGRAMA:

Trad: "traduz" o arquivo de entrada, gerando o ambiente do jogo.

Verbo.pm: contém todas as ações que podem ser executadas pelo jogador, bem como
          suas implementações.

Leitor.pm: faz a leitura, limpeza, identificação e execução dos comandos 
           passados pelo jogador na entrada do jogo.

ES.pm: contém todas as rotinas de entrada/saída do jogo.

   A esses pacotes, somam-se os da primeira fase, devidamente corrigidos:

Objeto.pm: rotinas de manipulação dos objetos do jogo.

Lugar.pm: rotinas de manipulação dos lugares do jogo.



- EXECUÇÃO DO PROGRAMA:

   Para execução do programa, basta rodá-lo com um arquivo de descrição, nos 
moldes estabelecidos pelo professor. Ex.: adventure.pl <arquivo de descrição>



- EXEMPLO DE EXECUÇÃO:

Este é o quintal de sua casa. À esquerda esta a entrada para a casa
Luzes estranhas movimentam-se de um lado pro outro.
Você olha pra cima e vê uma nave espacial.

Objetos: revolver nave
Suas coisas:
Jogador: pegar revolver
Jogador: va para a esquerda
No meio da sala tem uma pilha gigante de coisas. Que bagunca, hein!
Também tem um botão na parede.
À direita está o quintal da sua casa.

Objetos: pilha botao
Suas coisas: revolver
Jogador: atirar na pilha
Não é possível executar esta ação aqui.
Jogador: pegue a pilha
Não consigo pegar isso.
Jogador: mova a pilha
Não é possível executar esta ação aqui.
Jogador: olhe a pilha
Tem tantas coisas aqui, mas nada parece ser útil.
Jogador: ver o botao
Por que você não experimenta apertar pra ver o que acontece?
Jogador: direita
Este é o quintal de sua casa. À esquerda esta a entrada para a casa
Luzes estranhas movimentam-se de um lado pro outro.
Você olha pra cima e vê uma nave espacial.

Objetos: nave
Suas coisas: revolver
Jogador: pegue a nave
Não consigo pegar isso.
Jogador: atire na nave
Não é possível executar esta ação aqui.
Jogador: ir para a esquerda
No meio da sala tem uma pilha gigante de coisas. Que bagunca, hein!
Também tem um botão na parede.
À direita está o quintal da sua casa.

Objetos: pilha botao
Suas coisas: revolver
Jogador: aperte o botao
Ao apertar o botão uma arma super poderosa é acionada e ela destrói a nave
espacial.
Agora você pode voltar a dormir sem aquelas luzes te perturbando.
FIM