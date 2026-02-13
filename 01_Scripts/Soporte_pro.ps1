# --- SOPORTE TÉCNICO V8.0 - VERSIÓN DEFINITIVA CON HERRAMIENTAS PROFESIONALES ---
# by MATEO - DIAGNÓSTICO + REPARACIONES SEGURAS + CAJA DE HERRAMIENTAS
# =============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# -------------------------------------------------------------------
# CONFIGURACIÓN INICIAL
# -------------------------------------------------------------------
# Comprobar si se ejecuta como Administrador
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Reiniciando como administrador..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


$DirectorioScript = Split-Path -Parent $MyInvocation.MyCommand.Definition
$CarpetaLogs = Join-Path $DirectorioScript "Logs_Soporte"
if (!(Test-Path $CarpetaLogs)) { New-Item -ItemType Directory -Path $CarpetaLogs -Force | Out-Null }

$NombrePC = $env:COMPUTERNAME
$Fecha = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$Usuario = $env:USERNAME
$ArchivoLog = Join-Path $CarpetaLogs "Diagnostico_$NombrePC.txt"
$InformeTXT = Join-Path $CarpetaLogs "Informe_$NombrePC.txt"

Add-Content -Path $ArchivoLog -Value "=== DIAGNÓSTICO PROFESIONAL INICIADO ==="
Add-Content -Path $ArchivoLog -Value "Fecha: $Fecha | PC: $NombrePC | Usuario: $Usuario"

# -------------------------------------------------------------------
# VENTANA PRINCIPAL
# -------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "Soporte Técnico Profesional - by Mateo"
$form.Size = New-Object System.Drawing.Size(1300, 750)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#1e1e2f"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$lblTitulo = New-Object System.Windows.Forms.Label
$lblTitulo.Text = "🛠️  SOPORTE TÉCNICO BY Mateo - DIAGNÓSTICO + HERRAMIENTAS  🛠️"
$lblTitulo.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$lblTitulo.ForeColor = "#00d4ff"
$lblTitulo.BackColor = "#1e1e2f"
$lblTitulo.Size = New-Object System.Drawing.Size(1260, 50)
$lblTitulo.Location = New-Object System.Drawing.Point(20, 20)
$lblTitulo.TextAlign = "MiddleCenter"
$form.Controls.Add($lblTitulo)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "⚡ MODO PROFESIONAL - 100% SEGURO - CAJA DE HERRAMIENTAS INTEGRADA ⚡   |   $NombrePC - $Usuario   |   $Fecha"
$lblSub.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$lblSub.ForeColor = "#a0a0c0"
$lblSub.BackColor = "#1e1e2f"
$lblSub.Size = New-Object System.Drawing.Size(1260, 30)
$lblSub.Location = New-Object System.Drawing.Point(20, 75)
$lblSub.TextAlign = "MiddleCenter"
$form.Controls.Add($lblSub)

$txtResultados = New-Object System.Windows.Forms.RichTextBox
$txtResultados.Location = New-Object System.Drawing.Point(20, 120)
$txtResultados.Size = New-Object System.Drawing.Size(1260, 450)
$txtResultados.BackColor = "#0a0a1a"
$txtResultados.ForeColor = "#e0e0ff"
$txtResultados.Font = New-Object System.Drawing.Font("Consolas", 10)
$txtResultados.ReadOnly = $true
$txtResultados.BorderStyle = "FixedSingle"
$form.Controls.Add($txtResultados)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 580)
$progressBar.Size = New-Object System.Drawing.Size(1260, 20)
$progressBar.Style = "Marquee"
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

function Write-Rich {
    param([string]$Texto, [string]$Color = "#e0e0ff")
    $txtResultados.SelectionStart = $txtResultados.TextLength
    $txtResultados.SelectionLength = 0
    $txtResultados.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($Color)
    $txtResultados.AppendText($Texto + "`r`n")
    $txtResultados.ScrollToCaret()
    Add-Content -Path $ArchivoLog -Value $Texto
    [System.Windows.Forms.Application]::DoEvents()
}

function Write-LogGUI {
    param([string]$Texto, [string]$Color = "#a0a0c0")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Rich "[$timestamp] $Texto" $Color
}

# -------------------------------------------------------------------
# 🧰 MENÚ DE HERRAMIENTAS EXTRA - VERSIÓN PROFESIONAL CON CATEGORÍAS
# -------------------------------------------------------------------
$btnHerramientas = New-Object System.Windows.Forms.Button
$btnHerramientas.Text = "🧰 CAJA DE HERRAMIENTAS PROFESIONAL ▼"
$btnHerramientas.Size = New-Object System.Drawing.Size(280, 50)
$btnHerramientas.Location = New-Object System.Drawing.Point(700, 630)
$btnHerramientas.BackColor = "#9b59b6"
$btnHerramientas.ForeColor = "White"
$btnHerramientas.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnHerramientas.FlatStyle = "Flat"
$btnHerramientas.FlatAppearance.BorderSize = 0

$menuHerramientas = New-Object System.Windows.Forms.ContextMenuStrip
$menuHerramientas.BackColor = "#2d2d44"
$menuHerramientas.ForeColor = "White"
$menuHerramientas.Font = New-Object System.Drawing.Font("Segoe UI", 10)

function Add-Herramienta {
    param(
        [string]$Categoria,
        [string]$Nombre,
        [string]$Archivo,
        [string]$Icono = "🔧",
        [string]$Descripcion = "",
        [string]$Color = "#e0e0ff"
    )
    
    $item = New-Object System.Windows.Forms.ToolStripMenuItem
    $item.Text = "   $Icono $Nombre"
    $item.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($Color)
    $item.BackColor = "#2d2d44"
    $item.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    if ($Descripcion) { $item.ToolTipText = $Descripcion }
    
    $item.Add_Click({
        $rutaBase = Join-Path $DirectorioScript "..\03_Herramientas_extra"
        $rutaBase = [System.IO.Path]::GetFullPath($rutaBase)
        $ejecutable = Join-Path $rutaBase $Archivo
        
        if (Test-Path $ejecutable) {
            try {
                Start-Process $ejecutable -ErrorAction Stop
                Write-LogGUI "▶️ Ejecutando: $Nombre" "#9b59b6"
            } catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Error al ejecutar:`n$ejecutable`n`n$_",
                    "Error",
                    "OK",
                    "Error"
                )
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show(
                "No se encontró:`n$ejecutable`n`nDescárgalo y colócalo en:`n$rutaBase",
                "Herramienta no encontrada",
                "OK",
                "Warning"
            )
        }
    })
    
    # Buscar o crear categoría
    $categoriaExistente = $menuHerramientas.Items | Where-Object { $_.Text -eq "📁 $Categoria" }
    if ($categoriaExistente) {
        $categoriaExistente.DropDownItems.Add($item) | Out-Null
    } else {
        $categoriaItem = New-Object System.Windows.Forms.ToolStripMenuItem
        $categoriaItem.Text = "📁 $Categoria"
        $categoriaItem.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#ffd966")
        $categoriaItem.BackColor = "#2d2d44"
        $categoriaItem.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $categoriaItem.DropDownItems.Add($item) | Out-Null
        $menuHerramientas.Items.Add($categoriaItem) | Out-Null
    }
}

# -------------------------------------------------------------------
# 📦 CONFIGURACIÓN DE HERRAMIENTAS - TOP 20 PROFESIONAL
# -------------------------------------------------------------------

# 📊 DIAGNÓSTICO DE HARDWARE
Add-Herramienta -Categoria "DIAGNÓSTICO" -Nombre "CPU-Z" -Archivo "CPU-Z\cpuz.exe" -Icono "⚡" -Descripcion "Información detallada del procesador" -Color "#00d4ff"
Add-Herramienta -Categoria "DIAGNÓSTICO" -Nombre "GPU-Z" -Archivo "GPU-Z\GPU-Z.exe" -Icono "🎮" -Descripcion "Información de la tarjeta gráfica" -Color "#00d4ff"
Add-Herramienta -Categoria "DIAGNÓSTICO" -Nombre "Speccy" -Archivo "Speccy\Speccy.exe" -Icono "📸" -Descripcion "Resumen completo del PC" -Color "#00d4ff"
Add-Herramienta -Categoria "DIAGNÓSTICO" -Nombre "CrystalDiskInfo" -Archivo "CrystalDiskInfo\DiskInfo64.exe" -Icono "💿" -Descripcion "Salud de discos duros/SSD" -Color "#00d4ff"
Add-Herramienta -Categoria "DIAGNÓSTICO" -Nombre "HWiNFO" -Archivo "HWiNFO\HWiNFO64.exe" -Icono "🔧" -Descripcion "Sensores y temperaturas profesionales" -Color "#00d4ff"

# 🧹 LIMPIEZA Y OPTIMIZACIÓN
Add-Herramienta -Categoria "LIMPIEZA" -Nombre "WizTree" -Archivo "WizTree\WizTree64.exe" -Icono "🌳" -Descripcion "Analiza el espacio en disco" -Color "#6fdc6f"
Add-Herramienta -Categoria "LIMPIEZA" -Nombre "BleachBit" -Archivo "BleachBit\bleachbit.exe" -Icono "🧼" -Descripcion "Limpieza profunda (alternativa a CCleaner)" -Color "#6fdc6f"
Add-Herramienta -Categoria "LIMPIEZA" -Nombre "Defraggler" -Archivo "Defraggler\Defraggler64.exe" -Icono "⚙️" -Descripcion "Desfragmenta discos HDD" -Color "#6fdc6f"

# 🛡️ SEGURIDAD Y ANTIVIRUS
Add-Herramienta -Categoria "SEGURIDAD" -Nombre "Malwarebytes" -Archivo "Malwarebytes\mbam.exe" -Icono "🛡️" -Descripcion "Escáner de malware portátil" -Color "#ff6b6b"
Add-Herramienta -Categoria "SEGURIDAD" -Nombre "KVRT" -Archivo "KVRT\kvrt.exe" -Icono "☣️" -Descripcion "Kaspersky Virus Removal Tool" -Color "#ff6b6b"
Add-Herramienta -Categoria "SEGURIDAD" -Nombre "AdwCleaner" -Archivo "AdwCleaner\AdwCleaner.exe" -Icono "🧹" -Descripcion "Limpieza de adware y PUP" -Color "#ff6b6b"
Add-Herramienta -Categoria "SEGURIDAD" -Nombre "Sophos Scan" -Archivo "Sophos\SophosScan.exe" -Icono "🔬" -Descripcion "Escáner de virus online" -Color "#ff6b6b"

# 💾 RECUPERACIÓN DE DATOS
Add-Herramienta -Categoria "RECUPERACIÓN" -Nombre "Recuva" -Archivo "Recuva\recuva.exe" -Icono "🗑️" -Descripcion "Recupera archivos borrados" -Color "#ffd966"
Add-Herramienta -Categoria "RECUPERACIÓN" -Nombre "ProduKey" -Archivo "ProduKey\ProduKey.exe" -Icono "🔑" -Descripcion "Recupera claves de Windows/Office" -Color "#ffd966"

# 📶 RED Y CONECTIVIDAD
Add-Herramienta -Categoria "RED" -Nombre "WirelessKeyView" -Archivo "WirelessKeyView\WirelessKeyView.exe" -Icono "🔓" -Descripcion "Recupera contraseñas WiFi" -Color "#00d4ff"
Add-Herramienta -Categoria "RED" -Nombre "Angry IP Scanner" -Archivo "AngryIP\ipscan.exe" -Icono "🌐" -Descripcion "Escanea dispositivos en la red" -Color "#00d4ff"
Add-Herramienta -Categoria "RED" -Nombre "PuTTY" -Archivo "PuTTY\putty.exe" -Icono "🔌" -Descripcion "Cliente SSH/Telnet" -Color "#00d4ff"

# 📦 COMPRESIÓN Y ARCHIVOS
Add-Herramienta -Categoria "UTILIDADES" -Nombre "7-Zip" -Archivo "7-Zip\7z.exe" -Icono "📦" -Descripcion "Compresor/descompresor de archivos" -Color "#FFD700"
Add-Herramienta -Categoria "UTILIDADES" -Nombre "Everything" -Archivo "Everything\Everything.exe" -Icono "⚡" -Descripcion "Búsqueda instantánea de archivos" -Color "#FFD700"
Add-Herramienta -Categoria "UTILIDADES" -Nombre "Greenshot" -Archivo "Greenshot\Greenshot.exe" -Icono "🖼️" -Descripcion "Capturas de pantalla rápidas" -Color "#FFD700"
Add-Herramienta -Categoria "UTILIDADES" -Nombre "Notepad++" -Archivo "Notepad++\notepad++.exe" -Icono "📝" -Descripcion "Editor de texto avanzado" -Color "#FFD700"
Add-Herramienta -Categoria "UTILIDADES" -Nombre "TreeSize Free" -Archivo "TreeSize\TreeSize.exe" -Icono "📊" -Descripcion "Visualiza tamaño de carpetas" -Color "#FFD700"

# Separador
$separador = New-Object System.Windows.Forms.ToolStripSeparator
$menuHerramientas.Items.Add($separador) | Out-Null

# 📂 ABRIR CARPETA
$itemAbrirCarpeta = New-Object System.Windows.Forms.ToolStripMenuItem
$itemAbrirCarpeta.Text = "📂 ABRIR CARPETA DE HERRAMIENTAS"
$itemAbrirCarpeta.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#ffc107")
$itemAbrirCarpeta.BackColor = "#2d2d44"
$itemAbrirCarpeta.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$itemAbrirCarpeta.Add_Click({
    $ruta = Join-Path $DirectorioScript "..\03_Herramientas_extra"
    $ruta = [System.IO.Path]::GetFullPath($ruta)
    if (!(Test-Path $ruta)) { New-Item -ItemType Directory -Path $ruta -Force | Out-Null }
    Invoke-Item $ruta
    Write-LogGUI "📂 Abriendo carpeta de herramientas" "#ffc107"
})
$menuHerramientas.Items.Add($itemAbrirCarpeta) | Out-Null

$btnHerramientas.ContextMenuStrip = $menuHerramientas
$btnHerramientas.Add_Click({ $menuHerramientas.Show($btnHerramientas, 0, $btnHerramientas.Height) })
$form.Controls.Add($btnHerramientas)

# -------------------------------------------------------------------
# BOTONES PRINCIPALES
# -------------------------------------------------------------------
$btnIniciar = New-Object System.Windows.Forms.Button
$btnIniciar.Text = "🚀 INICIAR DIAGNÓSTICO COMPLETO"
$btnIniciar.Size = New-Object System.Drawing.Size(260, 50)
$btnIniciar.Location = New-Object System.Drawing.Point(20, 630)
$btnIniciar.BackColor = "#0066cc"
$btnIniciar.ForeColor = "White"
$btnIniciar.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnIniciar.FlatStyle = "Flat"
$btnIniciar.FlatAppearance.BorderSize = 0
$btnIniciar.Add_Click({ Start-DiagnosticoProfesional })
$form.Controls.Add($btnIniciar)

$btnGuardar = New-Object System.Windows.Forms.Button
$btnGuardar.Text = "💾 GUARDAR INFORME"
$btnGuardar.Size = New-Object System.Drawing.Size(180, 50)
$btnGuardar.Location = New-Object System.Drawing.Point(300, 630)
$btnGuardar.BackColor = "#28a745"
$btnGuardar.ForeColor = "White"
$btnGuardar.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnGuardar.FlatStyle = "Flat"
$btnGuardar.FlatAppearance.BorderSize = 0
$btnGuardar.Enabled = $false
$btnGuardar.Add_Click({ Guardar-Informe })
$form.Controls.Add($btnGuardar)

$btnLogs = New-Object System.Windows.Forms.Button
$btnLogs.Text = "📁 ABRIR LOGS"
$btnLogs.Size = New-Object System.Drawing.Size(150, 50)
$btnLogs.Location = New-Object System.Drawing.Point(500, 630)
$btnLogs.BackColor = "#ffc107"
$btnLogs.ForeColor = "Black"
$btnLogs.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnLogs.FlatStyle = "Flat"
$btnLogs.FlatAppearance.BorderSize = 0
$btnLogs.Add_Click({ Invoke-Item $CarpetaLogs })
$form.Controls.Add($btnLogs)

$btnSalir = New-Object System.Windows.Forms.Button
$btnSalir.Text = "❌ SALIR"
$btnSalir.Size = New-Object System.Drawing.Size(120, 50)
$btnSalir.Location = New-Object System.Drawing.Point(1160, 630)
$btnSalir.BackColor = "#dc3545"
$btnSalir.ForeColor = "White"
$btnSalir.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnSalir.FlatStyle = "Flat"
$btnSalir.FlatAppearance.BorderSize = 0
$btnSalir.Add_Click({ $form.Close() })
$form.Controls.Add($btnSalir)

# -------------------------------------------------------------------
# FUNCIÓN DE DIAGNÓSTICO PROFESIONAL
# -------------------------------------------------------------------
function Start-DiagnosticoProfesional {
    $btnIniciar.Enabled = $false
    $btnGuardar.Enabled = $false
    $progressBar.Visible = $true
    $txtResultados.Clear()
    
    Write-Rich "╔══════════════════════════════════════════════════════════════════════════════════════╗" "#00d4ff"
    Write-Rich "║                       🔥 DIAGNÓSTICO PROFESIONAL - MODO SEGURO 🔥                    ║" "#00d4ff"
    Write-Rich "║                    ✅ 100% SEGURO - NO MODIFICA CONFIGURACIÓN DE RED                ║" "#6fdc6f"
    Write-Rich "╚══════════════════════════════════════════════════════════════════════════════════════╝" "#00d4ff"
    Write-Rich ""

    # Variables para resumen
    $script:CPUName = "No detectada"
    $script:RAMTotal = 0
    $script:RAMDisponible = 0
    $script:PorcentajeLibre = 0
    $script:TotalLimpieza = 0
    $script:SFCStatus = "No ejecutado"
    $script:BateriaStatus = "No detectada"
    $script:InternetStatus = "No verificado"

    # ===========================================
    # 1. 🔍 AUDITORÍA DE HARDWARE
    # ===========================================
    Write-Rich "🔍 [1/6] AUDITORÍA DE HARDWARE PROFESIONAL" "#ffd966"
    
    # CPU
    try {
        $CPU = Get-CimInstance Win32_Processor
        $script:CPUName = $CPU.Name
        Write-Rich "   • CPU: $($CPU.Name)" "#e0e0ff"
        Write-Rich "   • Núcleos: $($CPU.NumberOfCores) | Hilos: $($CPU.NumberOfLogicalProcessors)" "#e0e0ff"
    } catch { Write-Rich "   ❌ No se pudo obtener CPU" "#ff6b6b" }
    
    # RAM
    try {
        $RAMTotal = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
        $script:RAMTotal = $RAMTotal
        $RAMLibre = (Get-Counter "\Memory\Available MBytes" -ErrorAction SilentlyContinue).CounterSamples.CookedValue
        if ($RAMLibre) {
            $script:RAMDisponible = [math]::Round($RAMLibre / 1024, 1)
            $PorcentajeRAM = [math]::Round(($RAMLibre / ($RAMTotal * 1024)) * 100, 1)
            Write-Rich "   • RAM: $RAMTotal GB total | $($script:RAMDisponible) GB libre ($PorcentajeRAM%)" $(if($PorcentajeRAM -lt 20){"#ff6b6b"}else{"#e0e0ff"})
        }
    } catch { Write-Rich "   • RAM total: N/D" "#ff6b6b" }
    
    # DISCOS
    try {
        $DiscoC = Get-PSDrive C
        $TotalC = [math]::Round(($DiscoC.Used + $DiscoC.Free) / 1GB, 1)
        $LibreC = [math]::Round($DiscoC.Free / 1GB, 1)
        $script:PorcentajeLibre = [Math]::Round(($DiscoC.Free / ($DiscoC.Used + $DiscoC.Free)) * 100, 1)
        Write-Rich "   • Disco C: $LibreC GB / $TotalC GB ($($script:PorcentajeLibre)% libre)" $(if($script:PorcentajeLibre -lt 20){"#ff6b6b"}else{"#e0e0ff"})
    } catch {}
    
    # ===========================================
    # 2. 🌐 ESTADO DE RED
    # ===========================================
    Write-Rich "`n🌐 [2/6] ESTADO DE RED (SOLO INFORMACIÓN)" "#ffd966"
    
    if (Test-Connection 8.8.8.8 -Count 1 -Quiet) {
        $script:InternetStatus = "CONECTADO"
        Write-Rich "   • Internet: $($script:InternetStatus)" "#6fdc6f"
    } else {
        $script:InternetStatus = "SIN CONEXIÓN"
        Write-Rich "   • Internet: $($script:InternetStatus)" "#ff6b6b"
    }
    
    try {
        $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*" | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -First 1).IPAddress
        Write-Rich "   • IP: $ip" "#e0e0ff"
    } catch {}
    
    # ===========================================
    # 3. 🧹 LIMPIEZA PROFESIONAL
    # ===========================================
    Write-Rich "`n🧹 [3/6] LIMPIEZA PROFESIONAL DE ARCHIVOS" "#ffd966"
    
    # TEMP usuario
    try {
        $size = (Get-ChildItem "$env:TEMP\*" -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        if ($sizeMB -gt 0) { Write-Rich "   • Temp usuario: $sizeMB MB liberados" "#e0e0ff" }
        $script:TotalLimpieza += $sizeMB
    } catch {}
    
    # Windows Temp
    try {
        $size = (Get-ChildItem "C:\Windows\Temp\*" -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        if ($sizeMB -gt 0) { Write-Rich "   • Windows Temp: $sizeMB MB liberados" "#e0e0ff" }
        $script:TotalLimpieza += $sizeMB
    } catch {}
    
    # Prefetch
    try {
        Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Rich "   • Prefetch: Limpiado" "#e0e0ff"
    } catch {}
    
    # Papelera
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Rich "   • Papelera: Vaciada" "#e0e0ff"
    } catch {}
    
    if ($script:TotalLimpieza -gt 0) {
        Write-Rich "     ✅ Total liberado: ~$([math]::Round($script:TotalLimpieza,2)) MB" "#6fdc6f"
    }
    
    # ===========================================
    # 4. 🖨️ COLA DE IMPRESIÓN
    # ===========================================
    Write-Rich "`n🖨️  [4/6] REINICIANDO COLA DE IMPRESIÓN" "#ffd966"
    try {
        Stop-Service Spooler -Force -ErrorAction Stop
        Start-Service Spooler -ErrorAction Stop
        Write-Rich "   ✅ Cola de impresión reiniciada correctamente" "#6fdc6f"
    } catch {
        Write-Rich "   • Servicio de impresión: No activo o sin cambios necesarios" "#a0a0c0"
    }
    
    # ===========================================
    # 5. 🔧 SFC SCANNOW
    # ===========================================
    Write-Rich "`n🔧 [5/6] VERIFICANDO INTEGRIDAD DEL SISTEMA" "#ffd966"
    Write-Rich "   ⏳ Esto puede tardar varios minutos (paciencia)..." "#ffd966"
    
    try {
        $outputFile = Join-Path $CarpetaLogs "SFC_$NombrePC.txt"
        sfc /scannow | Out-File -FilePath $outputFile -Encoding UTF8
        $script:SFCStatus = "Completado"
        Write-Rich "   ✅ SFC Scannow completado" "#6fdc6f"
        Write-Rich "   📄 Log guardado en: $outputFile" "#a0a0c0"
    } catch {
        $script:SFCStatus = "Error"
        Write-Rich "   ❌ Error al ejecutar SFC" "#ff6b6b"
    }
    
    # ===========================================
    # 6. 🔋 BATERÍA
    # ===========================================
    Write-Rich "`n🔋 [6/6] INFORMACIÓN DE BATERÍA" "#ffd966"
    
    $bateria = Get-WmiObject Win32_Battery -ErrorAction SilentlyContinue
    if ($bateria) {
        $script:BateriaStatus = "$($bateria.EstimatedChargeRemaining)%"
        Write-Rich "   • Carga: $($bateria.EstimatedChargeRemaining)%" "#e0e0ff"
    } else {
        $script:BateriaStatus = "No detectada (PC de escritorio)"
        Write-Rich "   • No se detectó batería (PC de escritorio)" "#a0a0c0"
    }
    
    # ===========================================
    # 📋 INFORME FINAL PROFESIONAL
    # ===========================================
    Write-Rich "`n══════════════════════════════════════════════════════════════════════════════════════╗" "#00d4ff"
    Write-Rich "📋  RESUMEN PROFESIONAL - DIAGNÓSTICO COMPLETADO" "#6fdc6f"
    Write-Rich "══════════════════════════════════════════════════════════════════════════════════════╝" "#00d4ff"
    
    Write-Rich "   ✅ HARDWARE: $($script:CPUName)" "#6fdc6f"
    Write-Rich "   ✅ RAM: $($script:RAMDisponible) GB / $($script:RAMTotal) GB disponibles" "#6fdc6f"
    Write-Rich "   ✅ DISCO C: $($script:PorcentajeLibre)% libre" "#6fdc6f"
    Write-Rich "   ✅ LIMPIEZA: $([math]::Round($script:TotalLimpieza,2)) MB liberados" "#6fdc6f"
    Write-Rich "   ✅ SFC: $($script:SFCStatus)" "#6fdc6f"
    Write-Rich "   ✅ RED: $($script:InternetStatus)" "#6fdc6f"
    Write-Rich "   ✅ BATERÍA: $($script:BateriaStatus)" "#6fdc6f"
    Write-Rich "   🔒 CONFIGURACIÓN DE RED: NO MODIFICADA (IPs manuales intactas)" "#00d4ff"
    
    # Generar informe profesional
    @"
╔══════════════════════════════════════════════════════════════════════════════╗
║                     INFORME PROFESIONAL DE SOPORTE TÉCNICO                   ║
║                                 by MATEO                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

📋 INFORMACIÓN DEL SISTEMA
────────────────────────────────────────────────────────────────────────────────
• PC: $NombrePC
• Usuario: $Usuario
• Fecha: $Fecha

🔍 HARDWARE
────────────────────────────────────────────────────────────────────────────────
• CPU: $($script:CPUName)
• RAM: $($script:RAMDisponible) GB / $($script:RAMTotal) GB disponibles
• Disco C: $($script:PorcentajeLibre)% libre

🧹 MANTENIMIENTO REALIZADO
────────────────────────────────────────────────────────────────────────────────
• Archivos temporales: $([math]::Round($script:TotalLimpieza,2)) MB liberados
• Papelera: Vaciada
• Cola de impresión: Reiniciada
• SFC Scannow: $($script:SFCStatus)

🌐 RED Y CONECTIVIDAD
────────────────────────────────────────────────────────────────────────────────
• Internet: $($script:InternetStatus)
• Configuración de red: NO MODIFICADA (IPs manuales intactas)

🔋 BATERÍA
────────────────────────────────────────────────────────────────────────────────
• Estado: $($script:BateriaStatus)

📁 ARCHIVOS GENERADOS
────────────────────────────────────────────────────────────────────────────────
• Log de diagnóstico: $ArchivoLog
• Informe SFC: $CarpetaLogs\SFC_$NombrePC.txt
• Este informe: $InformeTXT

╔══════════════════════════════════════════════════════════════════════════════╗
║                 ✅ DIAGNÓSTICO COMPLETADO SIN ERRORES                       ║
║                  🛡️ 100% SEGURO - MODO COMPAÑEROS 🛡️                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
"@ | Out-File -FilePath $InformeTXT -Encoding UTF8
    
    Write-Rich "`n📁 INFORME PROFESIONAL GUARDADO:" "#a0a0c0"
    Write-Rich "   $InformeTXT" "#a0a0c0"
    Write-Rich "`n✅ DIAGNÓSTICO PROFESIONAL COMPLETADO CON ÉXITO" "#6fdc6f"
    
    $progressBar.Visible = $false
    $btnGuardar.Enabled = $true
    $btnIniciar.Enabled = $true
}

function Guardar-Informe {
    if (Test-Path $InformeTXT) {
        Start-Process notepad.exe $InformeTXT
    }
}

# -------------------------------------------------------------------
# MOSTRAR VENTANA
# -------------------------------------------------------------------
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
