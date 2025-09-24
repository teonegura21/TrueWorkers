# -*- coding: utf-8 -*-
from pathlib import Path
path = Path('mesteri-platform/app_client/lib/src/features/home/presentation/screens/home_screen.dart')
content = path.read_text(encoding='utf-8')
lines = content.splitlines()
new_lines = []
skip_block = False
for line in lines:
    if "subtitle:" in line and "category" not in line:
        continue
    if 'final String subtitle;' in line:
        continue
    if 'required this.subtitle' in line:
        continue
    if 'const SizedBox(height: 4)' in line:
        skip_block = True
        continue
    if skip_block:
        if line.strip() == '),':
            skip_block = False
        continue
    new_lines.append(line)
path.write_text('\r\n'.join(new_lines) + '\r\n', encoding='utf-8')
