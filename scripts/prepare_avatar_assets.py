#!/usr/bin/env python3
"""Lossless mesh/UV GLB preparation: convert embedded WebP textures to PNG.

Preserves all geometry buffers, UVs, nodes, transforms and material references.
Visual review of the original scan is a separate P0 acceptance gate.
"""
import hashlib
import io
import json
import struct
from pathlib import Path
from PIL import Image

SOURCES = {
    "model_1791878457744.glb": "pyincc_avatar_primary.glb",
    "model_1791877892370.glb": "pyincc_avatar_alternate.glb",
}

def unpack(data):
    if data[:4] != b"glTF" or len(data) < 20 or struct.unpack_from("<I", data, 8)[0] != len(data):
        raise ValueError("invalid GLB header")
    offset = 12
    chunks = []
    while offset < len(data):
        length, kind = struct.unpack_from("<II", data, offset)
        offset += 8
        if offset + length > len(data):
            raise ValueError("invalid GLB chunk length")
        chunks.append((kind, data[offset:offset + length]))
        offset += length
    if len(chunks) != 2 or chunks[0][0] != 0x4E4F534A or chunks[1][0] != 0x004E4942:
        raise ValueError("expected JSON + BIN GLB")
    return json.loads(chunks[0][1]), bytearray(chunks[1][1])

def pack(doc, binary):
    js = json.dumps(doc, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    js += b" " * (-len(js) % 4)
    binary += b"\x00" * (-len(binary) % 4)
    size = 12 + 8 + len(js) + 8 + len(binary)
    return b"glTF" + struct.pack("<II", 2, size) + struct.pack("<II", len(js), 0x4E4F534A) + js + struct.pack("<II", len(binary), 0x004E4942) + binary

def prepare(root):
    dest = root / "assets" / "avatars"
    dest.mkdir(parents=True, exist_ok=True)
    for source_name, target in SOURCES.items():
        path = root / source_name
        if not path.is_file():
            raise RuntimeError(f"P0 FAIL: missing source {source_name}")
        source_doc, source_bin = unpack(path.read_bytes())
        doc, binary = unpack(path.read_bytes())
        meshes = doc.get("meshes", [])
        if not meshes or not all("TEXCOORD_0" in p.get("attributes", {}) for m in meshes for p in m["primitives"]):
            raise RuntimeError(f"P0 FAIL: UV missing {source_name}")
        images = doc.get("images", [])
        if not images or not doc.get("textures"):
            raise RuntimeError(f"P0 FAIL: source images missing {source_name}")
        for image in images:
            view = doc["bufferViews"][image["bufferView"]]
            begin = view.get("byteOffset", 0)
            payload = bytes(source_bin[begin:begin + view["byteLength"]])
            if image.get("mimeType") == "image/webp":
                with Image.open(io.BytesIO(payload)) as im:
                    out = io.BytesIO()
                    im.save(out, format="PNG")
                    payload = out.getvalue()
                image["mimeType"] = "image/png"
                binary += b"\x00" * (-len(binary) % 4)
                view["byteOffset"] = len(binary)
                view["byteLength"] = len(payload)
                binary.extend(payload)
            elif image.get("mimeType") != "image/png":
                raise RuntimeError(f"P0 FAIL: unsupported image type {image.get('mimeType')}")
        # EXT_texture_webp stores its image index under extensions, not
        # texture.source. Migrate references before dropping the extension.
        for texture in doc["textures"]:
            extensions = texture.get("extensions", {})
            webp = extensions.pop("EXT_texture_webp", None)
            if webp is not None:
                source = webp.get("source")
                if not isinstance(source, int) or not 0 <= source < len(images):
                    raise RuntimeError(f"P0 FAIL: invalid WebP texture reference {source_name}")
                texture["source"] = source
            if not extensions:
                texture.pop("extensions", None)
            source = texture.get("source")
            if not isinstance(source, int) or not 0 <= source < len(images):
                raise RuntimeError(f"P0 FAIL: texture source unresolved {source_name}")
        doc["buffers"][0]["byteLength"] = len(binary)
        doc["extensionsRequired"] = [x for x in doc.get("extensionsRequired", []) if x != "EXT_texture_webp"]
        doc["extensionsUsed"] = [x for x in doc.get("extensionsUsed", []) if x != "EXT_texture_webp"]
        if not doc["extensionsRequired"]:
            doc.pop("extensionsRequired", None)
        if not doc["extensionsUsed"]:
            doc.pop("extensionsUsed", None)
        output = dest / target
        output.write_bytes(pack(doc, binary))
        verify, _ = unpack(output.read_bytes())
        if verify["meshes"] != source_doc["meshes"] or verify.get("nodes") != source_doc.get("nodes") or verify.get("accessors") != source_doc.get("accessors"):
            raise RuntimeError(f"P0 FAIL: geometry changed {target}")
        if any(t.get("source") is None or "EXT_texture_webp" in t.get("extensions", {}) for t in verify["textures"]):
            raise RuntimeError(f"P0 FAIL: invalid PNG texture references {target}")
        if "EXT_texture_webp" in verify.get("extensionsUsed", []) or "EXT_texture_webp" in verify.get("extensionsRequired", []):
            raise RuntimeError(f"P0 FAIL: stale WebP extension {target}")
        if any(im.get("mimeType") != "image/png" for im in verify["images"]):
            raise RuntimeError(f"P0 FAIL: texture conversion {target}")
        print(f"ASSET_STRUCTURAL_PASS {target} bytes={output.stat().st_size} images={len(images)} sha256={hashlib.sha256(output.read_bytes()).hexdigest()}")
if __name__ == "__main__":
    prepare(Path("."))
