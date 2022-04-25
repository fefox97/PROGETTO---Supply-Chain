edge(a,b).
edge(b,c).
edge(b,d).
edge(d,e).
edge(c,f).
edge(e,f).
edge(f,g).

path(A,B,Path) :-
    travel(A,B,[A],Q), 
    reverse(Q,Path).

travel(A,B,P,[B|P]) :- 
    edge(A,B).
travel(A,B,Visited,Path) :-
    edge(A,C),           
    C \== B,
    \+member(C,Visited),
    travel(C,B,[C|Visited],Path).