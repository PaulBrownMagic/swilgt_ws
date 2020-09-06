:- if((
    current_logtalk_flag(prolog_dialect, swi)
)).

	:- initialization((
		logtalk_load([ types(list)
		             , swilgt_http(loader)
		             ]),
	    use_module(library(http/websocket)),
		logtalk_load([ ws
		             , ws_handler
					 , websockets
					 ],
					 [optimize(on)])
	)).

:- else.
    :- initialization((
	    write('(this library requires SWI-Prolog as the backend compiler)'), nl
	)).
:- endif.
