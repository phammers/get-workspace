<#
.SYNOPSIS
	Small utility to get a project from TFS and map the appropriate workspace.

.DESCRIPTION
    Will perform the following:
    1.  Ascertain which TFS collection the project belongs to
    2.  Map the specified workspace to the appropriate project (default is study)
    3.  Fetch the latest specified branch from tfs
    4.  Copy any SwitchStartupProject json config files (if existing)
    5.  Launch visual studio

.PARAMETER study
	Required.  Provide the study code.  

.PARAMETER branch
	Optional.  The branch name to fetch.  Default DEV  

.PARAMETER workspace
    Optional.  Name of the desired workspace.  Default is the study name.

.EXAMPLE
./get-workspace.ps1 STUDY123

.EXAMPLE
./get-workspace.ps1 STUDY123 -branch main

.EXAMPLE
./get-workspace.ps1 STUDY123 -branch main -workspace STUDY123_OTHER

#>
param(
  [Parameter(Mandatory=$true)]
  [String]$study,
  [String]$branch = "DEV",
  [String]$workspace = $study
)
function GetCollectionName {

    Param ([string]$studyName, [string] $tfsUrl)

    for (($i=2015); $i -lt (Get-Date).Year + 1; $i++){
       try{
           $url = Invoke-WebRequest "$tfsUrl/PROD$i/$study" -Method 'GET' -UseDefaultCredentials
           if ($url.StatusCode -eq 200){
             return "PROD$i"
           }
       }
       catch {}
    }

    return ""

}
$study = $study.ToUpper().Trim()
$workspace = $workspace.ToUpper().Trim()
$settings = Get-Content "$PSScriptRoot\settings.json" | ConvertFrom-Json
$path = "$($settings.localProjectLocation)\$workspace"
$tfsUrl = $settings.tfsUrl.Trim()
$branch = $branch.ToUpper().Trim()
$branchPath = "$path\$branch\Study"

Write-Host "Getting collection name for $study ......"
    $collectionName = GetCollectionName $study $tfsUrl
    if($collectionName -eq "")
    {
        Write-Host "Study $study does not exist in our tfs collections"
        return 1
    }

$vsPath = $settings.vsPath.Trim()
Push-Location $vsPath
Set-Alias tf $settings.tfPath.Trim()

Write-Host "Setting up the workspace in VisualStudio......"
    tf workspace /new /noprompt "$workspace;$env:USERNAME" /server:"$tfsUrl/$collectionName" 
    if($?)
    {
        tf workfold /unmap "/workspace:$workspace" $vsPath  
        tf workfold  /map  "$/$study"  "$path"  /collection:"$tfsUrl/$collectionName" /workspace:$workspace
    }

Write-Host "Getting the $branch branch...be patient!!!!!!!!!"
    If(!(test-path "$branchPath"))
    {
          New-Item -ItemType Directory -Path "$branchPath"
    }

    tf get "$branchPath" /recursive

if ([System.IO.File]::Exists($settings.switchStartupSettingsPath.Trim()) -And ![System.IO.File]::Exists("$branchPath\IXRS.sln.startup.json"))
{
    Copy-Item "D:\Settings\IXRS.sln.startup.json" -Destination "$branchPath" 
}
Pop-Location
Invoke-Expression "$branchPath\IXRS.sln"



