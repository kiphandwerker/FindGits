# PowerShell script to search selected folders on all drives for .git directories

$searchRoots = @("C:\Users\19018\OneDrive\Programs")  # Add/remove paths as needed

# Store all valid git repo results
$results = @()

foreach ($startPath in $searchRoots) {
    if (Test-Path $startPath) {
        Write-Host "Scanning $startPath ..." -ForegroundColor Cyan

        try {
            Get-ChildItem -Path $startPath -Recurse -Directory -Force -ErrorAction SilentlyContinue |
            ForEach-Object {
                $fullPath = $_.FullName
                $gitPath = Join-Path $fullPath ".git"
                $configPath = Join-Path $gitPath "config"

                if (Test-Path $gitPath) {
                    $hasGitHub = $false

                    if (Test-Path $configPath) {
                        $configContent = Get-Content $configPath -ErrorAction SilentlyContinue
                        if ($configContent -match "github\.com[:/]+") {
                            $hasGitHub = $true
                        }
                    }

                    $relativeRoot = $fullPath.Substring($startPath.Length).TrimStart('\').Split('\')[0]
                    $groupFolder = Join-Path $startPath $relativeRoot

                    $results += [PSCustomObject]@{
                        Group        = $groupFolder
                        FolderPath   = $fullPath
                        GitHubRepo   = if ($hasGitHub) { "Yes" } else { "No" }
                    }
                }
            }
        }
        catch {
            Write-Host "Error searching ${startPath}: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Path not found: $startPath" -ForegroundColor Yellow
    }
}

# Group and display only folders that have a .git directory
$grouped = $results | Group-Object Group

foreach ($group in $grouped) {
    #Write-Host "`nGroup: $($group.Name)" -ForegroundColor Yellow
    $group.Group | Select-Object FolderPath, GitHubRepo #| Format-Table -AutoSize
}


