#!/usr/bin/env python3
"""Prepare real GLBs preserving original mesh, UV and embedded textures.

This is a loss-minimizing preparation, NOT skin reconstruction or visual approval.
Do not alter or overwrite the original GLBs.
"""
import hashlib
import json
import struct
from pathlib import Path

import trimesh

SOURCES = {
    "model_1791878457744.glb": "pyincc_avatar_primary.glb",
    "model_1791877892370.glb": "pyincc_avatar_alternate.glb",
}

def prepare(root: Path):
    dest = root / "assets" / "avatars"
    dest.mkdir(parents=True, exist_ok=True)
    for name, target in SOURCES.items():
        source = root / name
        if not source.is_file():
            raise RuntimeError(f"P0 FAIL: missing source {name}")
        scene = trimesh.load(source, force="scene", process=False)
        if not scene.geometry:
            raise RuntimeError(f"P0 FAIL: no geometry in {name}")
        before = 0
        for mesh in scene.geometry.values():
            if not isinstance(mesh, trimesh.Trimesh) or len(mesh.faces) == 0:
                raise RuntimeError(f"P0 FAIL: invalid geometry in {name}")
            before += len(mesh.faces)
            uv = getattr(mesh.visual, "uv", None)
            if uv is None or len(uv) != len(mesh.vertices):
                raise RuntimeError(f"P0 FAIL: UV missing in {name}")
            if mesh.visual.kind != "texture":
                raise RuntimeError(f"P0 FAIL: texture visuals missing in {name}")
            if getattr(mesh.visual.material, "baseColorTexture", None) is None:
                raise RuntimeError(f"P0 FAIL: base color texture missing in {name}")
        # Keep the original UV and texture maps; never silently replace them
        # with a flat gray material. Visual skin review remains a separate gate.
        output = dest / target
        output.write_bytes(scene.export(file_type="glb"))
        data = output.read_bytes()
        if data[:4] != b"glTF" or struct.unpack_from("<I", data, 8)[0] != len(data):
            raise RuntimeError(f"P0 FAIL: invalid GLB {target}")
        json_len = struct.unpack_from("<I", data, 12)[0]
        gltf = json.loads(data[20:20 + json_len])
        if not gltf.get("images") or not gltf.get("textures"):
            raise RuntimeError(f"P0 FAIL: embedded texture lost in {target}")
        if not all("TEXCOORD_0" in p["attributes"] for m in gltf["meshes"] for p in m["primitives"]):
            raise RuntimeError(f"P0 FAIL: UV lost in {target}")
        after = sum(len(g.faces) for g in trimesh.load(output, force="scene", process=False).geometry.values())
        if before != after:
            raise RuntimeError(f"P0 FAIL: triangle count changed in {target}")
        print(f"ASSET_STRUCTURAL_PASS {target} bytes={len(data)} triangles={after} sha256={hashlib.sha256(data).hexdigest()}")

if __name__ == "__main__":
    prepare(Path("."))
