# RemoveBOM
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
Get-ChildItem -Path . -Filter *.json -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content $filePath -Encoding Byte

    # Check for BOM (0xEF 0xBB 0xBF)
    if ($content[0] -eq 0xEF -and $content[1] -eq 0xBB -and $content[2] -eq 0xBF) {
        # Remove BOM
        $contentWithoutBOM = $content[3..$content.Length]
        # Save the file without BOM
        [System.IO.File]::WriteAllBytes($filePath, $contentWithoutBOM)
        Write-Host "Removed BOM from $filePath"
    } else {
        Write-Host "No BOM found in $filePath"
    }
}
