:- object(websockets).

    :- private(websockets_/1).
	:- dynamic(websockets_/1).
	websockets_([]).
    :- private(websockets_/2).
	:- dynamic(websockets_/2).

    :- private(update_to_/1).
	update_to_(New) :-
	    with_mutex(single, (
			retractall(websockets_(_)),
			asserta(websockets_(New)))).
    :- private(update_to_/2).
	update_to_(Group, New) :-
	    ground(Group),
	    with_mutex(Group, (
			retractall(websockets_(Group, _)),
			asserta(websockets_(Group, New)))).

    :- public(remember/1).
	remember(WS) :-
	    websockets_(WSs),
		update_to_([WS|WSs]).
    :- public(remember/2).
	remember(Group, WS) :-
	    once((websockets_(Group, WSs) ; WSs = [])),
		update_to_(Group, [WS|WSs]),
		remember(WS).

    :- public(forget/1).
	forget(WS) :-
	    websockets_(Orig),
		list::delete(Orig, WS, Remaining),
		update_to_(Remaining).
    :- public(forget/2).
	forget(Group, WS) :-
	    websockets_(Group, Orig),
		list::delete(Orig, WS, Remaining),
		update_to_(Group, Remaining).

    :- public(broadcast/1).
	broadcast(Msg) :-
	    websockets_(WSs),
	    forall(list::member(WS, WSs), ws::send(WS, Msg)).
    :- public(broadcast/2).
	broadcast(Group, Msg) :-
	    websockets_(Group, WSs),
	    forall(list::member(WS, WSs), ws::send(WS, Msg)).

:- end_object.
