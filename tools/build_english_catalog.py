"""Generate the offline English draft from Russian text in the Godot script.

This developer tool needs a local CTranslate2 Argos ru-en model. The game only
loads the generated JSON and has no translation service or Python dependency.
"""

import ast
import json
import os
import re
from pathlib import Path

import ctranslate2
import sentencepiece


ROOT = Path(__file__).resolve().parents[1]
MODEL = Path(os.environ.get("ARGOS_RU_EN_MODEL", str(ROOT.parent / "translation-model" / "translate-ru_en-1_9")))
SOURCES = [ROOT / "scripts" / "main.gd", ROOT / "scripts" / "political_dispatches.gd", ROOT / "scripts" / "campaign_arcs.gd"]
OUTPUT = ROOT / "localization" / "en.json"
CYRILLIC = re.compile(r"[А-Яа-яЁё]")
LITERAL = re.compile(r'"(?:\\.|[^"\\])*"')
FORMAT = re.compile(r"%(?:[-+ 0-9.]*)[dfs]|\{[a-z_]+\}")


def collect() -> list[str]:
    values = set()
    for source in SOURCES:
        for match in LITERAL.finditer(source.read_text(encoding="utf-8")):
            try:
                value = ast.literal_eval(match.group())
            except (SyntaxError, ValueError):
                continue
            if isinstance(value, str) and CYRILLIC.search(value):
                values.add(value)
    return sorted(values)


def main() -> None:
    values = collect()
    old = json.loads(OUTPUT.read_text(encoding="utf-8")) if OUTPUT.exists() else {}
    sp = sentencepiece.SentencePieceProcessor(model_file=str(MODEL / "sentencepiece.model"))
    engine = ctranslate2.Translator(str(MODEL / "model"), device="cpu", inter_threads=4)
    catalog = dict(old)
    pending = [s for s in values if s not in catalog]
    for offset in range(0, len(pending), 24):
        batch = pending[offset : offset + 24]
        source_tokens = [sp.encode(s, out_type=str) for s in batch]
        results = engine.translate_batch(source_tokens, beam_size=3, max_batch_size=24)
        for source, result in zip(batch, results):
            english = sp.decode(result.hypotheses[0]).strip()
            if len(FORMAT.findall(english)) != len(FORMAT.findall(source)):
                # Preserve format markers; the shorter fragments can be refined by hand.
                pieces = FORMAT.split(source)
                markers = FORMAT.findall(source)
                translated_pieces = [
                    sp.decode(engine.translate_batch([sp.encode(piece, out_type=str)], beam_size=2)[0].hypotheses[0]).strip()
                    if CYRILLIC.search(piece) else piece
                    for piece in pieces
                ]
                english = "".join(
                    part + (markers[i] if i < len(markers) else "")
                    for i, part in enumerate(translated_pieces)
                )
            catalog[source] = english or source
        if offset % 240 == 0:
            OUTPUT.parent.mkdir(exist_ok=True)
            OUTPUT.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            print(f"Translated {min(offset + 24, len(pending))}/{len(pending)}", flush=True)
    for source in values:
        if "{" not in source or len(FORMAT.findall(str(catalog.get(source, "")))) == len(FORMAT.findall(source)):
            continue
        pieces = FORMAT.split(source)
        markers = FORMAT.findall(source)
        translated_pieces = [
            sp.decode(engine.translate_batch([sp.encode(piece, out_type=str)], beam_size=2)[0].hypotheses[0]).strip()
            if CYRILLIC.search(piece) else piece
            for piece in pieces
        ]
        catalog[source] = "".join(
            part + (markers[i] if i < len(markers) else "")
            for i, part in enumerate(translated_pieces)
        )
    # The model was trained on sentence case. Raw all-cap labels otherwise
    # produce mistakes such as "CONTINUATE" and "DEFOLT".
    uppercase = [s for s in values if s.isupper() and len(s) < 180]
    for offset in range(0, len(uppercase), 24):
        batch = uppercase[offset : offset + 24]
        normalized = [re.sub(r"[А-Яа-яЁё]", lambda m: m.group().upper(), s.lower(), count=1) for s in batch]
        results = engine.translate_batch([sp.encode(s, out_type=str) for s in normalized], beam_size=3, max_batch_size=24)
        for source, result in zip(batch, results):
            english = sp.decode(result.hypotheses[0]).strip()
            if not source.rstrip().endswith((".", "!", "?")):
                english = english.rstrip(".")
            if len(FORMAT.findall(english)) == len(FORMAT.findall(source)):
                catalog[source] = english.upper()
    catalog.update(
        {
            "НАСЛЕДНИК\nРЕСПУБЛИКИ": "HEIR TO THE\nREPUBLIC",
            "НАСЛЕДНИК РЕСПУБЛИКИ": "HEIR TO THE REPUBLIC",
            "Восточный Союз": "Eastern Union",
            "Западная Федерация": "Western Federation",
            "Церковь Веры": "Church of the Faith",
            "Режим киборга": "Cyborg Mode",
            "РЕЖИМ КИБОРГА": "CYBORG MODE",
            "Анна Радан": "Anna Radan",
            "Марек Вольский": "Marek Volsky",
            "Лея Нарин": "Leia Narin",
            "Мила Сорец": "Mila Sorets",
            "Элиан Варек": "Elian Varek",
            "Дарья Крес": "Darya Kres",
            "Ирина": "Irina",
            "Антон": "Anton",
        }
    )
    OUTPUT.parent.mkdir(exist_ok=True)
    OUTPUT.write_text(json.dumps(dict(sorted(catalog.items())), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(catalog)} translations to {OUTPUT}", flush=True)


if __name__ == "__main__":
    main()
