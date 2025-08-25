function CopyFilesToFolder ($fromFolder, $toFolder) {
    $childItems = Get-ChildItem $fromFolder
    $childItems | ForEach-Object {
         Copy-Item -Path $_.FullName -Destination $toFolder -Recurse -Force
    }
}

CopyFilesToFolder "D:\temp\Mystuff" "L:\Mystuff"





$childitems = Get-ChildItem "D:\temp\Mystuff"



$childitems.FullName




function CopyFilesToFolder ($fromFolder, $toFolder) {
    $childItems = Get-ChildItem $fromFolder
    ForEach ($childitem in $childItems ){
        Copy-Item -Path $Childitem.FullName -Destination $toFolder -Recurse -Force

    }


CopyFilesToFolder "D:\temp\Mystuff" "L:\Mystuff"}
$childitems.FullName


Copy-Item -Path "D:\Temp\ApplicationSource\AA\AACDD\V3.1234\Desktop" -Destination "L:\ApplicationSource" -Container -Recurse -Force

$path = "L:\ApplicationSource\AA\AACDD\V3.1234\Desktop"
$pathparts = $path.Split('\')

$pathparts


#Use this command to create the bottom folder, all folders get created if the folders don't exist
New-Item -Path "L:\ApplicationSource\AA\AACDD\V3.1234\Desktop" -ItemType Directory


