# -*- coding: utf-8 -*-
from pathlib import Path
path = Path('mesteri-platform/app_client/lib/src/features/home/presentation/screens/home_screen.dart')
text = path.read_text(encoding='utf-8')
pattern = "            ),\r\n\r\n            ),\r\n\r\n          ],"
if pattern in text:
    text = text.replace(pattern, "            ),\r\n\r\n          ],", 1)
else:
    raise SystemExit('pattern not found')
path.write_text(text, encoding='utf-8')
