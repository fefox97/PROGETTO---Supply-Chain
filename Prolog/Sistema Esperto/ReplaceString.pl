%qui stiamo dicendo che se sostituiamo un elemento di una lista vuota con un altro elemento, restituiamo una lista vuota
replaceAllOccurences([],_,_,[]).

%qui stiamo dicendo che se l'elemento da sostituire è in testa alla lista, 
%allora restituiamo la lista con l'elemento di testa sostituito
replaceAllOccurences([ToReplace|Tail1],ToReplace,ReplaceWith,[ReplaceWith|Tail2]) :-
    replaceAllOccurences(Tail1,ToReplace,ReplaceWith,Tail2).

%qui stiamo dicendo che se l'elemento da sostituire non è in testa alla lista,
%allora resituiamo la coda della lista
replaceAllOccurences([Head|Tail3],ToReplace,ReplaceWith,[Head|Tail2]) :-
  ToReplace \== Head,
  replaceAllOccurences(Tail3,ToReplace,ReplaceWith,Tail2).

%sostituzione di tutte le occorrenze di un carattere in una stringa
replaceString(String, ToReplace, ReplaceWith, Result) :-
    string_chars(String,X),
    replaceAllOccurences(X, ToReplace, ReplaceWith, Y),
    string_chars(Result,Y).