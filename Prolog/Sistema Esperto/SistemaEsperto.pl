:- working_directory(D, '/Users/fefox/Library/Mobile Documents/com~apple~CloudDocs/Università Magistrale/KEBDI/PROGETTO - Supply Chain/Prolog/Sistema Esperto/').

:- consult('/Users/fefox/Library/Mobile Documents/com~apple~CloudDocs/Università Magistrale/KEBDI/PROGETTO - Supply Chain/Prolog/Utility/thea-master/thea.pl').
:- consult('/Users/fefox/Library/Mobile Documents/com~apple~CloudDocs/Università Magistrale/KEBDI/PROGETTO - Supply Chain/Prolog/Utility/regoleSupportoBPMNAggiustate.pl').
:- consult('/Users/fefox/Library/Mobile Documents/com~apple~CloudDocs/Università Magistrale/KEBDI/PROGETTO - Supply Chain/Prolog/fatti.pl').

%----------------------------------------------------------------------------------------------------
% REGOLE GENERALI
%----------------------------------------------------------------------------------------------------

%----------------------------------------------------------------------------------------------------
% replaceAllOccurrences(+List, +ToReplace, +ReplaceWith, -NewList)

%se viene sostituito un elemento di una lista vuota con un altro elemento, il risultato è una lista vuota
replaceAllOccurences([],_,_,[]).

%se l'elemento da sostituire è in testa alla lista, allora il risultato è la lista con l'elemento di testa sostituito
replaceAllOccurences([ToReplace|Tail1],ToReplace,ReplaceWith,[ReplaceWith|Tail2]) :-
    replaceAllOccurences(Tail1,ToReplace,ReplaceWith,Tail2).

%se l'elemento da sostituire non è in testa alla lista, allora il risultato è la coda della lista
replaceAllOccurences([Head|Tail3],ToReplace,ReplaceWith,[Head|Tail2]) :-
  ToReplace \== Head,
  replaceAllOccurences(Tail3,ToReplace,ReplaceWith,Tail2).
%----------------------------------------------------------------------------------------------------

%sostituzione di un carattere (anche con più occorrenze) all'interno di una stringa
%replaceString(+String, +ToReplace, +ReplaceWith, -NewString)
replaceString(String, ToReplace, ReplaceWith, Result) :-
    string_chars(String,X),
    replaceAllOccurences(X, ToReplace, ReplaceWith, Y),
    string_chars(Result,Y).

%----------------------------------------------------------------------------------------------------

%restituisce tutti gli individui di una classe
%getIndividual(+NomeClasse, -Individuo, -ShortIndividuo)
getIndividual(NClass,Individual,ShortIndividual) :-
    replaceString(NClass,' ','_',Class),
    %write_ln(Class),
    (atom_concat('https://w3id.org/italia/onto/PublicContract/', Class, ClassIRI); atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO_POP_MERGED#', Class, ClassIRI); atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/1/PCSCOPRO2#', Class, ClassIRI); atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO#', Class, ClassIRI); atom_concat('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/Directory_felice.moretta/Acquisto_beni_ASL/Files%20OWL/PCSCOPRO_DATA.owl#', Class, ClassIRI)),
    classAssertion(ClassIRI,Individual),
    shortType(Individual, ShortIndividual).
    %write(Value), nl.

%----------------------------------------------------------------------------------------------------

%restituisce tutti gli elementi annotati
annotatedElement(Type,Name,ID,ShortType,Class,Individual,ShortIndividual):- 
    (has_DomainLink(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,Individual));
    activityKindOf(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,Individual));
    activityManagesData(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,Individual));
    activityHasPerformer(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,Individual))),
    shortType(Individual,ShortIndividual).

%----------------------------------------------------------------------------------------------------

%raggruppa task, gateway ed event
nodo(Name,ID,ShortType) :-
    task(Name,ID,ShortType);
    gateway(Name,ID,ShortType);
    event(Name,ID,ShortType).

%raggruppa i sequence flow e i message flow
arco(source(SName,SID,SType),target(TName,TID,TType)) :-
    sequenceFlow(source(SName,SID,SType),target(TName,TID,TType));
    messageFlow(source(SName,SID,SType),target(TName,TID,TType)).

%----------------------------------------------------------------------------------------------------

%stampa di una lista di nodi
writePath([]).

writePath([H|T]) :-
    format("-> ~w ",H),
    writePath(T).

%----------------------------------------------------------------------------------------------------

%VERIFICA PRECEDENZA

%stampa percorso
writePrecedenza(NodoA, NodoB, Percorso):-
    precedenza(NodoA, NodoB, Percorso),
    writePath(Percorso).

%verifica
precedenza(NodoA, NodoB, Percorso) :-
    percorso(NodoA, NodoB, [NodoA], PercorsoR),
    reverse(PercorsoR, Percorso).   %inverto il percorso per ottenere l'ordine corretto

%verifico se esiste un arco che collega direttamente due nodi
percorso(NodoA, NodoB, NodoInt, [NodoB|NodoInt]) :-
    arco(source(NodoA,IDNodoA,_),target(NodoB,IDNodoB,_)).

%se non esiste un arco che collega direttamente due nodi, verifico se esiste un arco intermedio
percorso(NodoA, NodoB, Visitato, Percorso) :-
    arco(source(NodoA,_,_),target(NodoC,_,_)),
    NodoC \== NodoB,
    \+member(NodoC, Visitato),
    percorso(NodoC, NodoB, [NodoC|Visitato], Percorso).

%----------------------------------------------------------------------------------------------------

%REGOLA 1
%Verificare che un ordine di acquisto sia sempre preceduto da una richiesta di approviggionamento da parte della Farmacia centrale.
regola1():-
    writePrecedenza(NameA, NameB, Percorso),
    getIndividual('Comunicazione',_,ShortIndividualA),
    annotatedElement(_,NameA,_,task,_,_,ShortIndividualA),
    sub_atom(ShortIndividualA,_,_,_,'RA'),
    getIndividual('Comunicazione',_,ShortIndividualB),
    annotatedElement(_,NameB,_,task,_,_,ShortIndividualB),
    sub_atom(ShortIndividualB,_,_,_,'OA').