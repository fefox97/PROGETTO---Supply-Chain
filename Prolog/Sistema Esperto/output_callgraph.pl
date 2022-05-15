:- consult('/Users/fefox/Desktop/PROGETTO - Supply Chain/Prolog/Sistema Esperto/sistemaEsperto.pl').
:- use_module(library(callgraph)).

:- modules_dot([sistemaEsperto, regoleSupportoBPMNAggiustate],[],callgraph).