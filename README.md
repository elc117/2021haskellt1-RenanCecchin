# Programação Funcional - Haskell
## Trabalho 1: Generative Art com Programação Funcional em Haskell
###### Conteúdo
- Funcionamento geral do código
- Posicionamento das formas
- Geração das cores
- Referências
###### Funcionamento geral do código
Para o Trabalho 1 de Haskell a minha escolha de arte generativa foi inspirada em uma 
[imagem](http://3.bp.blogspot.com/-TQ0gi_ajUSk/VWodsH3vRiI/AAAAAAAAAEU/d4vBMI0gY9w/s1600/20110511153010.jpg)
da internet, a partir dela tive a ideia de fazer vários triângulos com um dos lados sendo o centro da imagem e,
como parâmetro fosse possível escolher quantos triângulos haveriam em cada parte da imagem.  
Durante o desenvolvimento enfrentei algumas dificuldades que modificaram minha ideia original, 
diante disso escolhi seguir a essência da ideia e adicionar elementos para incrementar o trabalho e o 
[resultado](fig.svg) foi surpreendente.
###### Posicionamento das formas
Como a ideia era gerar triangulos que partissem do centro da imagem até as bordas eu dividi a altura, 
para os triângulos da esquerda e da direita, e a largua, para os triângulos de cima e de baixo, pelo `número de lados-1`.
Após isso, eu usei *list comprehension* para gerar pontos de zero até o valor do resolução usando 
esses pontos que consegui dividindo as dimensões da imagem
```haskell
genTriangles :: Int -> Point -> [Triangle]
genTriangles n (w,h) = xlist ++ ylist ++ (mirrorPos 'x' (w,h) xlist) ++ (mirrorPos 'y' (w,h) ylist)
    where xlist = [((a,b), center, (a,b/2)) | a <- [0], b <- [0, h/(fromIntegral (n-1)).. h - h/(fromIntegral (n-1))], center <- [(w/2, h/2)]]
          ylist = [((a,b), center, (a/2,b)) | a <- [0, w/(fromIntegral (n-1)).. w - w/(fromIntegral (n-1))], b <- [0], center <- [(w/2, h/2)]]
```
Porém, com essa maneira de gerar triângulos há um problema: quando a resolução não é N por N sobram espaços vazios na imagem.
Dito isso, eu adicionei um retângulo do tamanho da imagem para evitar espaços vazios e adicionar um efeito de transparência que
fortalece a cor de todos os triângulos na imagem, e adiciona um efeito de transparência aos espaços que antes ficavam em branco.
###### Geração das cores
No quesito cores, eu optei por fazer um gradiente de cores que mudam conforme o número de triângulos desejados, com isso em mente
eu criei 6 padrões diferentes para o gradiente que são escolhidos a partir do resto de uma divisão por 6, pois abrange 6 resultados diferentes.
Além disso, a taxa de crescimento dos gradientes depende de quantos triângulos o usuário escolheu gerar.
```haskell
gradientPalette :: Int -> Float -> [(Int,Int,Int,Float)]
gradientPalette n opacity
    | nrandom == 0 = [(r,g,b,o) | r <- increaselist, g <- [0], b <- decreaselist, o <- [opacity]]
    | nrandom == 1 = [(r,g,b,o) | r <- decreaselist, g <- [0], b <- increaselist, o <- [opacity]]
    | nrandom == 2 = [(r,g,b,o) | r <- [0], g <- increaselist, b <- decreaselist, o <- [opacity]]
    | nrandom == 3 = [(r,g,b,o) | r <- [0], g <- decreaselist, b <- increaselist, o <- [opacity]]
    | nrandom == 4 = [(r,g,b,o) | r <- increaselist, g <- decreaselist, b <- [0], o <- [opacity]]
    | otherwise = [(r,g,b,o) | r <- decreaselist, g <- increaselist, b <- [0], o <- [opacity]]
    where gap = 255 `div` n
          nrandom = n `mod` 6
          decreaselist = [0, gap..255]
          increaselist = reverse decreaselist
```
###### Referências
- [Inspiração da imagem](http://pedagogiavivanarede.blogspot.com/2015/05/arte-abstrata-geometrica.html)
- Ajuda do colega Guilherme Medeiros da Cunha
