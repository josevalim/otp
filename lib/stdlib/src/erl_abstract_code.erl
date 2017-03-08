-module(erl_abstract_code).
-export([debug_info/4]).

debug_info(_Format, _Module, {none,_CompilerOpts}, _Opts) ->
  {error, missing};
debug_info(erlang_v1, _Module, {Code,_CompilerOpts}, _Opts) ->
  {ok, Code};
debug_info(_, _, _, _) ->
  {error, unknown_format}.
