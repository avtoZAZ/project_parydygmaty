:- use_module(library(lists)).

% ===== Baza wiedzy o przepisach =====
przepis(nalesniki, '🥞 Naleśniki').
przepis(jajecznica, '🍳 Jajecznica').
przepis(omlet, '🍳 Omlet').
przepis(makaron_z_serem, '🧀 Makaron z serem').
przepis(ryz_z_kurczakiem, '🍗 Ryż z kurczakiem').
przepis(salatka_warzywna, '🥗 Sałatka warzywna').
przepis(zapiekanka_ziemniaczana, '🥔 Zapiekanka ziemniaczana').
przepis(kanapki, '🥪 Kanapki').
przepis(pasta_jajeczna, '🥚 Pasta jajeczna').
przepis(tortilla, '🌯 Tortilla').
przepis(zupa_pomidorowa, '🍅 Zupa pomidorowa').
przepis(placki_ziemniaczane, '🥔 Placki ziemniaczane').

skladnik(nalesniki, jajka). skladnik(nalesniki, mleko). skladnik(nalesniki, maka). skladnik(nalesniki, maslo).
skladnik(jajecznica, jajka). skladnik(jajecznica, maslo). skladnik(jajecznica, cebula).
skladnik(omlet, jajka). skladnik(omlet, mleko). skladnik(omlet, ser).
skladnik(makaron_z_serem, makaron). skladnik(makaron_z_serem, ser). skladnik(makaron_z_serem, maslo).
skladnik(ryz_z_kurczakiem, ryz). skladnik(ryz_z_kurczakiem, kurczak). skladnik(ryz_z_kurczakiem, czosnek). skladnik(ryz_z_kurczakiem, cebula).
skladnik(salatka_warzywna, ogorek). skladnik(salatka_warzywna, pomidor). skladnik(salatka_warzywna, papryka). skladnik(salatka_warzywna, fasola). skladnik(salatka_warzywna, kukurydza).
skladnik(zapiekanka_ziemniaczana, ziemniaki). skladnik(zapiekanka_ziemniaczana, cebula). skladnik(zapiekanka_ziemniaczana, smietana). skladnik(zapiekanka_ziemniaczana, ser).
skladnik(kanapki, chleb). skladnik(kanapki, ser). skladnik(kanapki, pomidor).
skladnik(pasta_jajeczna, jajka). skladnik(pasta_jajeczna, maslo). skladnik(pasta_jajeczna, cebula).
skladnik(tortilla, kurczak). skladnik(tortilla, papryka). skladnik(tortilla, cebula). skladnik(tortilla, ser).
skladnik(zupa_pomidorowa, pomidor). skladnik(zupa_pomidorowa, cebula). skladnik(zupa_pomidorowa, czosnek). skladnik(zupa_pomidorowa, smietana).
skladnik(placki_ziemniaczane, ziemniaki). skladnik(placki_ziemniaczane, cebula). skladnik(placki_ziemniaczane, maka). skladnik(placki_ziemniaczane, jajka).

czas(nalesniki, 20). czas(jajecznica, 10). czas(omlet, 15). czas(makaron_z_serem, 15).
czas(ryz_z_kurczakiem, 35). czas(salatka_warzywna, 12). czas(zapiekanka_ziemniaczana, 50).
czas(kanapki, 7). czas(pasta_jajeczna, 18). czas(tortilla, 30). czas(zupa_pomidorowa, 40). czas(placki_ziemniaczane, 30).

trudnosc(nalesniki, latwe). trudnosc(jajecznica, latwe). trudnosc(omlet, latwe). trudnosc(makaron_z_serem, latwe).
trudnosc(ryz_z_kurczakiem, srednie). trudnosc(salatka_warzywna, latwe). trudnosc(zapiekanka_ziemniaczana, srednie).
trudnosc(kanapki, latwe). trudnosc(pasta_jajeczna, latwe). trudnosc(tortilla, srednie). trudnosc(zupa_pomidorowa, srednie). trudnosc(placki_ziemniaczane, srednie).

% ===== Reguły =====
skladniki_przepisu(Danie, Lista) :- findall(S, skladnik(Danie, S), Lista).

pasujace_skladniki(Danie, Uzytkownik, ListaPasujacych) :-
    skladniki_przepisu(Danie, Wymagane),
    include({Uzytkownik}/[S]>>member(S, Uzytkownik), Wymagane, ListaPasujacych).

brakujace_skladniki(Danie, Uzytkownik, ListaBrakujacych) :-
    skladniki_przepisu(Danie, Wymagane),
    exclude({Uzytkownik}/[S]>>member(S, Uzytkownik), Wymagane, ListaBrakujacych).

mozna_zrobic(Danie, Uzytkownik) :-
    brakujace_skladniki(Danie, Uzytkownik, Braki),
    Braki = [].

procent_dopasowania(Danie, Uzytkownik, Procent) :-
    skladniki_przepisu(Danie, Wymagane),
    length(Wymagane, Wszystkie),
    pasujace_skladniki(Danie, Uzytkownik, Pasujace),
    length(Pasujace, Trafienia),
    (Wszystkie > 0 -> Procent is round((Trafienia / Wszystkie) * 100) ; Procent is 0).

ocena_trudnosci(latwe, 3).
ocena_trudnosci(srednie, 2).
ocena_trudnosci(trudne, 1).

wynik(Danie, Uzytkownik, Score) :-
    procent_dopasowania(Danie, Uzytkownik, Procent),
    brakujace_skladniki(Danie, Uzytkownik, Braki),
    length(Braki, IleBrakow),
    trudnosc(Danie, T), ocena_trudnosci(T, Bonus),
    Score is Procent*10 + Bonus - IleBrakow.

najlepsza_rekomendacja(Uzytkownik, Danie) :-
    findall(Score-D, (przepis(D,_), D=D, wynik(D, Uzytkownik, Score)), Pary),
    keysort(Pary, Posortowane),
    reverse(Posortowane, [_-Danie|_]).
