param (
    [Alias('h')]
    [switch]$Help = $False,
    [Alias('b')]
    [string]$BasePath
)


# Process Help
if ($Help -eq $true) {
    "Verify Drivers/Executables are Authenticode signed"
    ""
    "RQEUIRMENTS:"
    "  - Windows 10 20H2 or higher"
    "  - Windows Powershell 5.1 or higher"

    ""
    "USAGE:"
    "  $($MyInvocation.MyCommand.Name) [OPTIONS]"
    ""
    "OPTIONS:"
    "  -b, -basepath [PATH]  Base Path"
    "  -h, -help             Show this help message"
    ""
    exit
}


function _LoggerCore() {
    param(
        [Parameter(Mandatory=$true)][string] $Message,
        [validateset("debug", "info", "success", "warn", "error")]
        [Parameter(Mandatory=$false)][string] $Level = "info"
    )

    $ts = $(get-date).ToString("yyyy-MM-dd HH:mm:ss")

    switch ($Level) {
        debug {
            $lvlColor = "DarkGray"
            $lvlNum = 10
            $lvlName = "DEBUG"
        }
        info {
            $lvlColor = $null
            $lvlNum = 20
            $lvlName = "INFO"
        }
        success {
            $lvlColor = "Green"
            $lvlNum = 20
            $lvlName = "SUCCESS"
        }
        warn {
            $lvlColor = "Yellow"
            $lvlNum = 30
            $lvlName = "WARN"
        }
        error {
            $lvlColor = "Red"
            $lvlNum = 40
            $lvlName = "ERROR"
        }
        Default {
            $lvlColor = $null
            $lvlNum = 0
            $lvlName = "UNKNOWN"
        }
    }
    $lvlStr = $lvlName.PadLeft(8)

    if ($LogTrace -eq $true -or $DEBUG) {
        $glvl = 0
    } else {
        $glvl = 20
    }
    if ( $lvlNum -ge $glvl) {
        if ( $null -eq $lvlColor ) {
            Write-Host "$ts [$lvlStr] $Message"
        } else {
            Write-Host -ForegroundColor "$lvlColor" "$ts [$lvlStr] $Message"
        }
    }
}


function Log-Debug {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    _LoggerCore -Level "debug" -Message "$Message"
}


function Log-Info {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    _LoggerCore -Level "info" -Message "$Message"
}

function Log-Success {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    _LoggerCore -Level "success" -Message "$Message"
}

function Log-Warning {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    _LoggerCore -Level "warn" -Message "$Message"
}

function Log-Error {
    param(
        [Parameter(Mandatory=$true)][string] $Message
    )
    _LoggerCore -Level "error" -Message "$Message"
}


if ([string]::IsNullorEmpty($BasePath)) {
    Log-Error "Base path not specified!"
    exit 1
}

if (!(Test-Path -ErrorAction SilentlyContinue -PathType Container $BasePath)) {
    Log-Error "Base Path is invalid!"
    exit 1
} else {
    Log-Info "Base Path is set to - $BasePath"
}

# List of files to verify
Log-Info "Collecting files to verify"
$FilesToVerify = Get-ChildItem -Recurse -File $BasePath | Where {!$_.PSIsContainer} | Select-Object -ExpandProperty FullName | Where {$_.EndsWith(".cat") -or $_.EndsWith(".exe") -or $_.EndsWith(".msi") -or $_.EndsWith("sys") -or $_.EndsWith(".dll")} | Where {!$_.EndsWith("qemu-ga-x86_64.msi") -and !$_.EndsWith("qemu-ga-i386.msi") }

$errCount = 0

try {
    Log-Info "Verifying Signatures"
    $index=0
    foreach($file in $FilesToVerify) {
        $index++
        $FileFullPath = Resolve-Path  -Path $file
        Log-Info "Checking - $FileFullPath"
        if(Test-Path -ErrorAction SilentlyContinue $FileFullPath){
            if ((Get-AuthenticodeSignature -FilePath $FileFullPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Status) -eq "Valid") {
                Log-Success "Authenticode Signature - VALID"
            } else {
                Log-Error "Authenticode Signature - INVALID!"
                $errCount++
            }
        } else {
            Log-Error "File not found - $FileFullPath"
            $errCount++
        }
    }
} catch {
    Log-Error "Error occured - $PSItem"
    exit 1
}


if ($errCount -gt 0) {
    Log-Error "$errCount files failed verification"
    exit 1
} else {
    Log-Success "All files passed verification"
}
