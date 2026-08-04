# ============================================================
#  IMPAR KIT v30 - Instalador Windows
#  Ímpar Imóveis © 2025 | Joinville/SC
#  Requer: PowerShell 5.1+ | Executar como Administrador
# ============================================================

#Requires -Version 5.1

param(
    [switch]$Silencioso,
    [switch]$SemAgendamento,
    [switch]$SoAtualizarArquivos
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Configuração ─────────────────────────────────────────────
$VERSAO        = "30"
$PASTA_IMPAR   = "C:\Ímpar"
$ARQUIVO_PY    = "$PASTA_IMPAR\manutencao_impar.py"
$TASK_NAME     = "Ímpar_AutomationMonitor"
$SCRIPT_FONTE  = Join-Path $PSScriptRoot "manutencao_impar_v2.py"
$LOG_INSTALL   = "$PASTA_IMPAR\Logs\install_v$VERSAO.log"

# ── Helpers ──────────────────────────────────────────────────
function Escrever-Linha {
    param([string]$Texto, [string]$Cor = "White")
    Write-Host $Texto -ForegroundColor $Cor
    if (Test-Path (Split-Path $LOG_INSTALL)) {
        Add-Content -Path $LOG_INSTALL -Value "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') | $Texto" -Encoding UTF8
    }
}

function Verificar-Admin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Encontrar-Python {
    $candidatos = @("python", "python3", "py")
    foreach ($cmd in $candidatos) {
        try {
            $v = & $cmd --version 2>&1
            if ($v -match "Python (\d+\.\d+)") {
                $ver = [version]$Matches[1]
                if ($ver -ge [version]"3.9") { return $cmd }
            }
        } catch {}
    }
    return $null
}

function Remover-TaskSeExistir {
    param([string]$Nome)
    try {
        $t = Get-ScheduledTask -TaskName $Nome -ErrorAction SilentlyContinue
        if ($t) {
            Unregister-ScheduledTask -TaskName $Nome -Confirm:$false
            Escrever-Linha "  Tarefa anterior '$Nome' removida." "Yellow"
        }
    } catch {}
}

# ── Banner ───────────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     ÍMPAR KIT v$VERSAO - Instalador Windows                      ║" -ForegroundColor Cyan
Write-Host "║     Manutenção Impar v2.0 | Auto-Recovery Inteligente        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Pré-requisitos ───────────────────────────────────────────
Escrever-Linha "[ 1/6 ] Verificando pré-requisitos..." "Cyan"

if (-not (Verificar-Admin)) {
    Write-Host ""
    Write-Host "  ❌  Execute este script como ADMINISTRADOR." -ForegroundColor Red
    Write-Host "  →   Clique com botão direito no PowerShell e escolha" -ForegroundColor Yellow
    Write-Host "      'Executar como administrador', depois rode novamente." -ForegroundColor Yellow
    Write-Host ""
    if (-not $Silencioso) { pause }
    exit 1
}
Escrever-Linha "  ✅  Administrador confirmado." "Green"

$python = Encontrar-Python
if (-not $python) {
    Write-Host ""
    Write-Host "  ❌  Python 3.9+ não encontrado no PATH." -ForegroundColor Red
    Write-Host "  →   Baixe em https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "      Marque a opção 'Add Python to PATH' durante a instalação." -ForegroundColor Yellow
    Write-Host "      Depois reinicie o PowerShell e execute o instalador novamente." -ForegroundColor Yellow
    Write-Host ""
    if (-not $Silencioso) { pause }
    exit 1
}
$pyVer = & $python --version 2>&1
Escrever-Linha "  ✅  $pyVer encontrado ($python)." "Green"

if (-not (Test-Path $SCRIPT_FONTE)) {
    Write-Host ""
    Write-Host "  ❌  Arquivo 'manutencao_impar_v2.py' não encontrado ao lado do instalador." -ForegroundColor Red
    Write-Host "  →   Verifique se descompactou o kit completo antes de executar." -ForegroundColor Yellow
    Write-Host ""
    if (-not $Silencioso) { pause }
    exit 1
}
Escrever-Linha "  ✅  Arquivo fonte encontrado." "Green"

# ── Estrutura de pastas ──────────────────────────────────────
Escrever-Linha "[ 2/6 ] Criando estrutura de pastas em C:\Ímpar..." "Cyan"

$pastas = @(
    $PASTA_IMPAR,
    "$PASTA_IMPAR\Automações",
    "$PASTA_IMPAR\Logs",
    "$PASTA_IMPAR\NF\emitidas",
    "$PASTA_IMPAR\WhatsApp",
    "$PASTA_IMPAR\Videos",
    "$PASTA_IMPAR\Facebook",
    "$PASTA_IMPAR\Backup"
)

foreach ($pasta in $pastas) {
    New-Item -ItemType Directory -Path $pasta -Force | Out-Null
    Escrever-Linha "  📁  $pasta" "DarkGray"
}
Escrever-Linha "  ✅  Estrutura criada." "Green"

# Inicializar log de instalação (agora que a pasta existe)
"" | Out-File -FilePath $LOG_INSTALL -Encoding UTF8 -Force
Escrever-Linha "══════════════════════════════════════" | Out-Null
Escrever-Linha "IMPAR KIT v$VERSAO - Log de Instalação"
Escrever-Linha "Data: $(Get-Date -f 'yyyy-MM-dd HH:mm:ss')"
Escrever-Linha "══════════════════════════════════════"

# ── Copiar arquivos ──────────────────────────────────────────
Escrever-Linha "[ 3/6 ] Copiando arquivos..." "Cyan"

# Backup se já existir versão anterior
if (Test-Path $ARQUIVO_PY) {
    $bkp = "$PASTA_IMPAR\Backup\manutencao_impar_$(Get-Date -f 'yyyyMMdd_HHmmss').py.bak"
    Copy-Item $ARQUIVO_PY $bkp -Force
    Escrever-Linha "  📦  Backup da versão anterior: $bkp" "DarkYellow"
}

Copy-Item $SCRIPT_FONTE $ARQUIVO_PY -Force
Escrever-Linha "  ✅  manutencao_impar.py instalado em $PASTA_IMPAR" "Green"

# Copiar docs se existirem ao lado do instalador
$docs = @("GUIA_RAPIDO_V2.txt", "MANUTENCAO_IMPAR_V2_MELHORIAS.md", "CHECKLIST_IMPLEMENTACAO.md")
foreach ($doc in $docs) {
    $src = Join-Path $PSScriptRoot $doc
    if (Test-Path $src) {
        Copy-Item $src "$PASTA_IMPAR\$doc" -Force
        Escrever-Linha "  📄  $doc copiado." "DarkGray"
    }
}

# ── Inicializar o sistema ────────────────────────────────────
Escrever-Linha "[ 4/6 ] Inicializando sistema..." "Cyan"

try {
    & $python $ARQUIVO_PY --init 2>&1 | ForEach-Object { Escrever-Linha "  $_" "DarkGray" }
    Escrever-Linha "  ✅  Inicialização concluída." "Green"
} catch {
    Escrever-Linha "  ⚠️  Aviso na inicialização: $_" "Yellow"
}

# ── Executar testes ──────────────────────────────────────────
Escrever-Linha "[ 5/6 ] Executando testes..." "Cyan"

$testResult = & $python $ARQUIVO_PY --test 2>&1
$testResult | ForEach-Object { Escrever-Linha "  $_" "DarkGray" }

if ($LASTEXITCODE -ne 0) {
    Escrever-Linha "  ⚠️  Alguns testes falharam (pode ser normal antes do reinício)." "Yellow"
} else {
    Escrever-Linha "  ✅  Todos os testes passaram." "Green"
}

# ── Agendar no Task Scheduler ────────────────────────────────
if (-not $SemAgendamento -and -not $SoAtualizarArquivos) {
    Escrever-Linha "[ 6/6 ] Agendando no Task Scheduler..." "Cyan"

    Remover-TaskSeExistir $TASK_NAME

    try {
        $action   = New-ScheduledTaskAction `
                        -Execute $python `
                        -Argument "`"$ARQUIVO_PY`""
        $trigger  = New-ScheduledTaskTrigger -AtStartup
        $settings = New-ScheduledTaskSettingsSet `
                        -AllowStartIfOnBatteries `
                        -DontStopIfGoingOnBatteries `
                        -StartWhenAvailable `
                        -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
                        -RestartCount 3 `
                        -RestartInterval (New-TimeSpan -Minutes 5)

        Register-ScheduledTask `
            -Action   $action `
            -Trigger  $trigger `
            -TaskName $TASK_NAME `
            -RunLevel Highest `
            -Settings $settings `
            -Force | Out-Null

        Escrever-Linha "  ✅  Tarefa '$TASK_NAME' registrada (inicia com o Windows)." "Green"
    } catch {
        Escrever-Linha "  ❌  Erro ao registrar tarefa: $_" "Red"
        Escrever-Linha "  →   Execute manualmente após reiniciar:" "Yellow"
        Escrever-Linha "      python `"$ARQUIVO_PY`"" "Yellow"
    }
} else {
    Escrever-Linha "[ 6/6 ] Agendamento ignorado (flag ativa)." "DarkGray"
}

# ── Resumo ────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                INSTALAÇÃO CONCLUÍDA  ✅                      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Versão instalada : Ímpar Kit v$VERSAO" -ForegroundColor White
Write-Host "  Diretório        : $PASTA_IMPAR" -ForegroundColor White
Write-Host "  Script principal : $ARQUIVO_PY" -ForegroundColor White
Write-Host "  Log instalação   : $LOG_INSTALL" -ForegroundColor White
Write-Host ""
Write-Host "  Próximos passos:" -ForegroundColor Cyan
Write-Host "  1. Reiniciar o computador (a tarefa inicia automaticamente)" -ForegroundColor White
Write-Host "  2. Aguardar 5 minutos e verificar logs:" -ForegroundColor White
Write-Host "     Get-Content `"$PASTA_IMPAR\Logs\manutencao.log`" -Wait" -ForegroundColor DarkGray
Write-Host "  3. Confirmar Task Scheduler: taskschd.msc → $TASK_NAME" -ForegroundColor White
Write-Host ""

if (-not $Silencioso) {
    $resp = Read-Host "  Deseja reiniciar agora? (S/N)"
    if ($resp -match "^[Ss]$") {
        Escrever-Linha "Reiniciando..." "Yellow"
        Restart-Computer -Force
    }
}
