# Tekst do prezentacji projektu (PL)

Dzień dobry,

Nasz projekt to **Doradca wyboru obiadu – Smart Kitchen AI**. To aplikacja, która pomaga zdecydować, co ugotować na obiad na podstawie składników dostępnych w domu.

## Czym jest aplikacja?
To nowoczesna aplikacja webowa w stylu cyberpunkowym. Użytkownik klika składniki w interfejsie „Twoja lodówka”, a system analizuje możliwe przepisy i zwraca najlepszą propozycję oraz alternatywy.

## Co robi Prolog?
Prolog jest sercem systemu eksperckiego:
- przechowuje fakty o przepisach i składnikach,
- oblicza, które składniki pasują,
- wylicza braki,
- liczy procent dopasowania,
- wybiera najlepszą rekomendację.

## Dlaczego Prolog pasuje do problemu?
Bo to klasyczny problem regułowy: mamy wiedzę (fakty) i wnioskowanie (reguły). Prolog idealnie wspiera taki model i pozwala czytelnie zapisać logikę decyzji.

## Jakie paradygmaty wykorzystaliśmy?
1. **Logiczny** – reguły decyzyjne i fakty w Prologu.
2. **Obiektowy** – klasy domenowe w Pythonie.
3. **Funkcyjny** – operacje map/filter/comprehensions.
4. **Imperatywny** – przebieg aplikacji, request/response.
5. **Asynchroniczny** – animowane skanowanie i płynne ładowanie wyników.

## Jak pokazać demo?
1. Uruchomić aplikację (`python app.py`).
2. Zaznaczyć kilka składników, np. jajka, mleko, mąka, ser.
3. Kliknąć „Znajdź obiad”.
4. Pokazać wynik: najlepsze danie, procent dopasowania, składniki brakujące i alternatywy.
5. Otworzyć `recipes.pl` i pokazać reguły `procent_dopasowania/3` i `najlepsza_rekomendacja/2`.

Dziękuję.
