# Notatki do prezentacji projektu

## Co robi aplikacja?
To system ekspercki pomagający wybrać język programowania na podstawie preferencji użytkownika. Użytkownik odpowiada na pytania, a aplikacja zwraca najlepszy język i alternatywy.

## Dlaczego Prolog pasuje do systemu eksperckiego?
Prolog naturalnie wspiera modelowanie wiedzy przez fakty i reguły. Dzięki temu łatwo opisać cechy języków i mechanizm wnioskowania oparty na dopasowaniu preferencji.

## Jakie paradygmaty zostały użyte?
- **Logiczny**: reguły i fakty w `expert.pl`.
- **Obiektowy**: klasy domenowe w Pythonie (`UserProfile`, `Question`, `Recommendation`).
- **Funkcyjny**: list comprehensions, `reduce`, transformacje danych.
- **Imperatywny**: przebieg quizu krok po kroku i obsługa API.
- **Asynchroniczny (opcjonalnie)**: animowany etap analizy i `fetch` w JS.

## Krótkie demo na zajęciach
1. Uruchomić aplikację Flask.
2. Odpowiedzieć na kilka pytań (np. web + ai + prosta składnia).
3. Pokazać wynik i wykres rankingowy.
4. Otworzyć `expert.pl` i pokazać fakty oraz reguły decyzyjne.
