@echo off
setlocal EnableDelayedExpansion

:: === DEFINISCI IL PERCORSO DEL TOOL ===
set TOOLPATH=%~dp0SquashFS
set MKTOOL=%TOOLPATH%\mksquashfs.exe

:: === VERIFICA PRESENZA TOOL ===
if not exist "%MKTOOL%" (
    echo ERRORE: Non trovo "%MKTOOL%"
    echo Assicurati che "mksquashfs.exe" sia nella cartella "SquashFS" accanto al file .bat.
    pause
    exit /b
)

:inizio
:: === CREA SCRIPT PER SCEGLIERE CARTELLA ===
echo Add-Type -AssemblyName System.Windows.Forms > select_folder.ps1
echo $dialog = New-Object System.Windows.Forms.FolderBrowserDialog >> select_folder.ps1
echo $dialog.Description = "Seleziona la cartella da comprimere" >> select_folder.ps1
echo if ($dialog.ShowDialog() -eq "OK") { $dialog.SelectedPath } >> select_folder.ps1

:: === CREA SCRIPT PER FILE DI DESTINAZIONE ===
echo Add-Type -AssemblyName System.Windows.Forms > select_file.ps1
echo $dialog = New-Object System.Windows.Forms.SaveFileDialog >> select_file.ps1
echo $dialog.Filter = "SquashFS Files (*.wsquashfs)|*.wsquashfs" >> select_file.ps1
echo $dialog.Title = "Seleziona file di destinazione" >> select_file.ps1
echo if ($dialog.ShowDialog() -eq "OK") { $dialog.FileName } >> select_file.ps1

:: === OTTIENI CARTELLA INPUT ===
for /f "delims=" %%i in ('powershell -STA -File select_folder.ps1') do set INPUT=%%i
if "%INPUT%"=="" (
    echo Nessuna cartella selezionata. Annullato.
    goto fine
)

:: === OTTIENI FILE OUTPUT ===
for /f "delims=" %%i in ('powershell -STA -File select_file.ps1') do set OUTPUT=%%i
if "%OUTPUT%"=="" (
    echo Nessun file di destinazione selezionato. Annullato.
    goto fine
)

:: === PULIZIA SCRIPT TEMPORANEI ===
del select_folder.ps1 >nul 2>&1
del select_file.ps1 >nul 2>&1

:: === COMPRESSIONE ===
echo.
echo Compressione in corso...
"%MKTOOL%" "%INPUT%" "%OUTPUT%" -comp xz -processors 4 -noappend -all-root
echo.
echo Compressione completata!
echo File creato: %OUTPUT%
echo.

:: === CHIEDI SE RIPETERE ===
choice /m "Vuoi comprimere un'altra cartella?"
if errorlevel 2 goto fine
goto inizio

:fine
pause
exit /b
