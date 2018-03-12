$ConfirmPreference='medium'
Function New-SQLBackup {
[cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='medium')]
param (
    [parameter(Mandatory=$true)]
    [ValidateSet('#Specify a location if you would like in here')]
    [ValidateNotNullOrEmpty()]
    [Alias("DestinationLocation","DBLocation","BackupTo")]
    [string]$BackupLocation,
    
    [parameter(Mandatory=$true)]
    [ValidateSet('#Specify a specific DB if youd like')]
    [ValidateNotNullOrEmpty()]
    [Alias("Instance","DBInstance")]
    [dbainstance]$SQLInstance,

    [string]$SavedErrorLog = "C:\Users\$ENV:USERNAME\Desktop\SQLScriptErrorLog.txt"
)
Begin {}

Process {
        TRY {
            Write-Verbose 'Collecting SQL Backup parameters'
            #Collect backup parameters with specified instance and backup location.
            $SQLBackupParams = @{ 'SqlInstance'=$SQLInstance
                                  'BackupDirectory'=$BackupLocation
                                  'Database'='era_db'
                                  'Type'='Full'
                                }

                IF ($PSCmdlet.ShouldProcess($SQLInstance)) {
                    Write-Verbose 'Starting backup on specified SQL instance'
                    #Back up DB
                    Backup-DbaDatabase @SQLBackupParams
                    Write-Verbose 'Backup complete'
            
            Write-Verbose 'Starting process for testing backup'
            Write-Verbose 'Prompting to test for backup'
            $Y_or_N = Read-Host 'The backup has completed. Would you like to test the backup and retrieve information Y or yes N or no?'
                IF ($Y_or_N -like 'y') {
                    Write-Verbose 'Testing DB backup'
                                
                     $SQLTestBackup = @{
                                        'SqlInstance'=$SQLInstance
                                       }

                         $TESTDBABACKUP = Test-DbaLastBackup @SQLTestBackup
                    
                    Write-Verbose 'Collecting list of DB test information for screen output'
                        $SQLTestBackupOBJECT = [pscustomobject] @{
                                                                'SourceServer'  = $TESTDBABACKUp.SourceServer
                                                                'DB'            = $TESTDBABACKUP.Database
                                                                'BackupExist?'  = $TESTDBABACKUP.FileExists
                                                                'BackupDate'    = $TESTDBABACKUP.BackupDate
                                                                'BackupStoredIn'= $TESTDBABACKUP.BackupFiles
                                                                }
                                                $SQLTestBackupOBJECT

                                                            }#IF2
                                                    
                ELSE {
                    Write-Host 'The script has completed. Your backup is located under your specified drive.'
                }
       }#IF
    }#TRY
        CATCH {
            Write-Warning 'An error has occured. Please view the error log on your desktop called SQLScriptErrorLog.txt'
            $_ | Out-File $SavedErrorLog
            #NOTE: Throw error to host
            throw
        }
    }#Process
End{}         
} #Function
