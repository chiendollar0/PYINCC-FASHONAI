#!/usr/bin/env python3
"""Create texture-free, neutral-material GLBs from original scans.

This is mesh/material preparation, NOT photorealistic skin reconstruction.
Do not alter or overwrite the original GLBs.
"""
import hashlib
import json
import struct
from pathlib import Path

import trimesh
from trimesh.visual.material import PBRMaterial
from trimesh.visual.texture import TextureVisuals

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
            mesh.visual = TextureVisuals(
                uv=uv.copy(),
                material=PBRMaterial(
                    baseColorFactor=[190, 178, 164, 255],
                    metallicFactor=0.0,
                    roughnessFactor=0.86,
                    doubleSided=True,
                ),
            )
        output = dest / target
        output.write_bytes(scene.export(file_type="glb"))
        data = output.read_bytes()
        if data[:4] != b"glTF" or struct.unpack_from("<I", data, 8)[0] != len(data):
            raise RuntimeError(f"P0 FAIL: invalid GLB {target}")
        json_len = struct.unpack_from("<I", data, 12)[0]
        gltf = json.loads(data[20:20 + json_len])
        if gltf.get("images") or gltf.get("textures") or gltf.get("extensionsRequired"):
            raise RuntimeError(f"P0 FAIL: source textures remain in {target}")
        if not all("TEXCOORD_0" in p["attributes"] for m in gltf["meshes"] for p in m["primitives"]):
            raise RuntimeError(f"P0 FAIL: UV lost in {target}")
        after = sum(len(g.faces) for g in trimesh.load(output, force="scene", process=False).geometry.values())
        if before != after:
            raise RuntimeError(f"P0 FAIL: triangle count changed in {target}")
        print(f"ASSET_PASS {target} bytes={len(data)} triangles={after} sha256={hashlib.sha256(data).hexdigest()}")

if __name__ == "__main__":
    prepare(Path("."))
