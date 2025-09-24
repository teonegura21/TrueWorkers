$ErrorActionPreference = 'Stop'

# Usage: ./normalize_diacritics.ps1 <path-to-dart-file>
$Path = $args[0]

if (-not $Path -or -not (Test-Path $Path)) {
  Write-Error "Path not found: $Path"
}

$file = Get-Item -LiteralPath $Path
$content = Get-Content -LiteralPath $file.FullName -Raw

$replacements = @(
  @{ From = 'AcE>iuni'; To = 'Acțiuni' }
  @{ From = 'Pla?ile'; To = 'Plățile' }
  @{ From = 'pA�nA�'; To = 'până' }
  @{ From = 'PA�nA�'; To = 'Până' }
  @{ From = 'curA�nd'; To = 'curând' }
  @{ From = 'Plate?te'; To = 'Plătește' }
  @{ From = '?tergere'; To = 'Ștergere' }
  @{ From = 'Ajutor Pl��E>i'; To = 'Ajutor Plăți' }
  @{ From = 'Pl��E>i'; To = 'Plăți' }
  @{ From = 'Pl��teETte'; To = 'Plătește' }
  @{ From = 'Plat��'; To = 'Plată' }
  @{ From = 'Securizat��'; To = 'Securizat' }
  @{ From = 'GaranE>ie'; To = 'Garanție' }
  @{ From = 'RISCUT ZERO'; To = 'RISC ZERO' }
  @{ From = 'reE>inute'; To = 'reținute' }
  @{ From = 'Arn'; To = 'în' }
  @{ From = 'pA�n��'; To = 'până' }
  @{ From = 'lucr��rii'; To = 'lucrării' }
  @{ From = 'elibereaz��'; To = 'eliberează' }
  @{ From = 'dup��'; To = 'după' }
  @{ From = 'platform��'; To = 'platformă' }
  @{ From = 'tranzacE>ie'; To = 'tranzacție' }
  @{ From = 'Pl��tit'; To = 'Plătit' }
  @{ From = 'pl��tit'; To = 'plătit' }
  @{ From = 'Sold de pl��tit'; To = 'Sold de plătit' }
  @{ From = 'Metod�� de plat�� selectat��'; To = 'Metodă de plată selectată' }
  @{ From = 'Securitatea pl��E>ii garantat��'; To = 'Securitatea plății garantată' }
  @{ From = 'Toate pl��E>ile'; To = 'Toate plățile' }
  @{ From = 'AZn procesare'; To = 'În procesare' }
  @{ From = 'AZn aETteptare'; To = 'În așteptare' }
  @{ From = 'EETuat'; To = 'Eșuat' }
  @{ From = 'plat��'; To = 'plată' }
)

foreach ($r in $replacements) {
  $from = [Regex]::Escape($r.From)
  $to = $r.To
  $content = [System.Text.RegularExpressions.Regex]::Replace($content, $from, $to)
}

Set-Content -LiteralPath $file.FullName -Value $content -NoNewline -Encoding UTF8
Write-Host "Normalized diacritics in $($file.FullName)"
