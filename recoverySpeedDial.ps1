<#
.SYNOPSIS
  Recover bookmarks saved in speeddial firefox addon.
.DESCRIPTION
  Search for firefox profiles and recover the bookmarks saved with speeddial 
  firefox addon, that was disabled with the quantum version of browser.
  If you do not enter the filename, the script search in the default path for Firefox profiles (in all profiles)
.EXAMPLE
.\recoverySpeedDial.ps1 -fileIn c:\users\username\appdata\roaming\Mozilla\Firefox\Profiles\xxxxxxxx.default\pref.js
.EXAMPLE
.\recoverySpeedDial.ps1 
.NOTES
  Version:        1.1
  Author:         LordRaven
  Creation Date:  2017/12/26
  Purpose/Change: version inicial
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
    [Parameter(mandatory=$false)][string]$fileIn
)


#----------------------------------------------------------[Functions]-------------------------------------------------------------

#region Functions

Function Process-File($fileIn1)
{

    $content = Get-Content $fileIn1

    $pattern = "(\d{1,3})(-)(url|label)(.{4})(.+)(.{3})"

    $aLabel = @()
    $aUrl = @()
    $aList = @()

    foreach ($line in $content)
    {
        if($line -match $pattern){

                switch ($Matches[3])
                {
                    "label" {
                        $rLabel = new-object PSObject -Property @{
                            cId = [int]$Matches[1];
                            cLabel= $Matches[5];
                            cUrl = $null;
                        }
                        $aLabel += $rLabel
                    }
                    "url" {
                        $rUrl = new-object PSObject -Property @{
                            cId1 = [int]$Matches[1];
                            cUrl= $Matches[5];
                        }
                        $aUrl += $rUrl
                    }
                }
           
        }
    }
    
    $aList = $aLabel.Clone()

    $aList|
       %{
          $id=$_.cId
          $tmp1 = $_
          $tmp2=$aUrl|?{$_.cId1 -eq $id}
          $tmp1.cUrl=$tmp2.cUrl
        }

    if ($aList.Count -gt 0) {    
        $fileOut = $PSScriptRoot + "\urls_saved_"+((get-date).ToString("_yyyymmdd_HHmmss")+".txt")
        $aList | sort -Property cId | Out-File $fileOut
        Start-Sleep 1
    }

    
    Write-Host "urls recovered: " + $aList.Count -ForegroundColor DarkCyan
}   

#endregion

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#region Execution

if ($fileIn){
    Process-File($fileIn)
} else {
    
    $pathMozilla = $Env:APPDATA + "\Mozilla\Firefox\Profiles"
    $profiles = Get-ChildItem  -Path $pathMozilla -Directory

    foreach ($prof in $profiles){
        $filetmp = Join-Path -Path $prof -ChildPath "\prefs.js"
        $fileIn = Join-Path -Path $pathMozilla -ChildPath $filetmp
        Write-Host "File analized: " + $fileIn -ForegroundColor Cyan
        Process-File($fileIn)
    }
}

#endregion