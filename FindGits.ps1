$searchRoots = @("C:\..")  # Add/remove paths as needed
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
                    $gitStatus = "Unknown"

                    if (Test-Path $configPath) {
                        $configContent = Get-Content $configPath -ErrorAction SilentlyContinue
                        if ($configContent -match "github\.com[:/]+") {
                            $hasGitHub = $true
                        }
                    }

                    Push-Location $fullPath
                    try {
                        & git fetch *>$null

                        $localHash = & git rev-parse HEAD 2>$null
                        $remoteHash = & git rev-parse "HEAD@{u}" 2>$null
                        $baseHash = & git merge-base HEAD "HEAD@{u}" 2>$null

                        if ($localHash -eq $remoteHash) {
                            $gitStatus = "Up to date"
                        } elseif ($localHash -eq $baseHash) {
                            $gitStatus = "Behind"
                        } elseif ($remoteHash -eq $baseHash) {
                            $gitStatus = "Ahead"
                        } else {
                            $gitStatus = "Diverged"
                        }
                    }
                    catch {
                        $gitStatus = "Error or no upstream"
                    }
                    Pop-Location

                    $relativeRoot = $fullPath.Substring($startPath.Length).TrimStart('\').Split('\')[0]
                    $groupFolder = Join-Path $startPath $relativeRoot

                    $results += [PSCustomObject]@{
                        Group        = $groupFolder
                        FolderPath   = $fullPath
                        GitHubRepo   = if ($hasGitHub) { "Yes" } else { "No" }
                        GitStatus    = $gitStatus
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

# Group and display
$grouped = $results | Group-Object Group

foreach ($group in $grouped) {
    $group.Group | Select-Object FolderPath, GitHubRepo, GitStatus
}
