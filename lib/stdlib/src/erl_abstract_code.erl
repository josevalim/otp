-module(erl_abstract_code).
-export([debug_info/4]).

-type abstract_code() :: [erl_parse:abstract_form()].

debug_info(_Format, _Module, {none,_CompilerOpts}, _Opts) ->
    {error, missing};
debug_info(erlang_v1, _Module, {AbstrCode,_CompilerOpts}, _Opts) ->
    {ok, AbstrCode};
debug_info(core_v1, _Module, {AbstrCode0,CompilerOpts0}, Opts) ->
    %% We do not want the parse_transforms around since we already
    %% performed them. In some cases we end up in trouble when
    %% performing them again.
    AbstrCode1 = cleanup_parse_transforms(AbstrCode0),
    %% Remove parse_transforms (and other options) from compile options.
    CompilerOpts1 = cleanup_compile_options(CompilerOpts0 ++ Opts),

    try compile:noenv_forms(AbstrCode1, [to_core, binary, return_errors] ++ CompilerOpts1) of
	{ok, _, Core} -> {ok, Core};
	_What -> {error, failed_conversion}
    catch
	error:_ -> {error, failed_conversion}
    end;
debug_info(_, _, _, _) ->
    {error, unknown_format}.

-spec cleanup_parse_transforms(abstract_code()) -> abstract_code().

cleanup_parse_transforms([{attribute, _, compile, {parse_transform, _}}|Left]) ->
    cleanup_parse_transforms(Left);
cleanup_parse_transforms([Other|Left]) ->
    [Other|cleanup_parse_transforms(Left)];
cleanup_parse_transforms([]) ->
    [].

-spec cleanup_compile_options([compile:option()]) -> [compile:option()].

cleanup_compile_options(Opts) ->
    lists:filter(fun keep_compile_option/1, Opts).

%% Using abstract, not asm or core.
keep_compile_option(from_asm) -> false;
keep_compile_option(from_core) -> false;
%% The parse transform will already have been applied, may cause
%% problems if it is re-applied.
keep_compile_option({parse_transform, _}) -> false;
keep_compile_option(warnings_as_errors) -> false;
keep_compile_option(_) -> true.
