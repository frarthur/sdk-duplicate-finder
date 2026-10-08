<# 
.SYNOPSIS
    Scanne les dossiers d'installation courants pour trouver des SDKs installés en double
    (même nom + même taille au niveau racine)
#>

$searchPaths = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Desktop",
    "$env:LOCALAPPDATA\Android",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps",
    "$env:PROGRAMFILES",
    "$env:PROGRAMFILES(X86)",
    "C:\Android",
    "C:\tools",
    "C:\sdk",
    "C:\flutter",
    "D:\Android",
    "D:\sdk",
    "D:\tools",
    "D:\flutter"
)

$excludePatterns = @(
    '^\\.',           # dossiers cachés
    'cache',
    'temp',
    'tmp',
    'build',
    'out',
    'bin',
    'obj',
    'node_modules',
    'packages',
    '.gradle',
    '.dart_tool',
    'flutter_tools',
    'ide_templates',
    'test_fixtures',
    'examples',
    'dev',
    'engine',
    'licenses',
    'thirdparty',
    'third_party',
    'intermediate',
    'source',
    'src',
    'legal',
    'include',
    'share',
    'doc',
    'docs',
    'man',
    'manpages',
    'locale',
    'localization',
    'resources',
    'resource',
    'assets',
    'asset',
    'data',
    'fixtures',
    'samples',
    'sample',
    'demo',
    'benchmark',
    'benchmarks',
    'integration_tests',
    'manual_tests',
    'automated_tests',
    'a11y_assessments',
    'bots',
    'packages\flutter_tools',
    'packages\flutter_test',
    'packages\flutter_driver',
    'packages\integration_test',
    'packages\flutter_localizations',
    'packages\flutter_gallery',
    'packages\flutterapp',
    'packages\flutter_view',
    'packages\flutter_plugin_android_lifecycle',
    'packages\flutter_secure_storage',
    'packages\package_info_plus',
    'packages\wakelock_plus',
    'packages\jni',
    'packages\jni_flutter',
    'packages\vm_service',
    'packages\flutter_volume_controller',
    'packages\flutter_svg',
    'packages\webview_flutter',
    'packages\shared_preferences',
    'packages\sqflite',
    'packages\flutter_secure_storage_darwin',
    'packages\flutter_secure_storage_linux',
    'packages\flutter_secure_storage_windows',
    'packages\flutter_secure_storage_web',
    'packages\flutter_secure_storage_platform_interface',
    'packages\flutter_secure_storage_macos',
    'packages\flutter_secure_storage_android',
    'packages\build_runner',
    'packages\xdg_directories'
)

Write-Host "=== Recherche de SDKs en double (racines seulement) ===" -ForegroundColor Cyan

$allRoots = @()
foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        try {
            $dirs = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue |
                Where-Object { 
                    $_.Name -match 'android|flutter|dart|jdk|java|node|gradle|maven|intellij|eclipse|dotnet|rust|cargo|golang|anaconda|miniconda|sdk|studio' -and
                    $_.Name -notmatch ($excludePatterns -join '|')
                }
            $allRoots += $dirs
        } catch { }
    }
}

# Aussi vérifier les dossiers JDK/Android SDK connus
$knownSdks = @(
    "$env:JAVA_HOME",
    "$env:ANDROID_HOME",
    "$env:ANDROID_SDK_ROOT",
    "$env:FLUTTER_ROOT",
    "$env:DART_SDK"
)
foreach ($sdk in $knownSdks) {
    if ($sdk -and (Test-Path $sdk)) {
        $parent = Split-Path $sdk -Parent
        if ($parent -and (Test-Path $parent)) {
            $allRoots += Get-Item $parent
        }
    }
}

Write-Host "Dossiers racines trouves : $($allRoots.Count)" -ForegroundColor Gray

$groups = $allRoots | Group-Object { $_.Name + "_" + $_.Length } | Where-Object { $_.Count -gt 1 }

if ($groups.Count -eq 0) {
    Write-Host "`nAucun doublon detecte (meme nom + meme taille au niveau racine)" -ForegroundColor Green
    exit 0
}

Write-Host "`nDoublons potentiels trouves : $($groups.Count) groupe(s)" -ForegroundColor Yellow

$totalWasted = 0
foreach ($group in $groups) {
    $sizeMB = [math]::Round($group.Group[0].Length / 1MB, 2)
    $wasted = [math]::Round(($group.Count - 1) * $group.Group[0].Length / 1MB, 2)
    $totalWasted += $wasted
    Write-Host "`n$($group.Name) - $sizeMB MB x $($group.Count) = ~$wasted MB gaspilles" -ForegroundColor Cyan
    foreach ($item in $group.Group) {
        Write-Host "   $($item.FullName)" -ForegroundColor White
    }
}

Write-Host "`n=== Total estime gaspille : $totalWasted MB ===" -ForegroundColor Red
Write-Host "`nConseil : Verifiez manuellement avant de supprimer." -ForegroundColor Gray
Write-Host "Meme taille ne garantit pas copies identiques (comparez contenu si doute)." -ForegroundColor Gray