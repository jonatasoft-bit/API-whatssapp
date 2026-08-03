# =============================================
#  Kit Piloto Automatico V30 — Instalador Windows
#  Requer: Windows 10/11, PowerShell 5+, Admin
# =============================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ERRORS = @()

function Step($num, $msg) {
    Write-Host "`n" -NoNewline
    Write-Host "[ETAPA $num] " -ForegroundColor Blue -NoNewline
    Write-Host $msg -ForegroundColor White
}
function Ok($msg)   { Write-Host "  v $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  ! $msg" -ForegroundColor Yellow }
function Info($msg) { Write-Host "  > $msg" -ForegroundColor Cyan }
function Err($msg)  { Write-Host "  X $msg" -ForegroundColor Red }

Clear-Host
Write-Host ""
Write-Host "  =============================================" -ForegroundColor Cyan
Write-Host "   Kit Piloto Automatico V30 — Windows" -ForegroundColor Cyan
Write-Host "  =============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Err "Execute como Administrador: clique direito no instalar.bat -> 'Executar como administrador'"
    Read-Host "Pressione Enter para fechar"
    exit 1
}

# ============================================================
Step "1/9" "Verificando conexao com a internet..."
# ============================================================
try {
    $null = Invoke-WebRequest -Uri "https://example.com" -TimeoutSec 5 -UseBasicParsing
    Ok "Internet OK"
} catch {
    Err "Sem internet. Conecte-se a rede e tente novamente."
    Read-Host "Pressione Enter para fechar"
    exit 1
}

# ============================================================
Step "2/9" "Verificando winget (gerenciador de pacotes)..."
# ============================================================
$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Info "Abrindo Microsoft Store para instalar App Installer..."
    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
    Warn "Instale o 'App Installer' na Microsoft Store, reinicie e execute novamente."
    Read-Host "Pressione Enter para fechar"
    exit 1
}
Ok "winget disponivel"

function Install-Winget($id, $name) {
    Info "Instalando $name..."
    $result = winget install $id --accept-source-agreements --accept-package-agreements -e --silent 2>&1
    $code = $LASTEXITCODE
    if ($code -eq 0 -or $code -eq -1978335212) {
        Ok "$name OK"
    } else {
        Warn "$name - verifique se ja esta instalado ou instale manualmente"
        $script:ERRORS += $name
    }
}

# ============================================================
Step "3/9" "Instalando Node.js..."
# ============================================================
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Install-Winget "OpenJS.NodeJS.LTS" "Node.js"
    # Atualizar PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Ok "Node.js ja instalado: $(node --version)"
}

# ============================================================
Step "4/9" "Instalando Python 3..."
# ============================================================
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Install-Winget "Python.Python.3.12" "Python 3"
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Ok "Python ja instalado"
}

# ============================================================
Step "5/9" "Instalando Git..."
# ============================================================
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Install-Winget "Git.Git" "Git"
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Ok "Git disponivel"
}

# ============================================================
Step "6/9" "Instalando aplicativos principais..."
# ============================================================
$apps = @(
    @{Id="Anthropic.Claude";     Name="Claude Desktop"},
    @{Id="Obsidian.Obsidian";    Name="Obsidian"},
    @{Id="WhatsApp.WhatsApp";    Name="WhatsApp"},
    @{Id="Docker.DockerDesktop"; Name="Docker Desktop"}
)

foreach ($app in $apps) {
    Install-Winget $app.Id $app.Name
}

# ============================================================
Step "7/9" "Instalando Claude Code (linha de comando)..."
# ============================================================
$claudeCli = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCli) {
    Info "Instalando Claude Code..."
    npm install -g @anthropic-ai/claude-code 2>$null
    Ok "Claude Code instalado"
} else {
    Ok "Claude Code ja disponivel"
}

# ============================================================
Step "8/9" "Instalando n8n (automacoes)..."
# ============================================================
$n8n = Get-Command n8n -ErrorAction SilentlyContinue
if (-not $n8n) {
    Info "Instalando n8n..."
    npm install -g n8n 2>$null
    Ok "n8n instalado"
} else {
    Ok "n8n ja disponivel"
}

# ============================================================
Step "9/9" "Configurando WhatsApp MCP e Claude Desktop..."
# ============================================================
$mcpDir = "$env:USERPROFILE\mcps"
New-Item -ItemType Directory -Path $mcpDir -Force | Out-Null

if (-not (Test-Path "$mcpDir\whatsapp-mcp")) {
    Info "Clonando WhatsApp MCP..."
    git clone https://github.com/lharries/whatsapp-mcp.git "$mcpDir\whatsapp-mcp" 2>$null
    if (Test-Path "$mcpDir\whatsapp-mcp") {
        Push-Location "$mcpDir\whatsapp-mcp"
        npm install --silent 2>$null
        Pop-Location
        Ok "WhatsApp MCP configurado em $mcpDir\whatsapp-mcp"
    } else {
        Warn "WhatsApp MCP nao configurado agora — siga o guia HTML"
    }
} else {
    Ok "WhatsApp MCP ja presente"
}

# Detectar pasta do kit
$kitPath = ""
$possiblePaths = @(
    "$env:USERPROFILE\Desktop\Kit-Piloto-Automatico-V30-DISTRIB",
    "$env:USERPROFILE\Documents\Kit-Piloto-Automatico-V30-DISTRIB",
    "C:\Kit-Piloto-Automatico-V30-DISTRIB"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $kitPath = $path
        Ok "Kit encontrado em: $kitPath"
        break
    }
}

if (-not $kitPath) {
    $kitPath = "$env:USERPROFILE\Documents\Kit-Piloto-Automatico-V30-DISTRIB"
    Warn "Kit nao encontrado — coloque a pasta em Documentos e configure manualmente"
}

# Configurar Claude Desktop
$configDir = "$env:APPDATA\Claude"
New-Item -ItemType Directory -Path $configDir -Force | Out-Null

$kitPathFwd  = $kitPath.Replace("\", "/")
$desktopPath = "$env:USERPROFILE\Desktop".Replace("\", "/")
$docsPath    = "$env:USERPROFILE\Documents".Replace("\", "/")

$configJson = @"
{
  "mcpServers": {
    "composio": {
      "command": "npx",
      "args": ["-y", "@composio/rube-mcp"]
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "$kitPathFwd",
        "$desktopPath",
        "$docsPath"
      ]
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
"@

$configJson | Out-File -FilePath "$configDir\claude_desktop_config.json" -Encoding UTF8
Ok "Configuracao do Claude Desktop salva em $configDir\claude_desktop_config.json"

# ============================================================
#  RESUMO FINAL
# ============================================================
Write-Host ""
Write-Host "  =============================================" -ForegroundColor Green
Write-Host "   OK  INSTALACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "  =============================================" -ForegroundColor Green
Write-Host ""

if ($ERRORS.Count -gt 0) {
    Warn "Itens que precisam de atencao: $($ERRORS -join ', ')"
    Write-Host ""
}

Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Abra o Claude Desktop (Menu Iniciar ou Area de Trabalho)"
Write-Host "  2. Crie conta em claude.ai e faca login"
Write-Host "  3. Obtenha sua chave API em https://console.anthropic.com"
Write-Host "     -> Crie conta -> API Keys -> Create Key"
Write-Host "  4. No Claude Desktop, digite:  instalar kpa30"
Write-Host "  5. Abra o guia:  ..\ABRA-ME.html  no navegador"
Write-Host ""
Write-Host "Para WhatsApp e Facebook, siga os passos do guia HTML." -ForegroundColor Yellow
Write-Host ""
Read-Host "Pressione Enter para fechar"
