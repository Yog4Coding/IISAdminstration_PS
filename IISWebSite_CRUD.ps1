# Basics Of IIS WebSite #
# CRUD Operation #


Function Create-Directory {
 param ([string]$DirPath  )

 if(!(Test-Path $DirPath))
    {
        New-Item -ItemType Directory -Path $DirPath
    }

}

Import-Module WebAdministration

#Get-Command -Name *web*

# Setting all Prerequsities 
$DemoSite = "C:\DemoSite"
$DemoApp = "$DemoSite\DemoApp"
$DemoVD1 = "$DemoSite\DemoVirtualDir1"
$DemoVD2 = "$DemoSite\DemoVirtualDir2"
$PORT = "4200"

Create-Directory $DemoSite
Create-Directory $DemoApp
Create-Directory $DemoVD1
Create-Directory $DemoVD2


# Create new App Pool
if((Test-Path 'IIS:\AppPools\DemoAppPool'))
{
    Remove-Item IIS:\AppPools\DemoAppPool -Force
}
New-Item IIS:\AppPools\DemoAppPool

# Create New Sites, Web Applications and Virtual Directories and Assign to Application Pool
New-Item IIS:\Sites\DemoSite -physicalPath $DemoSite -ApplicationPool "DemoAppPool" -Id $PORT -bindings @{protocol="https";bindingInformation=":${PORT}:"}
Set-ItemProperty IIS:\Sites\DemoSite -name applicationPool -value DemoAppPool

New-Item IIS:\Sites\DemoSite\DemoApp -physicalPath $DemoApp -type Application
Set-ItemProperty IIS:\sites\DemoSite\DemoApp -name applicationPool -value DemoAppPool
New-Item IIS:\Sites\DemoSite\DemoVirtualDir1 -physicalPath $DemoVD1 -type VirtualDirectory
New-Item IIS:\Sites\DemoSite\DemoApp\DemoVirtualDir2 -physicalPath $DemoVD2 -type VirtualDirectory


#Delete All above
#Remove-Website "DemoSite"
