# Get all JSON files in the project directory and subdirectories
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
