$Logfile = "C:\Your\Desired\Path\log.log" # Log file destination
$ServiceList = @('YourService', 'YourServiceTwo') # Input the name of the services you wish to restart
$ProcessError = ""

function Stop-AllServices {
    param (
        $ServiceList
    )
    LogWrite "$(Get-Date) Preparing to restart all services"
    foreach($ServiceName in $ServiceList) {
        if ((Get-Service -Name $ServiceName).Status -eq 'Running') {
			LogWrite "$(Get-Date) : $($ServiceName) is running, preparing to stop..."
			Get-Service -Name $ServiceName | Stop-Service -ErrorAction SilentlyContinue -ErrorVariable ProcessError
            if ((Get-Service -Name $ServiceName).Status -eq 'Stopped') {
                LogWrite "$(Get-Date) : $($ServiceName) has successfully stopped"
            }
		} elseif ((Get-Service -Name $ServiceName).Status -eq 'Stopped') {
            LogWrite "$(Get-Date) : $($ServiceName) already stopped!"
		} else {
            LogWrite "$(Get-Date) : $($ServiceName) - Service is in neither running nor stopped state"
		}
    }
}

function Start-AllServices {
    param (
        $ServiceList
    )
    foreach ($ServiceName in $ServiceList) {
        Get-Service -Name $ServiceName | Start-Service -ErrorAction SilentlyContinue -ErrorVariable ProcessError
        Start-Sleep -s 10
        if ((Get-Service -Name $ServiceName).Status -eq 'Stopped') {
            LogWrite "$(Get-Date) : $($ServiceName) has failed to start. $($ProcessError)"
        } else {
            LogWrite "$(Get-Date) : $($ServiceName) has started sucessfully"
        }
    }
}

function LogWrite {
   Param (
        [Parameter(Mandatory=$true)][string]$LogString
    )
   Add-content $Logfile $LogString
}

Stop-AllServices $ServiceList
Start-AllServices $ServiceList
