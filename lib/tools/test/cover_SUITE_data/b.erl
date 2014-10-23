-module(b).
-export([start/0, loop/0, wait/0]).

start() ->
    spawn(?MODULE, loop, []).

loop() ->
    receive
	{ping, Ping} ->
	    a:pong(Ping),
	    loop();
	stop ->
	    done
    end.

%% This checks for a bug in expressions which may have
%% multiple clauses but has none are in the same line
%% followed by a return value.
wait() ->
    receive after 1000 -> done end, ok.
