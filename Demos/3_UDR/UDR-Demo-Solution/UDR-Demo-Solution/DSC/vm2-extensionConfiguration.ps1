Configuration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration, xNetworking

Node $nodeName
  {
	  xFirewall fwIPv4Echo {
		  Name = "FPS-ICMP4-ERQ-In"
		  Enabled = $true
		  Ensure = "Present"
	  }
  }
}