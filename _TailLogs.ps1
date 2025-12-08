#TODO refactor and cleanup
$logFile = "C:\Users\$env:USERNAME\AppData\Roaming\r2modmanPlus-local\HadesII\profiles\Default\ReturnOfModding\LogOutput.log"

# Variables for tracking log state
$currentColor = $null
$currentEntry = @()  # Buffer to store multi-line log entries
$shouldFilter = $false  # Flag to determine if an entry should be filtered

Get-Content -Path $logFile -Wait | ForEach-Object {
    $line = $_

    # Check if this line is the start of a new log entry
    if ($line -match "^\[(\d+):(\d+):(\d+)\.\d+\]")
    {
        # Process the previous log entry before starting a new one
        if (-not $shouldFilter -and $currentEntry.Count -gt 0)
        {
            foreach ($entry in $currentEntry)
            {
                if ($currentColor)
                {
                    Write-Host $entry -ForegroundColor $currentColor
                }
                else
                {
                    Write-Host $entry
                }
            }
        }

        # Reset state for new log entry
        $currentEntry = @()
        $shouldFilter = $false
        $currentColor = $null

        # Extract and format timestamp
        $hour = [int]$matches[1]
        $minute = [int]$matches[2]
        $second = [int]$matches[3]
        $formattedTime = "{0:D2}:{1:D2}:{2:D2}" -f $hour, $minute, $second

        # Determine log level and color/filter
        if ($line -match "\[INFO/log_write\.hpp:64\]")
        {
            $shouldFilter = $true
        }
        elseif ($line -match "Warning")
        {
            $currentColor = "Yellow"
        }
        elseif ($line -match "Error")
        {
            $currentColor = "Red"
        }
        elseif ($line -match "Info")
        {
            $currentColor = "White"
        }

        # Replace timestamp and remove second bracket pair entirely
        $line = $line -replace "^\[\d+:\d+:\d+\.\d+\]", "[$formattedTime]"
        $line = $line -replace "^\[[^\]]+\]\[[^\]]+\]\s*", "[$formattedTime] "

        $currentEntry += $line
    }
    else
    {
        # Append multi-line log continuation
        $currentEntry += $line
    }
}
