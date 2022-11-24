param (
    [switch]$Help = $False,
    [string]$Path
)

# Process Help
if ($Help -eq $true) {
    "Verify Drivers/Executables are Authenticode signed"
    ""
    "USAGE:"
    "  $($MyInvocation.MyCommand.Name) FILE"
    ""
    "OPTIONS:"
    "  -Path [PATH]      Path to ISO file or mountpoint"
    "  -Help             Show this help message"
    ""
    exit
}

function Log-Info {
    param(
        [Parameter(Mandatory = $true)][string] $Message
    )
    $ts = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lvlStr = [string]::new("INFO").PadLeft(8)
    Write-Host "$ts [$lvlStr] $Message"
}

function Log-Success {
    param(
        [Parameter(Mandatory = $true)][string] $Message
    )
    $ts = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lvlStr = [string]::new("SUCCESS").PadLeft(8)
    Write-Host -ForegroundColor Green "$ts [$lvlStr] $Message"
}

function Log-Error {
    param(
        [Parameter(Mandatory = $true)][string] $Message
    )
    $ts = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lvlStr = [string]::new("ERROR").PadLeft(8)
    Write-Host -ForegroundColor Red "$ts [$lvlStr] $Message"
}


if ([string]::IsNullorEmpty($Path)) {
    Log-Error "File Path not specified or invalid!"
    exit 1
}

# Get Absolute path
try {
    $AbsolutePath = Resolve-Path -Path $Path | Select-Object -ExpandProperty Path
    if ([string]::IsNullorEmpty($AbsolutePath)) {
        throw "Failed to resolve $Path to absolute path"
    }
}
catch {
    Log-Error "$($_.Exception)"
    exit 1
}


$UnmountISO = $False

if (Test-Path -ErrorAction SilentlyContinue -PathType Container $AbsolutePath) {
    Log-Info "Mountpoint - $Path"
    $MountPoint = $Path
}
elseif (Test-Path -ErrorAction SilentlyContinue -PathType Leaf $AbsolutePath) {
    Log-Info "ISO File - $Path"
    try {
        Log-Info "Checking if file is already mounted"
        $DiskImage = Get-DiskImage -ImagePath $AbsolutePath -StorageType ISO -ErrorAction SilentlyContinue
        if (($DiskImage.Attached)) {
            Log-Success "Already mounted ISO File - $AbsolutePath"
        }
        else {
            Log-Info "Mounting ISO File - $AbsolutePath"
            $DiskImage = Mount-DiskImage -StorageType ISO -ImagePath $AbsolutePath -ErrorAction SilentlyContinue
            if (!($DiskImage.Attached)) {
                throw "Failed to mount iso file - $AbsolutePath"
            }
            else {
                $UnmountISO = $True
                Log-Success "Mounted ISO File - $AbsolutePath"
            }
        }
    }
    catch {
        Log-Error "$($_.Exception)"
        exit 1
    }
    # Either we mounted the ISO or we already have it mounted.
    $MountVolume = Get-Volume -DiskImage $DiskImage -ErrorAction SilentlyContinue
    $MountPoint = [string]::Format("{0}:\", $MountVolume.DriveLetter)
}
else {
    Log-Error "Path - $AbsolutePath is invalid!"
    exit 1
}

# List of files to verify
Log-Info "Collecting files to verify at - $MountPoint"
$FilesToVerify = Get-ChildItem -Recurse -File $MountPoint | Where-Object { !$_.PSIsContainer } | Select-Object -ExpandProperty FullName | Where-Object { $_.EndsWith(".cat") -or $_.EndsWith(".exe") -or $_.EndsWith(".msi") -or $_.EndsWith("sys") -or $_.EndsWith(".dll") } | Where-Object { !$_.EndsWith("qemu-ga-x86_64.msi") -and !$_.EndsWith("qemu-ga-i386.msi") }
Log-Info "Collected  files to verify at - $MountPoint [$($FilesToVerify.Length)]"
$errCount = 0
try {
    foreach ($item in $FilesToVerify) {
        Log-Info "Checking - $item"
        if (Test-Path -ErrorAction SilentlyContinue $item) {
            $itemSignature = Get-AuthenticodeSignature -FilePath $item -ErrorAction SilentlyContinu
            if ($itemSignature.Status -eq "Valid") {
                Log-Success "$($itemSignature.StatusMessage)"
            }
            else {
                Log-Error "$($itemSignature.StatusMessage)"
                $errCount++
            }
        }
        else {
            Log-Error "File not found - $item"
            $errCount++
        }
    }
}
catch {
    Log-Error "Error occured - $($_.Exception)"
    if ($UnmountISO) {
        Log-Info "Unmounting ISO - $AbsolutePath"
        try {
            Dismount-DiskImage -ImagePath $AbsolutePath -ErrorAction SilentlyContinue | Out-Null
        } catch {
            Log-Error "$($_.Exception)"
        }
    }
    exit 1
}


if ($errCount -gt 0) {
    Log-Error "$errCount files failed verification"
    if ($UnmountISO) {
        Log-Info "Unmounting ISO - $AbsolutePath"
        try {
            Dismount-DiskImage -ImagePath $AbsolutePath -ErrorAction SilentlyContinue | Out-Null
        } catch {
            Log-Error "$($_.Exception)"
        }
    }
    exit 1
}
else {
    Log-Success "All files passed verification"
    if ($UnmountISO) {
        Log-Info "Unmounting ISO - $AbsolutePath"
        try {
            Dismount-DiskImage -ImagePath $AbsolutePath -ErrorAction SilentlyContinue | Out-Null
        } catch {
            # dont exit with non zero as files are verified.
            Log-Error "$($_.Exception)"
        }
    }
}
