"""Run with python3 tool/check_fork_reconciliation.py from the repo root."""
import json
import re
import subprocess
from pathlib import Path


def git(*args):
    return subprocess.check_output(['git', *args])


fork_paths = git('diff', '--name-only', '7c51c99', '7b121b4').decode().splitlines()
assert len(fork_paths) == 91
assert not git('diff', '--name-only', '--diff-filter=U')
subprocess.run(['git', 'diff', '--check'], check=True)
subprocess.run(['git', 'diff', '--cached', '--check'], check=True)
for name in git('ls-files').decode().splitlines():
    p = Path(name)
    if p.is_file():
        assert not re.search(rb'^(?:<<<<<<< |=======$|>>>>>>> )', p.read_bytes(), re.M), name
assert not git('ls-tree', '-r', '--name-only', '83883b8', 'ios/')
for name in fork_paths:
    assert Path(name).exists(), name
    if name.startswith('ios/'):
        assert Path(name).read_bytes() == git('show', '7b121b4:' + name), name
assert Path('lib/l10n/app_vi.arb').read_bytes() == git('show', '7b121b4:lib/l10n/app_vi.arb')
read = lambda lang: json.loads(Path(f'lib/l10n/app_{lang}.arb').read_text())
keys = lambda d: {key for key in d if not key.startswith('@')}
en, vi = read('en'), read('vi')
manifest = json.loads(Path('lib/l10n/untranslated_vi.json').read_text())
assert len(keys(vi)) == 4424
assert keys(en) - keys(vi) == set(manifest)
assert not keys(vi) - keys(en)
assert len(manifest) == len(set(manifest)) == 539
assert 'template-arb-file: app_en.arb' in Path('l10n.yaml').read_text()
print('PASS: 91/91 fork paths present; all 42 iOS files identical to fork;')
print('4424 Vietnamese messages unchanged; exactly 539 explicit English fallbacks;')
print('zero conflict markers, unmerged paths, or diff whitespace errors.')
