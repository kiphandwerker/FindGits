# PowerShell script to search selected folders on all drives for .git directories

$searchRoots = @("C:\Users\19018\OneDrive\Programs")  # Add/remove paths as needed

foreach ($startPath in $searchRoots) {
    if (Test-Path $startPath) {
        Write-Host "Searching for .git directories in $startPath ..." -ForegroundColor Cyan

        try {
            Get-ChildItem -Path $startPath -Recurse -Directory -Force -ErrorAction SilentlyContinue |
            Where-Object {
                Test-Path -Path (Join-Path $_.FullName ".git")
            } |
            Select-Object FullName |
            ForEach-Object {
                Write-Host "Git repository found: $($_.FullName)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "Failed to search ${startPath}: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Path does not exist: $startPath" -ForegroundColor Yellow
    }
}
