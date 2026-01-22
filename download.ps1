# Stop on error
$ErrorActionPreference = "Stop"

$ProgressPreference = 'SilentlyContinue'

# Base directories
$RootDir = Get-Location
$DownloadsDir = Join-Path $RootDir "downloads"
$OpenCVDir    = Join-Path $RootDir "opencv-static/windows-x64"
$OrtDir       = Join-Path $RootDir "onnxruntime-static/windows-x64"
$OrtGpuDir       = Join-Path $RootDir "onnxruntime-gpu/windows-x64"

# Delete old folders if they exist
if (Test-Path $OpenCVDir) {
    Write-Host "Removing old OpenCV directory..."
    Remove-Item $OpenCVDir -Recurse -Force
}
if (Test-Path $OrtDir) {
    Write-Host "Removing old ONNX Runtime directory..."
    Remove-Item $OrtDir -Recurse -Force
} if (Test-Path $OrtGpuDir) {
    Write-Host "Removing old ONNX Runtime (GPU) directory..."
    Remove-Item $OrtGpuDir -Recurse -Force
}

# Create directories
New-Item -ItemType Directory -Force -Path $DownloadsDir | Out-Null
New-Item -ItemType Directory -Force -Path $OpenCVDir | Out-Null
New-Item -ItemType Directory -Force -Path $OrtDir | Out-Null
New-Item -ItemType Directory -Force -Path $OrtGpuDir | Out-Null

# -------------------------
# Download OpenCV
# -------------------------
$OpenCVUrl = "https://github.com/RapidAI/OpenCVBuilder/releases/download/4.11.0/opencv-4.11.0-windows-vs2022-x64-mt.7z"
$OpenCV7z  = Join-Path $DownloadsDir "opencv-4.11.0-windows-vs2022-x64-mt.7z"


if (!(Test-Path $OpenCV7z)) {
    Write-Host "Downloading OpenCV..."
    Invoke-WebRequest -Uri $OpenCVUrl -OutFile $OpenCV7z
} else {
    Write-Host "OpenCV archive already exists, skipping download."
}

Write-Host "Extracting OpenCV..."
7z x $OpenCV7z "-o$OpenCVDir" -y | Out-Null

# Move extracted contents up one level
$OpenCVExtractedDir = Join-Path $OpenCVDir "opencv-4.11.0-windows-vs2022-x64-mt"
if (Test-Path $OpenCVExtractedDir) {
    Write-Host "Flattening OpenCV directory..."
    Move-Item "$OpenCVExtractedDir\*" $OpenCVDir -Force
    Remove-Item $OpenCVExtractedDir -Recurse -Force
}

# -------------------------
# Download ONNX Runtime
# -------------------------
$OrtUrl = "https://github.com/RapidAI/OnnxruntimeBuilder/releases/download/1.23.2/onnxruntime-v1.23.2-windows-vs2022-x64-static-mt.7z"
$Ort7z  = Join-Path $DownloadsDir "onnxruntime-v1.23.2-windows-vs2022-x64-static-mt.7z"


if (!(Test-Path $Ort7z)) {
    Write-Host "Downloading ONNX Runtime..."
    Invoke-WebRequest -Uri $OrtUrl -OutFile $Ort7z
} else {
    Write-Host "ONNX Runtime archive already exists, skipping download."
}

Write-Host "Extracting ONNX Runtime..."
7z x $Ort7z "-o$OrtDir" -y | Out-Null


# Move extracted contents up one level
$OrtExtractedDir = Join-Path $OrtDir "onnxruntime-v1.23.2-windows-vs2022-x64-static-mt"
if (Test-Path $OrtExtractedDir) {
    Write-Host "Flattening ONNX Runtime directory..."
    Move-Item "$OrtExtractedDir\*" $OrtDir -Force
    Remove-Item $OrtExtractedDir -Recurse -Force
}

# Ensure ONNX Runtime include structure matches expected layout
$OrtInclude = Join-Path $OrtDir "include"
$TargetSessionDir = Join-Path $OrtInclude "onnxruntime/core/session"
if (!(Test-Path $TargetSessionDir)) {
    New-Item -ItemType Directory -Force -Path $TargetSessionDir | Out-Null
}
# Move all .h files from include to onnxruntime/core/session if not already there
Get-ChildItem -Path $OrtInclude -File -Filter *.h | ForEach-Object {
    Move-Item $_.FullName $TargetSessionDir -Force
}

# -------------------------
# Download ONNX Runtime (GPU)
# -------------------------
$OrtGpuUrl = "https://github.com/microsoft/onnxruntime/releases/download/v1.17.3/onnxruntime-win-x64-gpu-1.17.3.zip"
$OrtGpuZip  = Join-Path $DownloadsDir "onnxruntime-win-x64-gpu-1.17.3.zip"


if (!(Test-Path $OrtGpuZip)) {
    Write-Host "Downloading ONNX Runtime (GPU)..."
    Invoke-WebRequest -Uri $OrtGpuUrl -OutFile $OrtGpuZip
} else {
    Write-Host "ONNX Runtime (GPU) archive already exists, skipping download."
}

Write-Host "Extracting ONNX Runtime (GPU)..."
7z x $OrtGpuZip "-o$OrtGpuDir" -y | Out-Null


# Move extracted contents up one level
$OrtExtractedDir = Join-Path $OrtGpuDir "onnxruntime-win-x64-gpu-1.17.3"
if (Test-Path $OrtExtractedDir) {
    Write-Host "Flattening ONNX Runtime directory..."
    Move-Item "$OrtExtractedDir\*" $OrtGpuDir -Force
    Remove-Item $OrtExtractedDir -Recurse -Force
}

# Ensure ONNX Runtime include structure matches expected layout
$OrtGpuInclude = Join-Path $OrtGpuDir "include"
$TargetSessionDir = Join-Path $OrtGpuInclude "onnxruntime/core/session"
if (!(Test-Path $TargetSessionDir)) {
    New-Item -ItemType Directory -Force -Path $TargetSessionDir | Out-Null
}
# Move all .h files from include to onnxruntime/core/session if not already there
Get-ChildItem -Path $OrtGpuInclude -File -Filter *.h | ForEach-Object {
    Move-Item $_.FullName $TargetSessionDir -Force
}

Write-Host "Done."
Write-Host "OpenCV available at: $OpenCVDir"
Write-Host "ONNX Runtime available at: $OrtDir"
Write-Host "ONNX Runtime (GPU) available at: $OrtGpuDir"
