# Remove-CiscoWebexLowerThanVersion.ps1
<b>Powershell Script:</b> <br>
--- Remove Cisco Webex Productivity Tools and Cisco Webex Meetings App Versions LOWER than the definded one.<br>

<b>Attention:</b><br>
<b>Read the script before</b> you use it, or run it in TEST MODE!<br>
This script removes ALL Cisco Webex Productivity Tools and ALL Cisco Webex Meetings Apps LOWER than the definded Version!<br>
<b>Run as administrator!</b> <br>

I did not include a check if the script was started with admin priviledges to avoid issues when deployed with GPO or SCCM.<br>

<b>Information:</b><br>
<b>Cisco Webex Teams is excluded by filter to keep it installed</b><br>
Script can be used with tools like SCCM to ensure, that no old versions (with possible CVEs) are installed on company computers.<br>
Furthermore, you can use the script as a simple "Cleanup Script" for your clients, add further products or add an installer routine for the versions you want to be installed.<br>

<b>Features:</b><br>
--- Remove Cisco Webex<br>
--- Test Mode (Enabled by default)<br>
--- Log File<br>
--- Console Output<br>
--- Can be deployed with GPO or SCCM (Tested)<br>

The script is provided “as is”, “with all faults”, and without warranty of any kind.
