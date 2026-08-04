@echo off
chcp 65001 >nul
title IMPAR KIT v30 - Instalador Windows

echo.
echo  ============================================================
echo   IMPAR KIT v30 - Instalador Windows
echo   Impar Imoveis - Joinville/SC
echo  ============================================================
echo.

:: Verificar administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Execute como ADMINISTRADOR.
    echo.
    echo  Clique com botao direito neste arquivo e escolha
    echo  "Executar como administrador".
    echo.
    pause
    exit /b 1
)

echo  [OK] Permissoes de administrador confirmadas.
echo.
echo  Iniciando instalacao via PowerShell...
echo.

:: Habilitar execucao de scripts PowerShell e chamar o instalador
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar.ps1"

if %errorlevel% neq 0 (
    echo.
    echo  [ERRO] A instalacao terminou com erro (codigo %errorlevel%).
    echo  Verifique as mensagens acima.
    echo.
    pause
    exit /b %errorlevel%
)

exit /b 0
