:- object(ws).

    :- use_module(websocket,
	    [ http_open_websocket/3
	    , http_upgrade_to_websocket/3
		, ws_send/2
		, ws_receive/2
		, ws_receive/3
		, ws_close/3
		, ws_open/3
		, ws_property/2
        ]).

    :- public(open_websocket/3).
	open_websocket(URL, Websocket, Options) :- http_open_websocket(URL, Websocket, Options).
    :- public(upgrade_to_websocket/3).
	:- meta_predicate(upgrade_to_websocket(1, *, *)).
	upgrade_to_websocket(Goal, Options, Request) :- http_upgrade_to_websocket(Goal, Options, Request).
	:- public(send/2).
	send(Websocket, Message) :- ws_send(Websocket, Message).
	:- public(receive/2).
	receive(Websocket, Message) :- ws_receive(Websocket, Message).
	:- public(receive/3).
	receive(Websocket, Message, Options) :- ws_receive(Websocket, Message, Options).
	:- public(close/3).
	close(Websocket, Code, Data) :- ws_close(Websocket, Code, Data).
	:- public(open/3).
	open(Stream, WSStream, Options) :- ws_open(Stream, WSStream, Options).
	:- public(property/2).
	property(Websocket, Property) :- ws_property(Websocket, Property).

:- end_object.
