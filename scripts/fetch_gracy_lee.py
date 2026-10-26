#!/usr/bin/env python3
"""Fetch the owner-provided Drive ZIP and stage only the pinned Gracy Lee GLB.

This verifies source identity and GLB structure. Rights are separately recorded
in config/avatar-asset.json and docs/THIRD_PARTY_ASSETS.md. No fallback model.
"""
from io import BytesIO
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.parse import urlencode
from zipfile import ZipFile, BadZipFile
import hashlib
import json
import os
import struct
import sys
import tempfile

FILE_ID = "14A5sSxNTRgyK7MdlykIRen9OtwXLVOdF"
EXPECTED_ZIP_SIZE = 2934844
EXPECTED_ZIP_SHA256 = "ce4e222ae6f759f99ab3d0a0b5211033aa0f1d479c037adcb1f6428364611677"
EXPECTED_SIZE = 3291488
EXPECTED_SHA256 = "cba9ea4f3db8961609fdb4ef6fda33b9a7af818cea3e65f534a37047d0f5f2dc"
DEST = Path("assets/avatars/pyincc_avatar_primary.glb")
MAX_ZIP_BYTES = 10 * 1024 * 1024

def sha256(data):
    return hashlib.sha256(data).hexdigest()

def extract_verified_glb(archive_bytes):
    if len(archive_bytes) != EXPECTED_ZIP_SIZE or sha256(archive_bytes) != EXPECTED_ZIP_SHA256:
        raise ValueError("Drive ZIP size/SHA256 mismatch")
    try:
        with ZipFile(BytesIO(archive_bytes)) as z:
            entries = [i for i in z.infolist() if not i.is_dir()]
            if len(entries) != 1 or entries[0].filename != "gracy_lee.glb":
                raise ValueError("ZIP must contain exactly gracy_lee.glb")
            if entries[0].file_size != EXPECTED_SIZE or entries[0].file_size > 128 * 1024 * 1024:
                raise ValueError("GLB uncompressed size mismatch")
            data = z.read(entries[0])
    except BadZipFile as exc:
        raise ValueError("Drive did not return the expected ZIP archive") from exc
    if len(data) != EXPECTED_SIZE or sha256(data) != EXPECTED_SHA256:
        raise ValueError("Gracy Lee GLB size/SHA256 mismatch")
    if len(data) < 12 or data[:4] != b"glTF":
        raise ValueError("downloaded file is not GLB")
    version, declared_length = struct.unpack_from("<II", data, 4)
    if version != 2 or declared_length != len(data):
        raise ValueError("GLB header/version/length invalid")
    length, kind = struct.unpack_from("<II", data, 12)
    if kind != 0x4E4F534A or 20 + length > len(data):
        raise ValueError("GLB JSON chunk invalid")
    doc = json.loads(data[20:20 + length].decode("utf-8").rstrip(" \t\r\n\0"))
    extras = doc.get("asset", {}).get("extras", {})
    if extras.get("title") != "Gracy Lee" or "hong227" not in extras.get("author", ""):
        raise ValueError("GLB embedded attribution does not match selected Gracy Lee model")
    if "CC-BY-4.0" not in extras.get("license", ""):
        raise ValueError("GLB does not declare CC-BY-4.0")
    return data

def main():
    url = "https://drive.google.com/uc?" + urlencode({"export": "download", "id": FILE_ID})
    request = Request(url, headers={"User-Agent": "PYINCC-FashionAI-Asset-Verification/1.0"})
    with urlopen(request, timeout=60) as response:
        archive = response.read(MAX_ZIP_BYTES + 1)
    if len(archive) > MAX_ZIP_BYTES:
        raise SystemExit("Drive ZIP exceeds safety size limit")
    try:
        data = extract_verified_glb(archive)
    except (ValueError, OSError, json.JSONDecodeError) as exc:
        raise SystemExit("GRACY_ASSET_BLOCKED: " + str(exc)) from exc
    DEST.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=DEST.parent, suffix=".tmp")
    try:
        with os.fdopen(fd, "wb") as out:
            out.write(data)
        os.replace(tmp, DEST)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)
    print(f"GRACY_ASSET_SOURCE_VERIFIED path={DEST} bytes={len(data)} sha256={EXPECTED_SHA256}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
