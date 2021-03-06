%% -*- coding: utf-8 -*-
-module(service_onnet_cidinfo).
-author("Kirill Sysoev").
-svc_title("CID Info.").
-svc_needauth(false).

-export([process_get/2]).

-include_lib("zotonic.hrl").

process_get(_ReqData, Context) ->
    get_info(Context).

get_info(Context) ->
    case is_key_valid(Context) of
        'true' ->
            Calling_Number = z_context:get_q("calling_number", Context),
            Reply = [{'company_name', "ZAO Test"}, {'agrm_num', "145-PRE"}, {'contact_person', <<"Ivanov I. P.">>}, 
                     {'cur_balance', 1285.15}, {'login_name', "customer1"}, {'calling_number', Calling_Number}],
            {struct, Reply};
        _ ->
            {error,  access_denied, undefined}
    end.

is_key_valid(Context) ->
    PopUpKey = binary_to_list(m_config:get_value(onnet, popup_key, Context)),
    ControlString = io_lib:format("~s:~s", [z_context:get_q("calling_number", Context), PopUpKey]),
    lager:info("ControlString: ~p",[lists:flatten(ControlString)]),
    Md5Hash = lists:flatten([io_lib:format("~2.16.0b", [C]) || <<C>> <= erlang:md5(ControlString)]),
    lager:info("Md5Hash: ~p",[Md5Hash]),
    lager:info("Md5: ~p",[z_context:get_q("md5", Context)]),
    case z_context:get_q("md5", Context) of
        undefined -> false;
        Md5 -> string:to_lower(Md5Hash) == string:to_lower(Md5)
    end.
