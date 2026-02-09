# --- SCRIPT DE SOPORTE TÉCNICO V2.1 (DIAGNÓSTICO PRO) ---

# 1. Configuración de Logs
$DirectorioScript = Split-Path -Parent $MyInvocation.MyCommand.Definition
$CarpetaLogs = Join-Path $DirectorioScript "Logs_Soporte"
if (!(Test-Path $CarpetaLogs)) { New-Item -ItemType Directory -Path $CarpetaLogs }

$NombrePC = $env:COMPUTERNAME
$ArchivoLog = Join-Path $CarpetaLogs ("Log_$NombrePC.txt")
$Fecha = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

function Write-Log {
    param([string]$Mensaje, [string]$Color = "White")
    $Timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$Timestamp] $Mensaje" -ForegroundColor $Color
    Add-Content -Path $ArchivoLog -Value "[$Fecha] $Mensaje"
}

Clear-Host
Write-Log "=== INICIANDO SOPORTE EN $NombrePC BY MATEO===" -Color Yellow
Write-Log "---------------------------------------"
# --- SECCIÓN NUEVA: DIAGNÓSTICO DE HARDWARE ---
Write-Log ">>> EXTRAYENDO INFO DE HARDWARE..." -Color Magenta

# Obtener CPU
$CPU = (Get-CimInstance Win32_Processor).Name
Write-Log "CPU: $CPU"

# Obtener RAM (Convertido a GB)
$RAM = [Math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)
Write-Log "RAM Total: $RAM GB"

# Obtener tipo de Disco (SSD o HDD)
$Discos = Get-PhysicalDisk | Select-Object DeviceID, MediaType, Size
foreach ($D in $Discos) {
    $Tamano = [Math]::Round($D.Size / 1GB)
    Write-Log "Disco $($D.DeviceID): $($D.MediaType) de $Tamano GB"
}
# --- SECCIÓN: DIAGNÓSTICO DE HARDWARE ---
Write-Log ">>> EXTRAYENDO INFO DE HARDWARE..." -Color Magenta

# Obtener CPU, RAM y Discos (Lo que ya teníamos)
$CPU = (Get-CimInstance Win32_Processor).Name
Write-Log "CPU: $CPU"
$RAM = [Math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)
Write-Log "RAM Total: $RAM GB"
$Discos = Get-PhysicalDisk | Select-Object DeviceID, MediaType, Size
foreach ($D in $Discos) {
    $Tamano = [Math]::Round($D.Size / 1GB)
    Write-Log "Disco $($D.DeviceID): $($D.MediaType) de $Tamano GB"
}

# --- NUEVO: REPORTE DE BATERÍA (Solo para portátiles) ---
$EsPortatil = Get-CimInstance -ClassName Win32_Battery
if ($EsPortatil) {
    Write-Log "Detectado Portatil. Generando reporte de batería..." -Color Cyan
    $RutaBattery = Join-Path $CarpetaLogs "Bateria_$NombrePC.html"
    powercfg /batteryreport /output $RutaBattery | Out-Null
    Write-Log "Reporte de bateria guardado en: $RutaBattery"
} else {
    Write-Log "Equipo de sobremesa. Saltando reporte de bateria portatil."
}

Write-Log "---------------------------------------"


# --- TAREAS DE MANTENIMIENTO) ---

# A. RED
Write-Log "[1/4] Refrescando red..." -Color Cyan
ipconfig /flushdns | Out-Null
ipconfig /renew | Out-Null

# B. IMPRESORAS
Write-Log "[2/4] Reiniciando Spooler de impresion..." -Color Cyan
Stop-Service Spooler -Force
Start-Service Spooler

# C. LIMPIEZA
Write-Log "[3/4] Limpiando carpetas temporales..." -Color Cyan
$RutasTemp = @("$env:TEMP\*", "C:\Windows\Temp\*")
foreach ($Ruta in $RutasTemp) {
    Remove-Item $Ruta -Recurse -Force -ErrorAction SilentlyContinue
}

# D. REPARACIÓN
Write-Log "[4/4] Ejecutando SFC Scannow (Integridad)..." -Color Cyan
Write-Host "Iniciando examen del sistema. Esto tardara unos minutos..." -ForegroundColor Gray

# Ejecutamos SFC sin Out-Null para ver el progreso (0%... 100%)
sfc /scannow 

# Verificamos si SFC terminó con éxito usando la variable de estado
if ($LASTEXITCODE -eq 0) {
    Write-Log "SFC finalizado: No se encontraron errores o se repararon correctamente." -Color Green
} else {
    Write-Log "SFC detecto problemas que podrian requerir atencion manual." -Color Red
}
# --- SECCIÓN: DETECTIVE DE ERRORES (Últimos 5 errores críticos) ---
Write-Log ">>> BUSCANDO ERRORES CRITICOS RECIENTES..." -Color Red

$Errores = Get-EventLog -LogName System -EntryType Error -Newest 5 -ErrorAction SilentlyContinue

if ($Errores) {
    foreach ($E in $Errores) {
        Write-Log "ID: $($E.EventID) - Fuente: $($E.Source) - Fecha: $($E.TimeGenerated)" -Color Yellow
        # Esto guarda una breve descripcion en el log
        Add-Content -Path $ArchivoLog -Value "Detalle: $($E.Message.Substring(0,100))..."
    }
} else {
    Write-Log "No se han detectado errores críticos recientes. ¡Sistema estable!" -Color Green
}
Write-Log "=== PROCESO COMPLETADO CON EXITO ===" -Color Green
Write-Log "Informe guardado en: $ArchivoLog"
Pause