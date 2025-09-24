# -*- coding: utf-8 -*-
from pathlib import Path
text = Path('mesteri-platform/app_client/lib/src/features/home/presentation/screens/home_screen.dart').read_text(encoding='utf-8')
idx = text.index("category.title")
print(idx)
print(repr(text[idx-120:idx+120]))
