# -*- coding: utf-8 -*-
from pathlib import Path
text = Path('mesteri-platform/app_client/lib/src/features/home/presentation/screens/home_screen.dart').read_text(encoding='utf-8')
for idx, line in enumerate(text.splitlines(), start=1):
    if any(ord(c) > 127 for c in line):
        print(idx, line)
