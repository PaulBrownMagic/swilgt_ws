:- category(ws_handler).

    :- private(ws_handler/3).
	ws_handler(Path, Handler, Options) :-
		self(Self),
		http::handler(Path,
		    {Self, Handler, Options}/[Request]>>(ws::upgrade_to_websocket(Self::Handler, Options, Request)),
			[spawn([])]).

	:- private(default_loop_handler/3).
	default_loop_handler(Path, Handler, Options) :-
		self(Self),
		http::handler(Path,
		    {Self, Handler, Options}/[Request]>>(ws::upgrade_to_websocket(default_loop(Handler), Options, Request)),
			[spawn([])]).

    :- private(default_loop/2).
    default_loop(Handler, Websocket) :-
	    ws::receive(Websocket, Message),
		( Message.opcode == close
		-> true
		; call_handler(Handler, Websocket, Message),
		  default_loop(Websocket, Handler)
		).

    call_handler(Handler, Websocket, Message) :-
	   Handler =.. HParts, list::append(HParts, [Websocket, Message], FParts), FullHandler =.. FParts,
	   ::FullHandler.

:- end_category.
