# -*- coding: utf-8 -*-
from pathlib import Path
path = Path('mesteri-platform/app_client/lib/src/features/home/presentation/screens/home_screen.dart')
lines = path.read_text(encoding='utf-8').splitlines()
start = 1240
for idx in range(start, min(start + 120, len(lines))):
    print(f"{idx+1:04d}: {lines[idx]}")
