from __future__ import annotations

import json
import subprocess
from dataclasses import dataclass
from functools import reduce
from pathlib import Path
from typing import Dict, List

from flask import Flask, jsonify, render_template, request

BASE_DIR = Path(__file__).resolve().parent
PROLOG_FILE = BASE_DIR / "expert.pl"

app = Flask(__name__)


@dataclass
class Question:
    key: str
    text: str
    feature: str


@dataclass
class UserProfile:
    answers: Dict[str, bool]

    def selected_features(self, questions: List[Question]) -> List[str]:
        # Funkcyjne przetwarzanie odpowiedzi (list comprehension)
        return [q.feature for q in questions if self.answers.get(q.key, False)]

    def score(self) -> float:
        values = list(self.answers.values())
        if not values:
            return 0.0
        # Funkcyjny reduce
        total_yes = reduce(lambda acc, current: acc + (1 if current else 0), values, 0)
        return round((total_yes / len(values)) * 100, 1)


@dataclass
class Recommendation:
    language: str
    reason: str
    match_percent: float
    reasons: List[str]
    alternatives: List[Dict[str, object]]
    ranking: List[Dict[str, object]]


QUESTIONS = [
    Question("web", "Czy chcesz tworzyć strony internetowe?", "web"),
    Question("ai", "Czy interesuje Cię AI / data science?", "ai"),
    Question("math", "Czy lubisz matematykę?", "math"),
    Question("games", "Czy chcesz pisać gry?", "games"),
    Question("simple", "Czy wolisz prostą składnię?", "simple"),
    Question("mobile", "Czy interesują Cię aplikacje mobilne?", "mobile"),
    Question("quick", "Czy chcesz szybko zobaczyć efekty?", "quick"),
    Question("logic", "Czy lubisz logiczne myślenie?", "logic"),
    Question("performance", "Czy zależy Ci na wysokiej wydajności?", "performance"),
    Question("corporate", "Czy chcesz pracować w korporacji?", "corporate"),
]


def query_prolog(features: List[str]) -> List[Dict[str, object]]:
    feature_term = "[" + ",".join(features) + "]"
    goal = f"recommend_all({feature_term}, Results), writeln(Results), halt."
    cmd = ["swipl", "-q", "-s", str(PROLOG_FILE), "-g", goal]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)

    if result.returncode != 0:
        raise RuntimeError(
            "Nie udało się uruchomić Prologa (SWI-Prolog). "
            "Upewnij się, że 'swipl' jest zainstalowany.\n"
            f"STDERR: {result.stderr.strip()}"
        )

    line = result.stdout.strip().splitlines()[-1] if result.stdout.strip() else "[]"
    python_like = (
        line.replace("[", "[")
        .replace(")", ")")
        .replace("'", '"')
    )

    # Parsowanie wyniku listy termów przez dedykowany endpoint JSON z Prologa
    # Bezpieczniej: odpytać drugi cel, który zwraca JSON
    json_goal = f"recommend_all_json({feature_term}, Json), writeln(Json), halt."
    json_cmd = ["swipl", "-q", "-s", str(PROLOG_FILE), "-g", json_goal]
    json_result = subprocess.run(json_cmd, capture_output=True, text=True, check=False)

    if json_result.returncode != 0:
        raise RuntimeError(f"Błąd przy odczycie JSON z Prologa: {json_result.stderr.strip()}")

    json_payload = json_result.stdout.strip().splitlines()[-1] if json_result.stdout.strip() else "[]"
    return json.loads(json_payload)


def build_recommendation(raw: List[Dict[str, object]]) -> Recommendation:
    if not raw:
        return Recommendation(
            language="Python",
            reason="Domyślny wybór przy braku danych.",
            match_percent=50.0,
            reasons=["Uniwersalność", "Szybki start", "Duży ekosystem"],
            alternatives=[],
            ranking=[],
        )

    ranking = sorted(raw, key=lambda x: x["match_percent"], reverse=True)
    best = ranking[0]
    alternatives = ranking[1:4]

    return Recommendation(
        language=best["language"],
        reason=best["justification"],
        match_percent=best["match_percent"],
        reasons=best["top_reasons"][:3],
        alternatives=alternatives,
        ranking=ranking[:6],
    )


@app.route("/")
def index():
    return render_template("index.html", questions=[q.__dict__ for q in QUESTIONS])


@app.post("/api/recommend")
def recommend():
    payload = request.get_json(force=True)
    answers = payload.get("answers", {})

    # Imperatywny przebieg sterowania + walidacja
    normalized = {}
    for q in QUESTIONS:
        normalized[q.key] = bool(answers.get(q.key, False))

    profile = UserProfile(normalized)
    features = profile.selected_features(QUESTIONS)

    try:
        raw_results = query_prolog(features)
    except RuntimeError as exc:
        return jsonify({"error": str(exc)}), 500

    recommendation = build_recommendation(raw_results)

    return jsonify(
        {
            "language": recommendation.language,
            "reason": recommendation.reason,
            "match_percent": recommendation.match_percent,
            "reasons": recommendation.reasons,
            "alternatives": recommendation.alternatives,
            "ranking": recommendation.ranking,
            "profile_energy": profile.score(),
            "selected_features": features,
        }
    )


if __name__ == "__main__":
    app.run(debug=True)
