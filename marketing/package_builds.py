"""Create itch.io ZIP files with correct executable permission on Linux."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parent
UPLOAD = ROOT / "itch_upload"
COMMON = [UPLOAD / "README.txt", UPLOAD / "SOUND_CREDITS.md"]


def package(platform, executable, output):
    binary = UPLOAD / platform / executable
    with ZipFile(UPLOAD / output, "w", compression=ZIP_DEFLATED, compresslevel=9) as archive:
        for path in [binary, *COMMON]:
            entry = ZipInfo(path.name)
            entry.compress_type = ZIP_DEFLATED
            entry.create_system = 3
            entry.external_attr = (0o100755 if platform == "linux" and path == binary else 0o100644) << 16
            archive.writestr(entry, path.read_bytes(), compress_type=ZIP_DEFLATED, compresslevel=9)


if __name__ == "__main__":
    package("windows", "Heir to the Republic.exe", "Heir_to_the_Republic_Beta_0.9.2_Windows.zip")
    package("linux", "HeirToTheRepublic.x86_64", "Heir_to_the_Republic_Beta_0.9.2_Linux.zip")
