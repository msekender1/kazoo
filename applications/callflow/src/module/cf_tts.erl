%%%-------------------------------------------------------------------
%%% @copyright (C) 2014-2017, 2600Hz INC
%%% @doc
%%% "data":{
%%%   "text":"This is what should be said"
%%%   // optional
%%%   ,"voice":"male" // or "female"
%%%   ,"language":"en"
%%%   ,"engine":"flite" // or "ispeech if configured
%%% }
%%% @end
%%% @contributors
%%%-------------------------------------------------------------------
-module(cf_tts).

-behaviour(gen_cf_action).

-include("callflow.hrl").

-export([handle/2]).

%%--------------------------------------------------------------------
%% @public
%% @doc
%% Entry point for this module
%% @end
%%--------------------------------------------------------------------
-spec handle(kz_json:object(), kapps_call:call()) -> 'ok'.
handle(Data, Call) ->
    kapps_call_command:answer(Call),

    NoopId = kapps_call_command:tts(kz_json:get_binary_value(<<"text">>, Data)
                                   ,kz_json:get_binary_value(<<"voice">>, Data)
                                   ,kz_json:get_binary_value(<<"language">>, Data)
                                   ,kz_json:get_list_value(<<"terminators">>, Data, ?ANY_DIGIT)
                                   ,kz_json:get_binary_value(<<"engine">>, Data)
                                   ,Call
                                   ),
    lager:debug("tts is waiting for noop ~s", [NoopId]),
    case cf_util:wait_for_noop(Call, NoopId) of
        {'ok', Call1} ->
            %% Give control back to cf_exe process
            cf_exe:set_call(Call1),
            cf_exe:continue(Call1);
        {'error', _} ->
            cf_exe:stop(Call)
    end.
