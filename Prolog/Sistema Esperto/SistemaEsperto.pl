%:- module(sistemaEsperto, [percorsoF/4, precedenzaF/3]).
:- working_directory(D, '/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Sistema Esperto/').
:- consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Utility/thea-master/thea.pl').
:- consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Utility/regoleSupportoBPMNAggiustate.pl').
:- consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/fatti.pl').
%:- consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/fattiControprova.pl').

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% REGOLE GENERALI
%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%replaceAllOccurrences(+List, +ToReplace, +ReplaceWith, -NewList)

%se viene sostituito un elemento di una lista vuota con un altro elemento, il risultato è una lista vuota
replaceAllOccurences([], _, _, []).

%se l'elemento da sostituire è in testa alla lista, allora il risultato è la lista con l'elemento di testa sostituito
replaceAllOccurences([ToReplace|Tail1], ToReplace, ReplaceWith, [ReplaceWith|Tail2]) :-
    replaceAllOccurences(Tail1, ToReplace, ReplaceWith, Tail2).

%se l'elemento da sostituire non è in testa alla lista, allora effettua la sostituzione sulla coda
replaceAllOccurences([Head|Tail3], ToReplace, ReplaceWith, [Head|Tail2]) :-
    ToReplace \== Head, 
    replaceAllOccurences(Tail3, ToReplace, ReplaceWith, Tail2).
%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%sostituzione di un carattere (anche con più occorrenze) all'interno di una stringa

%replaceSubString(+String, +ToReplace, +ReplaceWith, -NewString)
replaceSubString(String, ToReplace, ReplaceWith, Result) :-
    string_chars(String, X), 
    replaceAllOccurences(X, ToReplace, ReplaceWith, Y), 
    string_chars(Result, Y).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%raggruppa task, gateway ed event
nodo(Name, ID, ShortType) :-
    task(Name, ID, ShortType);
    gateway(Name, ID, ShortType);
    event(Name, ID, ShortType).

%raggruppa i sequence flow e i message flow
arco(source(SName, SID, SType), flow(FlowType, SFlow), target(TName, TID, TType)) :-
    (sequenceFlow(source(SName, SID, SType), flow(FlowType, Flow), target(TName, TID, TType));
    messageFlow(source(SName, SID, SType), flow(FlowType, Flow), target(TName, TID, TType))),
    shortType(Flow, SFlow).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%stampa di una lista di nodi
writePath([]).

writePath([H|T]) :-
    format("-> ~w ", H), 
    writePath(T).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%restituisce tutti gli individui di una classe

%getIndividual(-ClassIRI, -ShortClass -Individual, -ShortIndividual)
getIndividual(Class, ShortClass, Individual, ShortIndividual) :-
    nonvar(ShortClass),    %mi accerto che NClass non sia una variabile, ma un termine ground
    replaceSubString(ShortClass, ' ', '_', NClass), 
    (atom_concat('https://w3id.org/italia/onto/PublicContract/', NClass, Class); atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO#', NClass, Class); atom_concat('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/Directory_felice.moretta/Acquisto_beni_ASL/Files%20OWL/PCSCOPRO_DATA.owl#', NClass, Class); atom_concat('http://www.semanticweb.org/indonto/ontologies/2014/0/SCOPRO#', NClass, Class)), 
    classAssertion(Class, Individual), 
    shortType(Individual, ShortIndividual);
    classAssertion(Class, Individual),
    ShortClass = 'Not defined', % qui non posso usare lo shortType perché su alcune Classi non funziona
    shortType(Individual, ShortIndividual).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%restituisce gli individui se dati i nomi di PropertyAssertion, Domain e Range; 
%restituisce gli individui e l'IRI della PropertyAssertion se dati solo i nomi di Domain e Range;
%restituisce gli individui, Domain e Range se dato il nome o l'IRI della PropertyAssertion.

%getPropertyAssertion(-PropertyIRI, -ShortProperty, -DomainIRI, -ShortDomain, -RangeIRI, -ShortRange, -IndividualDomain, -ShortIndividualDomain, -IndividualRange, -ShortIndividualRange)
getPropertyAssertion(Property, ShortProperty, Domain, ShortDomain, Range, ShortRange, IndividualD, ShortIndividualD, IndividualR, ShortIndividualR) :-
    nonvar(ShortProperty),  %mi accerto che Property non sia una variabile, ma un termine ground
    (atom_concat('http://www.semanticweb.org/fefox/ontologies/2022/2/PCSCOPRO#', ShortProperty, Property); atom_concat('https://w3id.org/italia/onto/PublicContract/', ShortProperty, Property); atom_concat('http://www.semanticweb.org/indonto/ontologies/2014/0/SCOPRO#', ShortProperty, Property)), 
    getIndividual(Domain, ShortDomain, IndividualD, ShortIndividualD), 
    getIndividual(Range, ShortRange, IndividualR, ShortIndividualR), 
    propertyAssertion(Property, IndividualD, IndividualR);
    getIndividual(Domain, ShortDomain, IndividualD, ShortIndividualD), 
    getIndividual(Range, ShortRange, IndividualR, ShortIndividualR), 
    propertyAssertion(Property, IndividualD, IndividualR),
    ShortProperty = 'Not defined'.  % qui non posso usare lo shortType perché su alcune propertyAssertion non funziona

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%CODICE INUTILE 
%perché alcuni individui hanno objectProperties della SuperClass e non della Classe

getLegami(property(PropertyIRI, Domain, Range), [], Legami) :-
    getLegame(property(PropertyIRI, Domain, Range), [property(PropertyIRI, SDomain, SRange)], Legami), 
    shortType(Domain, SDomain), 
    shortType(Range, SRange).

getLegami(property(PropertyIRI, Domain, Range), [IntRange|IntProperties], Legami) :-
    getLegame(property(PropertyIRI, Domain, Range), [property(PropertyIRI, SDomain, SRange)], Legami1), 
    shortType(Domain, SDomain), 
    shortType(Range, SRange), 
    getLegami(property(PropertyIRI, Domain, IntRange), IntProperties, Legami2), 
    append(Legami3, [_], Legami2), 
    append([Legami3, Legami1], Legami).

getLegame(property(PropertyIRI, Domain, Range), Controllati, [property(PropertyIRI, SDomain, SRange)|Controllati]) :-
    propertyDomain(PropertyIRI, Domain), 
    propertyRange(PropertyIRI, Range), 
    shortType(Domain, SDomain), 
    shortType(Range, SRange).

getLegame(property(PropertyIRI, Domain, Range), Controllati, Legami) :-
    propertyDomain(PropertyIRI, Domain), 
    propertyRange(PropertyIRI, IntRange), 
    IntRange \== Range, 
    shortType(IntDomain, SDomain), 
    shortType(Range, SRange), 
    \+member(property(PropertyIRI, SDomain, SRange), Controllati), 
    getLegame(property(PropertyIRI, Domain, IntRange), [property(PropertyIRI, SDomain, SRange)|Controllati], Legami).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%restituisce tutti gli elementi annotati
annotatedElement(bpmnElement(Type, Name, ID, ShortType), AnnotationType, ontologyElement(Class,CIndividual,ShortIndividual)):-
    has_DomainLink(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,CIndividual,ShortIndividual)), AnnotationType = 'has_DomainLink';
    activityKindOf(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,CIndividual,ShortIndividual)), AnnotationType = 'activityKindOf';
    activityManagesData(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,CIndividual,ShortIndividual)), AnnotationType = 'activityManagesData';
    activityHasPerformer(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,CIndividual,ShortIndividual)), AnnotationType = 'activityHasPerformer'.

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%VERIFICA PRECEDENZA

% %stampa percorso
% writePrecedenza(NodoA, ListaNodi):-
%     precedenza(NodoA, ListaNodi, PercorsoF), 
%     reverse(PercorsoF, Percorso), %inverto il percorso per ottenere l'ordine corretto
%     writePath(Percorso).

% %controlloPrecedenza verifica solo se esiste almeno un percorso tra il NodoA e il NodoB
% controlloPrecedenza(NodoIniziale, ListaNodi) :- 
%     precedenza(NodoIniziale, ListaNodi, _), !.

% %verifica precedenza tra due nodi
% %questo serve per evitare di dover inserire precedenza(NodoIniziale, [NodoFinale], Percorso), quando ci sono solo due nodi interessati
% precedenza(NodoIniziale, NodoFinale, Percorso) :-
%     percorso(NodoIniziale, NodoFinale, IDNodoIniziale, IDNodoFinale, [NodoIniziale], [IDNodoIniziale], PercorsoR, IDPercorsoR), 
%     reverse(PercorsoR, Percorso).

% precedenza(NodoIniziale, [NodoIntermedio|[]], Percorso) :-
%     percorso(NodoIniziale, NodoIntermedio, IDNodoIniziale, IDNodoIntermedo, [NodoIniziale], [IDNodoIniziale], Percorso, IDPercorsoR).

% precedenza(NodoIniziale, [NodoIntermedio|NodiIntermedi], Percorso) :-
%     percorso(NodoIniziale, NodoIntermedio, IDNodoIniziale, IDNodoIntermedo, [NodoIniziale], [IDNodoIniziale], Percorso1, IDPercorso1), 
%     precedenza(NodoIntermedio, NodiIntermedi, Percorso2), 
%     append(Percorso3, [_], Percorso2), %rimuovo l'ultimo elemento dal Percorso2, altrimenti risulterebbe ripetuto 2 volte
%     append([Percorso3, Percorso1], Percorso).

% %verifico se esiste un arco che collega direttamente due nodi
% percorso(NodoA, NodoB, IDNodoA, IDNodoB, Visitati, IDVisitati, [NodoB|Visitati], [IDNodoB|IDVisitati]) :-
%     arco(source(NodoA, IDNodoA, _), target(NodoB, IDNodoB, _)).

% %se non esiste un arco che collega direttamente due nodi, verifico se esiste un nodo intermedio
% percorso(NodoA, NodoB, IDNodoA, IDNodoB, Visitati, IDVisitati, Percorso, IDPercorso) :-
%     arco(source(NodoA, IDNodoA, _), target(NodoC, IDNodoC, _)), 
%     IDNodoC \== IDNodoB, 
%     \+member(IDNodoC, IDVisitati), 
%     percorso(NodoC, NodoB, IDNodoC, IDNodoB, [NodoC|Visitati], [IDNodoC|IDVisitati], Percorso, IDPercorso).

%....................................................................................................

%VERIFICA PRECEDENZA CON STRUTTURE A FUNTORI

%stampa percorso
writePrecedenzaF(nodo(NomeI, IDNodoI, ShortTypeI), ListaNodi) :-
    precedenzaF(nodo(NomeI, IDNodoI, ShortTypeI), ListaNodi, Percorso),
    writePath(Percorso).

controlloPrecedenzaF(nodo(NomeI, IDNodoI, ShortTypeI), ListaNodi) :- 
    precedenzaF(nodo(NomeI, IDNodoI, ShortTypeI), ListaNodi, _), !.

%verifica precedenza tra due nodi
%questo serve per evitare di dover inserire precedenza(NodoIniziale, [NodoFinale], Percorso), quando ci sono solo due nodi interessati
precedenzaF(nodo(NomeI, IDNodoI, ShortTypeI), nodo(NomeF, IDNodoF, ShortTypeF), PercorsoF) :-
    percorsoF(nodo(NomeI, IDNodoI, ShortTypeI), nodo(NomeF, IDNodoF, ShortTypeF), [nodo(NomeI, IDNodoI, ShortTypeI)], PercorsoF). 

precedenzaF(nodo(NomeI, IDNodoI, ShortTypeI), [nodo(NomeF, IDNodoF, ShortTypeF)|[]], PercorsoF) :-
    percorsoF(nodo(NomeI, IDNodoI, ShortTypeI), nodo(NomeF, IDNodoF, ShortTypeF), [nodo(NomeI, IDNodoI, ShortTypeI)], PercorsoF).

precedenzaF(nodo(NomeI, IDNodoI, ShortTypeI), [nodo(NomeInt, IDNodoInt, ShortTypeInt)|NodiIntermedi], PercorsoF) :-
    percorsoF(nodo(NomeI, IDNodoI, ShortTypeI), nodo(NomeInt, IDNodoInt, ShortTypeInt), [nodo(NomeI, IDNodoI, ShortTypeI)], PercorsoF1),
    precedenzaF(nodo(NomeInt, IDNodoInt, ShortTypeInt), NodiIntermedi, PercorsoF2),
    PercorsoF1 =.. [percorso|Percorso1],    %ritrasformo il funtore PercorsoF1 in una lista
    PercorsoF2 =.. [percorso|[NodoIniziale|Percorso2]],     %ritrasformo il funtore PercorsoF2 in una lista e rimuovo il primo nodo dal Percorso2, altrimenti risulterebbe ripetuto 2 volte
    append([Percorso1,Percorso2], Percorso), % accodo i due percorsi
    PercorsoF =.. [percorso|Percorso].  %ritrasformo la lista in un funtore

%verifico se esiste un arco che collega direttamente due nodi
percorsoF(nodo(NomeI, IDNodoI, ShortTypeI), nodo(NomeF, IDNodoF, ShortTypeF), Visitati, PercorsoF) :-
    arco(source(NomeI, IDNodoI, ShortTypeI), flow(FlowType, Flow), target(NomeF, IDNodoF, ShortTypeF)),
    append(Visitati, [flow(FlowType, Flow), nodo(NomeF, IDNodoF, ShortTypeF)], Percorso),
    PercorsoF =.. [percorso|Percorso].  %uso l'univ per generare un funtore percorso(nodo(),flow(),nodo(),...).

%se non esiste un arco che collega direttamente due nodi, verifico se esiste un nodo intermedio
percorsoF(nodo(NomeI, IDNodoI, ShortTypeI), nodo(NomeF, IDNodoF, ShortTypeF), Visitati, Percorso) :-
    arco(source(NomeI, IDNodoI, ShortTypeI), flow(FlowType, Flow), target(NomeInt, IDNodoInt, ShortTypeInt)), 
    IDNodoInt \== IDNodoF, 
    %\+member(nodo(NomeInt, IDNodoInt, ShortTypeInt), Visitati),
    occurrences_of_term(nodo(NomeInt, IDNodoInt, ShortTypeInt), Visitati, Count),
    Count < 2,
    append(Visitati, [flow(FlowType, Flow), nodo(NomeInt, IDNodoInt, ShortTypeInt)], VisitatiInt),
    percorsoF(nodo(NomeInt, IDNodoInt, ShortTypeInt), nodo(NomeF, IDNodoF, ShortTypeF), VisitatiInt, Percorso).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%REGOLA 1
%Verificare che un ordine di acquisto sia sempre preceduto da una richiesta di approvvigionamento da parte della Farmacia centrale.
regola1():-
    getPropertyAssertion(_, 'riguarda_bando_di_gara', DomainA, 'Richiesta di approvvigionamento', RangeA, ShortRangeA, IRichiestaApprovvigionamento, ShortIRichiestaApprovvigionamento, IBandoDiGara, ShortIBandoDiGara), 
    getPropertyAssertion(_, 'riguarda_bando_di_gara', DomainB, 'Ordine di acquisto', RangeB, ShortRangeB, IOrdineDiAcquisto, ShortIOrdineDiAcquisto, IBandoDiGara, ShortIBandoDiGara), 
    annotatedElement(bpmnElement(TypeA, NodoA, IDA, ShortTypeA), _, ontologyElement(ClassA, IndividualA, ShortIRichiestaApprovvigionamento)), 
    annotatedElement(bpmnElement(TypeB, NodoB, IDB, ShortTypeB), _, ontologyElement(ClassB, IndividualB, ShortIOrdineDiAcquisto)),
    (controlloPrecedenzaF(nodo(NodoA, _, _), nodo(NodoB, _, _)),
    format("La richiesta di approvvigionamento ~w annotata con il nodo '~w' precede l'ordine di acquisto ~w annotato con il nodo '~w'", [ShortIRichiestaApprovvigionamento, NodoA, ShortIOrdineDiAcquisto, NodoB]);
    \+controlloPrecedenzaF(nodo(NodoA, _, _), nodo(NodoB, _, _)),
    format("La richiesta di approvvigionamento ~w annotata con il nodo '~w' NON precede l'ordine di acquisto ~w annotato con il nodo '~w'", [ShortIRichiestaApprovvigionamento, NodoA, ShortIOrdineDiAcquisto, NodoB])).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%REGOLA 2
%Verificare che la proclamazione di un vincitore per una gara d'appalto (Avviso esito di procedura) sia preceduta, in ordine da: 
%una verifica dei documenti per l'emanazione del bando (Richiesta verifica documenti bando) e una emanazione della gara di appalto (Pubblicazione)
regola2():-
    getPropertyAssertion(_, 'riguarda_bando_di_gara', DomainA, 'Richiesta verifica documenti', RangeA, ShortRangeA, IRichiestaVerificaDocumenti, ShortIRichiestaVerificaDocumenti, IBandoDiGara, ShortIBandoDiGara), 
    getPropertyAssertion(_, 'hasCallForCompetition', DomainB, 'Publication', RangeB, ShortRangeB, IPubblicazione, ShortIPubblicazione, IBandoDiGara, ShortIBandoDiGara), 
    getPropertyAssertion(_, 'hasCallForCompetition', DomainC, 'Lot', RangeC, ShortRangeC, ILotto, ShortILotto, IBandoDiGara, ShortIBandoDiGara), 
    getPropertyAssertion(_, 'hasAwardNotice', DoaminD, 'Lot', RangeD, ShortRangeD, ILotto, ShortILotto, IAvvisoEsitoDiProcedura, ShortIAvvisoEsitoDiProcedura), 
    annotatedElement(bpmnElement(TypeA, NodoA, IDA, ShortTypeA), _, ontologyElement(ClassA, IndividualA, ShortIRichiestaVerificaDocumenti)), 
    annotatedElement(bpmnElement(TypeB, NodoB, IDB, ShortTypeB), _, ontologyElement(ClassB, IndividualB, ShortIPubblicazione)), 
    annotatedElement(bpmnElement(TypeC, NodoC, IDC, ShortTypeC), _, ontologyElement(ClassC, IndividualC, ShortIAvvisoEsitoDiProcedura)), 
    (controlloPrecedenzaF(nodo(NodoA, _, _), [nodo(NodoB, _, _), nodo(NodoC, _, _)]),
    format("La verifica dei documenti per l'emanazione del bando ~w, annotato con il nodo '~w', precede l'emanazione della gara di appalto ~w, annotata con il nodo '~w', che a sua volta precede la proclamazione del vincitore ~w, annotato con il nodo '~w'", [ShortIRichiestaVerificaDocumenti, NodoA, ShortIPubblicazione, NodoB, ShortIAvvisoEsitoDiProcedura, NodoC]);
    \+controlloPrecedenzaF(nodo(NodoA, _, _), [nodo(NodoB, _, _), nodo(NodoC, _, _)]),
    format("La verifica dei documenti per l'emanazione del bando ~w, annotato con il nodo '~w', NON precede l'emanazione della gara di appalto ~w, annotata con il nodo '~w', che a sua volta NON precede la proclamazione del vincitore ~w, annotato con il nodo '~w'", [ShortIRichiestaVerificaDocumenti, NodoA, ShortIPubblicazione, NodoB, ShortIAvvisoEsitoDiProcedura, NodoC])).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%REGOLA 3
%Verificare che l'emissione di un Certificato di Pagamento avvenga solo ed esclusivamente in seguito all'evasione dell'ordine.
regola3():-
    getPropertyAssertion(_, 'riguarda_ordine_di_acquisto', DomainA, 'Deliver_Stocked_Product', RangeA, ShortRangeA, ISpedizioneOrdine, ShortISpedizioneOrdine, IOrdineDiAcquisto, ShortIOrdineDiAcquisto), 
    getPropertyAssertion(_, 'riguarda_lotto', DomainB, 'Ordine di acquisto', RangeB, ShortRangeB, IOrdineDiAcquisto, ShortIOrdineDiAcquisto, ILotto, ShortILotto), 
    getPropertyAssertion(_, 'hasPaymentCertificate', DomainC, 'Lot', RangeC, ShortRangeC, ILotto, ShortILotto, ICertificatoDiPagamento, ShortICertificatoDiPagamento), 
    annotatedElement(bpmnElement(TypeA, NodoA, IDA, ShortTypeA), _, ontologyElement(ClassA, IndividualA, ShortISpedizioneOrdine)), 
    annotatedElement(bpmnElement(TypeB, NodoB, IDB, ShortTypeB), _, ontologyElement(ClassB, IndividualB, ShortICertificatoDiPagamento)), 
    (controlloPrecedenzaF(nodo(NodoA, _, _), nodo(NodoB, _, _)),
    format("L'evasione dell'ordine ~w, annotata con il nodo '~w', precede l'emissione del certificato di pagamento ~w, annotata con il nodo '~w'", [ShortISpedizioneOrdine, NodoA, ShortICertificatoDiPagamento, NodoB]);
    \+controlloPrecedenzaF(nodo(NodoA, _, _), nodo(NodoB, _, _)),
    format("L'evasione dell'ordine ~w, annotata con il nodo '~w', NON precede l'emissione del certificato di pagamento ~w, annotata con il nodo '~w'", [ShortISpedizioneOrdine, NodoA, ShortICertificatoDiPagamento, NodoB])).

%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%REGOLA 4
%Verifica che esista un percorso, e stampa tutti quelli che riesci a trovare, tra il task "Verifica dei documenti del bando" e "Stoccaggio nel magazzino generale".
%percorsi(nodo('Verifica dei documenti del bando', _, _), nodo('Stoccaggio nel magazzino generale', _, _), Percorsi)
percorsi(nodo(NomeI, IDNodoI, ShortTypeI), ListaNodi, Percorsi) :-
    findall(Percorso, precedenzaF(nodo(NomeI, IDNodoI, ShortTypeI), ListaNodi, Percorso), Percorsi).

:- tty_clear.