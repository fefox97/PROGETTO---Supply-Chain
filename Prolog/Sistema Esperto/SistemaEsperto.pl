:- working_directory(D, '/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Sistema Esperto/').

:- consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Utility/thea-master/thea.pl').
:- consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Utility/regoleSupportoBPMNAggiustate.pl').
:- consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/fatti.pl').

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
    (atom_concat('https://w3id.org/italia/onto/PublicContract/', Class, ClassIRI); atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO#', Class, ClassIRI); atom_concat('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/Directory_felice.moretta/Acquisto_beni_ASL/Files%20OWL/PCSCOPRO_DATA.owl#', Class, ClassIRI)),
    classAssertion(ClassIRI,Individual),
    shortType(Individual, ShortIndividual).
    %write(Value), nl.

%----------------------------------------------------------------------------------------------------

%restituisce gli individui se dati i nomi di PropertyAssertion, Domain e Range; 
%restituisce gli individui e l'IRI della PropertyAssertion se dati solo i nomi di Domain e Range.
%getIndividual(-IRIProprietà, +Dominio, +Range, -IndividualDomain, -IndividualRange)
getProperyAssertion(PropertyIRI, Domain, Range, IndividualD, IndividualR) :-
    getIndividual(Domain, IndividualD, ShortIndividualD),
    getIndividual(Range, IndividualR, ShortIndividualR),
    propertyAssertion(PropertyIRI, IndividualD, IndividualR).

%getIndividual(+NomeProprietà, +Dominio, +Range, -IndividualDomain, -IndividualRange)
getProperyAssertion(Property, Domain, Range, IndividualD, IndividualR) :-
    (atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO#', Property, PropertyIRI); atom_concat('https://w3id.org/italia/onto/PublicContract/', Property, PropertyIRI)),
    getIndividual(Domain, IndividualD, ShortIndividualD),
    getIndividual(Range, IndividualR, ShortIndividualR),
    propertyAssertion(PropertyIRI, IndividualD, IndividualR).

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
writePrecedenza(NodoA, NodoB):-
    precedenza(NodoA, NodoB, Percorso),
    writePath(Percorso).

%verifica
precedenza(NodoA, NodoB, Percorso) :-
    percorso(NodoA, NodoB, IDNodoA, IDNodoB, [NodoA], [IDNodoA], PercorsoR, IDPercorsoR),
    reverse(PercorsoR, Percorso).   %inverto il percorso per ottenere l'ordine corretto

%verifico se esiste un arco che collega direttamente due nodi
percorso(NodoA, NodoB, IDNodoA, IDNodoB, Visitati, IDVisitati, [NodoB|Visitati], [IDNodoB|IDVisitati]) :-
    arco(source(NodoA,IDNodoA,_),target(NodoB,IDNodoB,_)).

%se non esiste un arco che collega direttamente due nodi, verifico se esiste un nodo intermedio
percorso(NodoA, NodoB, IDNodoA, IDNodoB, Visitati, IDVisitati, Percorso, IDPercorso) :-
    arco(source(NodoA,IDNodoA,_),target(NodoC,IDNodoC,_)),
    IDNodoC \== IDNodoB,
    \+member(IDNodoC, IDVisitati),
    percorso(NodoC, NodoB, IDNodoC, IDNodoB, [NodoC|Visitati], [IDNodoC|IDVisitati], Percorso, IDPercorso).

%----------------------------------------------------------------------------------------------------

%REGOLA 1
%Verificare che un ordine di acquisto sia sempre preceduto da una richiesta di approviggionamento da parte della Farmacia centrale.
regola1():-
    precedenza(NameA, NameB, _),
    getIndividual('Richiesta di approvvigionamento',_,ShortIndividualA),
    annotatedElement(_,NameA,_,task,_,_,ShortIndividualA),
    getIndividual('Ordine di acquisto',_,ShortIndividualB),
    annotatedElement(_,NameB,_,sendTask,_,_,ShortIndividualB),
    format("La richiesta di approvvigionamento ~w precede l'ordine di acquisto ~w",[ShortIndividualA,ShortIndividualB]).