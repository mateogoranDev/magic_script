@echo off
:: Este comando abre PowerShell como administrador y lanza el script
@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp001_Scripts\Soporte_pro.ps1""' -Verb RunAs}"