#!/usr/bin/env python3
"""Fetch the owner-supplied Gracy Lee GLB from Drive, verifying exact bytes.

This is an asset acquisition step only. It does NOT approve redistribution,
change the rights gate, or declare an Android visual test successful.
"""
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.parse import urlencode
import hashlib
import os
import sys
import tempfile

FILE_ID = "14A5sSxNTRgyK7MdlykIRen9OtwXLVOdF"
EXPECTED_SIZE = 3291488
EXPECTED_SHA256 = "cba9ea4f3db8961609fdb4ef6fda33b9a7af818cea3e65f534a37047d0f5f2dc"
DEST = Path("assets/avatars/pyincc_avatar_primary.glb")

def main():
    if DEST.exists():
        data = DEST.read_bytes()
        if len(data) == EXPECTED_SIZE and hashlib.sha256(data).hexdigest() == EXPECTED_SHA256:
            print("Gracy Lee asset already present; hash verified")
            return 0
        raise SystemExit("Existing primary GLB differs from owner-approved file; refusing overwrite")
    url = "https://drive.google.com/uc?" + urlencode({"export": "download", "id": FILE_ID})
    request = Request(url, headers={"User-Agent": "PYINCC-FashionAI-Asset-Verification/1.0"})
    with urlopen(request, timeout=45) as response:
        content_type = response.headers.get("Content-Type", "")
        if "text/html" in content_type:
            raise SystemExit("Google Drive returned HTML rather than binary GLB; download not verified")
        data = response.read(EXPECTED_SIZE + 1)
    if len(data) != EXPECTED_SIZE:
        raise SystemExit(f"GLB byte-size mismatch: {len(data)} != {EXPECTED_SIZE}")
    if hashlib.sha256(data).hexdigest() != EXPECTED_SHA256:
        raise SystemExit("GLB SHA256 mismatch; refusing unverified source")
    if data[:4] != b"glTF":
        raise SystemExit("Downloaded file is not a GLB")
    DEST.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=DEST.parent, suffix=".tmp")
    try:
        with os.fdopen(fd, "wb") as out:
            out.write(data)
        os.replace(tmp, DEST)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)
    print(f"VERIFIED_SOURCE_ONLY {DEST}: {EXPECTED_SHA256}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
