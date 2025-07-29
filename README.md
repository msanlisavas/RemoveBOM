# RemoveBOM in ABP Projects
# PowerShell Script to Remove BOM from JSON Files

This PowerShell script recursively searches through a project directory and all its subdirectories to find all JSON files and removes the Byte Order Mark (BOM) if present. This is useful for ensuring that JSON files do not contain BOMs, which can cause issues in certain applications.

## Script Overview

The script performs the following steps:

1. **Search for JSON Files**:
   - Uses `Get-ChildItem` to find all `.json` files in the specified directory and its subdirectories.
   - Filters results to include only files with a `.json` extension.
   - Recursively searches all subdirectories.

2. **Check for BOM**:
   - Reads the content of each file in binary format (byte by byte) to detect the presence of a BOM.
   - Checks if the first three bytes of the file match the BOM for UTF-8 encoded files (`0xEF 0xBB 0xBF`).

3. **Remove BOM (if present)**:
   - If a BOM is found, it is removed from the file content.
   - The modified content is saved back to the original file without the BOM.

4. **Output**:
   - Prints a message to the console for each file, indicating whether a BOM was found and removed or if no BOM was found.

## Usage

To use this script, copy the following code into a `.ps1` file and run it in your PowerShell terminal:

```powershell
# Define directories to exclude (common in ABP projects)
$excludePaths = @("node_modules", "bin", "obj", ".vs", "packages", ".git", "dist", "build")

Write-Host "Scanning for JSON files with BOM..." -ForegroundColor Yellow

Get-ChildItem -Path . -Filter *.json -Recurse | Where-Object {
    $exclude = $false
    foreach ($excludePath in $excludePaths) {
        if ($_.FullName -like "*\$excludePath\*") {
            $exclude = $true
            break
        }
    }
    -not $exclude
} | ForEach-Object {
    $filePath = $_.FullName
    $relativePath = $_.FullName.Replace((Get-Location).Path, ".")
    
    try {
        $fileStream = [System.IO.File]::OpenRead($filePath)
        $buffer = New-Object byte[] 3
        $bytesRead = $fileStream.Read($buffer, 0, 3)
        $fileStream.Close()
        
        if ($bytesRead -eq 3 -and $buffer[0] -eq 0xEF -and $buffer[1] -eq 0xBB -and $buffer[2] -eq 0xBF) {
            $content = Get-Content $filePath -Encoding Byte
            $contentWithoutBOM = $content[3..($content.Length-1)]
            [System.IO.File]::WriteAllBytes($filePath, $contentWithoutBOM)
            Write-Host "Removed BOM from: $relativePath" -ForegroundColor Green
        } else {
            Write-Host "No BOM in: $relativePath" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Error processing $relativePath" -ForegroundColor Red
    }
}

Write-Host "Scan completed!" -ForegroundColor Yellow
