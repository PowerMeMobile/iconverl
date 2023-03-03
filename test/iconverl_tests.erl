-module(iconverl_tests).

-include_lib("eunit/include/eunit.hrl").

open_test() ->
    ?assertError(badarg, iconverl:open("utf-99", "ucs-34")),
    {{To, From}, CD} = iconverl:open("utf-8", "ucs-2be"),
    ?assertEqual(To, "utf-8"),
    ?assertEqual(From, "ucs-2be"),
    ?assert(is_reference(CD))
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
    %% "@£$¥èéùìòÇØøåÆæßÉÄÖÑÜ§¿äöñüà"
    D = list_to_binary([64,194,163,36,194,165,195,168,195,169,195,185,195,172,195,178,195,135,195,152,195,184,195,165,195,134,195,166,195,159,195,137,195,132,195,150,195,145,195,156,194,167,194,191,195,164,195,182,195,177,195,188,195,160]),
    ?assertEqual({ok, <<64,163,36,165,232,233,249,236,242,199,216,248,229,198,230,223,201,196,214,209,220,167,191,228,246,241,252,224>>}, iconverl:conv("latin1//IGNORE", "utf-8", D)).

conv8_latin1_not_supported_test() ->
    Str = [206,148,206,166,206,147,206,155,206,169,97,97,97,97,206,160,206,168,206,163,206,152,206,158,226,130,172], %% "ΔΦΓΛΩaaaaΠΨΣΘΞ€"
    D = list_to_binary(Str),
    ?assertEqual({ok, <<"aaaa">>}, iconverl:conv("latin1//IGNORE", "utf-8", D)).

conv8_latin1_special_test() ->
    D = list_to_binary([95,94,123,125,92,91,124,32,33,34,35,194,164,37,38,39,40,41,42,43,44,45,46,47,58,59,60,61,62,63,194,161]), %% "_^{}\[| !"#¤%&'()*+,-./:;<=>?¡"
    ?assertEqual({ok, <<95,94,123,125,92,91,124,32,33,34,35,164,37,38,39,40,41,42,43,44,45,46,47,58,59,60,61,62,63,161>>}, iconverl:conv("latin1//IGNORE", "utf-8", D)).

conv9_latin1_to_utf8ignore_test() ->
    D = list_to_binary("123"),
    {ok, Enc} = iconverl:conv("utf-8//IGNORE", "latin1", D),
    ?assertEqual(<<"123">>, Enc).

%conv9_latin1_to_utf8ignore_emoji_test() ->
%  D = list_to_binary([49, 50, 51, 16#d8, 16#3c, 16#df, 16#3f]),
%  {ok, Enc} = iconverl:conv("utf-8//IGNORE", "latin1", D),
%  ?assertEqual(<<"123">>, Enc).

conv9_ucs2be_to_utf8ignore_test() ->
    D = <<0,$t,0,$e,0,$s,0,$t>>, %% test
    {ok, Enc} = iconverl:conv("utf-8//IGNORE", "ucs-2be", D),
    ?assertEqual(<<"test">>, Enc).

conv9_ucs2be_to_utf8ignore_emoji_test() ->
    D = <<0,$t,0,$e,0,$s,0,$t, 16#d8, 16#3c, 16#df, 16#3f>>, %% test + emoji
    {ok, Enc} = iconverl:conv("utf-8//IGNORE", "ucs-2be", D),
    ?assertEqual(<<"test">>, Enc).

%conv9_ucs2be_to_utf8_emoji_test() ->
%   D = <<0,$t,0,$e,0,$s,0,$t, 16#d8, 16#3c, 16#df, 16#3f>>, %% test + emoji
%   {ok, Enc} = iconverl:conv("utf-8", "ucs-2be", D),
%   ?assertEqual(<<"test">>, Enc).

conv9_utf8_to_ucs2be_test() ->
    D = list_to_binary([$t,$e,$s,$t]), %% test
    {ok, Enc} = iconverl:conv("ucs-2be//IGNORE", "utf-8", D),
    ?assertEqual(<<0,$t,0,$e,0,$s,0,$t>>, Enc).

conv9_utf8_to_ucs2be_emoji_test() ->
   D = list_to_binary([$t,$e,$s,$t, 16#f0, 16#9f, 16#8c, 16#bf]), %% test + emoji
   {ok, Enc} = iconverl:conv("ucs-2be//IGNORE", "utf-8", D),
    ?assertEqual(<<0,$t,0,$e,0,$s,0,$t>>, Enc).

conv10_urf16_urf8_test() ->
  D = list_to_binary([0,$t,0,$e,0,$s,0,$t]), %% test
  {ok, Enc} = iconverl:conv("utf-8", "utf-16be", D),
  ?assertEqual(<<"test">>, Enc).

conv10_urf16_urf8_emoji_test() ->
  D = list_to_binary([0,$t,0,$e,0,$s,0,$t,16#d8, 16#3c, 16#df, 16#3f]), %% test + emoji
  {ok, Enc} = iconverl:conv("utf-8", "utf-16be", D),
  ?assertEqual(<<$t,$e,$s,$t,16#F0,16#9F,16#8C,16#BF>>, Enc).

conv10_urf16_urf8_arabic_test() ->
  D = list_to_binary([16#06,16#45, 16#06,16#31, 16#06,16#2d, 16#06,16#28, 16#06,16#4b, 16#06,16#27]), %% hello in arabic
  {ok, Enc} = iconverl:conv("utf-8", "utf-16be", D),
  ?assertEqual(<<217,133,216,177,216,173,216,168,217,139,216,167>>, Enc).
