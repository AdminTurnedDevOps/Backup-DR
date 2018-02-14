$ConfirmPreference='high'
function New-WinBackup {
[cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    
    param (

        [parameter(Mandatory=$true,
                HelpMessage='Please provide a network path to save your backup')]
        [ValidateNotNullOrEmpty()]
        [string]$NetworkPath,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('D:' , 'E:' , 'I:')]
        [string]$DriveToBackup,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupReport = (Read-Host "Please specify a location for your backup")
)
    Begin{ Write-Verbose "Starting the creation of the backup policy" }

    Process {

        Write-Verbose "Creating a new Windows Backup polic"
            #Creates a new backup policy.
            $BackupPolicy = New-WBPolicy

        Write-Verbose "retrieving backup volume, adding backup volume, and adding system state backup"
                            #Gets volume that you want to back up.
            $BackupVolume = Get-WBVolume -VolumePath $DriveToBackup
                            #Add's the backup volume that you specified and specifies your backup policy.
                            Add-WBVolume -Policy $BackupPolicy -Volume $BackupVolume
                            #Add's system state to your backup.
                            Add-WBSystemState -Policy $BackupPolicy

        Write-Verbose "Creating target path, adding target path, and setting target path"
                                #Specifies your backup target.
            $TargetBackupPath = New-WBBackupTarget -NetworkPath $NetworkPath
                                #Add's your backup target and specifies backup policy.
                                Add-WBBackupTarget -Policy $BackupPolicy -Target $TargetBackupPath
                                #Sets your backup options. In this case we are doing a full.
                                Set-WBVssBackupOptions -Policy $BackupPolicy -VssFullBackup

         Write-Verbose "Starting backup"
                                #This starts the backup with the specified backup policy.
                                Start-WBBackup -Policy $BackupPolicy

                                Get-WBSummary | out-file "$BackupReport\BackupReport $(Get-Date -Format yyyy-MM-dd).txt"
            } #Process
    End{}
} #Function