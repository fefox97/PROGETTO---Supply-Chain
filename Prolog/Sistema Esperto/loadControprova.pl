load():-
	consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Utility/thea-master/thea.pl'),
	load_axioms('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Utility/MM_Ontology.owl'),
	load_axioms('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Utility/BPMN2_Ontology.owl'),
	load_axioms('/Users/fefox/Desktop/PROGETTO - Supply Chain/Ontologie/Annotazioni/Controprova/BPMN_Supply_Chain_ASL.bpmn-s.owl'),
	load_axioms('/Users/fefox/Desktop/PROGETTO - Supply Chain/Ontologie/Annotazioni/Controprova/BPMN_Supply_Chain_ASL.bpmn-mm'),
	load_axioms('/Users/fefox/Desktop/PROGETTO - Supply Chain/Ontologie/PCSCOPRO_DATA_RDF.owl'),
	save_axioms('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/fattiControprova.pl',pl),
	consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Utility/regoleSupportoBPMNAggiustate.pl').