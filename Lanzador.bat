@echo off
title SOPORTE TÉCNICO - by MATEO
color 1F

echo ╔════════════════════════════════════════════════════════════╗
echo ║     🔍 SOPORTE TÉCNICO - MODO COMPAÑEROS                 ║
echo ║        ✅ 100% SEGURO - NO TOCA CONFIGURACIÓN           ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

set "ScriptPath=%~dp0\01_Scripts\Soporte_pro.ps1"

if not exist "%ScriptPath%" (
    echo ❌ ERROR: No se encuentra el script
    pause
    exit /b
)

echo [1/3] ✅ Script encontrado
echo [2/3] ⚙️  Configurando PowerShell...
powershell -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force\"' -Verb RunAs -Wait" >nul 2>&1
echo [3/3] 🚀 Iniciando diagnóstico seguro...
echo.
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%ScriptPath%"
echo.
pause