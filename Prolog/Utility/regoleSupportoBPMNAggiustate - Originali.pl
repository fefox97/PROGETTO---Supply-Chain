
has_DomainLink(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,Individual)):-
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#has_domainLink',CID,Individual),shortType(CID,ID),genericElement(Type,Name,ID,ShortType), classAssertion(CClass,Individual), shortType(CClass,Class);
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#has_domainLink',CID,Individual),shortType(CID,ID),genericElement(Type,Name,ID,ShortType), \+classAssertion(_,Individual), Class='Not defined'.

activityKindOf(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,Individual)):-
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#activity_is_a_kind_of',CID,Individual),shortType(CID,ID),genericElement(Type,Name,ID,ShortType), classAssertion(CClass,Individual), shortType(CClass,Class);
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#activity_is_a_kind_of',CID,Individual),shortType(CID,ID),genericElement(Type,Name,ID,ShortType), \+classAssertion(_,Individual), Class='Not defined'.







activityHasPerformer(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,Individual)):-
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#has_performerLink',CID,Individual),shortType(CID,ID),genericElement(Type,Name,ID,ShortType), classAssertion(CClass,Individual), shortType(CClass,Class);
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#has_performerLink',CID,Individual),shortType(CID,ID),genericElement(Type,Name,ID,ShortType), \+classAssertion(_,Individual), Class='Not defined'.

activityManagesData(bpmnElement(Type,Name,ID,ShortType),ontologyElement(Class,Individual)):-
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#activity_manages_data',CID,Individual),shortType(CID,ID),genericElement(Type,Name,ID,ShortType), classAssertion(CClass,Individual), shortType(CClass,Class);
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#activity_manages_data',CID,Individual),shortType(CID,ID),genericElement(Type,Name,ID,ShortType), \+classAssertion(_,Individual), Class='Not defined'.

task(Name,ID,ShortType):-
genericElement('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#task',Name,ID,ShortType);
descendantOf(GenericType,'http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#task'),genericElement(GenericType,Name,ID,ShortType).


gateway(Name,ID,ShortType):-genericElement('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#gateway',Name,ID,ShortType);
descendantOf(GenericType,'http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#gateway'),genericElement(GenericType,Name,ID,ShortType).


messageFlow(source(SName,SID,SType),target(TName,TID,TType)):-
classAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#messageFlow',Flow),
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#has_targetRef',Flow,Target), classAssertion(LTType,Target),shortType(Target,TID),genericElement(LTType,TName,TID,TType),propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#has_sourceRef',Flow,Source), classAssertion(LSType,Source),shortType(Source,SID),genericElement(LSType,SName,SID,SType).

sequenceFlow(source(SName,SID,SType),target(TName,TID,TType)):-
classAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#sequenceFlow',Flow),
propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#has_targetRef',Flow,Target), classAssertion(LTType,Target),shortType(Target,TID),genericElement(LTType,TName,TID,TType),propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#has_sourceRef',Flow,Source), classAssertion(LSType,Source),shortType(Source,SID),genericElement(LSType,SName,SID,SType).


event(Name,ID,ShortType):-
genericElement('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#event',Name,ID,ShortType);
descendantOf(GenericType,'http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#event'),genericElement(GenericType,Name,ID,ShortType).

genericElement(GenericType,Name,ID,ShortType):-
classAssertion(GenericType,B),propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#name',B,literal(type('http://www.w3.org/2001/XMLSchema#string', Name))),propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#id',B,literal(type('http://www.w3.org/2001/XMLSchema#ID', ID))), shortType(GenericType,ShortType);
classAssertion(GenericType,B),\+ propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#name',B,literal(type('http://www.w3.org/2001/XMLSchema#string', Name))),propertyAssertion('http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#id',B,literal(type('http://www.w3.org/2001/XMLSchema#ID', ID))),Name='Anonymous',shortType(GenericType,ShortType).


descendantOf(A,B):- subClassOf(A,B);
                    subClassOf(A,C),descendantOf(C,B).

shortType(String, Value) :-
    sub_atom(String, _, _, After, '#'),
    !,
    sub_atom(String, _, After, 0, Value).

