# Basics Of IIS App Pool #
# CRUD Operation #
Import-Module WebAdministration

Get-Command -Name *apppool*

# List IIS App Pools 
Get-ChildItem -Path IIS:\AppPools

(Get-Item -Path 'IIS:\AppPools\DefaultAppPool').userName

# Create App Pool
New-WebAppPool -Name "Learning1" -Verbose -Force

# Read All Properties
(Get-Item -Path 'IIS:\AppPools\Learning1').CPU.attributes | Select-Object name,value
(Get-Item -Path 'IIS:\AppPools\Learning1').Recycling.attributes | Select-Object name,value

# Updated Properties
Set-ItemProperty 'IIS:\AppPools\Learning1' -name "CPU" -value @{limit = 70000; action= "ThrottleUnderLoad";}

# Delete IIS App Pool
#Remove-WebAppPool "Learning1"