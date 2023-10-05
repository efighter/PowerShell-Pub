<#
.SYNOPSIS
    TODO
.DESCRIPTION
    TODO
.EXAMPLE
    TODO
.INPUTS
    TODO
.OUTPUTS
    TODO
.NOTES
    TODO
#>

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue

########################################################
#                      VARIABLES
########################################################
$startDate                              = (Get-Date)
$global:dateFormatForFile               = "%Y-%m-%d_%H-%M-%S"
$startDateForFileNames                  = Get-Date -UFormat $dateFormatForFile

$cntContentDBs                          = 0
$totSCGigsDiscovered                    = 0
$totCDBGigsDiscovered                   = 0
$global:cntContentDBs                   = 0
$cntTotalSites                          = 0
$cntTotalWebs                           = 0

########################################################
#           INPUT AND OUTPUT FILES
########################################################
# [string]$global:credPath                = "$PSScriptRoot\CPYSPPrereqs_pswrd.txt"
[string]$global:configFilePath              = "$PSScriptRoot\PM_Lists_Config.xml"
[string]$global:logFilePath                 = "$PSScriptRoot\_OutFiles\PM_Lists_LOG_$($startDateForFileNames).log"
[string]$global:ReportFile                  = "$PSScriptRoot\_OutFiles\PM_Lists_RPT_$($startDateForFileNames).csv"

########################################################
#                      FUNCTIONS
########################################################
function Import-Configuration 
{
    param ()
    [xml]$configXML = Get-Content $global:configFilePath
}

function LogMessage
{ 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Message,
        [Parameter(Mandatory=$false)]
        [string]$ForegroundColor = "White"
    )
    Begin{}
    Process {
        $FinalMessage = "$(Get-Date -UFormat $dateFormatFor) $($Message)"
        Write-Host $FinalMessage -ForegroundColor $ForegroundColor
        $FinalMessage | Out-File -Filepath $logfilePath -append
    }
    End {}
}



########################################################
#                        LOGIC
########################################################

LogMessage -Message "==========================================" -ForegroundColor Green
LogMessage -Message "             Begin Execution              " -ForegroundColor Green
LogMessage -Message "==========================================" -ForegroundColor Green
LogMessage -Message "Start time $($startDate)" -ForegroundColor Yellow
LogMessage -Message "==========================================" -ForegroundColor Green

LogMessage -Message "  - Generating Trigger file" -ForegroundColor Cyan
#Import-Configuration


$AllContentDBs = Get-SPContentDatabase
$totalContentDBs = $AllContentDBs.Count

foreach ($contentDB in $AllContentDBs)
{
    # if ($contentDB.name -like "*OneDrive*"){continue}else{}
    # if($trigger.Status.ToUpper -eq "ACTIVE"){}else{continue}

    $global:cntContentDBs++
    $sitesInContentDB = $contentDB.sites

    LogMessage -Message "    - Starting to work on Content Database: [$($global:cntContentDBs)/$($totalContentDBs)] $($contentDB.name)" -ForegroundColor Cyan
    LogMessage -Message "      - Site Count: $($sitesInContentDB.count)" -ForegroundColor red
    
    
    foreach ($site in $sitesInContentDB)
    {
        $cntTotalSites++
        $webs = $site.allwebs
        LogMessage -Message "        - Web Count: $($webs.count)" -ForegroundColor red

        foreach($web in $webs)
        {
            $cntTotalWebs++
            $lists = $web.lists

            foreach($list in $lists)
            {

                $items = $list.items

                [pscustomobject]@{ 
                    Title                   = $list.title;
                    Site                    = $site.url;
                    ID                      = $list.ID;
                    ItemCount               = $items.count;
                    DefaultViewURL          = $list.DefaultViewUrl;
                    LastModifiedDate        = $list.LastItemModifiedDate;
                    BaseType                = $list.BaseType;
                    EnableVersioning        = $list.EnableVersioning;
                    MajorVersionLimit       = $list.MajorVersionLimit;
                    CreatedDate             = $list.created;
                    BaseTemplate            = $list.BaseTemplate
                } | Export-Csv -Path  $global:Reportfile -Append -NoTypeInformation
            }


        }

    }
    
}

########################################################
#                        END
########################################################

$eTime = New-TimeSpan $startDate $(Get-Date)
LogMessage -Message "==========================================" -ForegroundColor Green
LogMessage -Message "            Completed Execution            " -ForegroundColor Green
LogMessage -Message "==========================================" -ForegroundColor Green
LogMessage -Message "Elapsed Time $($eTime.Hours) : $($eTime.Minutes) : $($eTime.Seconds)" -ForegroundColor Yellow
LogMessage -Message "  - Total Content Databases Discovered: $($global:cntContentDBs)" -ForegroundColor Yellow
LogMessage -Message "  - Total Site Collections Discovered : $($cntTotalSites)" -ForegroundColor Yellow
LogMessage -Message "  - Total Sub Sites  Discovered       : $($cntTotalWebs)" -ForegroundColor Yellow

LogMessage -Message "==========================================" -ForegroundColor Green