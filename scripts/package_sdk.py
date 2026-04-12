#!/usr/bin/env python3
from __future__ import annotations

import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "build"
RELEASE = BUILD / "sdk-release" / "mega-3dk-sdk-v4.7"


def copy_tree(src: Path, dst: Path) -> None:
    if not src.exists():
        return
    if src.is_dir():
        shutil.copytree(src, dst, dirs_exist_ok=True)
    else:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)


def main() -> None:
    if RELEASE.exists():
        shutil.rmtree(RELEASE)
    RELEASE.mkdir(parents=True, exist_ok=True)

    copy_tree(ROOT / "sdk" / "include", RELEASE / "include")
    copy_tree(ROOT / "sdk" / "src", RELEASE / "src")
    copy_tree(ROOT / "sdk" / "examples", RELEASE / "examples")
    copy_tree(ROOT / "docs" / "SDK.md", RELEASE / "docs" / "SDK.md")
    copy_tree(ROOT / "README.md", RELEASE / "README.md")

    rom_dir = BUILD / "rom"
    for rom_name in [
        "mega-3dk.bin",
        "mega-3dk-sdk-minimal.bin",
        "mega-3dk-sdk-multimesh.bin",
        "mega-3dk-sdk-template.bin",
    ]:
        copy_tree(rom_dir / rom_name, RELEASE / "roms" / rom_name)

    (RELEASE / "MANIFEST.txt").write_text(
        "\n".join(
            [
                "mega-3dk SDK package",
                "version: v4.7 snapshot",
                "contains: public headers, docs, examples, and demo ROMs",
            ]
        )
        + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
