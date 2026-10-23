"""Unit fixtures stay in temporary directories; they are never app assets."""
import base64
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest
import warnings
from zipfile import ZipFile

try:
    from scripts import avatar_gate as gate
except ImportError:
    gate = None

UID = '5e0c47f7f7fe453bb4d3c8c7eba356e8'
PRIMARY = 'assets/avatars/pyincc_avatar_primary.glb'
APK_KEY = 'assets/flutter_assets/' + PRIMARY


def glb_fixture(change=None, version=2):
    positions = struct.pack('<9f', 0, 0, 0, 1, 0, 0, 0, 1, 0)
    uv = struct.pack('<6f', 0, 0, 1, 0, 0, 1)
    png = base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=')
    binary = positions + uv + png
    doc = {'asset': {'version': '2.0'}, 'scene': 0,
           'scenes': [{'nodes': [0]}], 'nodes': [{'mesh': 0}],
           'buffers': [{'byteLength': len(binary)}],
           'bufferViews': [{'buffer': 0, 'byteOffset': 0, 'byteLength': len(positions)},
                           {'buffer': 0, 'byteOffset': len(positions), 'byteLength': len(uv)},
                           {'buffer': 0, 'byteOffset': len(positions + uv), 'byteLength': len(png)}],
           'accessors': [{'bufferView': 0, 'componentType': 5126, 'count': 3, 'type': 'VEC3', 'min': [0, 0, 0], 'max': [1, 1, 0]},
                         {'bufferView': 1, 'componentType': 5126, 'count': 3, 'type': 'VEC2'}],
           'meshes': [{'primitives': [{'attributes': {'POSITION': 0, 'TEXCOORD_0': 1}, 'material': 0}]}],
           'materials': [{'pbrMetallicRoughness': {'baseColorTexture': {'index': 0}}}],
           'textures': [{'source': 0}], 'images': [{'bufferView': 2, 'mimeType': 'image/png'}]}
    if change:
        change(doc)
    js = json.dumps(doc, separators=(',', ':')).encode()
    js += b' ' * (-len(js) % 4)
    binary += b'\0' * (-len(binary) % 4)
    total = 12 + 8 + len(js) + 8 + len(binary)
    return b'glTF' + struct.pack('<II', version, total) + struct.pack('<II', len(js), 0x4E4F534A) + js + struct.pack('<II', len(binary), 0x004E4942) + binary


class AvatarGateTests(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(gate, 'missing fail-closed avatar gate')
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.asset = self.root / PRIMARY
        self.asset.parent.mkdir(parents=True)
        self.asset.write_bytes(glb_fixture())
        evidence = self.root / 'docs/evidence/unit-test-rights.txt'
        evidence.parent.mkdir(parents=True)
        evidence.write_text('UNIT TEST FIXTURE ONLY. This is not a real asset license.')
        self.credit = self.root / 'assets/avatars/GRACY_LEE_ATTRIBUTION.txt'
        self.credit.write_text('UNIT TEST attribution; not a real license.')
        self.manifest = {'schema_version': 1, 'approval_status': 'verified',
                         'model_uid': UID, 'source_url': 'https://sketchfab.com/3d-models/gracy-lee-' + UID,
                         'canonical_url': 'https://sketchfab.com/3d-models/test-fixture-' + UID,
                         'author': 'UNIT TEST ONLY',
                         'license': {'id': 'UNIT-TEST', 'url': 'https://example.org/unit-test-license'},
                         'permissions': {'download': True, 'commercial_use': True, 'app_distribution': True},
                         'reviewed_by': 'UNIT TEST', 'reviewed_at': '2026-10-19T00:00:00+07:00',
                         'evidence': {'kind': 'license_grant', 'path': 'docs/evidence/unit-test-rights.txt', 'sha256': hashlib.sha256(evidence.read_bytes()).hexdigest()},
                         'attribution': {'path': 'assets/avatars/GRACY_LEE_ATTRIBUTION.txt', 'sha256': hashlib.sha256(self.credit.read_bytes()).hexdigest()},
                         'asset': {'path': PRIMARY, 'bytes': self.asset.stat().st_size, 'sha256': hashlib.sha256(self.asset.read_bytes()).hexdigest()}}
        self.write_manifest()

    def write_manifest(self):
        p = self.root / 'config/avatar-asset.json'
        p.parent.mkdir(exist_ok=True)
        p.write_text(json.dumps(self.manifest))

    def rejected(self, pattern):
        return self.assertRaisesRegex(gate.GateError, pattern)

    def change_glb(self, change=None, version=2):
        self.asset.write_bytes(glb_fixture(change, version))
        self.manifest['asset'].update(bytes=self.asset.stat().st_size, sha256=hashlib.sha256(self.asset.read_bytes()).hexdigest())
        self.write_manifest()

    def apk(self, entries=None):
        p = self.root / 'unit-test.apk'
        with ZipFile(p, 'w') as z:
            for name, data in entries or [(APK_KEY, self.asset.read_bytes()), ('assets/flutter_assets/assets/avatars/GRACY_LEE_ATTRIBUTION.txt', self.credit.read_bytes())]:
                z.writestr(name, data)
        return p

    def test_approved_single_asset_returns_exact_identity(self):
        d = gate.validate_assets(self.root)
        self.assertEqual(d['asset']['sha256'], hashlib.sha256(self.asset.read_bytes()).hexdigest())
        self.assertFalse(d['production_verified'])

    def test_old_selected_model_is_rejected_after_gracy_selection(self):
        self.manifest['model_uid'] = '4385c4af843e43379df8b702d04634f9'
        self.manifest['canonical_url'] = 'https://sketchfab.com/3d-models/old-' + self.manifest['model_uid']
        self.write_manifest()
        with self.rejected('model'):
            gate.validate_assets(self.root)

    def test_missing_attribution_blocks(self):
        self.manifest.pop('attribution')
        self.write_manifest()
        with self.rejected('attribution'):
            gate.validate_assets(self.root)

    def test_changed_attribution_blocks(self):
        self.credit.write_text('changed')
        with self.rejected('attribution'):
            gate.validate_assets(self.root)

    def test_missing_apk_attribution_blocks(self):
        p = self.apk([(APK_KEY, self.asset.read_bytes())])
        with self.rejected('attribution'):
            gate.verify_apk(self.root, p)

    def test_altered_apk_attribution_blocks(self):
        p = self.apk([(APK_KEY, self.asset.read_bytes()),
                      ('assets/flutter_assets/assets/avatars/GRACY_LEE_ATTRIBUTION.txt', b'changed')])
        with self.rejected('attribution'):
            gate.verify_apk(self.root, p)

    def test_missing_manifest_blocks(self):
        (self.root / 'config/avatar-asset.json').unlink()
        with self.rejected('manifest'):
            gate.validate_assets(self.root)

    def test_pending_rights_blocks_before_any_asset_is_used(self):
        self.manifest['approval_status'] = 'blocked'
        self.write_manifest()
        with self.rejected('rights'):
            gate.validate_assets(self.root)

    def test_string_true_does_not_grant_permission(self):
        self.manifest['permissions']['download'] = 'true'
        self.write_manifest()
        with self.rejected('permission'):
            gate.validate_assets(self.root)

    def test_short_url_is_not_canonical_identity(self):
        self.manifest['canonical_url'] = 'https://skfb.ly/6YvQ7'
        self.write_manifest()
        with self.rejected('canonical'):
            gate.validate_assets(self.root)

    def test_different_model_cannot_replace_owner_selection(self):
        self.manifest['model_uid'] = '0' * 32
        self.write_manifest()
        with self.rejected('model'):
            gate.validate_assets(self.root)

    def test_missing_license_cannot_pass(self):
        self.manifest['license'] = {}
        self.write_manifest()
        with self.rejected('license'):
            gate.validate_assets(self.root)

    def test_missing_reviewer_cannot_pass(self):
        self.manifest['reviewed_by'] = ''
        self.write_manifest()
        with self.rejected('review'):
            gate.validate_assets(self.root)

    def test_evidence_cannot_escape_repository(self):
        self.manifest['evidence']['path'] = '../outside.txt'
        self.write_manifest()
        with self.rejected('evidence'):
            gate.validate_assets(self.root)

    def test_changed_rights_evidence_blocks(self):
        (self.root / self.manifest['evidence']['path']).write_text('changed')
        with self.rejected('evidence'):
            gate.validate_assets(self.root)

    def test_missing_primary_blocks(self):
        self.asset.unlink()
        with self.rejected('exactly one'):
            gate.validate_assets(self.root)

    def test_nested_alternate_glb_blocks(self):
        p = self.asset.parent / 'hidden/old.GLB'
        p.parent.mkdir()
        p.write_bytes(self.asset.read_bytes())
        with self.rejected('exactly one'):
            gate.validate_assets(self.root)

    def test_asset_hash_mismatch_blocks(self):
        self.manifest['asset']['sha256'] = '0' * 64
        self.write_manifest()
        with self.rejected('hash'):
            gate.validate_assets(self.root)

    def test_invalid_glb_version_blocks_even_if_hash_matches(self):
        self.change_glb(version=1)
        with self.rejected('GLB'):
            gate.validate_assets(self.root)

    def test_missing_uv_blocks(self):
        self.change_glb(lambda d: d['meshes'][0]['primitives'][0]['attributes'].pop('TEXCOORD_0'))
        with self.rejected('UV'):
            gate.validate_assets(self.root)

    def test_external_texture_blocks_offline_packaging(self):
        self.change_glb(lambda d: d['images'][0].update(uri='https://example.org/image.png'))
        with self.rejected('external'):
            gate.validate_assets(self.root)

    def test_bad_texture_reference_blocks(self):
        self.change_glb(lambda d: d['textures'][0].update(source=99))
        with self.rejected('texture'):
            gate.validate_assets(self.root)

    def test_out_of_bounds_buffer_view_blocks(self):
        self.change_glb(lambda d: d['bufferViews'][0].update(byteLength=10**8))
        with self.rejected('buffer'):
            gate.validate_assets(self.root)

    def test_accessor_count_cannot_read_beyond_vertex_buffer(self):
        self.change_glb(lambda d: d['accessors'][0].update(count=100000000))
        with self.rejected('accessor'):
            gate.verify_apk(self.root, self.apk())

    def test_accessor_type_is_required(self):
        self.change_glb(lambda d: d['accessors'][0].pop('type'))
        with self.rejected('accessor'):
            gate.validate_assets(self.root)

    def test_accessor_offset_cannot_escape_buffer_view(self):
        self.change_glb(lambda d: d['accessors'][0].update(byteOffset=4096))
        with self.rejected('accessor'):
            gate.validate_assets(self.root)

    def test_uv_vertex_count_must_match_positions(self):
        self.change_glb(lambda d: d['accessors'][1].update(count=2))
        with self.rejected('count'):
            gate.validate_assets(self.root)

    def test_stride_cannot_overlap_vertex_elements(self):
        self.change_glb(lambda d: d['bufferViews'][0].update(byteStride=4))
        with self.rejected('accessor'):
            gate.validate_assets(self.root)

    def test_textured_model_allows_solid_color_secondary_primitive_without_uv(self):
        def add_solid(d):
            d['materials'].append({'pbrMetallicRoughness': {'baseColorFactor': [0, 0, 0, 1]}})
            d['meshes'][0]['primitives'].append({'attributes': {'POSITION': 0}, 'material': 1})
        self.change_glb(add_solid)
        try:
            result = gate.validate_assets(self.root)
        except gate.GateError as exc:
            self.fail('valid solid-color secondary primitive rejected: ' + str(exc))
        self.assertEqual(result['status'], 'VERIFIED_STRUCTURAL_ONLY')

    def test_unused_texture_cannot_fake_material_coverage(self):
        self.change_glb(lambda d: d['materials'][0]['pbrMetallicRoughness'].pop('baseColorTexture'))
        with self.rejected('texture'):
            gate.validate_assets(self.root)

    def test_actual_apk_bytes_are_hashed(self):
        p = self.apk()
        d = gate.verify_apk(self.root, p)
        self.assertEqual(d['apk']['sha256'], hashlib.sha256(p.read_bytes()).hexdigest())
        self.assertEqual(d['packaged_asset']['sha256'], self.manifest['asset']['sha256'])
        self.assertFalse(d['physical_android_verified'])

    def test_altered_apk_asset_blocks(self):
        p = self.apk([(APK_KEY, self.asset.read_bytes()[:-1] + b'X')])
        with self.rejected('hash'):
            gate.verify_apk(self.root, p)

    def test_old_alternate_in_apk_blocks(self):
        p = self.apk([(APK_KEY, self.asset.read_bytes()), ('assets/old/alternate.glb', b'old')])
        with self.rejected('inventory'):
            gate.verify_apk(self.root, p)

    def test_duplicate_zip_entry_blocks(self):
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', UserWarning)
            p = self.apk([(APK_KEY, self.asset.read_bytes()), (APK_KEY, self.asset.read_bytes())])
        with self.rejected('duplicate'):
            gate.verify_apk(self.root, p)

    def test_missing_glb_in_apk_blocks(self):
        p = self.apk([('assets/readme.txt', b'none')])
        with self.rejected('inventory'):
            gate.verify_apk(self.root, p)

    def test_cli_returns_blocked_and_writes_truthful_report(self):
        self.manifest['approval_status'] = 'blocked'
        self.write_manifest()
        report = self.root / 'evidence/gate.json'
        cp = subprocess.run([sys.executable, str(Path(gate.__file__)), '--root', str(self.root), '--report', str(report)], capture_output=True, text=True)
        self.assertEqual(cp.returncode, 2)
        d = json.loads(report.read_text())
        self.assertEqual(d['status'], 'BLOCKED')
        self.assertFalse(d['production_verified'])
        self.assertIn('rights', d['reason'])


if __name__ == '__main__':
    unittest.main()

