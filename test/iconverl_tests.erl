-module(iconverl_tests).

-include_lib("eunit/include/eunit.hrl").

open_test() ->
    ?assertError(badarg, iconverl:open("utf-99", "ucs-34")),
    {{To, From}, CD} = iconverl:open("utf-8", "ucs-2be"),
    ?assertEqual(To, "utf-8"),
    ?assertEqual(From, "ucs-2be"),
    ?assert(is_binary(CD))
    .

conv2_test() ->
    CD = iconverl:open("ucs-2be", "utf-8"),
     ?assertEqual({ok, <<0,$t,0,$e,0,$s,0,$t>>}, iconverl:conv(CD, <<"test">>)),
     ?assertEqual({error, eilseq}, iconverl:conv(CD, <<129,129>>)).

conv3_test() ->
     ?assertError(badarg, iconverl:open("utf-99", "ucs-34")),
     ?assertEqual({ok, <<0,$t,0,$e,0,$s,0,$t>>},
     iconverl:conv("ucs-2be", "utf-8", <<"test">>)),
     ?assertEqual({error, eilseq}, iconverl:conv("ucs-2be", "utf-8", <<129,129>>)).

conv4_utf8_to_latin1_test() ->
    D = <<195,135,226,130,172,49,206,169,50>>, %% Ç€1Ω2
    ?assertEqual({error, eilseq}, iconverl:conv("latin1", "utf-8", D)).

conv5_utf8_to_latin1_ignore_test() ->
    D = <<195,135,226,130,172,49,206,169,50>>, %% Ç€1Ω2 -> Ç12
    ?assertEqual({ok, <<199,49,50>>}, iconverl:conv("latin1//IGNORE", "utf-8", D)).

conv6_utf8_to_latin1_translite_test() ->
    D = <<195,135,226,130,172,49,206,169,50>>, %% Ç€1Ω2 -> ÇEUR1?2 
    ?assertEqual({ok, <<199,69,85,82,49,63,50>>}, iconverl:conv("latin1//TRANSLIT", "utf-8", D)).

conv7_latin1_digits_test() ->
    D = list_to_binary("0123456789"), 
    ?assertEqual({ok, <<48,49,50,51,52,53,54,55,56,57>>}, iconverl:conv("latin1//IGNORE", "utf-8", D)).

conv7_latin1_chars_up_test() ->
    L = "abcdefghijklmnopqrstuvwxyz",
    D = list_to_binary(L),
    ?assertEqual({ok, list_to_binary(lists:seq(97, 96 + length(L)))}, iconverl:conv("latin1//IGNORE", "utf-8", D)).

conv7_latin1_chars_low_test() ->
    L = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    D = list_to_binary(L),
    ?assertEqual({ok, list_to_binary(lists:seq(65, 64 + length(L)))}, iconverl:conv("latin1//IGNORE", "utf-8", D)).


conv8_not_usual_0338_test() ->
    D = list_to_binary("@£$¥èéùìòÇØøåÆæßÉÄÖÑÜ§¿äöñüà"), 
    ?assertEqual({ok, <<64,163,36,165,232,233,249,236,242,199,216,248,229,198,230,223,201,196,214,209,220,167,191,228,246,241,252,224>>}, iconverl:conv("latin1//IGNORE", "utf-8", D)).

conv8_latin1_not_supported_test() ->
    D = list_to_binary("ΔΦΓΛΩΠΨΣΘΞ€"), 
    ?assertEqual({ok, <<>>}, iconverl:conv("latin1//IGNORE", "utf-8", D)).

conv8_latin1_special_test() ->
    D = list_to_binary("_^{}\\[| !\"#¤%&'()*+,-./:;<=>?¡"), 
    ?assertEqual({ok, <<95,94,123,125,92,91,124,32,33,34,35,164,37,38,39,40,41,42,43,44,45,46,47,58,59,60,61,62,63,161>>}, iconverl:conv("latin1//IGNORE", "utf-8", D)).
