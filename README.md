# Git Repository Finder (PowerShell)

This PowerShell script searches through specified directories for folders that are Git repositories (i.e., contain a `.git` folder), and checks whether they are associated with **GitHub**.

# Table of Contents
- [Features](#-features)
- [Usage](#️-usage)
- [Notes](#-notes)
- [Requirements](#-requirements)

## 🔍 Features

- Recursively scans selected root folders for Git repositories
- Identifies if the repository is connected to GitHub
- Can group output by top-level directory for better organization
- Displays results in a simple table-style format in the console

## 🛠️ Usage

1. Open PowerShell.
2. Edit the script to set your own folder paths in the `$searchRoots` array:
    ```powershell
    $searchRoots = @("C:\Users", "D:\Projects", "E:\Code")
    ```
3. Run the script:
    ```powershell
    .\FindGits.ps1
    ```

## 💡 Notes

- The script checks for the existence of `.git/config` and searches for `github.com` to determine if the repo is GitHub-based.
- You can modify the grouping depth or search filters depending on how your project folders are structured.
- It gracefully handles folders it cannot access due to permission issues.

## ✅ Requirements

- Windows PowerShell (v5+) or PowerShell Core
- Read access to the target directories