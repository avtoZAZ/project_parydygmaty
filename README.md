# Projekt zaliczeniowy – Paradygmaty programowania

## Temat
**System ekspercki: „Jaki język programowania wybrać?”**

## Opis działania aplikacji
Aplikacja to interaktywny, cyberpunkowy quiz webowy. Użytkownik odpowiada na 10 pytań dotyczących preferencji (web, AI, matematyka, gry, składnia, mobile, szybkość efektów, logika, wydajność, korporacje).

Po odpowiedzi:
1. Frontend wysyła dane do backendu Flask (`/api/recommend`).
2. Python normalizuje odpowiedzi i tworzy profil użytkownika.
3. Python uruchamia **SWI-Prolog** na pliku `expert.pl`.
4. Prolog liczy dopasowania cech do języków, sortuje ranking i zwraca JSON.
5. Frontend pokazuje:
   - rekomendowany język,
   - krótkie uzasadnienie,
   - procent dopasowania,
   - 3 powody wyboru,
   - alternatywne języki,
   - wykres słupkowy dopasowań.

## Paradygmaty programowania w projekcie

### 1) Programowanie logiczne (Prolog)
- Fakty `cecha/2`, `uzasadnienie/2`.
- Reguły: `policz_dopasowanie/6`, `polecany_jezyk/3`, `recommend_all/2`.
- Główna funkcjonalność decyzyjna jest w **Prologu**.

### 2) Programowanie obiektowe (Python)
- Klasy `Question`, `UserProfile`, `Recommendation` w `app.py`.

### 3) Programowanie funkcyjne (Python)
- List comprehensions w `selected_features`.
- `reduce` w `UserProfile.score`.
- `map` w JS podczas renderowania list powodów i alternatyw.

### 4) Programowanie imperatywne
- Krokowy przepływ quizu i walidacji danych (`renderQuestion`, `selectAnswer`, endpoint Flask).

### 5) Element współbieżności/asynchroniczności (opcjonalnie)
- Asynchroniczny frontend (`async/await`, fetch API, animowany ekran analizy).

## Struktura projektu
- `app.py` – backend Flask + integracja Python ↔ Prolog
- `expert.pl` – silnik ekspercki Prolog
- `templates/index.html` – widok aplikacji
- `static/css/style.css` – styl cyberpunk / glassmorphism
- `static/js/app.js` – logika quizu, animacje, wykres
- `data/sample_answers.json` – przykładowe dane testowe
- `PRESENTATION_NOTES.md` – notatki do prezentacji
- `requirements.txt` – zależności

## Instrukcja uruchomienia

### Wymagania
- Python 3.10+
- SWI-Prolog (`swipl` dostępny w PATH)

### Kroki
```bash
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
pip install -r requirements.txt
python app.py
```

Następnie otwórz: `http://127.0.0.1:5000`

## Przykładowy scenariusz
1. Użytkownik zaznacza: web=tak, ai=tak, simple=tak, quick=tak, corporate=tak.
2. Prolog wylicza najwyższe dopasowanie dla **Python** lub **JavaScript** (zależnie od pełnego profilu).
3. Aplikacja pokazuje wynik z procentem i alternatywami.

## Ważna informacja
✅ **Główna funkcjonalność decyzyjna została zaimplementowana w Prologu (`expert.pl`)**, a Python pełni rolę integracji i serwowania aplikacji.
