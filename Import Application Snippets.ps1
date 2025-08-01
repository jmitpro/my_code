$CSVOutPath = 'c:\temp\AppSrc.csv'
#Change to your site's ConfigMgr PSDrive before running this script

#Get each Application, then get the source path from each Applications's Deployment Types
Write-Host "Fetching application details - this takes a few minutes, please wait...`n"

$Applications = Get-CMApplication
$AppCount = $Applications.Count
Write-Host "$AppCount applications found.`n"

#Iterate over the apps list pulling out the details for each app. Takes a couple of minutes.
$i = 1
$AppSourceList = ForEach($App in $Applications)
{
    Write-Progress -Activity 'Checking apps and deployment types' -Id 1 -PercentComplete $(($i / $AppCount) * 100) -CurrentOperation "app $i / $AppCount"
    $PackageXml = [xml]$App.SDMPackageXML
    #An app can have multiple Deployment Types, each with their own source location. DT details are stored in the XML properties
    ForEach($DT in $PackageXml.AppMgmtDigest.DeploymentType) {
        $DtTitle = $DT.Title.'#text'    #need to quote property names with hashes in them, normal backtick escaping doesn't work
        $DtTech = $DT.Technology
        $DtLocation = $DT.Installer.Contents.Content.Location
        New-Object -TypeName psobject -Property (@{AppDisplayName = $App.LocalizedDisplayName; PackageID = $App.PackageID;
        CiId = $app.CI_ID; Enabled = $app.IsEnabled; Superseded = $app.IsSuperseded; HasContent = $app.HasContent;
        DepTitle = $DtTitle; DepTypeTech = $DtTech; DepTypeSrcLocation = $DtLocation})
    }
    $i++
}

#$AppSourceList | Out-GridView
$AppSourceList | Export-Csv -Path $CSVOutPath -NoTypeInformation




#$sourcelocation = "cagevsu01.saifg.rbc.com\ZJP0$"
#$destlocation = "maple.fg.rbc.com\data\Toronto\APP\ZJP0\PR0"


$sourcelocation = "MDT01.corp.viamonstra.com"
$destlocation = "CM01.corp.viamonstra.com"

$drives = Get-WmiObject -Class Win32_LogicalDisk
$srcdrvfound = 'NO'
$destdrvfound = 'NO'

ForEach ($drive in $drives) {
    $drvprovider = $drive.ProviderName
    $drvtype = $drive.DriveType
    $driveletter = $drive.DeviceID
    
    If ($drvtype -eq 4) { #these are mapped network drives
        If ($drvprovider -match  $sourcelocation ) {
            Write-Host "Source drive is mapped"
            $sourcedrvletter = $driveletter
            Write-Host "Source drive is: $sourcedrvletter"
            $srcdrvfound = 'YES'
    }    
    
        If ($drvprovider -match  $destlocation ) {
            Write-Host "Destination drive is mapped"
            $destdrvletter = $driveletter
            Write-Host "Destination drive is: $destdrvletter"
            $destdrvfound = 'YES'
        }       
    }

}
If ($srcdrvfound -eq 'YES' -AND $destdrvfound -eq'YES') {#both drives are mapped to thr right servers
    Write-Host 'Mapped drives found'
}
else {
    Write-Host 'Both drives NOT found' 
}
