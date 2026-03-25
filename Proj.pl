
%Tomas Sobral Teixeira, 103796
%O objetivo deste projeto e escrever a primeira parte de 
%um programa em PROLOG para resolver puzzles hashi.



%2.1 extrai_ilhas_linha/3

%extrai_ilhas_linha(N_L, Linha, Ilhas), em que N_L e um inteiro positivo,
%correspondente ao numero de uma linha e Linha e uma lista correspondente a uma linha
%de um puzzle, significa que Ilhas e a lista ordenada (ilhas da esquerda para a direita)
%cujos elementos sao as ilhas da linha Linha.



extrai_ilhas_linha(N_L, Linha, Ilhas):-
	findall(ilha(N_pontes, (N_L, Coluna)), (nth1(Coluna,Linha,N_pontes), N_pontes=\=0), Ilhas). 
	%nth1 nao precisa de member antes senao duplica coisas com o mesmo elemento



%2.2 ilhas/2

%ilhas(Puz, Ilhas), em que Puz e um puzzle, significa que Ilhas e a lista ordenada
%(ilhas da esquerda para a direita e de cima para baixo) cujos elementos sao as ilhas de Puz.



ilhas(Puz,Ilhas):-
	findall(Ilhas_Linha, (nth1(N_L, Puz, Linha), 
		extrai_ilhas_linha(N_L, Linha, Ilhas_Linha)), IlhasJuntas),
	append(IlhasJuntas,Ilhas).



%2.3 vizinhas/3

%vizinhas(Ilhas, Ilha, Vizinhas), em que Ilhas e a lista de ilhas de um puzzle
%e Ilha e uma dessas ilhas, significa que Vizinhas e a lista ordenada (ilhas de cima para
%baixo e da esquerda para a direita ) cujos elementos sao as ilhas vizinhas de Ilha.



primeiro_el([P|_],P).

vizinhas(Ilhas,ilha(_,(L,C)),Vizinhas):-
	findall(Ilha, (member(Ilha,Ilhas),Ilha=ilha(_,(L_Cima,C)),L_Cima<L), Todas_Cima),
	findall(Ilha, (member(Ilha,Ilhas),Ilha=ilha(_,(L,C_Esq)),C_Esq<C), Todas_Esquerda),
	findall(Ilha, (member(Ilha,Ilhas),Ilha=ilha(_,(L,C_Dir)),C_Dir>C), Todas_Direita),
	findall(Ilha, (member(Ilha,Ilhas),Ilha=ilha(_,(L_Baixo,C)),L_Baixo>L), Todas_Baixo),
	findall(Ilha_Vizinha, (last(Todas_Cima,Ilha_Vizinha); last(Todas_Esquerda,Ilha_Vizinha); 
		primeiro_el(Todas_Direita,Ilha_Vizinha); primeiro_el(Todas_Baixo,Ilha_Vizinha)), Vizinhas).



%2.4 estado/2

%estado(Ilhas, Estado), em que Ilhas e a lista de ilhas de um puzzle, significa que
%Estado e a lista ordenada cujos elementos sao as entradas referentes a cada uma das
%ilhas de Ilhas.



estado(Ilhas,Estado):-
	findall([Ilha,Vizinhas,[]], (member(Ilha,Ilhas), vizinhas(Ilhas,Ilha,Vizinhas)), Estado).



%2.5 posicoes_entre/3

%posicoes_entre(Pos1, Pos2, Posicoes), em que Pos1 e Pos2 sao posicoes, significa que 
%Posicoes e a lista ordenada de posicoes entre Pos1 e Pos2 (excluindo Pos1 e Pos2). 
%Se Pos1 e Pos2 nao pertencerem a mesma linha ou a mesma coluna, o resultado e false.



posicoes_entre((L,C1),(L,C2),Posicoes):- %mesma linha
	!,findall((L,C), ((between(C1,C2,C),C1<C,C<C2);(between(C2,C1,C),C1>C,C>C2)),Posicoes).


posicoes_entre((L1,C),(L2,C),Posicoes):- %mesma coluna
	!,findall((L,C), ((between(L1,L2,L),L1<L,L<L2);(between(L2,L1,L),L1>L,L>L2)),Posicoes).



%2.6 cria_ponte/3

%cria_ponte(Pos1, Pos2, Ponte), em que Pos1 e Pos2 sao 2 posicoes, significa
%que Ponte e uma ponte entre essas 2 posicoes.



cria_ponte(Pos1,Pos2,Ponte):-
	sort([Pos1,Pos2],Pos_Ordenadas),
	Pos_Ordenadas = [Primeira,Segunda],
	Ponte = ponte(Primeira, Segunda).



%2.7 caminho_livre/5

%caminho_livre(Pos1, Pos2, Posicoes, I, Vz), em que Pos1 e Pos2 sao posicoes, 
%Posicoes e a lista ordenada de posicoes entre Pos1 e Pos2, I e uma ilha, e Vz
%e uma das suas vizinhas, significa que a adicao da ponte ponte(Pos1, Pos2) nao faz
%com que I e Vz deixem de ser vizinhas.



caminho_livre(Pos1,Pos2,Posicoes,ilha(_,(Pos_ilha)),ilha(_,(Pos_vz))):-
	posicoes_entre(Pos_ilha,Pos_vz,Posicoes_entre_I_e_Vz),
	findall(Posicao, (member(Posicao,Posicoes),member(Posicao,Posicoes_entre_I_e_Vz)),Intersecao),
	(length(Intersecao,0);(member(Pos1,[Pos_ilha,Pos_vz]),member(Pos2,[Pos_ilha,Pos_vz]))),!.



%2.8 actualiza_vizinhas_entrada/5

%actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, Entrada, Nova_Entrada),
%em que Pos1 e Pos2 sao as posicoes entre as quais ira ser adicionada uma ponte,
%Posicoes e a lista ordenada de posicoes entre Pos1 e Pos2, e Entrada e uma entrada, 
%significa que Nova_Entrada e igual a Entrada, excepto no que diz respeito 
%a lista de ilhas vizinhas; esta deve ser actualizada,
%removendo as ilhas que deixaram de ser vizinhas, apos a adicao da ponte.



actualiza_vizinhas_entrada(Pos1,Pos2,Posicoes,Entrada,Nova_Entrada):-
	Entrada=[Ilha,Vizinhas,Pontes],
	findall(Vizinha, (member(Vizinha,Vizinhas), 
		caminho_livre(Pos1,Pos2,Posicoes,Ilha,Vizinha)), Resto_Vizinhas),
	Nova_Entrada=[Ilha,Resto_Vizinhas,Pontes].



%2.9 actualiza_vizinhas_apos_pontes/4

%actualiza_vizinhas_apos_pontes(Estado, Pos1, Pos2, Novo_estado) ,
%em que Estado e um estado, Pos1 e Pos2 sao as posicoes entre as
%quais foi adicionada uma ponte, significa que Novo_estado e o estado que se obtem de
%Estado apos a actualizacao das ilhas vizinhas de cada uma das suas entradas.



actualiza_vizinhas_apos_pontes(Estado,Pos1,Pos2,Novo_Estado):-
	posicoes_entre(Pos1,Pos2,Posicoes),
	findall(Nova_Entrada,(member(Entrada,Estado),
		actualiza_vizinhas_entrada(Pos1,Pos2,Posicoes,Entrada,Nova_Entrada)), 
		Novo_Estado).



%2.10 ilhas_terminadas/2

%ilhas_terminadas(Estado, Ilhas_term), em que Estado e um estado, significa que 
%Ilhas_term e a lista de ilhas que ja tem todas as pontes associadas, designadas por ilhas 
%terminadas. Se a entrada referente a uma ilha for [ilha(N_pontes,nPos), Vizinhas, Pontes], 
%esta ilha esta terminada se N_pontes for diferente de X e o comprimento da lista Pontes for N_pontes.



ilhas_terminadas(Estado,Ilhas_term):-
	findall(Ilha, (member(Entrada,Estado), Entrada=[ilha(N_pontes,Pos),_,Pontes], N_pontes\='X', 
		length(Pontes,N_pontes), Ilha=ilha(N_pontes,Pos)), Ilhas_term).



%2.11 tira_ilhas_terminadas_entrada/3

%tira_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_entrada), em que Ilhas_term 
%e uma lista de ilhas terminadas e Entrada e uma entrada, significa que Nova_entrada 
%e a entrada resultante de remover as ilhas de Ilhas_term, da lista de ilhas vizinhas de entrada.



tira_ilhas_terminadas_entrada(Ilhas_term,[Ilha,Vizinhas,Pontes],Nova_entrada):-
	subtract(Vizinhas,Ilhas_term,Resto_Vizinhas),
	Nova_entrada=[Ilha,Resto_Vizinhas,Pontes].



%2.12 tira_ilhas_terminadas/3

%tira_ilhas_terminadas(Estado, Ilhas_term, Novo_estado), em que Estado e um estado
%e Ilhas_term e uma lista de ilhas terminadas, significa que Novo_estado e o estado 
%resultante de aplicar o predicadotira_ilhas_terminadas_entrada a cada uma das entradas de Estado.



tira_ilhas_terminadas(Estado,Ilhas_term,Novo_Estado):-
	findall(Nova_Entrada, (member(Entrada,Estado), 
		tira_ilhas_terminadas_entrada(Ilhas_term,Entrada,Nova_Entrada)), 
		Novo_Estado).



%2.13 marca_ilhas_terminadas_entrada/3

%marca_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_entrada), em que Ilhas_term
%e uma lista de ilhas terminadas e Entrada e uma entrada, significa que Nova_entrada e a 
%entrada obtida de Entrada da seguinte forma: se a ilha de Entrada pertencer a Ilhas_term, o numero
%de pontes desta e substituido por X; em caso contrario Nova_entrada e igual a Entrada.



marca_ilhas_terminadas_entrada(Ilhas_term,[Ilha,Vizinhas,Pontes],Nova_entrada):-
	member(Ilha,Ilhas_term),
	Ilha=ilha(_,(L,C)),
	Nova_entrada=[ilha('X',(L,C)),Vizinhas,Pontes],!.


marca_ilhas_terminadas_entrada(_,Entrada,Entrada).


%2.14 marca_ilhas_terminadas/3

%marca_ilhas_terminadas(Estado, Ilhas_term, Novo_estado), em queEstado e um estado e 
%Ilhas_term e uma lista de ilhas terminadas, significa que Novo_estado e o estado resultante 
%de aplicar o predicadomarca_ilhas_terminadas_entrada a cada uma das entradas de Estado.



marca_ilhas_terminadas(Estado,Ilhas_term,Novo_estado):-
	findall(Nova_Entrada, (member(Entrada,Estado),
		marca_ilhas_terminadas_entrada(Ilhas_term,Entrada,Nova_Entrada)), 
		Novo_estado).



%2.15 trata_ilhas_terminadas

%trata_ilhas_terminadas(Estado, Novo_estado), em que Estado e um estado, significa que 
%Novo_estado e o estado resultante de aplicar os predicados tira_ilhas_terminadas 
%e marca_ilhas_terminadas a Estado.



trata_ilhas_terminadas(Estado,Novo_estado):-
	ilhas_terminadas(Estado,Ilhas_term),
	tira_ilhas_terminadas(Estado,Ilhas_term,Estado_mid),
	marca_ilhas_terminadas(Estado_mid,Ilhas_term,Novo_estado).



%Auxiliar 2.16 novas_pontes/4
%novas_pontes(Num_Pontes,Pos_Ilha1,Pos_Ilha2,Pontes), em Num_Pontes e o 
%numero de pontes a serem adicionadas, Pos_Ilha1 e Pos_Ilha2 sao posicoes 
%de ilhas e Pontes e uma lista de Num_Pontes pontes entre Ilha1 e Ilha2. 



novas_pontes(0,_,_,[]):-!.

novas_pontes(Num_pontes,Pos_Ilha1,Pos_Ilha2,[Ponte|Pontes]):-
	Num_pontes>0,
	cria_ponte(Pos_Ilha1,Pos_Ilha2,Ponte),
	New_Num_pontes is Num_pontes-1,
	novas_pontes(New_Num_pontes,Pos_Ilha1,Pos_Ilha2,Pontes).



%2.16 junta_pontes/5

%junta_pontes(Estado, Num_pontes, Ilha1, Ilha2, Novo_estado), em que Estado 
%e um estado e Ilha1 e Ilha2 sao 2 ilhas, significa que Novo_estado e o estado 
%que se obtem de Estado por adicao de Num_pontes pontes entre Ilha1 e Ilha2.



junta_pontes(Estado,Num_pontes,Ilha1,Ilha2,Novo_estado_final):-
	Ilha1=ilha(_,Pos_Ilha1),
	Ilha2=ilha(_,Pos_Ilha2),
	novas_pontes(Num_pontes,Pos_Ilha1,Pos_Ilha2,Pontes_Novas),
	findall(Nova_Entrada, (member(Entrada,Estado),
		((member(Ilha1,Entrada);member(Ilha2,Entrada)), Entrada=[Ilha,Vizinhas,Pontes_antigas], 
		append(Pontes_antigas,Pontes_Novas,Pontes), Nova_Entrada=[Ilha,Vizinhas,Pontes])),Novo_Estado1),
	actualiza_vizinhas_apos_pontes(Novo_Estado1,Pos_Ilha1,Pos_Ilha2,Novo_Estado2),
	trata_ilhas_terminadas(Novo_Estado2,Novo_estado_final).













