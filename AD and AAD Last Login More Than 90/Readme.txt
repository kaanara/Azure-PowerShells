###########################################################

I create this scripit because we need to list users last login more than 90 days. 

This script lists active users in Active Directory and Azure Active Directories and filters given conditions like logon date more than 90.
and pop-up shows the results.

Beofre to run these modules must be run on Powershell 7.x

Active directory domain services and lightweight directory tools must be installed 
https://docs.microsoft.com/en-us/troubleshoot/windows-server/system-management-components/remote-server-administration-tools

Install-Module Microsoft.Graph 
Install-Module -Name Join-Object 
Install-Module -Name ImportExcel

