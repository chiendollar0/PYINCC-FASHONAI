"""Owner-created GLB and APK integrity regression tests."""
import base64
import hashlib
import json
from pathlib import Path
import struct
import tempfile
import unittest
from zipfile import ZipFile

from scripts import avatar_gate as gate

PRIMARY = 'assets/avatars/pyincc_avatar_primary.glb'
APK_KEY = 'assets/flutter_assets/' + PRIMARY


def glb_fixture(version=2, with_skin=False):
    positions = struct.pack('<9f', 0, 0, 0, 1, 0, 0, 0, 1, 0)
    uv = struct.pack('<6f', 0, 0, 1, 0, 0, 1)
    png = base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=')
    binary = positions + uv + png
    doc = {'asset': {'version': '2.0'}, 'scene': 0, 'scenes': [{'nodes': [0]}],
           'nodes': [{'mesh': 0}], 'buffers': [{'byteLength': len(binary)}],
           'bufferViews': [{'buffer': 0, 'byteOffset': 0, 'byteLength': len(positions)},
                           {'buffer': 0, 'byteOffset': len(positions), 'byteLength': len(uv)},
                           {'buffer': 0, 'byteOffset': len(positions + uv), 'byteLength': len(png)}],
           'accessors': [{'bufferView': 0, 'componentType': 5126, 'count': 3, 'type': 'VEC3'},
                         {'bufferView': 1, 'componentType': 5126, 'count': 3, 'type': 'VEC2'}],
           'meshes': [{'primitives': [{'attributes': {'POSITION': 0, 'TEXCOORD_0': 1}, 'material': 0}]}],
           'materials': [{'pbrMetallicRoughness': {'baseColorTexture': {'index': 0}}}],
           'textures': [{'source': 0}], 'images': [{'bufferView': 2, 'mimeType': 'image/png'}]}
    if with_skin:
        doc['skins'] = [{'joints': [0]}]
    js = json.dumps(doc, separators=(',', ':')).encode()
    js += b' ' * (-len(js) % 4)
    binary += b'\\0' * (-len(binary) % 4)
    total = 12 + 8 + len(js) + 8 + len(binary)
    return (b'glTF' + struct.pack('<II', version, total) +
            struct.pack('<II', len(js), 0x4E4F534A) + js +
            struct.pack('<II', len(binary), 0x004E4942) + binary)


class OwnerAvatarGateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.asset = self.root / PRIMARY
        self.asset.parent.mkdir(parents=True)
        self.asset.write_bytes(glb_fixture())
        self.manifest_path = self.root / 'config/avatar-asset.json'
        self.manifest_path.parent.mkdir(parents=True)
        self.manifest = {
            'schema_version': 1, 'approval_status': 'verified',
            'source_type': 'owner_created_and_uploaded',
            'owner_attestation': {'role': 'repository_owner',
                'statement': 'Repository owner confirms original mesh ownership and authorizes app distribution.'},
            'asset': {'path': PRIMARY, 'bytes': self.asset.stat().st_size, 'sha256': None}
        }
        self.write_manifest()

    def write_manifest(self):
        self.manifest_path.write_text(json.dumps(self.manifest))

    def make_apk(self, payload=None):
        apk = self.root / 'app.apk'
        with ZipFile(apk, 'w') as z:
            z.writestr(APK_KEY, payload if payload is not None else self.asset.read_bytes())
        return apk

    def test_owner_created_static_glb_passes_structural_gate(self):
        result = gate.validate_assets(self.root)
        self.assertEqual(result['status'], 'VERIFIED_STRUCTURAL_ONLY')
        self.assertEqual(result['asset']['sha256'], hashlib.sha256(self.asset.read_bytes()).hexdigest())
        self.assertEqual(result['structure']['skin_count'], 0)
        self.assertFalse(result['production_verified'])

    def test_missing_owner_attestation_blocks(self):
        self.manifest['owner_attestation'] = {}
        self.write_manifest()
        with self.assertRaisesRegex(gate.GateError, 'attestation'):
            gate.validate_assets(self.root)

    def test_wrong_asset_path_blocks(self):
        self.manifest['asset']['path'] = 'assets/other.glb'
        self.write_manifest()
        with self.assertRaisesRegex(gate.GateError, 'path'):
            gate.validate_assets(self.root)

    def test_wrong_sha256_blocks_when_pinned(self):
        self.manifest['asset']['sha256'] = '0' * 64
        self.write_manifest()
        with self.assertRaisesRegex(gate.GateError, 'SHA-256'):
            gate.validate_assets(self.root)

    def test_invalid_glb_version_blocks(self):
        self.asset.write_bytes(glb_fixture(version=1))
        self.manifest['asset']['bytes'] = self.asset.stat().st_size
        self.write_manifest()
        with self.assertRaisesRegex(gate.GateError, 'version'):
            gate.validate_assets(self.root)

    def test_skeleton_blocks_static_mesh_contract(self):
        self.asset.write_bytes(glb_fixture(with_skin=True))
        self.manifest['asset']['bytes'] = self.asset.stat().st_size
        self.write_manifest()
        with self.assertRaisesRegex(gate.GateError, 'skins/skeleton'):
            gate.validate_assets(self.root)

    def test_apk_contains_exact_official_glb_bytes(self):
        result = gate.verify_apk(self.root, self.make_apk())
        self.assertEqual(result['packaged_asset']['sha256'], result['asset']['sha256'])
        self.assertFalse(result['physical_android_verified'])

    def test_apk_altered_glb_blocks(self):
        raw = self.asset.read_bytes()
        with self.assertRaisesRegex(gate.GateError, 'hash mismatch'):
            gate.verify_apk(self.root, self.make_apk(raw[:-1] + b'X'))

    def test_apk_without_official_glb_blocks(self):
        apk = self.root / 'no-avatar.apk'
        with ZipFile(apk, 'w') as z:
            z.writestr('assets/readme.txt', b'no avatar')
        with self.assertRaisesRegex(gate.GateError, 'inventory'):
            gate.verify_apk(self.root, apk)


if __name__ == '__main__':
    unittest.main()
