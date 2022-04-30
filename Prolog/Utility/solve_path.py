# NOTE: replace text in file with new text
file = ['/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/fatti.pl', '/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/fattiControprova.pl']

for fatti in file:
    with open(fatti, 'r') as f:
        text = f.read()
        #print(text)

    text = text.replace('http://localhost:8060/BPMNSemanticAnnotator/resources/files/BPMN2_Ontology.owl#', 'http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/BPMN2_Ontology.owl#')
    text = text.replace('http://localhost:8080/BPMNSemanticAnnotator/resources/files/MM_Ontology.owl#','http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl#')
    text = text.replace('http://localhost:8080/BPMNSemanticAnnotator/resources/files/MM_Ontology.owl','http://193.206.100.151/annotatorFiles/AnnotatoreSemanticoClient/CartelleUtenti/MM_Ontology.owl')
    text = text.replace('PCSCOPRO%23','')

    with open(fatti, 'w') as f:
        f.write(text)
        print("DONE.")