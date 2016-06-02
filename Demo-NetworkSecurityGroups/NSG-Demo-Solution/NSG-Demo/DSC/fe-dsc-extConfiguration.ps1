Configuration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
	  File InstallDir {
		  DestinationPath = "C:\Install"
		  Ensure = "Present"
		  Type ="Directory"
	  }

	  Script DownloadPsTools {
		  TestScript = {
			  Test-Path -Path "C:\Install\PSTools.zip"
		  }

		  SetScript = {
			  $downloadUri = "https://download.sysinternals.com/files/PSTools.zip"
			  $outFile = "C:\Install\PSTools.zip"
			  Invoke-WebRequest -Uri $downloadUri -OutFile $outFile
			  Unblock-File -Path $outFile
		  }

		  GetScript = {
			  @{Result = "DownloadPsTools"}
		  }

		  DependsOn = "[File]InstallDir"
	  }
  }
}