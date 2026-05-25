# Doradca wyboru obiadu – Smart Kitchen AI

## 1. Temat projektu
Aplikacja webowa rekomendująca potrawy na podstawie składników użytkownika.

## 2. Opis działania
Użytkownik zaznacza składniki, które ma w domu. Backend Flask przekazuje listę do Prologa (`recipes.pl`), a silnik ekspercki oblicza dopasowanie dla wszystkich dań i zwraca najlepszą rekomendację oraz alternatywy.

## 3. Instrukcja uruchomienia
1. Zainstaluj Python 3.10+ i SWI-Prolog (`swipl`).
2. Uruchom:
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```
3. Otwórz `http://127.0.0.1:5000`.

## 4. Integracja Python + Prolog
- Python uruchamia zapytania Prologowe przez `subprocess` i `swipl`.
- Prolog wykonuje reguły: dopasowanie składników, braki, procent dopasowania i ranking.
- Python mapuje wyniki na obiekty domenowe i zwraca JSON do frontendu.

## 5. Paradygmaty programowania
- **Logiczny**: fakty i reguły w `recipes.pl` (`skladnik/2`, `mozna_zrobic/2`, `procent_dopasowania/3`, `najlepsza_rekomendacja/2`).
- **Obiektowy**: klasy `Ingredient`, `Recipe`, `Recommendation`, `UserPantry` w `app.py`.
- **Funkcyjny**: `map`, list comprehensions, lambda sortująca, transformacje list.
- **Imperatywny**: obsługa requestów Flask, sekwencja kroków analizy, rendering UI.
- **Współbieżny/asynchroniczny (opcjonalnie)**: asynchroniczny `fetch`, animowane skanowanie i progres.

## 6. Przykładowy scenariusz
Użytkownik wybiera: `jajka`, `mleko`, `maka`, `maslo`, `ser`. System może zaproponować np. naleśniki lub omlet, pokazuje procent dopasowania, brakujące składniki i alternatywne przepisy.

## 7. Kluczowa informacja
**Główna funkcjonalność rekomendacji jest w Prologu (`recipes.pl`).** Python pełni rolę warstwy integracyjnej i API.
