:- use_module(library(http/json)).
:- use_module(library(lists)).

language(python).
language(javascript).
language(java).
language(cpp).
language(csharp).
language(haskell).
language(prolog).
language(kotlin).
language(swift).
language(rust).

cecha(python, web).
cecha(python, ai).
cecha(python, simple).
cecha(python, quick).
cecha(python, corporate).

cecha(javascript, web).
cecha(javascript, quick).
cecha(javascript, mobile).
cecha(javascript, simple).

cecha(java, corporate).
cecha(java, mobile).
cecha(java, performance).
cecha(java, games).

cecha(cpp, performance).
cecha(cpp, games).
cecha(cpp, math).
cecha(cpp, corporate).

cecha(csharp, games).
cecha(csharp, corporate).
cecha(csharp, web).
cecha(csharp, mobile).

cecha(haskell, math).
cecha(haskell, logic).
cecha(haskell, performance).
cecha(haskell, ai).

cecha(prolog, logic).
cecha(prolog, ai).
cecha(prolog, math).
cecha(prolog, quick).

cecha(kotlin, mobile).
cecha(kotlin, corporate).
cecha(kotlin, simple).
cecha(kotlin, web).

cecha(swift, mobile).
cecha(swift, performance).
cecha(swift, simple).
cecha(swift, corporate).

cecha(rust, performance).
cecha(rust, math).
cecha(rust, logic).
cecha(rust, corporate).

uzasadnienie(python, 'Python jest świetny do AI, automatyzacji i szybkiego prototypowania.').
uzasadnienie(javascript, 'JavaScript dominuje w web developmencie i daje szybkie efekty wizualne.').
uzasadnienie(java, 'Java jest mocna w projektach korporacyjnych i aplikacjach mobilnych Android.').
uzasadnienie(cpp, 'C++ zapewnia wysoką wydajność i sprawdza się w silnikach gier.').
uzasadnienie(csharp, 'C# dobrze łączy game dev z rozwiązaniami biznesowymi .NET.').
uzasadnienie(haskell, 'Haskell promuje czyste myślenie funkcyjne i ścisłą matematykę.').
uzasadnienie(prolog, 'Prolog jest naturalny dla systemów eksperckich i logicznego wnioskowania.').
uzasadnienie(kotlin, 'Kotlin ma nowoczesną składnię i jest mocny na Androidzie.').
uzasadnienie(swift, 'Swift to najlepszy wybór dla ekosystemu Apple i aplikacji iOS.').
uzasadnienie(rust, 'Rust łączy bezpieczeństwo pamięci z wydajnością systemową.').

powod(Op, web, 'Silne zastosowanie w technologiach webowych') :- cecha(Op, web).
powod(Op, ai, 'Dobre wsparcie dla AI i data science') :- cecha(Op, ai).
powod(Op, math, 'Świetny wybór dla osób lubiących matematykę') :- cecha(Op, math).
powod(Op, games, 'Nadaje się do tworzenia gier') :- cecha(Op, games).
powod(Op, simple, 'Ma relatywnie prostą i czytelną składnię') :- cecha(Op, simple).
powod(Op, mobile, 'Posiada mocne wsparcie dla aplikacji mobilnych') :- cecha(Op, mobile).
powod(Op, quick, 'Pozwala szybko zobaczyć efekty pracy') :- cecha(Op, quick).
powod(Op, logic, 'Wspiera logiczne i analityczne myślenie') :- cecha(Op, logic).
powod(Op, performance, 'Oferuje wysoką wydajność') :- cecha(Op, performance).
powod(Op, corporate, 'Jest ceniony w środowisku korporacyjnym') :- cecha(Op, corporate).

policz_dopasowanie(Jezyk, Preferencje, Punkty, MaxPunkty, Procent, Powody) :-
    findall(C, cecha(Jezyk, C), Cechy),
    length(Cechy, MaxPunkty),
    findall(P, (member(P, Preferencje), cecha(Jezyk, P)), Trafienia),
    length(Trafienia, Punkty),
    (MaxPunkty > 0 -> Procent is round((Punkty / MaxPunkty) * 100) ; Procent is 0),
    findall(Tekst, (member(F, Trafienia), powod(Jezyk, F, Tekst)), Powody).

polecany_jezyk(Jezyk, Preferencje, Punkty) :-
    language(Jezyk),
    policz_dopasowanie(Jezyk, Preferencje, Punkty, _M, _Proc, _Powody).

recommend_all(Preferencje, Sorted) :-
    findall(result(Jezyk, Procent, Uzasadnienie, Powody),
        (
            language(Jezyk),
            policz_dopasowanie(Jezyk, Preferencje, _Punkty, _Max, Procent, Powody),
            uzasadnienie(Jezyk, Uzasadnienie)
        ),
        Results),
    predsort(compare_results, Results, Sorted).

compare_results(Delta, result(_, P1, _, _), result(_, P2, _, _)) :-
    compare(Delta, P2, P1).

recommend_all_json(Preferencje, JsonAtom) :-
    recommend_all(Preferencje, Sorted),
    maplist(result_to_dict, Sorted, Dicts),
    atom_json_term(JsonAtom, Dicts, []).

result_to_dict(result(Jezyk, Procent, Uzasadnienie, Powody), _{
    language: Jezyk,
    match_percent: Procent,
    justification: Uzasadnienie,
    top_reasons: Powody
}).
