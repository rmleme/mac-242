Objeto revolver
desc=Atira balas.
:::
Objeto nave
desc={� uma gigantesca nave espacial, e parece com problemas! Vc jura que pode ouvir o barulho de motor falhando!!!
}
verbo pegar=nao_pega
combustivel=20
animado combustivel=acabou_gasolina
sinonimos nave=disco
:::
Objeto pilha
desc=Tem tantas coisas aqui, mas nada parece ser �til.
verbo pegar=nao_pega
:::
Objeto botao
desc=Por que voc� n�o experimenta apertar pra ver o que acontece?
verbo apertar=aperta_botao
verbo pegar=nao_pega
:::
Lugar Quintal
desc={Este � o quintal de sua casa. � esquerda esta a entrada para a casa
Luzes estranhas movimentam-se de um lado pro outro.
Voc� olha pra cima e v� uma nave espacial.
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
exibe("N�o consigo pegar isso.")
:::
Acao aperta_botao
exibe("Ao apertar o bot�o uma arma super poderosa � acionada e ela destr�i a nave espacial.")
exibe("Agora voc� pode voltar a dormir sem aquelas luzes te perturbando.")
final("FIM")
:::
Lugar Casa
desc={
No meio da sala tem uma pilha gigante de coisas. Que bagun�a, hein!
Tamb�m tem um bot�o na parede.
� direita est� o quintal da sua casa.
}
inclui pilha
inclui botao
saida direita=quintal
:::
Acao acabou_gasolina
final("A nave caiu bem em cima de vc... Adeus!!!")