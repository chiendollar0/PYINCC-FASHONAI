#!/usr/bin/env python3
"""Fail-closed FashionAI asset identity/rights and actual-APK checks.

This validates recorded rights review and structural/packaging evidence only.
It never certifies legal entitlement, visual quality, or physical Android UAT.
It performs no downloads, conversion, deletion, or asset regeneration.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import struct
import sys
from urllib.parse import urlparse
from zipfile import BadZipFile, ZipFile

MODEL_UID = '4385c4af843e43379df8b702d04634f9'
PRIMARY = 'assets/avatars/pyincc_avatar_primary.glb'
APK_KEY = 'assets/flutter_assets/' + PRIMARY
MANIFEST = 'config/avatar-asset.json'
MAX_ASSET_BYTES = 128 * 1024 * 1024


class GateError(ValueError):
    """An input or required evidence does not meet the packaging contract."""


def require(condition, reason):
    if not condition:
        raise GateError(reason)


def digest_file(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def repo_file(root, relative, label):
    require(isinstance(relative, str) and relative.strip(), label + ' path missing')
    p = PurePosixPath(relative)
    require(not p.is_absolute() and '..' not in p.parts and '\\' not in relative,
            label + ' path must remain inside repository')
    path = root / relative
    require(path.resolve().is_relative_to(root.resolve()) and not path.is_symlink(),
            label + ' path escapes repository or is a symlink')
    require(path.is_file(), label + ' file missing: ' + relative)
    return path


def secure_url(value):
    if not isinstance(value, str):
        return False
    p = urlparse(value)
    return p.scheme == 'https' and bool(p.hostname) and not p.username and not p.password


def index(items, value, label):
    require(type(value) is int and 0 <= value < len(items), label + ' reference invalid')
    return items[value]


def validate_glb(data):
    require(len(data) >= 28 and data[:4] == b'glTF', 'invalid GLB header')
    version, length = struct.unpack_from('<II', data, 4)
    require(version == 2 and length == len(data), 'invalid GLB version/length')
    chunks, offset = [], 12
    while offset < len(data):
        require(offset + 8 <= len(data), 'invalid GLB chunk header')
        size, kind = struct.unpack_from('<II', data, offset)
        offset += 8
        require(size % 4 == 0 and offset + size <= len(data), 'invalid GLB chunk bounds')
        chunks.append((kind, data[offset:offset + size]))
        offset += size
    require(len(chunks) == 2 and chunks[0][0] == 0x4E4F534A and chunks[1][0] == 0x004E4942,
            'GLB must contain embedded JSON and BIN')
    doc = json.loads(chunks[0][1])
    require(doc.get('asset', {}).get('version') == '2.0', 'GLB asset version invalid')
    buffers = doc.get('buffers', [])
    require(len(buffers) == 1 and not buffers[0].get('uri'), 'external/missing GLB buffer')
    bin_size = buffers[0].get('byteLength')
    require(type(bin_size) is int and 0 < bin_size <= len(chunks[1][1]) and len(chunks[1][1]) - bin_size <= 3,
            'GLB buffer size invalid')
    views = doc.get('bufferViews', [])
    for v in views:
        begin, size = v.get('byteOffset', 0), v.get('byteLength')
        require(v.get('buffer') == 0 and type(begin) is int and type(size) is int and
                begin >= 0 and size > 0 and begin + size <= bin_size, 'GLB buffer view out of bounds')
    images, textures = doc.get('images', []), doc.get('textures', [])
    require(images and textures, 'GLB embedded texture missing')
    for image in images:
        require(not image.get('uri'), 'external GLB image is forbidden for offline packaging')
        view = index(views, image.get('bufferView'), 'image buffer')
        raw = chunks[1][1][view.get('byteOffset', 0):view.get('byteOffset', 0) + view['byteLength']]
        mime = image.get('mimeType')
        require((mime == 'image/png' and raw.startswith(b'\x89PNG\r\n\x1a\n')) or
                (mime == 'image/jpeg' and raw.startswith(b'\xff\xd8\xff')),
                'GLB image must be embedded PNG/JPEG for the current viewer gate')
    for texture in textures:
        index(images, texture.get('source'), 'texture image')
    accessors, materials, meshes = doc.get('accessors', []), doc.get('materials', []), doc.get('meshes', [])
    require(meshes, 'GLB mesh missing')
    def vertex_accessor(value, semantic):
        accessor = index(accessors, value, 'mesh/UV accessor')
        kind = 'VEC2' if semantic.startswith('TEXCOORD_') else 'VEC3'
        require(accessor.get('type') == kind, 'GLB accessor type invalid: ' + semantic)
        component = accessor.get('componentType')
        allowed = (5121, 5123, 5126) if kind == 'VEC2' else (5126,)
        require(component in allowed, 'GLB accessor component type invalid: ' + semantic)
        if component != 5126:
            require(accessor.get('normalized') is True, 'GLB UV accessor must normalize integer components')
        component_bytes = {5121: 1, 5123: 2, 5126: 4}[component]
        element_bytes = component_bytes * (2 if kind == 'VEC2' else 3)
        count, begin = accessor.get('count'), accessor.get('byteOffset', 0)
        view = index(views, accessor.get('bufferView'), 'mesh/UV accessor buffer')
        stride = view.get('byteStride', element_bytes)
        require(type(count) is int and count > 0 and type(begin) is int and begin >= 0 and
                begin % component_bytes == 0 and type(stride) is int and
                element_bytes <= stride <= 252 and stride % component_bytes == 0 and
                begin + (count - 1) * stride + element_bytes <= view['byteLength'],
                'GLB accessor offset/count/stride exceeds buffer view: ' + semantic)
        return count

    texture_references = 0
    for mesh in meshes:
        primitives = mesh.get('primitives', [])
        require(primitives, 'GLB mesh primitives missing')
        for primitive in primitives:
            attrs = primitive.get('attributes', {})
            require('POSITION' in attrs, 'GLB mesh POSITION missing')
            vertex_count = vertex_accessor(attrs['POSITION'], 'POSITION')
            material = index(materials, primitive['material'], 'material') if 'material' in primitive else {}
            pbr = material.get('pbrMetallicRoughness', {})
            slots = [pbr[k] for k in ('baseColorTexture', 'metallicRoughnessTexture') if k in pbr]
            slots += [material[k] for k in ('normalTexture', 'occlusionTexture', 'emissiveTexture') if k in material]
            for slot in slots:
                index(textures, slot.get('index'), 'material texture')
                coord = slot.get('texCoord', 0)
                require(type(coord) is int and coord >= 0, 'GLB texture UV index invalid')
                semantic = 'TEXCOORD_' + str(coord)
                require(semantic in attrs, 'GLB mesh/UV attribute missing: ' + semantic)
                require(vertex_accessor(attrs[semantic], semantic) == vertex_count,
                        'GLB UV accessor count differs from POSITION count')
                texture_references += 1
    require(texture_references > 0, 'GLB embedded texture is not referenced by any primitive material')
    return {'meshes': len(meshes), 'images': len(images), 'structural_only': True}


def validate_assets(root):
    root = Path(root)
    try:
        manifest_path = repo_file(root, MANIFEST, 'manifest')
        m = json.loads(manifest_path.read_text(encoding='utf-8'))
        require(m.get('schema_version') == 1, 'unsupported manifest schema')
        require(m.get('approval_status') == 'verified', 'rights review pending: authorized model/GLB required')
        require(m.get('model_uid') == MODEL_UID, 'model differs from owner-selected temporary candidate')
        canonical = m.get('canonical_url')
        require(secure_url(canonical) and urlparse(canonical).hostname == 'sketchfab.com' and
                urlparse(canonical).path.startswith('/3d-models/') and
                urlparse(canonical).path.rstrip('/').endswith(MODEL_UID), 'canonical model identity invalid')
        require(isinstance(m.get('author'), str) and m['author'].strip(), 'model author missing')
        license_info = m.get('license', {})
        require(isinstance(license_info.get('id'), str) and license_info['id'].strip() and
                secure_url(license_info.get('url')), 'license identity missing')
        require(all(m.get('permissions', {}).get(k) is True for k in
                    ('download', 'commercial_use', 'app_distribution')), 'required permission not verified')
        require(isinstance(m.get('reviewed_by'), str) and m['reviewed_by'].strip(), 'rights reviewer missing')
        reviewed_at = datetime.fromisoformat(m.get('reviewed_at', ''))
        require(reviewed_at.tzinfo is not None, 'rights review timestamp requires timezone')
        evidence = m.get('evidence', {})
        require(evidence.get('kind') == 'license_grant', 'rights evidence must document a license grant, not a listing')
        proof = repo_file(root, evidence.get('path'), 'evidence')
        require(re.fullmatch(r'[0-9a-f]{64}', evidence.get('sha256', '')) and
                digest_file(proof) == evidence['sha256'], 'evidence hash mismatch')
        expected = m.get('asset', {})
        require(expected.get('path') == PRIMARY, 'asset path must match sole approved primary')
        inventory = sorted(p.relative_to(root).as_posix() for p in (root / 'assets/avatars').rglob('*')
                           if p.is_file() and p.suffix.lower() == '.glb')
        require(inventory == [PRIMARY], 'exactly one primary GLB required; found ' + repr(inventory))
        asset = repo_file(root, PRIMARY, 'asset')
        require(type(expected.get('bytes')) is int and 0 < expected['bytes'] <= MAX_ASSET_BYTES and
                asset.stat().st_size == expected['bytes'], 'asset byte size mismatch')
        sha = digest_file(asset)
        require(re.fullmatch(r'[0-9a-f]{64}', expected.get('sha256', '')) and sha == expected['sha256'],
                'asset hash mismatch')
        structure = validate_glb(asset.read_bytes())
        return {'status': 'VERIFIED_STRUCTURAL_ONLY', 'model_uid': MODEL_UID,
                'manifest_sha256': digest_file(manifest_path),
                'asset': {'path': PRIMARY, 'bytes': asset.stat().st_size, 'sha256': sha},
                'structure': structure, 'rights_review_recorded': True,
                'visual_verified': False, 'physical_android_verified': False, 'production_verified': False}
    except GateError:
        raise
    except (OSError, ValueError, TypeError, KeyError, IndexError, AttributeError, struct.error) as exc:
        raise GateError('invalid asset/rights manifest or GLB: ' + str(exc)) from exc


def verify_apk(root, apk):
    evidence = validate_assets(root)
    apk = Path(apk)
    try:
        with ZipFile(apk) as z:
            entries = z.infolist()
            names = [x.filename for x in entries]
            require(len(names) == len(set(names)), 'duplicate APK ZIP entry')
            glbs = [x for x in entries if x.filename.lower().endswith('.glb')]
            require([x.filename for x in glbs] == [APK_KEY], 'APK GLB inventory differs from sole approved asset')
            require(glbs[0].file_size == evidence['asset']['bytes'], 'packaged asset size mismatch')
            h, actual_size = hashlib.sha256(), 0
            with z.open(APK_KEY) as f:
                for chunk in iter(lambda: f.read(1024 * 1024), b''):
                    actual_size += len(chunk)
                    require(actual_size <= evidence['asset']['bytes'], 'packaged asset exceeds expected size')
                    h.update(chunk)
            require(actual_size == evidence['asset']['bytes'] and h.hexdigest() == evidence['asset']['sha256'],
                    'packaged asset hash mismatch')
        evidence.update(status='VERIFIED_PACKAGING_ONLY',
                        apk={'path': apk.name, 'bytes': apk.stat().st_size, 'sha256': digest_file(apk)},
                        packaged_asset={'path': APK_KEY, 'bytes': actual_size, 'sha256': h.hexdigest()})
        return evidence
    except GateError:
        raise
    except (OSError, BadZipFile, RuntimeError) as exc:
        raise GateError('invalid APK: ' + str(exc)) from exc


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path('.'))
    parser.add_argument('--apk', type=Path)
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    try:
        report = verify_apk(args.root, args.apk) if args.apk else validate_assets(args.root)
        code = 0
    except GateError as exc:
        report = {'status': 'BLOCKED', 'reason': str(exc), 'production_verified': False,
                  'visual_verified': False, 'physical_android_verified': False}
        code = 2
    report.update(checked_at=datetime.now(timezone.utc).isoformat(),
                  source_commit=os.environ.get('GITHUB_SHA'), run_id=os.environ.get('GITHUB_RUN_ID'))
    payload = json.dumps(report, indent=2, ensure_ascii=False) + '\n'
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(payload, encoding='utf-8')
    print(payload, end='')
    return code


if __name__ == '__main__':
    sys.exit(main())
