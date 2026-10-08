# SDK Duplicate Finder

A simple PowerShell script to quickly scan your computer for duplicate SDK installations that may be wasting gigabytes of disk space.

## Why?

SDKs (Android SDK, Flutter, JDK, Node.js, .NET, etc.) are often large (several GB each). It's easy to accidentally download/install them multiple times in different locations, wasting significant disk space.

This script scans common installation directories and finds folders with the **same name and same size** at the root level — a strong indicator of duplicate installations.

## Features

- Scans common SDK installation paths (Downloads, Program Files, AppData, custom paths like `C:\Android`, `C:\flutter`, etc.)
- Checks environment variables (`JAVA_HOME`, `ANDROID_HOME`, `FLUTTER_ROOT`, `DART_SDK`)
- Filters out noise (cache, build, temp, node_modules, .gradle, etc.)
- Groups by folder name + size to detect likely duplicates
- Reports estimated wasted space
- Fast — only checks root folders, not recursive content

## Usage

```powershell
# Run directly
powershell -ExecutionPolicy Bypass -File find-duplicate-sdks.ps1

# Or if execution policy allows
.\find-duplicate-sdks.ps1
```

## Example Output

```
=== Searching for duplicate SDKs (root level only) ===
Root folders found: 12

Potential duplicates found: 2 group(s)

flutter_3.19.0 - 2.45 GB x 2 = ~2.45 GB wasted
   C:\flutter
   C:\sdk\flutter

jdk-21.0.1 - 320 MB x 2 = ~320 MB wasted
   C:\Program Files\Eclipse Adoptium\jdk-21.0.1
   C:\Android\jdk-21

=== Total estimated wasted: 2.77 GB ===

Tip: Verify manually before deleting.
Same size doesn't guarantee identical copies (compare contents if unsure).
```

## Customization

Edit the `$searchPaths` array in the script to add your own SDK directories:

```powershell
$searchPaths = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Desktop",
    "$env:LOCALAPPDATA\Android",
    "$env:PROGRAMFILES",
    "$env:PROGRAMFILES(X86)",
    "C:\Android",
    "C:\tools",
    "C:\sdk",
    "C:\flutter",
    "D:\Android",
    "D:\sdk",
    "D:\tools",
    "D:\flutter",
    # Add your custom paths here
    "E:\Development\SDKs"
)
```

## Requirements

- Windows PowerShell 5.1+ (built into Windows)
- No external dependencies

## License

MIT License — feel free to use, modify, and distribute.