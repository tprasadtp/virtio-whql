param (
    [Alias('h')]
    [switch]$Help = $False,
    [Alias('l')]
    [string]$List,
    [Alias('b')]
    [string]$BasePath
)


# Process Help
if ($Help -eq $true) {
    "Verify List of files are Authenticode signed"
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
    "  -l, -list [PATH]      Path to list file"
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


# check if file exists
if (!(Test-Path -ErrorAction SilentlyContinue $List)) {
    Log-Error "File not found - $List"
    exit 1
} else {
    Log-Info "List Path is set to - $List"
}


if (!(Test-Path -ErrorAction SilentlyContinue -PathType Container $BasePath)) {
    Log-Error "Base Path is not specified!"
    exit 1
} else {
    Log-Info "Base Path is set to - $BasePath"
}

$errCount = 0

try {
    Log-Info "Verifying Signatures"
    $index=0
    foreach($line in Get-Content $List) {
        $index++
        if (![string]::IsNullOrWhiteSpace($line)) {
            $FileFullPath = Join-Path -Path $BasePath -ChildPath $line
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
        } else {
            Log-Warning "Ignoring empty item at line $index"
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
