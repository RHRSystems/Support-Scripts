# Script to back up log files from different environments
# Randy Raskin

$today = (Get-Date -Format "yyyyMMdd")
$hosthome = (Get-ComputerInfo).CSName

if (Select-String -Pattern "dev" -InputObject $hosthome) {
    $Hosts = "us1dev1", "us1dev2", "us1dev3"
    $Env = "DEV"
} elseif (Select-String -Pattern "qa" -InputObject $hosthome) {
    $Hosts = "us1qa1", "us1qa2", "us1qa3"
    $Env = "QA"
} else {  #we know the rest are the PROD boxes
    $Hosts = "us1", "us2", "us3"
    $Env = "PROD"
}

foreach ($item in $Hosts) { #now loop through the log directory in each env

    $sourcePath = "\\$item\c$\InternalAPP\server\logs"
    $destinationPath = "\\usfiler5\Systems\Applications\Logs\$Env\$item"

    Write-Host ""
    Write-Host "Running for - $item : $sourcePath ---> $destinationPath"

    try {
            #First remove old files based on dates
            $files = Get-ChildItem -Path $destinationPath -Recurse
            Set-Location -Path $destinationPath

            foreach ($file in $files) {
                $last_modified = $file.LastWriteTime
                $time_diff_in_days = [math]::Floor(((Get-Date) - $last_modified).TotalDays)

                if ($time_diff_in_days -gt 31) {
                    Write-Host "Removing old file - $file, which is $time_diff_in_days old."

                    try {
                            Remove-Item $file -Force -ErrorAction SilentlyContinue
                    } catch {
                            Write-Host "Error occurred removing old file: $_"
                    }
                }
         }

    } catch {
            Write-Host "Error occurred removing old files. $_"
    }

    #Now copy over and rename new files
    try {
            Write-Host "Copying..."
            Get-ChildItem -Path $sourcePath\apps*.log | Copy-Item -Destination {$_.Name + "." + $today }
    } catch {
            Write-Host "Error occurred copying: $_"
    }
}
