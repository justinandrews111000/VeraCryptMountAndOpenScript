# Author: Justin Andrews
# PowerShell Script: OpenEncryptedContainer.ps1

# Function to prompt for the password securely and convert to plain text
function Get-PlainTextPassword {
    $securePassword = Read-Host "Enter the password for the VeraCrypt container: " -AsSecureString
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
}

# Path to VeraCrypt
$veracryptPath = "C:\Program Files\VeraCrypt\VeraCrypt.exe"

# Path to the encrypted container file
$containerPath = "C:\path\to\your\encrypted_container.hc"

# Drive letter to mount the container
$driveLetter = "Y:"

# Retry Seninal 
$success = $false

while (-not $success) {
    $passwordPlainText = Get-PlainTextPassword

    # Mount the container
    $process = Start-Process -FilePath $veracryptPath -ArgumentList "/v `"$containerPath`" /l $driveLetter /p `"$passwordPlainText`" /q /s /m rm" -NoNewWindow -Wait -PassThru

    # Clear the plain text password from memory
    $passwordPlainText = $null
    [GC]::Collect()

    if ($process.ExitCode -eq 0) {
        $success = $true
        Write-Host "VeraCrypt container mounted successfully on drive $driveLetter."

        # Open the mounted drive in File Explorer
        Start-Process explorer.exe $driveLetter
                # Wait for the user to press Enter to unmount
        Read-Host -Prompt "Press Enter to unmount the VeraCrypt container"

        # Unmount the container
        $unmountProcess = Start-Process -FilePath $veracryptPath -ArgumentList "/d $driveLetter /q /s" -NoNewWindow -Wait -PassThru

        if ($unmountProcess.ExitCode -eq 0) {
            Write-Host "VeraCrypt container unmounted successfully."
        } else {
            Write-Host "Failed to unmount the VeraCrypt container."
        }
    } else {
        Write-Host "Failed to mount the VeraCrypt container. Please try again."
    }
}
