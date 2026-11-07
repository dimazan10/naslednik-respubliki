"""Recreate the game's 32-second original background music loop."""

from __future__ import annotations

import math
import random
import wave
from pathlib import Path


OUTPUT = Path(__file__).resolve().parents[1] / "audio" / "variants" / "music_03_documents.wav"
RATE = 22_050
DURATION = 32.0


def clamp(value: float) -> float:
    return max(-1.0, min(1.0, value))


def filtered_noise(count: int, rng: random.Random, smoothing: float) -> list[float]:
    value = 0.0
    result: list[float] = []
    for _ in range(count):
        value = value * smoothing + rng.uniform(-1.0, 1.0) * (1.0 - smoothing)
        result.append(value)
    return result


def music_loop() -> list[float]:
    count = int(DURATION * RATE)
    rng = random.Random(9103)

    def snap(frequency: float) -> float:
        return round(frequency * DURATION) / DURATION

    root = snap(164.82)
    dust = filtered_noise(count, rng, 0.997)
    samples: list[float] = []
    melody_degrees = (
        1.0, 1.1892, 1.4983, 1.1892,
        1.0, 1.3348, 1.4983, 1.7818,
        1.4983, 1.1892, 1.0, 0.8909,
        1.0, 1.1892, 1.3348, 1.1892,
    )
    for index in range(count):
        t = index / RATE
        bar = int(t // 4.0) % 4
        local = t % 4.0
        chord_root = root * 2 ** ((0, 5, 3, -2)[bar] / 12.0)
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
        upper_pad = (
            math.sin(2 * math.pi * chord_root * 4.0 * t)
            + math.sin(2 * math.pi * chord_root * 4.7568 * t) * 0.72
            + math.sin(2 * math.pi * chord_root * 5.9932 * t) * 0.48
        ) / 2.2
        pad += upper_pad * (0.105 + 0.025 * math.sin(math.pi * local / 4.0))
        tick_position = (t * 2.0) % 1.0
        tick = math.exp(-tick_position * 48.0)
        note = (
            math.sin(2 * math.pi * 980.0 * t) * 0.075
            + math.sin(2 * math.pi * 1470.0 * t) * 0.032
            + dust[index] * 0.10
        ) * tick
        melody_step_length = 0.5
        melody_step = int(t / melody_step_length) % 16
        melody_local = t % melody_step_length
        melody_frequency = chord_root * 3.0 * melody_degrees[melody_step]
        melody_envelope = (1.0 - math.exp(-melody_local * 55.0)) * math.exp(-melody_local * 5.2)
        melody_phase = 2 * math.pi * melody_frequency * melody_local
        melody = (
            math.sin(melody_phase)
            + math.sin(melody_phase * 2.0) * 0.32
            + math.sin(melody_phase * 3.0) * 0.11
        ) / 1.43
        note += melody * melody_envelope * 0.24
        samples.append(math.tanh(drone + pad + note + dust[index] * 0.055) * 0.72)
    fade = int(RATE * 0.06)
    for index in range(fade):
        factor = math.sin((index / max(1, fade - 1)) * math.pi / 2.0)
        samples[index] *= factor
        samples[-1 - index] *= factor
    return samples


def create_pcm() -> bytes:
    samples = music_loop()
    maximum = max((abs(sample) for sample in samples), default=1.0)
    scale = 0.86 / maximum if maximum > 0.0 else 1.0
    samples = [sample * scale for sample in samples]
    maximum = max((abs(sample) for sample in samples), default=1.0)
    scale = 0.86 / maximum if maximum > 0.86 else 1.0
    return b"".join(int(clamp(sample * scale) * 32767).to_bytes(2, "little", signed=True) for sample in samples)


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(RATE)
        target.writeframes(create_pcm())
    print(OUTPUT)


if __name__ == "__main__":
    main()
