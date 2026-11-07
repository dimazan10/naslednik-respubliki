"""Build an original 55-second trailer arrangement from the game's own theme.

The only source recording is audio/variants/music_03_documents.wav, composed
for this project. New percussion, drones, brass, and risers are synthesized
here with the Python standard library. No third-party samples are used.
"""

from array import array
from math import cos, exp, pi, sin, sqrt, tanh
from pathlib import Path
import random
import wave


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "audio" / "variants" / "music_03_documents.wav"
OUTPUT = ROOT / "marketing" / "trailer_music_rising_tension_55s.wav"
RATE = 22050
DURATION = 55.0
COUNT = int(RATE * DURATION)
BEAT = 2.0 / 3.0  # 90 BPM, matching the game's 32-second theme.
MIX = array("f", [0.0]) * COUNT
RNG = random.Random(2642)


def clamp(x: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, x))


def ramp(t: float, a: float, b: float) -> float:
    return clamp((t - a) / (b - a), 0.0, 1.0)


def theme_gain(t: float) -> float:
    if t < 32.0:
        level = 0.32 + 0.31 * ramp(t, 3.0, 31.0)
        return level * ramp(t, 0.0, 1.5) * (1.0 - ramp(t, 31.8, 33.0))
    if t < 36.0:
        return 0.0
    if t < 51.0:
        return (0.48 + 0.19 * ramp(t, 36.0, 48.0)) * ramp(t, 36.0, 38.5) * (1.0 - ramp(t, 49.5, 51.0))
    return 0.0


def add_theme() -> None:
    with wave.open(str(SOURCE), "rb") as src:
        assert src.getframerate() == RATE and src.getnchannels() == 1 and src.getsampwidth() == 2
        raw = src.readframes(src.getnframes())
    theme = array("h")
    theme.frombytes(raw)
    length = len(theme)
    filtered = 0.0
    for i in range(COUNT):
        t = i / RATE
        sample = theme[i % length] / 32768.0
        # Darkened, restrained beginning; high frequencies open as tension grows.
        cutoff = 950.0 + 4500.0 * ramp(t, 4.0, 28.0)
        if t >= 36.0:
            cutoff = 6500.0
        alpha = clamp(2.0 * pi * cutoff / RATE, 0.0, 0.95)
        filtered += alpha * (sample - filtered)
        MIX[i] += filtered * theme_gain(t)


def midi_hz(note: int) -> float:
    return 440.0 * 2.0 ** ((note - 69) / 12.0)


def add_tone(start: float, duration: float, note: int, volume: float, voice: str) -> None:
    first = int(start * RATE)
    if first >= COUNT:
        return
    total = min(int(duration * RATE), COUNT - first)
    f = midi_hz(note)
    attack = 0.025 if voice == "brass" else 0.10 if voice == "drone" else 0.004
    release = 0.35 if voice == "drone" else 0.24 if voice == "brass" else 0.09
    for j in range(total):
        seconds = j / RATE
        envelope = min(1.0, seconds / attack, (total - j) / (RATE * release))
        phase = 2.0 * pi * f * seconds
        if voice == "brass":
            value = sin(phase) + 0.39 * sin(2 * phase) + 0.16 * sin(3 * phase)
            envelope *= 0.92 + 0.08 * sin(2 * pi * 4.1 * seconds)
        elif voice == "drone":
            value = sin(phase) + 0.19 * sin(2 * phase)
        else:
            value = sin(phase) + 0.35 * sin(2 * phase)
            envelope *= exp(-1.5 * seconds)
        MIX[first + j] += volume * envelope * value


def add_kick(t: float, volume: float) -> None:
    first = int(t * RATE)
    total = min(int(0.25 * RATE), COUNT - first)
    phase = 0.0
    for j in range(total):
        x = j / RATE
        freq = 58.0 + 78.0 * (1.0 - x / 0.25) ** 2
        phase += 2.0 * pi * freq / RATE
        MIX[first + j] += volume * (1.0 - x / 0.25) ** 2 * sin(phase)


def add_snare(t: float, volume: float) -> None:
    first = int(t * RATE)
    total = min(int(0.16 * RATE), COUNT - first)
    last = 0.0
    for j in range(total):
        x = j / total
        white = RNG.uniform(-1.0, 1.0)
        high = white - 0.80 * last
        last = white
        body = 0.20 * sin(2.0 * pi * 165.0 * j / RATE)
        MIX[first + j] += volume * (1.0 - x) ** 2 * (0.62 * high + body)


def add_tick(t: float, volume: float) -> None:
    first = int(t * RATE)
    total = min(int(0.035 * RATE), COUNT - first)
    last = 0.0
    for j in range(total):
        white = RNG.uniform(-1.0, 1.0)
        high = white - 0.91 * last
        last = white
        MIX[first + j] += volume * (1.0 - j / total) ** 2 * high


def add_riser(start: float, end: float, volume: float) -> None:
    first, last = int(start * RATE), int(end * RATE)
    low = 0.0
    for i in range(first, min(last, COUNT)):
        x = (i - first) / (last - first)
        low = 0.965 * low + 0.035 * RNG.uniform(-1.0, 1.0)
        flutter = sin(2 * pi * (2.0 + 6.0 * x) * (i / RATE))
        MIX[i] += volume * x * x * (0.62 * low + 0.38 * flutter)


def arrange() -> None:
    add_theme()

    # A clock-like pulse grows into a steady march; all hits stay on the grid.
    for beat in range(int(51.0 / BEAT)):
        t = beat * BEAT
        if 4.0 <= t < 32.0:
            add_tick(t, 0.010 + 0.018 * ramp(t, 4.0, 31.0))
        elif 36.0 <= t < 50.6:
            add_tick(t, 0.032)
        if 10.0 <= t < 32.0 and beat % 2 == 0:
            add_kick(t, 0.055 + 0.050 * ramp(t, 10.0, 30.0))
        if 20.0 <= t < 32.0 and beat % 4 in (1, 3):
            add_snare(t, 0.025 + 0.023 * ramp(t, 20.0, 31.0))
        if 36.0 <= t < 50.6:
            if beat % 2 == 0:
                add_kick(t, 0.13 + 0.035 * ramp(t, 36.0, 48.0))
            else:
                add_snare(t, 0.065 + 0.025 * ramp(t, 36.0, 48.0))

    # Low E pedal matches the original theme's recurring harmonic center.
    for t in (8, 12, 16, 20, 24, 28):
        add_tone(t, 3.7, 40, 0.018 + 0.020 * ramp(t, 8, 30), "drone")
    for t in (36, 40, 44, 48):
        add_tone(t, 3.7, 40, 0.048, "drone")
        add_tone(t, 3.5, 52, 0.018, "drone")

    # Restrained brass and repeated notes, intensifying after the siren gap.
    for t, note in ((18, 64), (20, 71), (22, 64), (24, 74), (26, 71), (28, 64), (30, 71)):
        add_tone(t, 0.42, note, 0.025 + 0.012 * ramp(t, 18, 30), "bell")
    for t in (22, 27.3, 36.5, 41.8, 47.2):
        add_tone(t, 1.65, 52, 0.027 if t < 32 else 0.065, "brass")
        add_tone(t, 1.55, 59, 0.010 if t < 32 else 0.029, "brass")
    for beat in range(54, 75):
        t = beat * BEAT
        if 36.0 <= t < 50.0 and beat % 2 == 1:
            add_tone(t, 0.24, 64 if beat % 4 == 1 else 71, 0.027, "bell")

    add_riser(28.0, 32.55, 0.090)
    add_riser(46.0, 50.8, 0.072)

    # Final title card: one emphatic minor chord and a clean decay.
    add_kick(50.8, 0.24)
    for note, vol in ((28, 0.090), (40, 0.072), (52, 0.055), (55, 0.038), (59, 0.033), (64, 0.026)):
        add_tone(50.8, 4.1, note, vol, "brass" if note >= 52 else "drone")


def save() -> None:
    peak = max(abs(x) for x in MIX)
    gain = min(1.0, 0.91 / peak) if peak else 1.0
    pcm = array("h")
    for i, value in enumerate(MIX):
        t = i / RATE
        master_fade = ramp(t, 0.0, 0.25) * (1.0 - ramp(t, 53.0, DURATION))
        shaped = tanh(value * gain * master_fade * 1.05)
        pcm.append(int(clamp(shaped, -1.0, 1.0) * 32767))
    with wave.open(str(OUTPUT), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(pcm.tobytes())
    rms = sqrt(sum((x / 32768.0) ** 2 for x in pcm) / len(pcm))
    print(f"{OUTPUT}\n{DURATION:.0f}s | peak={max(abs(x) for x in pcm)/32768:.3f} | rms={rms:.3f}")


if __name__ == "__main__":
    arrange()
    save()
