# SWILGT Websockets

A little library for working with SWI-Prolog's `library(http/websocket)` in Logtalk. Depends upon `swilgt_http`.

## `ws.lgt`

This is a proxy to `library(http/websocket)`. All predicates in the library that are prefixed `ws_` are accessed by swapping the prefix to `ws::`. For example, instead of:

``` prolog
ws_send(Websocket, text("Hello, world!")).
```

We write:

``` prolog
ws::send(Websocket, text("Hello, world!")).
```

The remaining two predicates are prefixed with `http_`, which we also replace with `ws::`. That gives us `ws::open_websocket/3` and `ws::upgrade_to_websocket/3`.

## `ws_handler.lgt`

This is akin to the `handler.lgt` category provided in `swilgt_http`. It allows you to define a handler for a websocket URL like so:

``` prolog
:- object(echo,
    imports(ws_handler)).
    
    :- initialization((
        ^^ws_handler(root(echo), echo_handler, [])
    )).
    
    :- public(echo_handler/1).
    echo_handler(Websocket) :-
        ws::receive(Websocket, Message),
        ( Message.opcode == close
        -> true
        ; ws::send(Message),
          echo_handler(Websocket)).
    
:- end_object.
```

Don't forget the websocket URL for testing that will be `ws://localhost:<PORT>/echo`.

This handler allows you to do complex things with your websocket, such as make use of `websockets.lgt` discussed next. But for such simple use cases `ws_handler` also provides a default loop handler that takes care of much of that boilerplate. This code will do the exact same thing:

``` prolog
:- object(echo,
    imports(ws_handler)).
    
    :- initialization((
       ^^default_loop_handler(root(echo), echo_handler, [])
    )).
    
    :- public(echo_handler/2).
    echo_handler(Websocket, Message) :-
        ws::send(Websocket, Message).
        
:- end_object.
```

## `websockets.lgt`

This is an object for managing multiple websockets either in one big group or in named groups (or rooms if you will). This allows you to broadcast messages.

To manage one big group you can tell the object to remember a websocket with `websockets::remember(Websocket)`, the same for forgetting: `websockets::forget(Websocket)`. Broadcasting just requires the message: `websockets::broadcast(text("Hello every websocket connection!"))`. So if we wanted to echo every received message to every connected websocket, our echo example would become:

``` prolog
:- object(echo,
    imports(ws_handler)).
    
    :- initialization((
        ^^ws_handler(root(echo), echo_handler, [])
    )).
    
    :- public(echo_handler/1).
    echo_handler(Websocket) :-
        websockets::remember(Websocket),
        echo_loop(Websocket).

    :- private(echo_loop/1).
    echo_loop(Websocket) :-
        ws::receive(Websocket, Message),
        ( Message.opcode == close
        -> websockets::forget(Websocket)
        ; websockets::broadcast(Message),
          echo_loop(Websocket)).
    
:- end_object.
```

To manage groups of websockets the predicates remain the same but with an additional first argument identity, so to use the Prolog IRC room name (##prolog) as an example:

``` prolog
websockets::remember('##prolog', Websocket).
websockets::broadcast('##prolog', text("Help?")).
websockets::forget('##prolog', Websocket).
```
