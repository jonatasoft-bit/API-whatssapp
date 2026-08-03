@echo off
chcp 65001 >nul
echo.
echo  =============================================
echo   Kit Piloto Automatico V30 - Windows
echo  =============================================
echo.
echo  Iniciando instalacao...
echo.

:: Verificar se esta rodando como Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo  ATENCAO: Precisa de permissao de Administrador!
    echo.
    echo  Clique com o botao DIREITO neste arquivo
    echo  e escolha "Executar como administrador"
    echo.
    pause
    exit /b 1
)

PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar.ps1"
pause
