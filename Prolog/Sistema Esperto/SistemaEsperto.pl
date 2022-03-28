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

%getIndividual(-IRIClasse, -Individuo, -ShortIndividuo)
getIndividual(ClassIRI,Individual,ShortIndividual) :-
    classAssertion(ClassIRI,Individual),
    shortType(Individual, ShortIndividual).

%getIndividual(+NomeClasse, -Individuo, -ShortIndividuo)
getIndividual(NClass,Individual,ShortIndividual) :-
    nonvar(NClass),     %mi accerto che NClass non sia una variabile, ma un termine ground
    replaceString(NClass,' ','_',Class),
    (atom_concat('https://w3id.org/italia/onto/PublicContract/', Class, ClassIRI); atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO#', Class, ClassIRI); atom_concat('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/Directory_felice.moretta/Acquisto_beni_ASL/Files%20OWL/PCSCOPRO_DATA.owl#', Class, ClassIRI); atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO#', Class, ClassIRI); atom_concat('http://www.semanticweb.org/indonto/ontologies/2014/0/SCOPRO#', Class, ClassIRI)),
    classAssertion(ClassIRI,Individual),
    shortType(Individual, ShortIndividual).

%----------------------------------------------------------------------------------------------------

%restituisce gli individui se dati i nomi di PropertyAssertion, Domain e Range; 
%restituisce gli individui e l'IRI della PropertyAssertion se dati solo i nomi di Domain e Range.
%getProperyAssertion(-IRIProprietà, +Dominio, +Range, -IndividualDomain, -IndividualRange)
getProperyAssertion(PropertyIRI, Domain, Range, IndividualD, ShortIndividualD, IndividualR, ShortIndividualR) :-
    getIndividual(Domain, IndividualD, ShortIndividualD),
    getIndividual(Range, IndividualR, ShortIndividualR),
    propertyAssertion(PropertyIRI, IndividualD, IndividualR).

%getProperyAssertion(+NomeProprietà, +Dominio, +Range, -IndividualDomain, -IndividualRange)
getProperyAssertion(Property, Domain, Range, IndividualD, ShortIndividualD, IndividualR, ShortIndividualR) :-
    nonvar(Property),   %mi accerto che Property non sia una variabile, ma un termine ground
    (atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO#', Property, PropertyIRI); atom_concat('https://w3id.org/italia/onto/PublicContract/', Property, PropertyIRI); atom_concat('http://www.semanticweb.org/indonto/ontologies/2014/0/SCOPRO#', Property, PropertyIRI)),
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
writePrecedenza(NodoA, ListaNodi):-
    precedenza(NodoA, ListaNodi, PercorsoF),
    reverse(PercorsoF, Percorso),  %inverto il percorso per ottenere l'ordine corretto
    writePath(Percorso).

%controlloPrecedenza verifica solo se esiste almeno un percorso tra il NodoA e il NodoB
controlloPrecedenza(NodoIniziale, ListaNodi) :- 
    precedenza(NodoIniziale, ListaNodi, _), !.

%verifica
precedenza(NodoIniziale, NodoFinale, Percorso) :-
    percorso(NodoIniziale, NodoFinale, IDNodoIniziale, IDNodoFinale, [NodoIniziale], [IDNodoIniziale], PercorsoR, IDPercorsoR),
    reverse(PercorsoR, Percorso).

precedenza(NodoIniziale, [NodoIntermedio|[]], Percorso) :-
    percorso(NodoIniziale, NodoIntermedio, IDNodoIniziale, IDNodoIntermedo, [NodoIniziale], [IDNodoIniziale], Percorso, IDPercorsoR).

precedenza(NodoIniziale, [NodoIntermedio|NodiIntermedi], Percorso) :-
    percorso(NodoIniziale, NodoIntermedio, IDNodoIniziale, IDNodoIntermedo, [NodoIniziale], [IDNodoIniziale], Percorso1, IDPercorso1),
    precedenza(NodoIntermedio, NodiIntermedi, Percorso2),
    append(Percorso3, [_], Percorso2), %rimuovo l'ultimo elemento dal Percorso2, altrimenti risulterebbe ripetuto 2 volte
    append([Percorso3,Percorso1],Percorso).

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
%Verificare che un ordine di acquisto sia sempre preceduto da una richiesta di approvvigionamento da parte della Farmacia centrale.
regola1():-
    getProperyAssertion('riguarda_bando_di_gara', 'Richiesta di approvvigionamento', _, IRichiestaApprovvigionamento, ShortIRichiestaApprovvigionamento, IBandoDiGara, ShortIBandoDiGara),
    getProperyAssertion('riguarda_bando_di_gara', 'Ordine di acquisto', _, IOrdineDiAcquisto, ShortIOrdineDiAcquisto, IBandoDiGara, ShortIBandoDiGara),
    annotatedElement(_,NodoA,_,_,_,_,ShortIRichiestaApprovvigionamento),
    annotatedElement(_,NodoB,_,_,_,_,ShortIOrdineDiAcquisto),
    controlloPrecedenza(NodoA, NodoB),
    format("La richiesta di approvvigionamento ~w precede l'ordine di acquisto ~w",[ShortIRichiestaApprovvigionamento,ShortIOrdineDiAcquisto]).

%----------------------------------------------------------------------------------------------------

%REGOLA 2
%Verificare che la proclamazione di un vincitore per una gara d'appalto (Avviso esito di procedura) sia preceduta, in ordine da: 
%una verifica dei documenti per l'emanazione del bando (Richiesta verifica documenti bando) e una emanazione della gara di appalto (Pubblicazione)
regola2():-
    getProperyAssertion('riguarda_bando_di_gara', 'Richiesta verifica documenti', _, IRichiestaVerificaDocumenti, ShortIRichiestaVerificaDocumenti, IBandoDiGara, ShortIBandoDiGara),
    getProperyAssertion('hasCallForCompetition', 'Publication', _, IPubblicazione, ShortIPubblicazione, IBandoDiGara, ShortIBandoDiGara),
    getProperyAssertion('hasCallForCompetition', 'Lot', _, ILotto, ShortILotto, IBandoDiGara, ShortIBandoDiGara),
    getProperyAssertion('hasAwardNotice', 'Lot', _, ILotto, ShortILotto, IAvvisoEsitoDiProcedura, ShortIAvvisoEsitoDiProcedura),
    annotatedElement(_,NodoA,_,_,_,_,ShortIRichiestaVerificaDocumenti),
    annotatedElement(_,NodoB,_,_,_,_,ShortIPubblicazione),
    annotatedElement(_,NodoC,_,_,_,_,ShortIAvvisoEsitoDiProcedura),
    controlloPrecedenza(NodoA, [NodoB, NodoC]),
    format("La verifica dei documenti per l'emanazione del bando ~w precede l'emanazione della gara di appalto ~w, che a sua volta precede la proclamazione del vincitore ~w",[ShortIRichiestaVerificaDocumenti,ShortIPubblicazione,ShortIAvvisoEsitoDiProcedura]).

%REGOLA 3
%Verificare che l'emissione di un Certificato di Pagamento avvenga solo ed esclusivamente in seguito all'evasione dell'ordine.
regola3(NodoA,NodoB,IDA,IDB):-
    getProperyAssertion('riguarda_ordine_di_acquisto', 'Deliver_Stocked_Product', _, ISpedizioneOrdine, ShortISpedizioneOrdine, IOrdineDiAcquisto, ShortIOrdineDiAcquisto),
    getProperyAssertion('riguarda_lotto', 'Ordine di acquisto', _, IOrdineDiAcquisto, ShortIOrdineDiAcquisto, ILotto, ShortILotto),
    getProperyAssertion('hasPaymentCertificate', 'Lot', _, ILotto, ShortILotto, ICertificatoDiPagamento, ShortICertificatoDiPagamento),
    annotatedElement(_,NodoA,IDA,_,_,_,ShortISpedizioneOrdine),
    annotatedElement(_,NodoB,IDB,_,_,_,ShortICertificatoDiPagamento),
    controlloPrecedenza(NodoA, NodoB),
    format("L'evasione dell'ordine ~w precede l'emissione del certificato di pagamento ~w",[ShortISpedizioneOrdine,ShortICertificatoDiPagamento]).
