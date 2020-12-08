Objeto revolver
desc=Atira balas.
:::
Objeto nave
desc={É uma gigantesca nave espacial, e parece com problemas! Vc jura que pode ouvir o barulho de motor falhando!!!
}
verbo pegar=nao_pega
combustivel=20
animado combustivel=acabou_gasolina
sinonimos nave=disco
:::
Objeto pilha
desc=Tem tantas coisas aqui, mas nada parece ser útil.
verbo pegar=nao_pega
:::
Objeto botao
desc=Por que você não experimenta apertar pra ver o que acontece?
verbo apertar=aperta_botao
verbo pegar=nao_pega
:::
Lugar Quintal
desc={Este é o quintal de sua casa. À esquerda esta a entrada para a casa
Luzes estranhas movimentam-se de um lado pro outro.
Você olha pra cima e vê uma nave espacial.
}
inclui revolver
inclui aventureiro
inclui nave
saida esquerda=casa
sinonimos direita=leste
sinonimos esquerda=oeste
sinonimos pegar=agarrar
:::
Acao nao_pega
exibe("Não consigo pegar isso.")
:::
Acao aperta_botao
exibe("Ao apertar o botão uma arma super poderosa é acionada e ela destrói a nave espacial.")
exibe("Agora você pode voltar a dormir sem aquelas luzes te perturbando.")
final("FIM")
:::
Lugar Casa
desc={
No meio da sala tem uma pilha gigante de coisas. Que bagunça, hein!
Também tem um botão na parede.
À direita está o quintal da sua casa.
}
inclui pilha
inclui botao
saida direita=quintal
:::
Acao acabou_gasolina
final("A nave caiu bem em cima de vc... Adeus!!!")