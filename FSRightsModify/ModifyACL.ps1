
#####################################################################################################
# Removing filesystem permission for specifed domain account on specified folder and its subfloders #
# Logging action into specified folder                                                              #
# 2DO:  Exception handling                                                                          #
#       When update = 0 permissions in review are not accurate due to inheritance                   #
######################################## RoSiCzech 19.11.2019 #######################################

$filePath = "YourRootFolder"     #<-- Put root folder where you want to remove permissions
                            #    Permissions will be removed also to subfolders!
$user = 'AccountToBeRemoved' #<-- Put domain account you want to remove permissions 
$logFolder = "LogFolder"     #<-- Put Folder for log file  
$updateACL = 1              #<-- Put 0 if you want to see affected folder only
                            #<-- Put 1 if you want to change permission

$server = $env:ComputerName
$folders = Get-ChildItem $filePath -Recurse -Directory
$filePathToName = (($filepath.Replace(":\","-")).Replace("\","-"))
$Logfile = "$logFolder\$server-$filePathToName .log"
$me = ($env:UserDomain+"\"+$env:UserName)
Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}
$now = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
LogWrite ("########################  Script started at $now by $me ")
LogWrite ("########################  Root folder for processing: $filePath")
LogWrite ("########################  Removing ACL for user: $user ")

Function Remove-FolderPermissions ($Folder,$user)
    {      
        $i = 0
        Write-Host "Processing subfolder folder " $Folder.FullName
        LogWrite ("Processing subfolder " + $Folder.FullName)
        $acl = Get-Acl -Path $Folder.FullName
        foreach ($access in $acl.Access)    
        {           
            $access.IdentityReference.Value        
            if ($access.IdentityReference.Value -eq $user)
            {            
                $acl.RemoveAccessRule($access) | Out-Null
                Write-Host -ForegroundColor Green "new acl  `n" + $acl.AccessToString
                LogWrite ("New acl to be applied: `n" + $acl.AccessToString)
                $i++
            }        
        }    
        if ($i -eq 0)
        {
            LogWrite ("No change in folder permissions")
        }    
        else
         {
            if($updateACL -eq 1)
             {
                 Set-Acl -Path $Folder.FullName -AclObject $acl
             }
            else
             {
                Set-Acl -Path $Folder.FullName -AclObject $acl -WhatIf
                LogWrite ("!!! Review only, to remove ACL set updateACL = 1 at script begining !!! ") 
             }
             
             LogWrite ("`nRemoved $user from $Folder")
         }
         LogWrite ("------------------------------------------------------------------------------count of " + $user + " Presence was: " + $i)

    }

    Remove-FolderPermissions (Get-Item $filePath) $user # to process root folder

    foreach ($folder in $folders) 
{
    Remove-FolderPermissions $folder $user    
}
$now = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
LogWrite ("########################  Script finished at $now ")