from __future__ import annotations

import json
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from flask import Flask, jsonify, render_template, request

BASE_DIR = Path(__file__).resolve().parent
PROLOG_FILE = BASE_DIR / "recipes.pl"

app = Flask(__name__)


@dataclass(frozen=True)
class Ingredient:
    name: str
    label: str
    emoji: str


@dataclass
class Recipe:
    slug: str
    name: str
    needed: list[str]
    has: list[str]
    missing: list[str]
    match_percent: int
    difficulty: str
    prep_time: int


@dataclass
class Recommendation:
    best: Recipe
    alternatives: list[Recipe]
    reason: str


@dataclass
class UserPantry:
    ingredients: list[str]

    def normalized(self) -> list[str]:
        return sorted(set([x.strip().lower() for x in self.ingredients if x.strip()]))


def prolog_query(goal: str) -> str:
    cmd = ["swipl", "-q", "-s", str(PROLOG_FILE), "-g", f"{goal}, halt."]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "Błąd SWI-Prolog")
    lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    return lines[-1] if lines else ""


def parse_list_atom(raw: str) -> list[str]:
    cleaned = raw.strip().strip("[]")
    if not cleaned:
        return []
    return [item.strip() for item in cleaned.split(",") if item.strip()]


def get_recipes_for_pantry(user_ingredients: list[str]) -> list[Recipe]:
    recipes = parse_list_atom(prolog_query("findall(D, przepis(D,_), Ds), writeln(Ds)"))
    uterm = "[" + ",".join(user_ingredients) + "]"
    rows: list[Recipe] = []

    for recipe in recipes:
        needed = parse_list_atom(prolog_query(f"skladniki_przepisu({recipe}, L), writeln(L)"))
        has = parse_list_atom(prolog_query(f"pasujace_skladniki({recipe}, {uterm}, L), writeln(L)"))
        missing = parse_list_atom(prolog_query(f"brakujace_skladniki({recipe}, {uterm}, L), writeln(L)"))
        match_percent = int(prolog_query(f"procent_dopasowania({recipe}, {uterm}, P), writeln(P)"))
        difficulty = prolog_query(f"trudnosc({recipe}, T), writeln(T)")
        prep_time = int(prolog_query(f"czas({recipe}, C), writeln(C)"))
        name = prolog_query(f"przepis({recipe}, N), writeln(N)")

        rows.append(
            Recipe(
                slug=recipe,
                name=name,
                needed=needed,
                has=has,
                missing=missing,
                match_percent=match_percent,
                difficulty=difficulty,
                prep_time=prep_time,
            )
        )

    return sorted(rows, key=lambda r: (r.match_percent, -len(r.missing), -r.prep_time), reverse=True)


def build_recommendation(recipes: list[Recipe]) -> Recommendation:
    best = recipes[0]
    alternatives = recipes[1:5]
    reason = (
        f"Wybrano {best.name}, bo ma najwyższe dopasowanie ({best.match_percent}%), "
        f"niewiele braków ({len(best.missing)}) i czas przygotowania {best.prep_time} min."
    )
    return Recommendation(best=best, alternatives=alternatives, reason=reason)


INGREDIENTS = [
    Ingredient("jajka", "Jajka", "🥚"), Ingredient("mleko", "Mleko", "🥛"), Ingredient("maka", "Mąka", "🌾"),
    Ingredient("ser", "Ser", "🧀"), Ingredient("pomidor", "Pomidor", "🍅"), Ingredient("makaron", "Makaron", "🍝"),
    Ingredient("ryz", "Ryż", "🍚"), Ingredient("kurczak", "Kurczak", "🍗"), Ingredient("ziemniaki", "Ziemniaki", "🥔"),
    Ingredient("cebula", "Cebula", "🧅"), Ingredient("czosnek", "Czosnek", "🧄"), Ingredient("maslo", "Masło", "🧈"),
    Ingredient("smietana", "Śmietana", "🥣"), Ingredient("pieczarki", "Pieczarki", "🍄"), Ingredient("chleb", "Chleb", "🍞"),
    Ingredient("tunczyk", "Tuńczyk", "🐟"), Ingredient("ogorek", "Ogórek", "🥒"), Ingredient("papryka", "Papryka", "🫑"),
    Ingredient("fasola", "Fasola", "🫘"), Ingredient("kukurydza", "Kukurydza", "🌽"),
]


@app.get("/")
def index() -> str:
    return render_template("index.html", ingredients=[i.__dict__ for i in INGREDIENTS])


@app.post("/api/recommend")
def recommend() -> Any:
    payload = request.get_json(force=True)
    pantry = UserPantry(payload.get("ingredients", []))
    selected = pantry.normalized()

    if not selected:
        return jsonify({"error": "Wybierz przynajmniej jeden składnik."}), 400

    try:
        recipe_rows = get_recipes_for_pantry(selected)
    except Exception as exc:
        return jsonify({"error": f"Błąd integracji z Prologiem: {exc}"}), 500

    recommendation = build_recommendation(recipe_rows)

    to_dict = lambda r: {
        "slug": r.slug,
        "name": r.name,
        "needed": r.needed,
        "has": r.has,
        "missing": r.missing,
        "match_percent": r.match_percent,
        "difficulty": r.difficulty,
        "prep_time": r.prep_time,
    }

    return jsonify(
        {
            "selected": selected,
            "best": to_dict(recommendation.best),
            "alternatives": list(map(to_dict, recommendation.alternatives)),
            "reason": recommendation.reason,
        }
    )


if __name__ == "__main__":
    app.run(debug=True)
