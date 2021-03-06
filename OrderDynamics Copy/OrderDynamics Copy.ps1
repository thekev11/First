#Setting Paramaters and Variables
Param(
    [string]$source,
    [string]$destination
    )
[string]$exclude

$exclude= "*.cs"
$include= "*.dll"
$bin= Get-ChildItem "$source\c#\Wingtiptoys\bin" -Recurse 
$filesdll = Get-ChildItem "$source\C#\Packages" -Recurse -Include $include
$share  = Get-ChildItem $destination -Recurse 
$filesall = Get-ChildItem $source -Recurse -Exclude $exclude

#Modifying Web.config
$webConfigFilePath = "$source\C#\WingtipToys\Web.config" 
$currentDate = (get-date).tostring("mm_dd_yyyy-hh_mm_s")
$backup = $webConfigFilePath + "_$currentDate"
$xml = [xml](get-content $webConfigFilePath);

$xml.Save($backup)
$change = $xml.get_DocumentElement();  
$change."system.web".compilation.debug = "false";
$xml.Save($webConfigFilePath)

#copying files to bin while checking modified time
foreach($D in $filesdll){
    $counter=0
    foreach($B in $bin){
        if ($D.name -eq $B.name){
                if ($D.LastWriteTime.date -le $B.lastwritetime.date){
                $counter=1
            }
        }   
    }
    if($counter -eq 0){
        Copy-Item -path $D.fullname -destination "$source\C#\WingtipToys\bin" -recurse   
  
}
}

#copying files to share while checking modified time
foreach($A in $filesall){
    $counter=0
    foreach($S in $share){
       if($A.name -eq $S.name){

            if ($A.LastWriteTime.date -le $S.lastwritetime.date){
                $counter=1
            }
        }
        
    }
    $NewPath = Join-Path $destination $A.FullName.Replace($Source,"")
    if($counter -eq 0){
        Copy-Item -path $A.fullname -destination $destination -Recurse
    }
}

