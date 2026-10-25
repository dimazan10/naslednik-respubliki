"""Generate the original placeholder audio library used by the prototype.

The sounds are deliberately synthetic and contain no third-party samples.  Run
this script again after changing a recipe to rebuild audio/variants/*.wav.
"""

from __future__ import annotations

import math
import random
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "audio" / "variants"
SFX_RATE = 44_100
MUSIC_RATE = 22_050


def clamp(value: float, low: float = -1.0, high: float = 1.0) -> float:
    return max(low, min(high, value))


def normalize(samples: list[float], peak: float = 0.86) -> list[float]:
    maximum = max((abs(sample) for sample in samples), default=1.0)
    scale = peak / maximum if maximum > peak else 1.0
    return [sample * scale for sample in samples]


def normalize_music(samples: list[float], peak: float = 0.86) -> list[float]:
    """Bring quiet music up to its target peak instead of only preventing clipping."""
    maximum = max((abs(sample) for sample in samples), default=1.0)
    scale = peak / maximum if maximum > 0.0 else 1.0
    return [sample * scale for sample in samples]


def write_wav(name: str, samples: list[float], rate: int) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    pcm = bytearray()
    for sample in normalize(samples):
        pcm.extend(int(clamp(sample) * 32767).to_bytes(2, "little", signed=True))
    with wave.open(str(OUT / name), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(rate)
        target.writeframes(pcm)


def read_wav(name: str) -> tuple[list[float], int]:
    with wave.open(str(OUT / name), "rb") as source:
        rate = source.getframerate()
        frames = source.readframes(source.getnframes())
    samples = [int.from_bytes(frames[index:index + 2], "little", signed=True) / 32767.0 for index in range(0, len(frames), 2)]
    return samples, rate


def build_pack_preview(number: int) -> None:
    parts: list[float] = []
    gap = [0.0] * int(SFX_RATE * 0.34)
    for category in ("page", "hover", "click", "report", "decision", "warning", "week", "ending", "war_start", "protest"):
        samples, rate = read_wav(f"{category}_{number:02d}.wav")
        if rate != SFX_RATE:
            raise ValueError(f"Unexpected preview rate for {category}: {rate}")
        limit = int(SFX_RATE * 2.2) if category in ("war_start", "protest") else len(samples)
        parts.extend(samples[:limit])
        parts.extend(gap)
    write_wav(f"sound_pack_{number:02d}_preview.wav", parts, SFX_RATE)


def filtered_noise(count: int, rng: random.Random, smoothing: float) -> list[float]:
    value = 0.0
    result: list[float] = []
    for _ in range(count):
        value = value * smoothing + rng.uniform(-1.0, 1.0) * (1.0 - smoothing)
        result.append(value)
    return result


def paper(seed: int, duration: float, weight: float, turns: int) -> list[float]:
    rng = random.Random(seed)
    count = int(duration * SFX_RATE)
    fine = filtered_noise(count, rng, 0.72)
    coarse = filtered_noise(count, rng, 0.965)
    samples = [0.0] * count
    centers = [duration * (0.22 + 0.56 * index / max(1, turns - 1)) for index in range(turns)]
    for index in range(count):
        t = index / SFX_RATE
        envelope = 0.0
        for center in centers:
            distance = abs(t - center)
            envelope += math.exp(-distance * (22.0 + weight * 8.0))
        edge = min(1.0, t * 55.0, (duration - t) * 38.0)
        scrape = math.sin(2.0 * math.pi * (94.0 + 38.0 * t) * t) * coarse[index]
        samples[index] = edge * envelope * (fine[index] * (0.72 + weight * 0.18) + scrape * 0.55)
    return samples


def mechanical(seed: int, duration: float, pitch: float, wood: float) -> list[float]:
    rng = random.Random(seed)
    count = int(duration * SFX_RATE)
    noise = filtered_noise(count, rng, 0.45)
    samples: list[float] = []
    for index in range(count):
        t = index / SFX_RATE
        decay = math.exp(-t * (34.0 - wood * 8.0))
        tone = math.sin(2 * math.pi * pitch * t) + 0.45 * math.sin(2 * math.pi * pitch * 1.93 * t)
        samples.append(decay * (tone * (0.42 + wood * 0.18) + noise[index] * 0.52))
    return samples


def stamp(seed: int, duration: float, pitch: float, paper_mix: float) -> list[float]:
    impact = mechanical(seed, duration, pitch, 0.9)
    rustle = paper(seed + 100, duration, 0.7, 2)
    return [impact[index] * 0.88 + rustle[index] * paper_mix for index in range(len(impact))]


def chirp(duration: float, start: float, end: float, amplitude: float = 0.7) -> list[float]:
    count = int(duration * SFX_RATE)
    samples: list[float] = []
    for index in range(count):
        t = index / SFX_RATE
        progress = index / max(1, count - 1)
        frequency = start + (end - start) * progress
        envelope = min(1.0, progress * 30.0) * (1.0 - progress) ** 2.6
        samples.append(math.sin(2 * math.pi * frequency * t) * envelope * amplitude)
    return samples


def warning(seed: int, duration: float, base: float) -> list[float]:
    rng = random.Random(seed)
    count = int(duration * SFX_RATE)
    noise = filtered_noise(count, rng, 0.985)
    samples: list[float] = []
    for index in range(count):
        t = index / SFX_RATE
        progress = index / max(1, count - 1)
        envelope = math.sin(math.pi * progress) ** 0.65
        pulse = 0.72 + 0.28 * math.sin(2 * math.pi * 4.0 * t)
        tone = math.sin(2 * math.pi * base * t) + 0.35 * math.sin(2 * math.pi * base * 1.49 * t)
        samples.append(envelope * pulse * (tone * 0.48 + noise[index] * 0.44))
    return samples


def calendar(seed: int, duration: float, bell: float) -> list[float]:
    rustle = paper(seed, duration, 0.8, 3)
    samples = rustle[:]
    for index in range(len(samples)):
        t = index / SFX_RATE
        if t > duration * 0.46:
            local = t - duration * 0.46
            samples[index] += math.exp(-local * 5.2) * (
                math.sin(2 * math.pi * bell * local) * 0.38
                + math.sin(2 * math.pi * bell * 1.5 * local) * 0.19
            )
    return samples


def ending(duration: float, root: float, falling: bool) -> list[float]:
    count = int(duration * SFX_RATE)
    intervals = (1.0, 1.2, 1.5) if not falling else (1.0, 1.1892, 1.4142)
    samples: list[float] = []
    for index in range(count):
        t = index / SFX_RATE
        progress = index / max(1, count - 1)
        envelope = min(1.0, progress * 8.0) * (1.0 - progress) ** 1.3
        tone = sum(math.sin(2 * math.pi * root * interval * t) for interval in intervals) / len(intervals)
        samples.append(tone * envelope * 0.75)
    return samples


def explosion_layer(samples: list[float], time: float, strength: float, seed: int) -> None:
    rng = random.Random(seed)
    start = int(time * SFX_RATE)
    length = min(len(samples) - start, int(1.45 * SFX_RATE))
    noise = filtered_noise(length, rng, 0.86)
    for offset in range(max(0, length)):
        t = offset / SFX_RATE
        envelope = math.exp(-t * 3.7)
        rumble = math.sin(2 * math.pi * (42.0 - 8.0 * min(t, 1.0)) * t)
        crack = noise[offset] * math.exp(-t * 9.0)
        samples[start + offset] += strength * envelope * (rumble * 0.72 + crack * 2.2)


def war_start(seed: int, density: int) -> list[float]:
    duration = 4.2
    samples = [0.0] * int(duration * SFX_RATE)
    times = [0.18, 1.45, 2.85, 3.45][:density]
    for index, time in enumerate(times):
        explosion_layer(samples, time, 1.0 - index * 0.12, seed + index)
    rng = random.Random(seed + 90)
    wind = filtered_noise(len(samples), rng, 0.992)
    for index in range(len(samples)):
        samples[index] += wind[index] * 0.16
    return samples


def protest(seed: int, duration: float, tempo: float, intensity: float) -> list[float]:
    rng = random.Random(seed)
    count = int(duration * SFX_RATE)
    murmur = filtered_noise(count, rng, 0.985)
    rough = filtered_noise(count, rng, 0.72)
    voices = [rng.uniform(125.0, 245.0) for _ in range(9)]
    phases = [rng.uniform(0.0, math.tau) for _ in voices]
    samples: list[float] = []
    for index in range(count):
        t = index / SFX_RATE
        progress = index / max(1, count - 1)
        edge = min(1.0, progress * 8.0, (1.0 - progress) * 8.0)
        chant = max(0.0, math.sin(2 * math.pi * tempo * t)) ** 3
        vocal = sum(math.sin(2 * math.pi * frequency * t + phases[pos]) for pos, frequency in enumerate(voices)) / len(voices)
        samples.append(edge * intensity * (murmur[index] * 1.9 + rough[index] * 0.34 + vocal * (0.16 + chant * 0.22)))
    return samples


def soft_clip(value: float) -> float:
    return math.tanh(value)


def music_loop(theme: int, duration: float = 32.0) -> list[float]:
    rate = MUSIC_RATE
    count = int(duration * rate)
    rng = random.Random(9100 + theme)
    # Frequencies are snapped to whole loop cycles to keep continuous drones seamless.
    def snap(frequency: float) -> float:
        return round(frequency * duration) / duration

    # Keep the musical idea in the low register, but place its fundamental in
    # a range that ordinary laptop and monitor speakers can actually reproduce.
    # The previous 33-82 Hz-heavy mix mostly drove the limiter without becoming
    # audibly louder for the player.
    roots = [snap(146.84), snap(130.82), snap(164.82)]
    root = roots[theme - 1]
    samples: list[float] = []
    dust = filtered_noise(count, rng, 0.997)
    for index in range(count):
        t = index / rate
        bar = int(t // 4.0) % 4
        local = t % 4.0
        chord_shift = ([0, 3, -2, 5], [0, -2, 3, -4], [0, 5, 3, -2])[theme - 1][bar]
        chord_root = root * 2 ** (chord_shift / 12.0)
        drone = (
            math.sin(2 * math.pi * root * t) * 0.18
            + math.sin(2 * math.pi * snap(root / 2.0) * t) * 0.05
            + math.sin(2 * math.pi * snap(root * 2.0) * t) * 0.08
        )
        string = (
            math.sin(2 * math.pi * chord_root * t)
            + math.sin(2 * math.pi * chord_root * 1.1892 * t)
            + math.sin(2 * math.pi * chord_root * 1.4983 * t)
        ) / 3.0
        pad = string * (0.16 + 0.06 * math.sin(math.pi * local / 4.0))
        # The principal pad sits in the same register as the ambience, so a
        # loudness meter can report a strong signal while small speakers make
        # it practically disappear.  This restrained upper pad supplies the
        # 600-1600 Hz information that makes UI hover sounds clearly audible,
        # without turning the background score into a sequence of alerts.
        upper_pad = (
            math.sin(2 * math.pi * chord_root * 4.0 * t)
            + math.sin(2 * math.pi * chord_root * 4.7568 * t) * 0.72
            + math.sin(2 * math.pi * chord_root * 5.9932 * t) * 0.48
        ) / 2.2
        pad += upper_pad * (0.105 + 0.025 * math.sin(math.pi * local / 4.0))
        note = 0.0
        if theme == 1:
            for onset, degree in ((0.2, 2.0), (1.7, 2.378), (3.05, 2.997)):
                if local >= onset:
                    elapsed = local - onset
                    note += math.sin(2 * math.pi * chord_root * degree * elapsed) * math.exp(-elapsed * 2.7) * 0.22
        elif theme == 2:
            pulse = max(0.0, math.sin(2 * math.pi * 0.5 * t)) ** 5
            note = math.sin(2 * math.pi * chord_root * 2.0 * t) * pulse * 0.12
            pad *= 1.25
        else:
            tick_position = (t * 2.0) % 1.0
            tick = math.exp(-tick_position * 48.0)
            note = (
                math.sin(2 * math.pi * 980.0 * t) * 0.075
                + math.sin(2 * math.pi * 1470.0 * t) * 0.032
                + dust[index] * 0.10
            ) * tick
            # A restrained eight-note desk-piano motif makes the selected
            # theme recognisable as music from the very first second.  The
            # old version was measurable at full volume but consisted mostly
            # of a continuous drone, which listeners reasonably perceived as
            # silence or room tone.
            melody_step_length = 0.5
            melody_step = int(t / melody_step_length) % 16
            melody_local = t % melody_step_length
            melody_degrees = (
                1.0, 1.1892, 1.4983, 1.1892,
                1.0, 1.3348, 1.4983, 1.7818,
                1.4983, 1.1892, 1.0, 0.8909,
                1.0, 1.1892, 1.3348, 1.1892,
            )
            melody_frequency = chord_root * 3.0 * melody_degrees[melody_step]
            melody_envelope = (1.0 - math.exp(-melody_local * 55.0)) * math.exp(-melody_local * 5.2)
            melody_phase = 2 * math.pi * melody_frequency * melody_local
            melody = (
                math.sin(melody_phase)
                + math.sin(melody_phase * 2.0) * 0.32
                + math.sin(melody_phase * 3.0) * 0.11
            ) / 1.43
            note += melody * melody_envelope * 0.24
        samples.append(soft_clip(drone + pad + note + dust[index] * 0.055) * 0.72)
    # A very short zero crossing at the boundary prevents clicks while keeping the pause unobtrusive.
    fade = int(rate * 0.06)
    for index in range(fade):
        factor = math.sin((index / max(1, fade - 1)) * math.pi / 2.0)
        samples[index] *= factor
        samples[-1 - index] *= factor
    return samples


def main() -> None:
    for number, args in enumerate(((110, 0.31, 0.45, 2), (220, 0.42, 0.75, 3), (330, 0.55, 1.0, 4)), 1):
        write_wav(f"page_{number:02d}.wav", paper(*args), SFX_RATE)
    for number, (start, end) in enumerate(((760, 940), (520, 690), (900, 700)), 1):
        write_wav(f"hover_{number:02d}.wav", chirp(0.065, start, end, 0.42), SFX_RATE)
    for number, (pitch, wood) in enumerate(((180, 0.85), (265, 0.45), (120, 1.0)), 1):
        write_wav(f"click_{number:02d}.wav", mechanical(400 + number, 0.115, pitch, wood), SFX_RATE)
    for number, (pitch, mix) in enumerate(((92, 0.42), (128, 0.62), (74, 0.33)), 1):
        write_wav(f"report_{number:02d}.wav", stamp(500 + number, 0.32, pitch, mix), SFX_RATE)
    for number, (pitch, mix) in enumerate(((68, 0.24), (105, 0.44), (145, 0.58)), 1):
        write_wav(f"decision_{number:02d}.wav", stamp(600 + number, 0.28, pitch, mix), SFX_RATE)
    for number, base in enumerate((92.0, 116.0, 72.0), 1):
        write_wav(f"warning_{number:02d}.wav", warning(700 + number, 0.75, base), SFX_RATE)
    for number, bell in enumerate((392.0, 523.25, 329.63), 1):
        write_wav(f"week_{number:02d}.wav", calendar(800 + number, 0.95, bell), SFX_RATE)
    for number, (root, falling) in enumerate(((146.83, False), (130.81, True), (110.0, True)), 1):
        write_wav(f"ending_{number:02d}.wav", ending(1.65, root, falling), SFX_RATE)
    for number, density in enumerate((2, 3, 4), 1):
        write_wav(f"war_start_{number:02d}.wav", war_start(900 + number, density), SFX_RATE)
    for number, (tempo, intensity) in enumerate(((0.72, 0.72), (0.96, 0.82), (1.25, 0.90)), 1):
        write_wav(f"protest_{number:02d}.wav", protest(1000 + number, 5.4, tempo, intensity), SFX_RATE)
    for number, title in ((1, "cabinet"), (2, "cold_republic"), (3, "documents")):
        write_wav(f"music_{number:02d}_{title}.wav", normalize_music(music_loop(number)), MUSIC_RATE)
    for number in range(1, 4):
        build_pack_preview(number)
    print(f"Generated {len(list(OUT.glob('*.wav')))} WAV files in {OUT}")


if __name__ == "__main__":
    main()
