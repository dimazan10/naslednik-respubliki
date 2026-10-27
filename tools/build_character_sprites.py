"""Build the game's flat silhouette atlas without third-party image packages."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from xml.sax.saxutils import escape


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "portraits"
CELL = 256
COLUMNS = 6
INK = "#202328"
LIGHT = "#e7dcc5"


@dataclass(frozen=True)
class Character:
    key: str
    name: str
    accent: str
    hair: str
    detail: str
    description: str


CHARACTERS = [
    Character("president", "Президент", "#c7a96b", "part", "tie", "золотой галстук"),
    Character("father", "Отец", "#b5aa91", "silver", "father", "седина, круглые очки и награда"),
    Character("brother", "Старший брат", "#a9473f", "short", "officer", "офицерская фуражка и погоны"),
    Character("radan", "Анна Радан", "#8aa0af", "bob", "accountant", "каре, очки и значок монеты"),
    Character("grad", "Виктор Град", "#b99b66", "silver", "industrial", "седые виски и заводской знак"),
    Character("sorec", "Мила Сорец", "#77947d", "wave", "scarf", "волосы волной и зелёный шарф"),
    Character("volsky", "Марек Вольский", "#9b544a", "short", "police", "козырёк и ряд ведомственных пуговиц"),
    Character("kovach", "Ирина Ковач", "#738c9e", "bun", "lawyer", "пучок, очки и знак правосудия"),
    Character("sava", "Антон Сава", "#a59a82", "part", "folder", "пробор, галстук и папка"),
    Character("yun", "Милош Юн", "#728b9b", "short", "beret", "офицерский берет и знак обороны"),
    Character("zukan", "Грегор Жукан", "#a8665c", "short", "general", "фуражка, усы и планка наград"),
    Character("narin", "Лея Нарин", "#a9a176", "long", "diplomat", "длинные волосы и дипломатическая брошь"),
    Character("varek", "Элиан Варек", "#728fa5", "part", "western", "узкие очки и синяя лента"),
    Character("kres", "Дарья Крес", "#ad8b62", "bun", "energy", "собранные волосы и знак нефти"),
    Character("spouse", "Супруга президента", "#b5a16e", "long", "necklace", "длинные волосы и ожерелье"),
    Character("chef", "Повар резиденции", "#e0d4bb", "none", "chef", "поварской колпак и фартук"),
    Character("doctor", "Личный врач", "#829e92", "short", "doctor", "очки, халат и стетоскоп"),
    Character("chair", "Председатель парламента", "#a69779", "silver", "chair", "очки и парламентский знак"),
    Character("journalist", "Редактор", "#85939f", "side", "journalist", "наушник и блокнот"),
    Character("governor", "Губернатор", "#8b976f", "short", "governor", "региональный знак и шарф"),
    Character("official", "Чиновник", "#b6a482", "short", "tie", "простой галстук"),
    Character("military", "Военный", "#9c645c", "short", "officer", "фуражка и погоны"),
    Character("diplomat", "Дипломат", "#7e99aa", "part", "diplomat", "брошь дипломатической службы"),
    Character("family", "Близкий человек", "#a69c80", "wave", "necklace", "мягкая причёска и кулон"),
]


def hair(style: str, accent: str) -> str:
    if style == "none":
        return ""
    if style == "short":
        return f'<path d="M94 82 Q92 53 122 53 Q153 48 162 76 Q140 67 119 73 Q104 76 94 82Z" fill="{accent}"/>'
    if style == "part":
        return f'<path d="M94 82 Q94 51 127 53 Q154 52 162 76 Q141 65 126 65 L120 75 Q106 70 94 82Z" fill="{accent}"/><path d="M125 55 L119 76" stroke="{INK}" stroke-width="3"/>'
    if style == "silver":
        return f'<path d="M94 75 Q102 50 126 53 Q153 51 162 75 L155 89 L149 68 Q128 58 105 69 L101 92Z" fill="{accent}"/><path d="M96 93 L99 111 M160 93 L157 111" stroke="{accent}" stroke-width="8" stroke-linecap="round"/>'
    if style == "bob":
        return f'<path d="M93 79 Q88 48 127 49 Q165 49 164 81 L169 121 Q154 128 146 115 L151 84 Q127 61 104 81 L109 117 Q97 127 86 119Z" fill="{accent}"/>'
    if style == "wave":
        return f'<path d="M94 76 Q94 47 127 49 Q165 48 162 82 Q174 93 164 104 Q173 116 164 132 L149 129 Q154 114 150 103 L153 79 Q127 59 103 79 Q107 96 104 110 Q110 120 107 131 L91 129 Q86 111 92 101 Q84 89 94 76Z" fill="{accent}"/>'
    if style == "long":
        return f'<path d="M94 76 Q92 46 128 48 Q166 49 162 79 L172 152 L149 151 L151 79 Q128 58 104 79 L106 151 L83 152Z" fill="{accent}"/>'
    if style == "bun":
        return f'<circle cx="168" cy="75" r="18" fill="{accent}"/><path d="M94 83 Q93 50 128 51 Q156 52 163 78 Q143 64 128 66 Q109 63 94 83Z" fill="{accent}"/>'
    if style == "side":
        return f'<path d="M92 82 Q97 48 129 51 Q158 50 164 76 Q147 62 120 70 Q106 76 92 82Z" fill="{accent}"/>'
    raise ValueError(style)


def accessory(kind: str, accent: str) -> str:
    tie = f'<path d="M120 156 L136 156 L134 170 L142 205 L128 218 L114 205 L122 170Z" fill="{accent}"/>'
    glasses = f'<g fill="none" stroke="{accent}" stroke-width="3"><circle cx="113" cy="96" r="12"/><circle cx="143" cy="96" r="12"/><path d="M125 95 L131 95 M100 94 L91 91 M155 94 L165 91"/></g>'
    lapels = f'<path d="M104 150 L128 182 L152 150 M88 166 L112 196 M168 166 L144 196" fill="none" stroke="{accent}" stroke-width="4" stroke-linecap="round"/>'
    epaulettes = f'<path d="M57 168 L93 162 L96 171 L60 177Z M163 162 L199 168 L196 177 L160 171Z" fill="{accent}"/><circle cx="89" cy="167" r="3.5" fill="{LIGHT}"/><circle cx="167" cy="167" r="3.5" fill="{LIGHT}"/>'
    cap = f'<path d="M88 72 Q128 38 168 72 L165 85 L91 85Z" fill="{accent}"/><path d="M87 85 Q128 76 169 85 L174 93 Q128 101 82 93Z" fill="{INK}" stroke="{accent}" stroke-width="3"/><circle cx="128" cy="72" r="5" fill="{LIGHT}"/>'
    if kind == "tie":
        return lapels + tie
    if kind == "father":
        return glasses + lapels + tie + f'<circle cx="92" cy="191" r="9" fill="{accent}"/><circle cx="92" cy="191" r="4" fill="{LIGHT}"/>'
    if kind == "officer":
        return cap + epaulettes + f'<path d="M128 152 L128 223" stroke="{accent}" stroke-width="5"/><circle cx="128" cy="182" r="4" fill="{LIGHT}"/><circle cx="128" cy="203" r="4" fill="{LIGHT}"/>'
    if kind == "accountant":
        return glasses + lapels + f'<circle cx="91" cy="195" r="10" fill="none" stroke="{accent}" stroke-width="3"/><path d="M91 188 L91 202" stroke="{accent}" stroke-width="3"/>'
    if kind == "industrial":
        return lapels + tie + f'<path d="M86 190 L98 190 L98 201 L86 201Z M89 190 L89 184 L95 184 L95 190" fill="{accent}"/>'
    if kind == "scarf":
        return f'<path d="M101 149 Q128 174 155 149 L162 177 Q128 194 94 177Z" fill="{accent}"/><path d="M138 180 L148 217" stroke="{accent}" stroke-width="12" stroke-linecap="round"/>'
    if kind == "police":
        return cap + lapels + f'<circle cx="114" cy="179" r="4" fill="{accent}"/><circle cx="140" cy="179" r="4" fill="{accent}"/><circle cx="114" cy="199" r="4" fill="{accent}"/><circle cx="140" cy="199" r="4" fill="{accent}"/>'
    if kind == "lawyer":
        return glasses + lapels + f'<path d="M90 194 L104 194 M97 182 L97 205 M84 206 L110 206" stroke="{accent}" stroke-width="3"/><circle cx="97" cy="184" r="4" fill="{accent}"/>'
    if kind == "folder":
        return lapels + tie + f'<path d="M164 182 L190 178 L194 219 L167 222Z" fill="{accent}" opacity="0.8"/><path d="M169 190 L186 188" stroke="{LIGHT}" stroke-width="3"/>'
    if kind == "beret":
        return epaulettes + f'<path d="M91 74 Q107 48 143 57 Q171 57 174 78 L156 84 L96 84Z" fill="{accent}"/><path d="M96 85 L161 85" stroke="{LIGHT}" stroke-width="3"/><circle cx="126" cy="190" r="12" fill="none" stroke="{accent}" stroke-width="4"/>'
    if kind == "general":
        return cap + epaulettes + f'<path d="M109 113 Q120 107 128 115 Q136 107 147 113 Q138 127 128 119 Q118 127 109 113Z" fill="{accent}"/><rect x="107" y="185" width="42" height="8" rx="2" fill="{accent}"/><path d="M120 185 L120 193 M135 185 L135 193" stroke="{LIGHT}" stroke-width="3"/>'
    if kind == "diplomat":
        return lapels + f'<circle cx="128" cy="178" r="8" fill="{accent}"/><path d="M128 168 L128 188 M118 178 L138 178" stroke="{LIGHT}" stroke-width="2"/>'
    if kind == "western":
        return glasses + lapels + f'<path d="M128 154 L128 215" stroke="{accent}" stroke-width="11"/><circle cx="91" cy="190" r="5" fill="{accent}"/>'
    if kind == "energy":
        return f'<path d="M100 151 L128 178 L156 151" fill="none" stroke="{accent}" stroke-width="9"/><path d="M95 186 Q104 174 112 187 Q104 198 95 186Z" fill="{accent}"/><circle cx="103" cy="186" r="4" fill="{LIGHT}"/>'
    if kind == "necklace":
        return f'<path d="M103 153 Q128 194 153 153" fill="none" stroke="{accent}" stroke-width="5"/><circle cx="128" cy="187" r="8" fill="{accent}"/>'
    if kind == "chef":
        return f'<path d="M94 69 Q85 57 97 45 Q99 28 117 30 Q128 23 140 31 Q159 28 162 45 Q174 56 163 69Z" fill="{LIGHT}" stroke="{accent}" stroke-width="4"/><rect x="96" y="66" width="65" height="17" fill="{LIGHT}" stroke="{accent}" stroke-width="3"/><path d="M90 166 L166 166 L157 227 L99 227Z" fill="{LIGHT}"/><path d="M127 174 L127 218" stroke="{accent}" stroke-width="5"/>'
    if kind == "doctor":
        return glasses + f'<path d="M99 154 L118 174 L104 223 L72 233 M157 154 L138 174 L152 223 L184 233" fill="none" stroke="{LIGHT}" stroke-width="15"/><path d="M114 166 Q108 203 128 204 Q148 203 142 166" fill="none" stroke="{accent}" stroke-width="5"/><circle cx="128" cy="208" r="8" fill="{accent}"/>'
    if kind == "chair":
        return glasses + lapels + f'<path d="M88 191 L100 191 L100 201 L88 201Z" fill="{accent}"/><path d="M91 190 L91 185 L97 185 L97 190" stroke="{accent}" stroke-width="3"/>'
    if kind == "journalist":
        return lapels + f'<path d="M91 86 Q91 50 128 50 Q165 50 165 86" fill="none" stroke="{accent}" stroke-width="6"/><rect x="84" y="88" width="10" height="22" rx="4" fill="{accent}"/><rect x="162" y="88" width="10" height="22" rx="4" fill="{accent}"/><path d="M165 108 Q161 122 146 124" fill="none" stroke="{accent}" stroke-width="3"/><circle cx="146" cy="124" r="4" fill="{accent}"/><rect x="177" y="185" width="25" height="34" rx="2" fill="{LIGHT}" transform="rotate(11 177 185)"/>'
    if kind == "governor":
        return f'<path d="M102 153 Q128 170 154 153" fill="none" stroke="{accent}" stroke-width="10"/><path d="M83 189 L98 183 L112 190 L106 205 L88 205Z" fill="{accent}"/><path d="M96 186 L96 201" stroke="{LIGHT}" stroke-width="3"/>'
    raise ValueError(kind)


def sprite(character: Character, index: int) -> str:
    x = (index % COLUMNS) * CELL
    y = (index // COLUMNS) * CELL
    accent = character.accent
    return (
        f'<g transform="translate({x} {y})">'
        f'<circle cx="128" cy="112" r="78" fill="{accent}" opacity="0.13"/>'
        f'<path d="M30 233 C33 193 52 164 77 148 C91 144 103 140 114 140 L142 140 C153 140 165 144 179 148 C204 164 223 193 226 233 Z" fill="{INK}"/>'
        f'<rect x="115" y="111" width="26" height="32" fill="{INK}"/>'
        f'<circle cx="128" cy="91" r="35" fill="{INK}"/>'
        f'{hair(character.hair, accent)}'
        f'{accessory(character.detail, accent)}'
        '</g>'
    )


def main() -> None:
    assert len(CHARACTERS) == 24
    OUTPUT.mkdir(parents=True, exist_ok=True)
    width = COLUMNS * CELL
    height = (len(CHARACTERS) // COLUMNS) * CELL
    header = f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">'
    sheet = header + ''.join(sprite(character, index) for index, character in enumerate(CHARACTERS)) + '</svg>'
    (OUTPUT / 'characters.svg').write_text(sheet, encoding='utf-8')
    manifest = [
        {'id': item.key, 'name': item.name, 'index': index, 'column': index % COLUMNS, 'row': index // COLUMNS, 'detail': item.description}
        for index, item in enumerate(CHARACTERS)
    ]
    (OUTPUT / 'characters_manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    preview = [header, '<rect width="100%" height="100%" fill="#e8dfcb"/>']
    for index, item in enumerate(CHARACTERS):
        x = (index % COLUMNS) * CELL
        y = (index // COLUMNS) * CELL
        preview.append(f'<rect x="{x + 5}" y="{y + 5}" width="246" height="246" rx="16" fill="#eee6d5" stroke="#b9ad94"/>')
        preview.append(sprite(item, index))
        preview.append(f'<text x="{x + 128}" y="{y + 249}" text-anchor="middle" font-family="sans-serif" font-size="15" fill="#202328">{escape(item.name)}</text>')
    preview.append('</svg>')
    (OUTPUT / 'characters_preview.svg').write_text(''.join(preview), encoding='utf-8')
    rows = []
    for start in range(0, len(CHARACTERS), COLUMNS):
        rows.append('| ' + ' | '.join(item.name for item in CHARACTERS[start:start + COLUMNS]) + ' |')
    readme = '\n'.join([
        '# Персонажи',
        '',
        'Общий прозрачный спрайт-лист: `characters.png` (1536 × 1024). Каждая ячейка — 256 × 256 пикселей; отсчёт идёт слева направо, сверху вниз.',
        '',
        '![Силуэты персонажей](characters_preview.png)',
        '',
        '| 1 | 2 | 3 | 4 | 5 | 6 |',
        '|---|---|---|---|---|---|',
        *rows,
        '',
        'Описание деталей и номера ячеек находятся в `characters_manifest.json`. Для просмотра на светлом фоне откройте `characters_preview.svg`.',
        '',
        'Чтобы изменить персонажа, отредактируйте его запись или детали в `tools/build_character_sprites.py`, затем выполните `python tools/build_character_sprites.py` и запустите Godot со скриптом `res://tools/render_character_sprites.gd`.',
        '',
    ])
    (OUTPUT / 'README.md').write_text(readme, encoding='utf-8')
    print(f'Generated {len(CHARACTERS)} portraits in {COLUMNS} columns.')


if __name__ == '__main__':
    main()
