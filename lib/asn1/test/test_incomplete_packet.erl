%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2004-2012. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% %CopyrightEnd%
%%
%%
-module(test_incomplete_packet).

-export([test/2]).

-include_lib("test_server/include/test_server.hrl").


%% testing OTP-5104

test(Opt, Config) ->
    Msg = {'PersonnelRecord',{'Name',"Sven","S","Svensson"},
           "manager",123,"20000202",{'Name',"Inga","K","Svensson"},
           []},
    {ok, Split} = asn1_wrapper:encode('P-Record', 'PersonnelRecord', Msg),
    {Split1, _Split2} = if  is_binary(Split) ->
                     split_binary(Split, 8);
                 is_list(Split) ->
                     {lists:sublist(Split,8),lists:nthtail(8,Split)}
             end,
    case Opt of
        undec_rest ->
            {error,incomplete} = asn1_wrapper:decode('P-Record', 'PersonnelRecord',
                                               Split1),
            {ok, Msg, <<>>} = asn1_wrapper:decode('P-Record', 'PersonnelRecord',
                                               Split)
            ;
        _ ->
            {error, incomplete} = asn1_wrapper:decode('P-Record', 'PersonnelRecord',
                                            Split1),
            {ok, Msg} = asn1_wrapper:decode('P-Record', 'PersonnelRecord',
                                               Split)
    end,
    ok.
