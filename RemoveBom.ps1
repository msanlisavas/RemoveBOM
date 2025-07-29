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
