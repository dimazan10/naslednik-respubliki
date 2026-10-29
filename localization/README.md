# Game localization

`en.json` contains the offline English draft for Russian text in `scripts/main.gd`.
`overrides_en.json` contains edited translations for menus, mechanics, and other key text.
The game loads both files locally; it never calls a translation service while running.

The optional developer script `tools/build_english_catalog.py` collects new Russian
string literals and translates them with a locally installed Argos ru-en model via
CTranslate2 and SentencePiece. Set `ARGOS_RU_EN_MODEL` to the extracted model folder
if it is not in `../translation-model/translate-ru_en-1_9`. Review generated text
and add corrections to `overrides_en.json`. The model is not distributed with the game.
