"""Cut the selected CC0 Sumy air-raid siren for the first invasion report.

Source: KVV_Audio, https://freesound.org/people/KVV_Audio/sounds/727588/
The public high-quality preview carries the same CC0 sound as the original.
"""

from __future__ import annotations

import subprocess
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "build" / "sumy_siren_source_hq.mp3"
OUTPUT = ROOT / "audio" / "cc0" / "war_siren_sumy.wav"
SOURCE_URL = "https://cdn.freesound.org/previews/727/727588_12846320-hq.mp3"


def main() -> None:
    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    if not SOURCE.exists():
        urllib.request.urlretrieve(SOURCE_URL, SOURCE)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
            "-ss", "18.5", "-t", "5.1", "-i", str(SOURCE),
            "-af", "highpass=f=130,lowpass=f=4500,volume=2.0,afade=t=in:st=0:d=0.12,afade=t=out:st=3.8:d=1.3",
            "-ar", "44100", "-ac", "2", "-c:a", "pcm_s16le", str(OUTPUT),
        ],
        check=True,
    )
    print(OUTPUT)


if __name__ == "__main__":
    main()
