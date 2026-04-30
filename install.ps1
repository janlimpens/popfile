# POPFile installer for Windows
# Run: irm https://raw.githubusercontent.com/janlimpens/popfile/main/install.ps1 | iex

Write-Host "POPFile installer" -ForegroundColor Cyan
Write-Host "================="

# ── try Docker ──
$docker = Get-Command docker -ErrorAction SilentlyContinue
if ($docker -and (docker info 2>$null)) {
    Write-Host "→ Docker found, launching container…" -ForegroundColor Green
    docker run -d --name popfile --restart unless-stopped `
        -p 7070:7070 -e POPFILE_USER=/data -v popfile-data:/data `
        ghcr.io/janlimpens/popfile:latest
    Write-Host "→ POPFile is running at http://localhost:7070" -ForegroundColor Green
    Write-Host "  Stop:   docker stop popfile"
    Write-Host "  Logs:   docker logs popfile"
    exit 0
}

# ── try WSL ──
$wsl = Get-Command wsl -ErrorAction SilentlyContinue
if ($wsl) {
    Write-Host "→ WSL found, using the Linux installer inside WSL…" -ForegroundColor Green
    wsl bash -c "curl -fsSL https://raw.githubusercontent.com/janlimpens/popfile/main/install.sh | sh"
    exit 0
}

# ── nothing worked ──
Write-Host "✗ Neither Docker nor WSL found." -ForegroundColor Red
Write-Host ""
Write-Host "Install Docker Desktop:  https://docs.docker.com/desktop/setup/install/windows-install/"
Write-Host "Or enable WSL:           wsl --install"
Write-Host ""
Write-Host "Then run this script again."
